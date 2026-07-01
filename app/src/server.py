import json
import os
import socket
import threading
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer


_REQUEST_COUNTS = {}
_REQUEST_LOCK = threading.Lock()


def _truthy(value):
    return str(value).lower() in {"1", "true", "yes", "on"}


def _label_value(value):
    return str(value).replace("\\", "\\\\").replace('"', '\\"').replace("\n", "\\n")


def record_request(method, path, status):
    key = (method, path, str(int(status)))
    with _REQUEST_LOCK:
        _REQUEST_COUNTS[key] = _REQUEST_COUNTS.get(key, 0) + 1


def app_metadata():
    return {
        "app": os.getenv("APP_NAME", "cloudops-demo-app"),
        "environment": os.getenv("APP_ENV", "local"),
        "version": os.getenv("APP_VERSION", "0.1.0"),
        "image_tag": os.getenv("IMAGE_TAG", "local"),
        "hostname": socket.gethostname(),
    }


def prometheus_metrics():
    metadata = app_metadata()
    health_state = 0 if _truthy(os.getenv("FAILURE_MODE", "false")) else 1
    lines = [
        "# HELP cloudops_demo_requests_total HTTP requests handled by the demo app.",
        "# TYPE cloudops_demo_requests_total counter",
    ]

    with _REQUEST_LOCK:
        request_counts = dict(_REQUEST_COUNTS)

    for (method, path, status), count in sorted(request_counts.items()):
        lines.append(
            'cloudops_demo_requests_total{method="%s",path="%s",status="%s"} %s'
            % (_label_value(method), _label_value(path), _label_value(status), count)
        )

    lines.extend(
        [
            "# HELP cloudops_demo_health_state Health state reported by the readiness path. 1 is healthy, 0 is unhealthy.",
            "# TYPE cloudops_demo_health_state gauge",
            'cloudops_demo_health_state{environment="%s"} %s'
            % (_label_value(metadata["environment"]), health_state),
            "# HELP cloudops_demo_build_info Build and environment metadata for the demo app.",
            "# TYPE cloudops_demo_build_info gauge",
            'cloudops_demo_build_info{app="%s",environment="%s",version="%s",image_tag="%s"} 1'
            % (
                _label_value(metadata["app"]),
                _label_value(metadata["environment"]),
                _label_value(metadata["version"]),
                _label_value(metadata["image_tag"]),
            ),
        ]
    )
    return "\n".join(lines) + "\n"


class Handler(BaseHTTPRequestHandler):
    server_version = "cloudops-demo-app/0.1"

    def do_GET(self):
        if self.path == "/":
            record_request(self.command, self.path, HTTPStatus.OK)
            self._json(HTTPStatus.OK, app_metadata())
            return

        if self.path == "/healthz":
            if _truthy(os.getenv("FAILURE_MODE", "false")):
                record_request(self.command, self.path, HTTPStatus.SERVICE_UNAVAILABLE)
                self._json(
                    HTTPStatus.SERVICE_UNAVAILABLE,
                    {"status": "unhealthy", "reason": "failure mode enabled"},
                )
                return
            record_request(self.command, self.path, HTTPStatus.OK)
            self._json(HTTPStatus.OK, {"status": "healthy"})
            return

        if self.path == "/version":
            record_request(self.command, self.path, HTTPStatus.OK)
            self._json(HTTPStatus.OK, app_metadata())
            return

        if self.path == "/metrics":
            record_request(self.command, self.path, HTTPStatus.OK)
            self._text(HTTPStatus.OK, prometheus_metrics())
            return

        record_request(self.command, self.path, HTTPStatus.NOT_FOUND)
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

    def _text(self, status, payload):
        body = payload.encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "text/plain; version=0.0.4; charset=utf-8")
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
