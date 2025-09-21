import pytest
import requests
from utils import assert_not_gateway_error, any_code

@pytest.mark.integration
def test_root_page(base_url):
    r = requests.get(f"{base_url}/", timeout=8)
    assert_not_gateway_error(r)
    any_code(r, [200, 301, 302])
    assert "text/html" in r.headers.get("Content-Type", "")

@pytest.mark.integration
def test_static_asset(base_url):
    r = requests.get(f"{base_url}/dist/output.css", timeout=8)
    assert_not_gateway_error(r)
    any_code(r, [200, 304])

@pytest.mark.integration
def test_accept_header_html(base_url):
    r = requests.get(f"{base_url}/", headers={"Accept": "text/html"}, timeout=8)
    assert_not_gateway_error(r)
    any_code(r, [200, 301, 302])
