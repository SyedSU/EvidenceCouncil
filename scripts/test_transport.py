#!/usr/bin/env python3
"""Synthetic loopback transport fixture; does not run or impersonate an AI model."""
import http.server
import json
import pathlib
import subprocess
import sys
import threading
import time

class Handler(http.server.BaseHTTPRequestHandler):
    def log_message(self, *_):
        pass

    def do_POST(self):
        data = json.loads(self.rfile.read(int(self.headers['Content-Length'])))
        assert self.path == '/v1/chat/completions'
        assert data['stream'] is False and data['max_tokens'] == 768
        mode = data['model']
        if mode == 'slow':
            time.sleep(1)
        content = '' if mode == 'empty' else 'SYNTHETIC TRANSPORT FIXTURE'
        body = json.dumps({'choices': [{'message': {'content': content}}]}).encode()
        if mode == 'malformed':
            body = b'{broken'
        if mode == 'oversized':
            body = b'x' * 140000
        self.send_response(503 if mode == 'http_error' else 302 if mode == 'redirect' else 200)
        if mode == 'redirect':
            self.send_header('Location', 'http://127.0.0.1:18947/forbidden')
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        try:
            self.wfile.write(body)
        except (BrokenPipeError, ConnectionResetError):
            pass

if __name__ == '__main__':
    root = pathlib.Path(__file__).resolve().parents[1]
    server = http.server.ThreadingHTTPServer(('127.0.0.1', 18946), Handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    try:
        result = subprocess.run([sys.argv[1], '--headless', '--path', str(root / 'native'), '--script', 'tests/transport_test.gd'], timeout=30)
    finally:
        server.shutdown()
        server.server_close()
    sys.exit(result.returncode)
