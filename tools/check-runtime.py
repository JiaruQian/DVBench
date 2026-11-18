import argparse
import json
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))
from runtime_contract import validate_codex_catalog, validate_request_tools


def main():
    parser = argparse.ArgumentParser(description='Offline model tool checks; makes no API calls')
    parser.add_argument('--framework', choices=['codex', 'opencode', 'claudecode'], required=True)
    parser.add_argument('--request', type=Path, required=True, help='Sanitized actual model request JSON')
    parser.add_argument('--model-catalog', type=Path)
    parser.add_argument('--model')
    arguments = parser.parse_args()
    if arguments.framework == 'codex':
        if not arguments.model_catalog or not arguments.model:
            parser.error('Codex checks require --model-catalog and --model')
        validate_codex_catalog(arguments.model_catalog, arguments.model)
    request = json.loads(arguments.request.read_text())
    if arguments.model and request.get('model') != arguments.model:
        raise ValueError('Actual request does not use the selected model')
    validate_request_tools(request, arguments.framework)
    print(json.dumps({'status': 'PASS', 'scope': 'model-request tool schema only', 'framework': arguments.framework}))


if __name__ == '__main__':
    main()
