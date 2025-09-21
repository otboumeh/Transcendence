import os
import time
import glob
import json
import pytest
import requests

# Test data for security checks
BAD_PAYLOADS = [
    ("/?q=<script>alert(1)</script>", {}),  # XSS
    ("/?id=1' OR '1'='1", {}),  # SQL Injection
    ("/../../etc/passwd", {}),  # Path Traversal
    ("/api/users?cmd=;cat%20/etc/passwd", {}),  # Command Injection
    ("/?q=../../etc/passwd%00.jpg", {}),  # Null Byte Injection
]

GOOD_PAYLOADS = [
    ("/api/users", {}),
    ("/api/users?id=123", {}),
    ("/api/users?name=john", {}),
]

@pytest.mark.security
def test_security_headers(base_url):
    """Test that security headers are present and correct"""
    r = requests.get(f"{base_url}/", timeout=8)
    h = {k.lower(): v for k, v in r.headers.items()}
    
    assert "content-security-policy" in h
    assert h.get("x-content-type-options") == "nosniff"
    assert h.get("x-frame-options") == "SAMEORIGIN"
    assert "referrer-policy" in h
    assert "permissions-policy" in h
    assert "x-request-id" in h

@pytest.mark.security
def test_waf_blocks_bad_payloads(base_url):
    """Test that WAF blocks malicious payloads"""
    for path, kw in BAD_PAYLOADS:
        r = requests.get(f"{base_url}{path}", timeout=8, **kw)
        assert r.status_code in (403, 406), f"Expected block for {path}, got {r.status_code}"

@pytest.mark.security
def test_waf_allows_good_payloads(base_url):
    """Test that WAF allows legitimate requests"""
    for path, kw in GOOD_PAYLOADS:
        r = requests.get(f"{base_url}{path}", timeout=8, **kw)
        assert r.status_code < 500, f"Expected success for {path}, got {r.status_code}"

@pytest.mark.security
def test_rate_limit(base_url):
    """Test rate limiting on API endpoints"""
    if os.getenv("SEC_RATE_LIMIT_EXPECTED", "false").lower() != "true":
        pytest.skip("rate limit testing disabled")
    
    hits = []
    for _ in range(40):
        r = requests.get(f"{base_url}/api/users", timeout=5)
        hits.append(r.status_code)
        if 429 in hits:  # Stop if we hit the rate limit
            break
    
    assert 429 in hits, "No 429 rate limit response observed under burst"

@pytest.mark.security
def test_waf_audit_log(base_url):
    """Test that WAF generates audit logs for blocked requests"""
    # Send a request that should be blocked
    requests.get(f"{base_url}/?q=<script>alert(1)</script>", timeout=8)
    time.sleep(1)  # Wait for log to be written
    
    # Look for audit logs
    log_dir = "/waf-logs"  # Mounted from host ./waf/logs
    files = sorted(glob.glob(f"{log_dir}/**/*.log", recursive=True))
    assert files, "No audit logs found"
    
    # Check newest log content
    with open(files[-1], "r") as fh:
        content = fh.read()
        assert any(word in content.lower() for word in ["attack", "anomaly"]), \
            "No security terms found in audit log"

@pytest.mark.security
def test_websocket_handshake(base_url):
    """Test that WebSocket connections still work through WAF"""
    ws_url = f"{base_url}/ws".replace("http://", "ws://")
    headers = {
        "Connection": "Upgrade",
        "Upgrade": "websocket",
        "Sec-WebSocket-Version": "13",
        "Sec-WebSocket-Key": "dGhlIHNhbXBsZSBub25jZQ=="
    }
    
    r = requests.get(ws_url, headers=headers)
    assert r.status_code in (101, 400), \
        f"WebSocket handshake failed with {r.status_code}"