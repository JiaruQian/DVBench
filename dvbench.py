#!/usr/bin/env python3
import argparse
import base64
import csv
import io
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tarfile
import urllib.error
import urllib.request
import uuid


ROOT = Path(__file__).resolve().parent
OPERATIONS = {'doctor', 'rollout', 'verify', 'status', 'resume', 'cancel', 'feedback', 'artifact'}


def load(path):
    return json.loads(Path(path).read_text())


def save(path, value):
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(path.name + '.tmp')
    temporary.write_text(json.dumps(value, indent=2, ensure_ascii=False) + '\n')
    temporary.replace(path)


def reference(config, key, required=True):
    name = config.get(key)
    value = os.environ.get(name, '') if name else ''
    if required and not value:
        raise ValueError('Set the environment variable named by ' + key)
    return value


def identifier(value):
    if not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9_.-]{0,95}', value):
        raise ValueError('Invalid identifier: ' + value)
    return value


def selected(arguments):
    catalog = load(ROOT / 'catalog.json')
    known = {row['task_id']: row for row in catalog}
    if arguments.all:
        requested = list(known)
    elif arguments.task_file:
        requested = [line.strip() for line in arguments.task_file.read_text().splitlines() if line.strip() and not line.lstrip().startswith('#')]
    else:
        requested = arguments.task or []
    if not requested or set(requested) - set(known):
        raise ValueError('Select known task IDs using --task, --task-file or --all')
    return [row for row in catalog if row['task_id'] in set(requested)]


def snapshot(directory):
    directory = Path(directory).resolve()
    if not directory.is_dir():
        raise ValueError('Submission directory does not exist')
    files = {}
    total = 0
    for path in sorted(directory.rglob('*')):
        if path.is_symlink():
            raise ValueError('Submission may not contain links')
        if path.is_dir():
            continue
        if not path.is_file() or path.stat().st_nlink > 1:
            raise ValueError('Submission must contain ordinary independent files')
        content = path.read_bytes()
        total += len(content)
        if len(files) >= 4096 or total > 64 * 1024 * 1024:
            raise ValueError('Submission exceeds file or byte limit')
        files[path.relative_to(directory).as_posix()] = base64.b64encode(content).decode('ascii')
    return files


def check_submission(directory):
    files = snapshot(directory)
    required = ['flow/features.md', 'flow/features.json', 'flow/testplan.md', 'flow/testplan.json', 'model/model.sv', 'sources.f']
    missing = [name for name in required if name not in files]
    if missing:
        raise ValueError('Missing files: ' + ', '.join(missing))
    for name, key in [('flow/features.json', 'features'), ('flow/testplan.json', 'tests')]:
        value = json.loads(base64.b64decode(files[name]))
        if not isinstance(value, dict) or not isinstance(value.get(key), list) or not value[key]:
            raise ValueError(name + ' requires a nonempty ' + key + ' array')
    sources = base64.b64decode(files['sources.f']).decode().splitlines()
    sources = [name.strip() for name in sources if name.strip()]
    for name in sources:
        path = Path(name)
        if path.is_absolute() or '..' in path.parts or name.startswith(('-', '+')) or any(character in name for character in '*?') or path.suffix not in ('.sv', '.v') or name not in files:
            raise ValueError('Invalid or missing source in sources.f: ' + name)
    if 'model/model.sv' not in sources:
        raise ValueError('sources.f must include model/model.sv')
    return {'files': len(files), 'sources': len(sources)}


def flatten(value, prefix=''):
    result = {}
    for key, item in value.items():
        name = prefix + key
        if isinstance(item, dict):
            result.update(flatten(item, name + '.'))
        elif isinstance(item, list):
            result[name] = json.dumps(item, ensure_ascii=False)
        else:
            result[name] = item
    return result


def rpc(config, operation, payload):
    if operation not in OPERATIONS:
        raise ValueError('Unsupported operation')
    request = {'protocol': 'dvbench-rpc-1', 'request_id': uuid.uuid4().hex, 'operation': operation, 'payload': payload}
    backend = config.get('backend', {})
    timeout = config.get('transport_timeout_seconds', 120)
    data = json.dumps(request, ensure_ascii=False).encode()
    if backend.get('type') == 'hosted':
        url = reference(backend, 'url_env')
        token = reference(backend, 'token_env')
        if not url.startswith(('https://', 'http://127.0.0.1:', 'http://localhost:')):
            raise ValueError('Use HTTPS for a remote service')
        query = urllib.request.Request(url.rstrip('/') + '/rpc', data=data, headers={'Content-Type': 'application/json', 'Authorization': 'Bearer ' + token})
        with urllib.request.urlopen(query, timeout=timeout) as response:
            result = json.loads(response.read(16 * 1024 * 1024 + 1))
    elif backend.get('type') == 'ssh':
        alias = reference(backend, 'alias_env')
        if not re.fullmatch(r'[A-Za-z0-9][A-Za-z0-9_.-]*', alias):
            raise ValueError('SSH alias must be a configured host alias')
        command = ['ssh', '-T', '-o', 'BatchMode=yes', '-o', 'ConnectTimeout=12', '-o', 'IPQoS=none', alias, 'dvbench-worker']
        response = subprocess.run(command, input=data, capture_output=True, timeout=timeout)
        if response.returncode:
            raise RuntimeError('SSH worker failed; inspect the maintainer-side log')
        result = json.loads(response.stdout)
    else:
        raise ValueError('Configure backend.type as hosted or ssh')
    if not isinstance(result, dict) or result.get('request_id') != request['request_id']:
        raise ValueError('Unbound or malformed backend response')
    if result.get('error'):
        raise RuntimeError(str(result['error']))
    return result.get('result', {})


def selection_options(parser):
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--task', action='append')
    group.add_argument('--task-file', type=Path)
    group.add_argument('--all', action='store_true')


def positive(value):
    number = int(value)
    if number < 1:
        raise argparse.ArgumentTypeError('Expected a positive integer')
    return number


def main(argv=None):
    parser = argparse.ArgumentParser(description='DVBench tasks and hosted/SSH execution client')
    parser.add_argument('--config', type=Path)
    commands = parser.add_subparsers(dest='command', required=True)
    tasks = commands.add_parser('tasks')
    tasks.add_argument('action', choices=['list'])
    tasks.add_argument('--level')
    tasks.add_argument('--domain')
    tasks.add_argument('--json', action='store_true')
    prepare = commands.add_parser('prepare')
    selection_options(prepare)
    prepare.add_argument('--output', required=True, type=Path)
    check = commands.add_parser('check-submission')
    check.add_argument('--submission', required=True, type=Path)
    pack = commands.add_parser('pack')
    pack.add_argument('--submission', required=True, type=Path)
    pack.add_argument('--output', required=True, type=Path)
    doctor = commands.add_parser('doctor')
    doctor.add_argument('--local-only', action='store_true')
    doctor.add_argument('--output', type=Path)
    rollout = commands.add_parser('rollout')
    selection_options(rollout)
    rollout.add_argument('--agent', type=Path, required=True)
    rollout.add_argument('--profile', type=Path, default=ROOT / 'examples/profile.json')
    rollout.add_argument('--run', required=True, type=identifier)
    rollout.add_argument('--jobs', type=positive, default=1)
    rollout.add_argument('--purpose', choices=['smoke', 'pilot', 'benchmark'], default='benchmark')
    local = commands.add_parser('run-agent')
    local.add_argument('--task', required=True, type=identifier)
    local.add_argument('--agent', required=True, type=Path)
    local.add_argument('--output', required=True, type=Path)
    for name in ['verify', 'status', 'resume', 'cancel']:
        entry = commands.add_parser(name)
        entry.add_argument('--run', required=True, type=identifier)
        if name == 'verify':
            entry.add_argument('--jobs', type=positive, default=1)
        entry.add_argument('--output', type=Path)
    feedback = commands.add_parser('feedback')
    feedback.add_argument('--run', required=True, type=identifier)
    feedback.add_argument('--task', required=True, type=identifier)
    feedback.add_argument('--submission', required=True, type=Path)
    feedback.add_argument('--output', required=True, type=Path)
    artifact = commands.add_parser('artifact')
    artifact.add_argument('--run', required=True, type=identifier)
    artifact.add_argument('--task', required=True, type=identifier)
    artifact.add_argument('--artifact', required=True)
    artifact.add_argument('--output', required=True, type=Path)
    report = commands.add_parser('report')
    report.add_argument('--input', required=True, type=Path)
    report.add_argument('--output', required=True, type=Path)
    arguments = parser.parse_args(argv)
    config = load(arguments.config) if arguments.config else {}
    if arguments.command == 'tasks':
        rows = [row for row in load(ROOT / 'catalog.json') if (not arguments.level or row['level'] == arguments.level) and (not arguments.domain or row['domain'] == arguments.domain)]
        if arguments.json:
            print(json.dumps(rows, indent=2, ensure_ascii=False))
        else:
            for row in rows:
                print('\t'.join([row['task_id'], row['level'], row['domain'], row['name']]))
        return 0
    if arguments.command == 'prepare':
        if arguments.output.exists():
            raise ValueError('Output must be a new directory')
        rows = selected(arguments)
        arguments.output.mkdir(parents=True)
        for row in rows:
            destination = arguments.output / row['task_id']
            shutil.copytree(ROOT / row['directory'], destination / 'public')
            (destination / 'submission').mkdir()
        print('Prepared ' + str(len(rows)) + ' task workspaces')
        return 0
    if arguments.command == 'check-submission':
        print(json.dumps(check_submission(arguments.submission)))
        return 0
    if arguments.command == 'run-agent':
        from agent_runner import run_agent
        rows = [row for row in load(ROOT / 'catalog.json') if row['task_id'] == arguments.task]
        if len(rows) != 1:
            raise ValueError('Unknown task ID')
        print(json.dumps(run_agent(ROOT, rows[0], load(arguments.agent), arguments.output), indent=2))
        return 0
    if arguments.command == 'pack':
        check_submission(arguments.submission)
        files = snapshot(arguments.submission)
        arguments.output.parent.mkdir(parents=True, exist_ok=True)
        with arguments.output.open('xb') as target:
            with tarfile.open(fileobj=target, mode='w:gz') as archive:
                for name, encoded in files.items():
                    content = base64.b64decode(encoded)
                    entry = tarfile.TarInfo(name)
                    entry.size = len(content)
                    entry.mode = 0o644
                    archive.addfile(entry, io.BytesIO(content))
        print(str(arguments.output))
        return 0
    if arguments.command == 'report':
        result = load(arguments.input)
        rows = result.get('tasks', [])
        if not isinstance(rows, list):
            raise ValueError('Report input requires a tasks array')
        arguments.output.mkdir(parents=True, exist_ok=True)
        save(arguments.output / 'metrics.json', result)
        rows = [flatten(row) for row in rows]
        fields = sorted({key for row in rows for key in row})
        with (arguments.output / 'metrics.csv').open('w', newline='') as target:
            writer = csv.DictWriter(target, fieldnames=fields, extrasaction='ignore')
            writer.writeheader()
            writer.writerows(rows)
        print(str(arguments.output))
        return 0
    if arguments.command == 'doctor':
        catalog = load(ROOT / 'catalog.json')
        missing = [row['task_id'] for row in catalog if not (ROOT / row['directory'] / 'instruction.md').is_file()]
        result = {'python': sys.version.split()[0], 'tasks': len(catalog), 'missing_tasks': missing}
        if missing or len(catalog) != 95:
            raise ValueError('Incomplete task catalog')
        if not arguments.local_only:
            result['backend'] = rpc(config, 'doctor', {'model_requests': False})
    elif arguments.command == 'rollout':
        agent = load(arguments.agent)
        command = agent.get('command_argv')
        if not isinstance(command, list) or not command or not all(isinstance(value, str) for value in command):
            raise ValueError('Agent requires a command_argv string array')
        if any(key in agent for key in ['api_key', 'token', 'password', 'private_key']):
            raise ValueError('Use credential environment references')
        result = rpc(config, 'rollout', {'run': arguments.run, 'task_ids': [row['task_id'] for row in selected(arguments)], 'agent': agent, 'jobs': arguments.jobs, 'purpose': arguments.purpose, 'profile': load(arguments.profile)})
    elif arguments.command == 'feedback':
        result = rpc(config, 'feedback', {'run': arguments.run, 'task_id': arguments.task, 'files': snapshot(arguments.submission)})
    elif arguments.command == 'artifact':
        result = rpc(config, 'artifact', {'run': arguments.run, 'task_id': arguments.task, 'artifact_id': arguments.artifact})
        content = base64.b64decode(result['data_base64'], validate=True)
        arguments.output.parent.mkdir(parents=True, exist_ok=True)
        with arguments.output.open('xb') as target:
            target.write(content)
        return 0
    else:
        payload = {'run': arguments.run}
        if arguments.command == 'verify':
            payload['jobs'] = arguments.jobs
        result = rpc(config, arguments.command, payload)
    if getattr(arguments, 'output', None):
        save(arguments.output, result)
    print(json.dumps(result, indent=2, ensure_ascii=False))
    return 0


if __name__ == '__main__':
    try:
        raise SystemExit(main())
    except (ValueError, OSError, RuntimeError, subprocess.SubprocessError, urllib.error.URLError) as error:
        print(str(error), file=sys.stderr)
        raise SystemExit(2)
