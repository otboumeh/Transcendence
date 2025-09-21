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
