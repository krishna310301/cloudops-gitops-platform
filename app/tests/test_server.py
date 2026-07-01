import os
import pathlib
import sys
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))

from src.server import _REQUEST_COUNTS, _truthy, app_metadata, prometheus_metrics, record_request


class ServerTest(unittest.TestCase):
    def test_truthy_values(self):
        self.assertTrue(_truthy("true"))
        self.assertTrue(_truthy("1"))
        self.assertFalse(_truthy("false"))
        self.assertFalse(_truthy(""))

    def test_metadata_uses_environment(self):
        old_env = dict(os.environ)
        try:
            os.environ["APP_ENV"] = "dev"
            os.environ["APP_VERSION"] = "1.2.3"
            os.environ["IMAGE_TAG"] = "abc123"
            metadata = app_metadata()
            self.assertEqual(metadata["environment"], "dev")
            self.assertEqual(metadata["version"], "1.2.3")
            self.assertEqual(metadata["image_tag"], "abc123")
        finally:
            os.environ.clear()
            os.environ.update(old_env)

    def test_prometheus_metrics_include_build_and_health_state(self):
        old_env = dict(os.environ)
        _REQUEST_COUNTS.clear()
        try:
            os.environ["APP_ENV"] = "staging"
            os.environ["APP_VERSION"] = "0.1.0-staging"
            os.environ["IMAGE_TAG"] = "0.1.0-staging"
            os.environ["FAILURE_MODE"] = "true"
            record_request("GET", "/healthz", 503)
            metrics = prometheus_metrics()
            self.assertIn('cloudops_demo_requests_total{method="GET",path="/healthz",status="503"} 1', metrics)
            self.assertIn('cloudops_demo_health_state{environment="staging"} 0', metrics)
            self.assertIn('image_tag="0.1.0-staging"', metrics)
        finally:
            _REQUEST_COUNTS.clear()
            os.environ.clear()
            os.environ.update(old_env)


if __name__ == "__main__":
    unittest.main()
