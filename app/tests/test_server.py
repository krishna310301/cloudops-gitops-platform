import os
import pathlib
import sys
import unittest

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))

from src.server import _truthy, app_metadata


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


if __name__ == "__main__":
    unittest.main()
