from chaostutorial.http import probes

"""
Tests for http actions

Warn: these tests need a web server running to execute correctly. Run Nginx in Docker before testing:

    ```
    docker run -d --rm --publish 8080:80 nginx
    ```
"""


def test_request_duration():
    configuration = None
    result = probes.request_duration(
        "http://localhost:8080", method="GET", timeout=2, configuration=configuration
    )

    assert result > 0.0


def test_request_mime_type():
    configuration = None
    result = probes.response_mime_type(
        "http://localhost:8080", method="GET", timeout=2, configuration=configuration
    )

    assert result == "text/html"
