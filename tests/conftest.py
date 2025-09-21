import os
import socket
import pytest
import requests
from tenacity import retry, stop_after_attempt, wait_fixed

TIMEOUT = int(os.getenv("TIMEOUT_SECS", "8"))
RETRIES = int(os.getenv("RETRIES", "8"))

@pytest.fixture(scope="session")
def base_url():
    return os.getenv("BASE_URL", "http://localhost")

@pytest.fixture(scope="session")
def ws_url():
    return os.getenv("WS_URL", "ws://localhost/ws")

@pytest.fixture(scope="session")
def prom_url():
    return os.getenv("PROM_URL", "http://localhost:9090")

@pytest.fixture(scope="session")
def grafana_cfg():
    return {
        "url": os.getenv("GRAFANA_URL", "http://localhost:3000"),
        "user": os.getenv("GRAFANA_USER"),
        "password": os.getenv("GRAFANA_PASS"),
    }

@retry(stop=stop_after_attempt(RETRIES), wait=wait_fixed(1))
def wait_http_200(url: str):
    r = requests.get(url, timeout=TIMEOUT)
    assert r.status_code == 200, f"{url} -> {r.status_code}"
    return r

def can_connect(host: str, port: int, timeout: int = TIMEOUT) -> bool:
    try:
        with socket.create_connection((host, port), timeout=timeout):
            return True
    except OSError:
        return False
