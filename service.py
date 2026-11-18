#!/usr/bin/env python3
import argparse
import hmac
import http.server
import json
import os
from pathlib import Path
import subprocess
import sys
import threading


OPERATIONS = {'doctor', 'rollout', 'verify', 'status', 'resume', 'cancel', 'feedback', 'artifact'}
LIMIT = 96 * 1024 * 1024


def dispatch(configuration, request):
    identity = request.get('request_id') if isinstance(request, dict) else None
    if not isinstance(identity, str) or not identity or len(identity) > 128:
        raise ValueError('A bounded request_id is required')
    if request.get('protocol') != 'dvbench-rpc-1' or request.get('operation') not in OPERATIONS or not isinstance(request.get('payload'), dict):
        raise ValueError('Invalid DVBench request')
    command = configuration.get('adapter_argv')
    if not isinstance(command, list) or not command or not all(isinstance(item, str) for item in command) or not Path(command[0]).is_absolute():
        raise ValueError('Configure an absolute, trusted adapter_argv')
    completed = subprocess.run(command, input=json.dumps(request).encode(), stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, timeout=configuration.get('adapter_timeout_seconds', 110))
    if completed.returncode or len(completed.stdout) > LIMIT:
        raise RuntimeError('Execution adapter failed; consult its private log')
    result = json.loads(completed.stdout)
    if not isinstance(result, dict) or result.get('request_id') != identity:
        raise ValueError('Execution adapter returned an unbound response')
    return result


class Server(http.server.ThreadingHTTPServer):
    daemon_threads = True

    def __init__(self, address, configuration, token):
        self.configuration = configuration
        self.token = token
        self.capacity = threading.BoundedSemaphore(configuration.get('request_slots', 16))
        super().__init__(address, Handler)


class Handler(http.server.BaseHTTPRequestHandler):
    def log_message(self, *arguments):
        return

    def reply(self, code, value):
        body = json.dumps(value, ensure_ascii=False).encode()
        self.send_response(code)
        self.send_header('Content-Type', 'application/json')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_POST(self):
        self.connection.settimeout(120)
        if self.path != '/rpc':
            self.reply(404, {'error': 'Unknown route'})
            return
        authorization = self.headers.get('Authorization', '')
        if not hmac.compare_digest(authorization, 'Bearer ' + self.server.token):
            self.reply(403, {'error': 'Authentication required'})
            return
        if not self.server.capacity.acquire(blocking=False):
            self.reply(503, {'error': 'Service request capacity reached'})
            return
        request = {}
        try:
            size = int(self.headers.get('Content-Length', '0'))
            if not 0 < size <= LIMIT:
                raise ValueError('Request outside size limit')
            body = self.rfile.read(size)
            if len(body) != size:
                raise ValueError('Incomplete request')
            request = json.loads(body)
            self.reply(200, dispatch(self.server.configuration, request))
        except (ValueError, OSError, RuntimeError, subprocess.SubprocessError):
            identity = request.get('request_id') if isinstance(request, dict) else None
            self.reply(502, {'request_id': identity, 'error': 'Backend request failed; consult the maintainer'})
        finally:
            self.server.capacity.release()


def main():
    parser = argparse.ArgumentParser(description='DVBench hosted/SSH transport for a trusted execution adapter')
    parser.add_argument('--config', required=True, type=Path)
    parser.add_argument('--stdio', action='store_true')
    parser.add_argument('--port', type=int, default=8765)
    arguments = parser.parse_args()
    configuration = json.loads(arguments.config.read_text())
    if arguments.stdio:
        body = sys.stdin.buffer.read(LIMIT + 1)
        if len(body) > LIMIT:
            raise ValueError('Request outside size limit')
        result = dispatch(configuration, json.loads(body))
        print(json.dumps(result, ensure_ascii=False))
    else:
        token = os.environ.get(configuration.get('token_env', 'DVBENCH_SERVICE_TOKEN'), '')
        if len(token) < 32:
            raise ValueError('Set a service token containing at least 32 characters')
        server = Server(('127.0.0.1', arguments.port), configuration, token)
        try:
            server.serve_forever()
        finally:
            server.server_close()


if __name__ == '__main__':
    main()
