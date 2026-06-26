import json
import os
import socket
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


def _truthy(value):
    return str(value).lower() in {"1", "true", "yes", "on"}


def app_metadata():
    return {
        "app": os.getenv("APP_NAME", "cloudops-demo-app"),
        "environment": os.getenv("APP_ENV", "local"),
        "version": os.getenv("APP_VERSION", "0.1.0"),
        "image_tag": os.getenv("IMAGE_TAG", "local"),
        "hostname": socket.gethostname(),
    }


class Handler(BaseHTTPRequestHandler):
    server_version = "cloudops-demo-app/0.1"

    def do_GET(self):
        if self.path == "/":
            self._json(HTTPStatus.OK, app_metadata())
            return

        if self.path == "/healthz":
            if _truthy(os.getenv("FAILURE_MODE", "false")):
                self._json(
                    HTTPStatus.SERVICE_UNAVAILABLE,
                    {"status": "unhealthy", "reason": "failure mode enabled"},
                )
                return
            self._json(HTTPStatus.OK, {"status": "healthy"})
            return

        if self.path == "/version":
            self._json(HTTPStatus.OK, app_metadata())
            return

        self._json(HTTPStatus.NOT_FOUND, {"error": "not found"})

    def log_message(self, fmt, *args):
        print(
            json.dumps(
                {
                    "client": self.client_address[0],
                    "method": self.command,
                    "path": self.path,
                    "message": fmt % args,
                }
            ),
            flush=True,
        )

    def _json(self, status, payload):
        body = json.dumps(payload).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


def run():
    port = int(os.getenv("PORT", "8080"))
    server = ThreadingHTTPServer(("0.0.0.0", port), Handler)
    print(json.dumps({"event": "server_started", "port": port}), flush=True)
    server.serve_forever()


if __name__ == "__main__":
    run()
