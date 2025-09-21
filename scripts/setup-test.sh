#!/usr/bin/env bash
set -euo pipefail

# === Paths relativos a la raíz del repo ===
TEST_DIR="tests"
COMPOSE_DIR="compose"
REPORTS_DIR="reports"

echo ">> Creando directorios..."
mkdir -p "$TEST_DIR" "$COMPOSE_DIR" "$REPORTS_DIR" "scripts"

echo ">> Escribiendo tests/requirements.txt..."
cat > "$TEST_DIR/requirements.txt" <<'EOF'
pytest==8.2.0
requests==2.32.3
websocket-client==1.8.0
tenacity==9.0.0
pytest-html==4.1.1
EOF

echo ">> Escribiendo tests/Dockerfile..."
cat > "$TEST_DIR/Dockerfile" <<'EOF'
FROM python:3.11-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app
COPY requirements.txt /app/requirements.txt
RUN pip install --upgrade pip && pip install -r /app/requirements.txt

COPY . /app
CMD ["pytest", "-q"]
EOF

echo ">> Escribiendo tests/pytest.ini..."
cat > "$TEST_DIR/pytest.ini" <<'EOF'
[pytest]
markers =
    integration: pruebas que requieren los contenedores levantados
    monitoring: valida Prometheus/Grafana/exporters
    smoke: pruebas rápidas de disponibilidad
    slow: pueden tardar más
addopts = -q
EOF

echo ">> Escribiendo tests/conftest.py..."
cat > "$TEST_DIR/conftest.py" <<'EOF'
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
EOF

echo ">> Escribiendo tests/utils.py..."
cat > "$TEST_DIR/utils.py" <<'EOF'
import requests
from typing import Iterable

BAD_GATEWAY_CODES = {502, 503, 504, 521, 522, 523}

def assert_not_gateway_error(resp: requests.Response):
    assert resp.status_code not in BAD_GATEWAY_CODES, (
        f"Gateway error {resp.status_code} for {resp.request.method} {resp.url}"
    )

def any_code(resp: requests.Response, ok: Iterable[int]):
    assert resp.status_code in ok, f"{resp.url} -> {resp.status_code}, esperado {ok}"
EOF

echo ">> Escribiendo tests/test_connectivity.py..."
cat > "$TEST_DIR/test_connectivity.py" <<'EOF'
import pytest

TARGETS = [
    ("nginx", 80),
    ("backend", 9000),
    ("game-ws", 8081),
    ("prometheus", 9090),
    ("grafana", 3000),
    ("node-exporter", 9100),
    ("cadvisor", 8080),
    ("nginx-exporter", 9113),
    ("php-fpm-exporter", 9253),
]

@pytest.mark.smoke
@pytest.mark.integration
def test_service_ports_reachable():
    from conftest import can_connect
    unreachable = []
    for host, port in TARGETS:
        if not can_connect(host, port):
            unreachable.append(f"{host}:{port}")
    assert not unreachable, "No accesibles: " + ", ".join(unreachable)
EOF

echo ">> Escribiendo tests/test_frontend.py..."
cat > "$TEST_DIR/test_frontend.py" <<'EOF'
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
EOF

echo ">> Escribiendo tests/test_backend_api.py..."
cat > "$TEST_DIR/test_backend_api.py" <<'EOF'
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
EOF

echo ">> Escribiendo tests/test_websocket.py..."
cat > "$TEST_DIR/test_websocket.py" <<'EOF'
import pytest
import websocket

@pytest.mark.integration
def test_ws_handshake_and_ping(ws_url):
    ws = websocket.create_connection(ws_url, timeout=8, header=["Origin: http://nginx"])
    try:
        ws.send("ping")
        msg = ws.recv()
        assert msg is not None and len(msg) > 0
    finally:
        ws.close()
EOF

echo ">> Escribiendo tests/test_monitoring.py..."
cat > "$TEST_DIR/test_monitoring.py" <<'EOF'
import pytest
import requests
from conftest import wait_http_200
from utils import any_code

EXPORTERS = [
    ("http://node-exporter:9100/metrics", "node exporter"),
    ("http://cadvisor:8080/metrics", "cadvisor"),
    ("http://nginx-exporter:9113/metrics", "nginx exporter"),
    ("http://php-fpm-exporter:9253/metrics", "php-fpm exporter"),
]

@pytest.mark.monitoring
@pytest.mark.integration
def test_prometheus_ready(prom_url):
    r = wait_http_200(f"{prom_url}/-/ready")
    assert "text/plain" in r.headers.get("Content-Type", "")

@pytest.mark.monitoring
@pytest.mark.integration
def test_prometheus_query_up(prom_url):
    r = requests.get(f"{prom_url}/api/v1/query", params={"query": "up"}, timeout=8)
    any_code(r, [200])
    payload = r.json()
    assert payload.get("status") == "success"
    assert isinstance(payload.get("data", {}).get("result", []), list)

@pytest.mark.monitoring
@pytest.mark.integration
def test_exporters_metrics_available():
    missing = []
    for url, name in EXPORTERS:
        r = requests.get(url, timeout=8)
        if r.status_code != 200 or "HELP" not in r.text:
            missing.append(f"{name} -> {url} ({r.status_code})")
    assert not missing, "Exporters sin métricas 200/HELP: " + ", ".join(missing)

@pytest.mark.monitoring
@pytest.mark.integration
def test_grafana_login_page(grafana_cfg):
    r = requests.get(f"{grafana_cfg['url']}/login", timeout=8)
    any_code(r, [200, 302])

@pytest.mark.monitoring
@pytest.mark.integration
def test_grafana_api_health_if_creds(grafana_cfg):
    if not grafana_cfg["user"] or not grafana_cfg["password"]:
        pytest.skip("Sin credenciales Grafana")
    r = requests.get(
        f"{grafana_cfg['url']}/api/health",
        auth=(grafana_cfg["user"], grafana_cfg["password"]),
        timeout=8,
    )
    any_code(r, [200])
    assert r.json().get("database") == "ok"
EOF

echo ">> Escribiendo compose/docker-compose.tests.yml..."
cat > "$COMPOSE_DIR/docker-compose.tests.yml" <<'EOF'
services:
  tester:
    build: ./tests
    depends_on:
      - nginx
      - backend
      - game-ws
      - prometheus
      - grafana
      - node-exporter
      - cadvisor
      - nginx-exporter
      - php-fpm-exporter
    networks:
      - default
      - monitoring
    environment:
      BASE_URL: http://nginx:80
      WS_URL: ws://nginx/ws
      PROM_URL: http://prometheus:9090
      GRAFANA_URL: http://grafana:3000
      GRAFANA_USER: admin
      GRAFANA_PASS: admin
      TIMEOUT_SECS: "8"
      RETRIES: "8"
    volumes:
      - ./tests:/app/tests
      - ./reports:/reports
    command:
      - pytest
      - -q
      - -m
      - "not slow"
      - --maxfail=1
      - --disable-warnings
      - --junitxml=/reports/junit.xml
      - --html=/reports/report.html
      - --self-contained-html
EOF

echo ">> Añadiendo .gitignore para reports..."
if [ ! -f ".gitignore" ] || ! grep -q "^reports/" .gitignore; then
  echo -e "\n# test reports\nreports/\n" >> .gitignore || true
fi

echo ""
echo "======================"
echo "✅ Setup de pruebas creado."
echo "Archivos en: $TEST_DIR y $COMPOSE_DIR/docker-compose.tests.yml"
echo ""
echo "Cómo ejecutar (con Docker Compose):"
echo "1) Levanta tu stack normal:"
echo "   docker compose -f $COMPOSE_DIR/docker-compose.yml up -d"
echo "2) Ejecuta el tester:"
echo "   docker compose -f $COMPOSE_DIR/docker-compose.yml -f $COMPOSE_DIR/docker-compose.tests.yml run --rm tester"
echo ""
echo "Reportes:"
echo " - JUnit:   $REPORTS_DIR/junit.xml"
echo " - HTML:    $REPORTS_DIR/report.html"
echo "======================"

