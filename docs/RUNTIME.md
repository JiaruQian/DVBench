# Agent runtime configuration

The prompt, CLI tools, gateway and evaluation profile are part of an experiment's conditions. Record them along with the submission. The files in this release carry the repaired task contracts; the operator's execution adapter must implement the associated runtime behavior.

## Standard profile

| Setting | Value |
|---|---:|
| Candidates per task | 1 |
| Cumulative agent decision turns | 300 |
| Delivery reminder | 250 |
| Whole-task wall time / cumulative token limit | No configured limit |
| Model request timeout | 3600 seconds |
| Maximum output tokens per response | 128000, subject to provider support |
| Golden feedback calls | 50 |
| Debug seed | 1 |
| Compilation | 900 seconds |
| Golden and candidate-model simulation | 600 seconds per seed |
| Mutant simulation | 1800 seconds per seed |
| Feedback transport timeout | 3660 seconds |
| Final seeds | 1, 7, 42 |
| Fixed mutants | 10 per task |
| Required coverage | Each of LINE, COND, BRANCH and TOGGLE >=90% |

`examples/profile.json` is the requested run profile. Each task also provides `public/deployment_budget.json`. A prompt is not a quota enforcement mechanism. A trusted execution adapter/gateway must retain the same decision counter across context compaction and session recovery, enforce limits, deliver the reminder and terminate the owned execution tree when required. Auxiliary token-count/compaction requests must be classified separately from answering decisions; their actual usage should still be accounted for when supplied by the provider.

## Claude Code

`tools/run-claude.sh` supplies `--max-turns 300`, a complete task prompt, the native `Bash,Read,Write,Edit,Glob,Grep,Skill` tools, and a `PreToolUse` reminder hook. The hook deduplicates assistant message IDs in the transcript and persists its ledger under the run's `runtime/` directory. It emits the reminder at the first tool boundary with at least 250 observed assistant messages. Check hook support on your pinned CLI before a formal run. This direct launcher starts a new run and does not implement session recovery; a recovery-capable external adapter must retain the transcript and ledger and enforce the cumulative remainder.

The default `CLAUDE_CODE_MAX_OUTPUT_TOKENS` is **128000**. An implicit 32000-token default truncated long reasoning responses during the DeepSeek experiments. The launcher also forwards `CLAUDE_CODE_EFFORT_LEVEL` and `CLAUDE_CODE_AUTO_COMPACT_WINDOW` if supplied. Use values supported by your actual provider; record any deviation from the standard profile.

For a DeepSeek Anthropic-compatible endpoint, provide its documented base URL and model identifier through `ANTHROPIC_BASE_URL` and `DVBENCH_CLAUDE_MODEL`. Do not silently change to a different model or protocol. An incomplete/empty provider response is a recoverable transport/provider condition, not successful task completion. Retain completed tools and partial visible output when resuming the same candidate.

## Codex and Astra / DeepSeek

The tested Codex runtime used CLI **0.164.0** with a model catalog explicitly defining native tool behavior. The original Astra run used a generic model fallback that omitted native `apply_patch`. The repaired catalog enables `apply_patch_tool_type: freeform` and the appropriate shell tool.

`examples/codex-models.json` contains the Astra and DeepSeek descriptors from those repaired runs. These are version-bound compatibility inputs, not a promise of model availability at every provider. Model names, reasoning level, provider route and credentials must match the operator's account. Do not infer a model's tool support solely from its name.

For a Codex configuration using the generic container launcher, set:

```json
{
  "framework": "codex",
  "model": "gpt-6-astra",
  "model_catalog": "examples/codex-models.json"
}
```

These are additional fields in the agent JSON, not a complete runnable configuration. Retain the `image`, `command_argv`, network and credential references from your own adapter. The launcher validates the descriptor before Docker starts and mounts the catalog read-only at `/run/codex-models.json`. Your wrapper must set Codex's `model_catalog_json` to this path (also available as `DVBENCH_CODEX_MODEL_CATALOG`) and use the task prompt at `/run/prompt.txt`. The generic launcher does not install Codex or implement its 300-decision gateway counter.

Validate a sanitized **actual outgoing answering request**, not just the catalog:

```bash
python3 -B tools/check-runtime.py --framework codex \
  --model gpt-6-astra --model-catalog examples/codex-models.json \
  --request /path/to/sanitized-request.json
```

The request must contain native `apply_patch` and a shell tool. Tool-free context-compaction requests should be identified by the trusted runtime and checked separately; do not broadly exempt every request with no tools. `runtime_contract.validate_request_tools` is available for integration into a gateway. No shell executable named `apply_patch` is needed for the native tool.

## OpenCode

The repaired runtime exposes `read`, `apply_patch` and `bash`. Use `tools/check-runtime.py --framework opencode --request /path/to/sanitized-request.json` to check an actual request. Configure the model and provider explicitly. The runtime's session/decision identity must persist across retries and compaction so that retries cannot reset the 300-turn allowance. A golden PASS does not instruct the agent to stop before completing its documents, independent model and testbench.

## Preflight and troubleshooting

1. Check local task files with `dvbench.py doctor --local-only` and validate your chosen image/CLI version.
2. Confirm the configured isolated network reaches both the answering gateway and task feedback endpoint. Keep judge credentials out of candidate containers.
3. Inspect an actual request for model identity, API protocol, native tools, output ceiling and reasoning settings. Record tool schemas without credentials or private reasoning content.
4. Use a controlled compile failure, a native edit, a subsequent compilation/simulation attempt, and artifact retrieval to verify the complete path. Exercise the closing reminder with a shortened control threshold in a separate control configuration; retain the formal 250/300 values.
5. Qualify task-specific cases described in [the maintainer guide](../maintainer/README.md), then launch the full task set.

| Symptom | Check |
|---|---|
| Codex describes edits but cannot apply them | Model catalog selected by the CLI and actual native tool schema. |
| Agent stops immediately after golden PASS | Prompt and skill must still require all deliverables and known repairs. |
| DeepSeek long reasoning ends without an answer | Output ceiling, provider terminal status, timeout and same-run recovery. |
| dv-094 package is undefined | Compile `backfill/apb_ntt_pkg.sv` before consumers in feedback and final evaluation. |
| Legal generated DUT instances rejected | Elaborated indexed scopes and native parameter matrix handling. |
| Read-only model cannot be copied into a profile | Writable destination assembly before restoring frozen metadata. |
| Coverage report is absent or points to another DUT | Bound scope, actual run ID, gate mapping and tool-report status; never substitute 100%. |
| `verify` cannot find a direct-launch run | Register/import its frozen snapshot into the execution adapter first. |

Useful upstream references: [Codex configuration](https://developers.openai.com/codex/config-reference/), [Claude Code CLI](https://code.claude.com/docs/en/cli-reference), [Claude Code hooks](https://code.claude.com/docs/en/hooks), and [DeepSeek API documentation](https://api-docs.deepseek.com/). Pin and qualify versions rather than assuming that a later CLI preserves the same schemas.
