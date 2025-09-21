import pytest
import requests
from utils import assert_not_gateway_error

API_PATHS = [
    ("GET", "/api/users"),
    ("POST", "/api/auth"),
    ("GET", "/api/matches"),
    ("GET", "/api/ladder"),
    ("PUT", "/api/users"),  # método inválido: esperamos 405/4xx, pero NO 502/504
]

@pytest.mark.integration
def test_api_through_nginx(base_url):
    for method, path in API_PATHS:
        url = f"{base_url}{path}"
        data = {"username": "test", "password": "test"} if method == "POST" else None
        r = requests.request(method, url, json=data, timeout=8)
        assert_not_gateway_error(r)
        assert r.status_code < 500 or r.status_code == 501, f"{url} -> {r.status_code}"
