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
