# ft_transcendence
Frontend en TypeScript (Babylon listo), NGINX (HTTPS/WSS), Backend PHP-FPM (REST + SQLite) y Game-WS en PHP-CLI (WebSocket). Observabilidad con ELK.

## Arranque rápido
1) `make certs` (TLS autofirmado)
2) `make up`
3) Frontend: https://localhost  • Kibana: http://localhost:5601  • ES: http://localhost:9200

## Servicios
- nginx: sirve estáticos + proxy /api/* (FPM) + /ws/game (CLI)
- backend: PHP-FPM + SQLite
- game-ws: PHP-CLI (Ratchet) servidor WebSocket
- elasticsearch + logstash + kibana: logs centralizados

## Desarrollo FE
Compila TS a `dist/` con tu bundler (Vite/Webpack). NGINX servirá lo que haya en `frontend/dist/`.

## Web Application Firewall (WAF)

The project includes a WAF using ModSecurity v3 + OWASP Core Rule Set (CRS) in a sidecar/front proxy container. This provides an additional layer of security by filtering and monitoring HTTP traffic between clients and the application.

### Traffic Flow with WAF

```
Client → WAF:80 → Nginx:80 → Backend Services
```

The WAF acts as the first point of contact for all incoming traffic, providing:
- Request filtering based on OWASP CRS rules
- JSON audit logging of security events
- Rate limiting for API endpoints
- Security headers enforcement

### Configuration

#### Paranoia Level

The WAF's paranoia level can be configured using the `PARANOIA_LEVEL` environment variable:

```bash
PARANOIA_LEVEL=1 make security-up  # Default, less strict
PARANOIA_LEVEL=2 make security-up  # More strict, may require tuning
```

Higher paranoia levels provide stricter security but may require more tuning to avoid false positives.

#### WebSocket Handling

WebSocket connections are automatically allowed through the WAF when using the proper upgrade headers. The `/ws` path is configured to bypass certain WAF rules that might interfere with WebSocket handshakes.

#### Rate Limiting

API endpoints are rate-limited by default:
- 10 requests per second per IP
- Burst allowance of 20 requests
- Returns HTTP 429 when exceeded

### Security Testing

Run security tests using:

```bash
make security-test
```

To run specific test categories:
```bash
make security-test "pytest -v -k 'security or waf or headers'"
```

The security test suite includes:
- Security headers verification
- WAF blocking tests for common attacks
- Rate limiting tests
- WebSocket connectivity tests
- Audit log verification

### Audit Logs

WAF audit logs are written to `./waf/logs/` in JSON format. Each blocked request includes:
- Timestamp
- Request ID (X-Request-ID header)
- Triggered rule IDs
- Anomaly scores
- Request details

To correlate requests across services, use the X-Request-ID header that's automatically added to all requests.

### ELK Integration

The WAF and Nginx are configured to output JSON-formatted logs ready for ELK ingestion:

- WAF audit logs: `/var/log/modsec/audit.log`
  - Format: JSON with security event details
  - Fields: service.name=waf, security.event=true, waf.rule.id, waf.anomaly.score

- Nginx access logs: `/var/log/nginx/access.json`
  - Format: JSON with standard fields
  - Additional: X-Request-ID for correlation

### Security Headers

The following security headers are automatically added to all responses:
- Content-Security-Policy (CSP)
- X-Content-Type-Options
- X-Frame-Options
- Referrer-Policy
- Permissions-Policy
- Strict-Transport-Security (HSTS, when using HTTPS)

### Making Changes

1. WAF Configuration:
   - ModSecurity settings: `waf/modsecurity.conf`
   - CRS settings: `waf/crs-setup.conf`
   - Nginx config: `waf/nginx.conf`

2. Testing Changes:
   - Add test cases to `tests/test_security.py`
   - Use `make security-test` to validate

3. Viewing Logs:
   - WAF audit logs: `tail -f waf/logs/audit.log`
   - Test reports: `reports/report.html`