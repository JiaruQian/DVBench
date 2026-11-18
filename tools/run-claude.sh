#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 2 ]]; then
  echo 'Usage: bash tools/run-claude.sh dv-NNN run-name' >&2
  exit 2
fi
task_id=$1
run_name=$2
[[ "$task_id" =~ ^dv-[0-9]{3}$ ]] || exit 2
[[ "$run_name" =~ ^[A-Za-z0-9][A-Za-z0-9_.-]{0,95}$ ]] || exit 2
: "${ANTHROPIC_API_KEY:?Set the Claude Code model key}"
: "${DVBENCH_CLAUDE_MODEL:?Set the answering model}"
: "${DVBENCH_CLAUDE_IMAGE:?Set the Claude Code image}"
: "${DVBENCH_DOCKER_NETWORK:?Set the isolated container network}"
: "${DVBENCH_SKILLS_DIR:?Set the skills directory}"
: "${DVBENCH_SKILL:?Set the skill directory name}"
: "${DVBENCH_FEEDBACK_URL:?Set the task feedback URL}"
: "${DVBENCH_FEEDBACK_TOKEN:?Set the run-scoped feedback token}"
[[ "$DVBENCH_SKILL" =~ ^[A-Za-z0-9][A-Za-z0-9_-]{0,63}$ ]] || exit 2
[[ "$DVBENCH_DOCKER_NETWORK" != host ]] || exit 2
[[ "$DVBENCH_CLAUDE_IMAGE" != -* ]] || exit 2
benchmark_root=${DVBENCH_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}
benchmark_root=$(cd "$benchmark_root" && pwd)
skills_root=$(cd "$DVBENCH_SKILLS_DIR" && pwd)
test -f "$skills_root/$DVBENCH_SKILL/SKILL.md"
run_root=${DVBENCH_RUN_ROOT:-"$HOME/dvbench-runs"}
mkdir -p "$run_root"
run_root=$(cd "$run_root" && pwd)
run_directory="$run_root/$run_name"
test ! -e "$run_directory"
public_directory=$(python3 -B - "$benchmark_root" "$task_id" <<'PY'
import json
from pathlib import Path
import sys
root = Path(sys.argv[1])
matches = [task for task in json.loads((root / 'catalog.json').read_text()) if task['task_id'] == sys.argv[2]]
if len(matches) != 1:
    raise SystemExit('Unknown task ID')
directory = (root / matches[0]['directory']).resolve()
directory.relative_to(root / 'questions')
print(directory)
PY
)
mkdir "$run_directory"
mkdir "$run_directory/submission"
python3 -B - "$benchmark_root" "$run_directory" "$DVBENCH_SKILL" <<'PY'
import json
from pathlib import Path
import sys
sys.path.insert(0, sys.argv[1])
from runtime_contract import execution_prompt
directory = Path(sys.argv[2])
(directory / 'prompt.txt').write_text('Use /' + sys.argv[3] + ' to complete this task. ' + execution_prompt(Path(sys.argv[1])))
(directory / 'runtime').mkdir()
settings = {'hooks': {'PreToolUse': [{'hooks': [{'type': 'command', 'command': 'python3 /run/claude-budget-hook.py /run/dvbench-state/turns.json', 'timeout': 10}]}]}}
(directory / 'settings.json').write_text(json.dumps(settings) + '\n')
PY
container_name="dvbench-${UID}-${run_name}-$$"
cleanup() {
  if ! docker rm --force "$container_name" >/dev/null 2>&1; then
    local active_containers
    active_containers=$(docker ps -a --format '{{.Names}}') || return 1
    if printf '%s\n' "$active_containers" | grep -Fxq "$container_name"; then
      echo "Container cleanup failed: $container_name" >&2
      return 1
    fi
  fi
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
environment_arguments=(--env ANTHROPIC_API_KEY --env DVBENCH_FEEDBACK_URL --env DVBENCH_FEEDBACK_TOKEN --env HOME=/home/agent --env DISABLE_AUTOUPDATER=1 --env "CLAUDE_CODE_MAX_OUTPUT_TOKENS=${CLAUDE_CODE_MAX_OUTPUT_TOKENS:-128000}")
for variable in CLAUDE_CODE_EFFORT_LEVEL CLAUDE_CODE_AUTO_COMPACT_WINDOW; do
  if [[ -n "${!variable:-}" ]]; then environment_arguments+=(--env "$variable"); fi
done
if [[ -n "${ANTHROPIC_BASE_URL:-}" ]]; then
  environment_arguments+=(--env ANTHROPIC_BASE_URL)
fi
set +e
docker run --rm --name "$container_name" \
  --network "$DVBENCH_DOCKER_NETWORK" --read-only --cap-drop ALL \
  --security-opt no-new-privileges --pids-limit 256 --memory 8g --cpus 4 \
  --user "$(id -u):$(id -g)" \
  --tmpfs /tmp:rw,nosuid,nodev,size=1g,mode=1777 \
  --tmpfs "/home/agent:rw,nosuid,nodev,size=512m,mode=0700,uid=$(id -u),gid=$(id -g)" \
  --mount "type=bind,src=$public_directory,dst=/public,readonly" \
  --mount "type=bind,src=$skills_root,dst=/opt/dvbench-skills,readonly" \
  --mount "type=bind,src=$run_directory/submission,dst=/submission" \
  --mount "type=bind,src=$run_directory/prompt.txt,dst=/run/prompt.txt,readonly" \
  --mount "type=bind,src=$run_directory/settings.json,dst=/run/settings.json,readonly" \
  --mount "type=bind,src=$benchmark_root/tools/claude-budget-hook.py,dst=/run/claude-budget-hook.py,readonly" \
  --mount "type=bind,src=$run_directory/runtime,dst=/run/dvbench-state" \
  --workdir /submission "${environment_arguments[@]}" \
  --entrypoint /bin/bash "$DVBENCH_CLAUDE_IMAGE" \
  -c 'mkdir -p "$HOME/.claude"; ln -s /opt/dvbench-skills "$HOME/.claude/skills"; exec claude "$@"' dvbench-claude \
  -p "$(cat "$run_directory/prompt.txt")" --model "$DVBENCH_CLAUDE_MODEL" \
  --max-turns 300 --permission-mode bypassPermissions \
  --settings /run/settings.json \
  --tools 'Bash,Read,Write,Edit,Glob,Grep,Skill' \
  --strict-mcp-config --mcp-config '{"mcpServers":{}}' \
  --output-format stream-json --verbose > "$run_directory/agent.jsonl" 2> "$run_directory/agent.stderr"
agent_exit=$?
set -e
cleanup
trap - EXIT
python3 -B - "$benchmark_root" "$run_directory" "$task_id" "$agent_exit" <<'PY'
import json
import os
from pathlib import Path
import shutil
import sys
sys.path.insert(0, sys.argv[1])
from dvbench import snapshot
root = Path(sys.argv[2])
snapshot(root / 'submission')
frozen = root / 'frozen'
shutil.copytree(root / 'submission', frozen)
for path in [frozen, *frozen.rglob('*')]:
    path.chmod(0o555 if path.is_dir() else 0o444)
result = {'task_id': sys.argv[3], 'run': root.name, 'agent_exit_code': int(sys.argv[4]), 'skill': os.environ['DVBENCH_SKILL'], 'model': os.environ['DVBENCH_CLAUDE_MODEL'], 'image': os.environ['DVBENCH_CLAUDE_IMAGE'], 'frozen': str(frozen)}
(root / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2))
PY
exit "$agent_exit"
