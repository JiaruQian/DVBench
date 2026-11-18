import argparse
import base64
import json
import os
from pathlib import Path
import stat
import urllib.request


def request(route, value):
    url = os.environ.get('DVBENCH_FEEDBACK_URL', 'http://gateway:8080')
    token = os.environ.get('DVBENCH_FEEDBACK_TOKEN')
    if not token:
        raise ValueError('The controller must provide DVBENCH_FEEDBACK_TOKEN')
    query = urllib.request.Request(url.rstrip('/') + route, data=json.dumps(value).encode(), headers={'Content-Type': 'application/json', 'x-api-key': token})
    with urllib.request.urlopen(query, timeout=3660) as response:
        return json.loads(response.read(16 * 1024 * 1024 + 1))


def main():
    parser = argparse.ArgumentParser(description='Golden-design feedback client')
    commands = parser.add_subparsers(dest='action', required=True)
    simulate = commands.add_parser('simulate')
    simulate.add_argument('--submission', type=Path, default=Path('/submission'))
    simulate.add_argument('--output', type=Path, required=True)
    artifact = commands.add_parser('artifact')
    artifact.add_argument('--attempt', type=int, required=True)
    artifact.add_argument('--name', required=True)
    artifact.add_argument('--output', type=Path, required=True)
    arguments = parser.parse_args()
    if arguments.output.exists():
        raise ValueError('Use a new output path')
    if arguments.action == 'simulate':
        if not arguments.submission.is_dir():
            raise ValueError('Submission directory does not exist')
        files = {}
        total = 0
        for path in sorted(arguments.submission.rglob('*')):
            info = path.lstat()
            if stat.S_ISDIR(info.st_mode):
                continue
            if not stat.S_ISREG(info.st_mode) or info.st_nlink != 1:
                raise ValueError('Only ordinary independent submission files are accepted')
            data = path.read_bytes()
            total += len(data)
            if total > 16 * 1024 * 1024 or len(files) >= 256:
                raise ValueError('Snapshot budget exceeded')
            files[path.relative_to(arguments.submission).as_posix()] = base64.b64encode(data).decode()
        result = request('/simulate', {'files': files})
        arguments.output.parent.mkdir(parents=True, exist_ok=True)
        with arguments.output.open('x') as target:
            json.dump(result, target, indent=2)
        print(json.dumps(result))
    else:
        if arguments.attempt < 1:
            raise ValueError('Expected a positive attempt')
        offset = 0
        arguments.output.parent.mkdir(parents=True, exist_ok=True)
        with arguments.output.open('xb') as target:
            while True:
                page = request('/artifact', {'attempt': arguments.attempt, 'name': arguments.name, 'offset': offset})
                encoded = page.get('base64', page.get('data_base64'))
                content = base64.b64decode(encoded, validate=True)
                if page['offset'] != offset or len(content) != page['bytes'] or (not content and not page['eof']):
                    raise ValueError('Invalid artifact page')
                target.write(content)
                offset += len(content)
                if page['eof']:
                    break
        print(json.dumps({'path': str(arguments.output), 'bytes': offset}))


if __name__ == '__main__':
    main()
