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
