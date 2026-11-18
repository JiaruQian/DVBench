import json
import os
from pathlib import Path
import re
import shutil
import signal
import subprocess
import uuid


def run_agent(root, task, configuration, output):
    from dvbench import snapshot
    from runtime_contract import execution_prompt, validate_codex_catalog
    output = output.resolve()
    if output.exists():
        raise ValueError('Use a new output directory')
    image = configuration.get('image')
    command = configuration.get('command_argv')
    if not isinstance(image, str) or not image or image.startswith('-'):
        raise ValueError('An installed Linux agent image is required')
    if not isinstance(command, list) or not command or not all(isinstance(item, str) for item in command):
        raise ValueError('command_argv must be an argument array')
    network = configuration.get('network', 'bridge')
    if not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9_.-]*', network) or network == 'host':
        raise ValueError('Use an isolated Docker network')
    catalog = None
    if configuration.get('framework') == 'codex':
        if not configuration.get('model_catalog'):
            raise ValueError('Codex requires an explicit model_catalog with native editing tools')
        catalog = (root / configuration['model_catalog']).resolve()
        validate_codex_catalog(catalog, configuration.get('model'))
    output.mkdir(parents=True)
    submission = output / 'submission'
    submission.mkdir()
    prompt = output / 'prompt.txt'
    prompt.write_text(execution_prompt(root))
    container = 'dvbench-agent-' + uuid.uuid4().hex
    arguments = ['docker', 'run', '--rm', '--name', container, '--network', network, '--read-only', '--cap-drop', 'ALL', '--security-opt', 'no-new-privileges', '--pids-limit', '256', '--memory', '8g', '--cpus', '4', '--user', str(os.getuid()) + ':' + str(os.getgid()), '--tmpfs', '/tmp:rw,nosuid,nodev,size=1g,mode=1777', '--workdir', '/submission', '--mount', 'type=bind,src=' + str(root / task['directory']) + ',dst=/public,readonly', '--mount', 'type=bind,src=' + str(submission) + ',dst=/submission', '--mount', 'type=bind,src=' + str(prompt) + ',dst=/run/prompt.txt,readonly', '--env', 'HOME=/tmp']
    mappings = {'provider': 'DVBENCH_PROVIDER', 'model': 'DVBENCH_MODEL', 'base_url_env': 'DVBENCH_MODEL_BASE_URL', 'credential_env': 'DVBENCH_MODEL_API_KEY'}
    environment = os.environ.copy()
    if catalog is not None:
        arguments += ['--mount', 'type=bind,src=' + str(catalog) + ',dst=/run/codex-models.json,readonly',
                      '--env', 'DVBENCH_CODEX_MODEL_CATALOG=/run/codex-models.json']
    environment['DVBENCH_TURN_LIMIT'] = '300'
    environment['DVBENCH_TURN_REMINDER'] = '250'
    arguments += ['--env', 'DVBENCH_TURN_LIMIT', '--env', 'DVBENCH_TURN_REMINDER']
    for key, target in mappings.items():
        if key not in configuration:
            continue
        value = configuration[key]
        if key.endswith('_env'):
            value = os.environ.get(value, '')
            if not value:
                raise ValueError('Set the environment variable referenced by ' + key)
        environment[target] = value
        arguments += ['--env', target]
    for key in ['DVBENCH_FEEDBACK_URL', 'DVBENCH_FEEDBACK_TOKEN']:
        if os.environ.get(key):
            arguments += ['--env', key]
    arguments += [image, *command]
    previous = {}

    def interrupted(number, frame):
        raise InterruptedError('Agent interrupted')

    for number in (signal.SIGTERM, signal.SIGINT):
        previous[number] = signal.signal(number, interrupted)
    completed = None
    try:
        with (output / 'agent.log').open('xb') as log:
            completed = subprocess.run(arguments, stdout=log, stderr=subprocess.STDOUT, env=environment)
    finally:
        cleanup = subprocess.run(['docker', 'rm', '--force', container], capture_output=True, timeout=30)
        inspected = subprocess.run(['docker', 'inspect', container], capture_output=True, timeout=30)
        for number, handler in previous.items():
            signal.signal(number, handler)
        if inspected.returncode == 0 or (cleanup.returncode and b'No such container' not in cleanup.stderr):
            raise RuntimeError('Cannot confirm agent container removal; inspect ' + container)
    snapshot(submission)
    frozen = output / 'frozen'
    shutil.copytree(submission, frozen)
    for path in [frozen, *frozen.rglob('*')]:
        path.chmod(0o555 if path.is_dir() else 0o444)
    result = {'task_id': task['task_id'], 'agent_exit_code': completed.returncode, 'submission': str(frozen), 'runner': 'local', 'evaluation': None}
    (output / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    return result
