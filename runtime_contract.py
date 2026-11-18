import json
from pathlib import Path


ROOT = Path(__file__).resolve().parent


def execution_prompt(root=ROOT):
    profile = json.loads((root / 'examples/profile.json').read_text())
    return (
        'Read /public/instruction.md and all referenced public documents. '
        'Write every required deliverable under /submission; keep feedback and temporary files under /tmp. '
        f'You have at most {profile["turn_limit"]} cumulative agent decision turns, with a delivery reminder '
        f'at turn {profile["turn_reminder"]}. Compaction and recovery do not reset this budget. '
        'There is no whole-task wall-time or cumulative token limit. '
        f'Individual model requests are limited to {profile["request_timeout_seconds"]} seconds. '
        'Read /public/public/deployment_budget.json for compilation, simulation and feedback limits. '
        'Use native file tools: apply_patch for Codex/OpenCode, Write/Edit for Claude Code. '
        'apply_patch is a tool call, not a shell command. '
        'Debug using bash /public/environment/run.sh simulate --submission /submission '
        '--output /tmp/feedback-01.json; choose a new output filename each time. '
        'Read listed logs and waveforms, repair known errors and rerun while budget remains. '
        'A golden PASS does not replace completing all required deliverables. '
        'Use the same self-contained model/model.sv for independent evaluation and scoreboard prediction. '
        'Do not use subagents or read hidden implementation assets. '
        'Save a complete submission and report its actual verification status before finishing.\n'
    )


def validate_codex_catalog(path, model):
    catalog = json.loads(Path(path).read_text())
    matches = [entry for entry in catalog.get('models', []) if entry.get('slug') == model]
    if len(matches) != 1:
        raise ValueError('Codex model catalog must contain exactly one entry for the answering model')
    entry = matches[0]
    if entry.get('apply_patch_tool_type') != 'freeform':
        raise ValueError('Codex requires a native freeform apply_patch tool configuration')
    if entry.get('shell_type') not in {'unified_exec', 'shell_command'}:
        raise ValueError('Codex requires an explicit supported shell tool configuration')
    return entry


def validate_request_tools(body, framework, auxiliary=False):
    if auxiliary:
        return
    definitions = list(body.get('tools', []))
    if isinstance(body.get('input'), list):
        for entry in body['input']:
            if entry.get('type') == 'additional_tools':
                definitions.extend(entry.get('tools', []))
    flattened = []

    def visit(definition):
        if definition.get('type') == 'namespace':
            for child in definition.get('tools', []):
                visit(child)
        else:
            flattened.append(definition.get('function', definition))

    for definition in definitions:
        visit(definition)
    names = {entry.get('name') for entry in flattened}
    if framework == 'codex':
        valid_patch = any(entry.get('name') == 'apply_patch' and entry.get('type') == 'custom'
                          for entry in flattened)
        if not valid_patch or not names.intersection({'exec_command', 'shell_command', 'shell'}):
            raise ValueError('Codex request is missing native apply_patch or shell tools')
    elif framework == 'opencode':
        if not {'read', 'apply_patch', 'bash'} <= names:
            raise ValueError('OpenCode request is missing read/apply_patch/bash tools')
    elif framework == 'claudecode':
        if not {'Read', 'Write', 'Edit', 'Bash'} <= names:
            raise ValueError('Claude Code request is missing required file/shell tools')
    else:
        raise ValueError('Unknown framework')
