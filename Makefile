# ======================================
# Transcendence - Makefile Maestro
# ======================================

# Rutas
COMPOSE   := docker compose -f ./compose/docker-compose.yml
CERTS_DIR := ./scripts/certs
NGINX_DIR := ./nginx
LOGS_DIR  := ./logs

# Colores
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[1;33m
BLUE=\033[0;34m
CYAN=\033[0;36m
WHITE=\033[1;37m
RESET=\033[0m

# Target por defecto para sub-makes de servicios (build/dev/test/migrate/etc.)
t ?= build

# ======================================
# PHONY
# ======================================
.PHONY: help up down build rebuild logs ps clean prune \
        nginx-up backend-up frontend-up game-up monitoring-up \
        nginx-logs backend-logs frontend-logs game-logs \
        grafana-up prometheus-up exporters-up \
        sh certs certs-clean nginx-test nginx-reload \
        status status-monitor init install-deps \
        up-% down-% restart-% rebuild-% logs-% ps-% sh-% \
        make-frontend make-backend make-game \
        rmake-frontend rmake-backend rmake-game \
        logs-save logs-save-% logs-tee logs-tee-% \
        frontend-down backend-down game-down nginx-down \
        security-up security-test security-down \
        tunnel-up tunnel-down cloudflare-certs \
        test demo-tunnel stop-tunnel

# ======================================
# ASCII & HELP
# ======================================
help:
	@echo "$(CYAN)"
	@echo "╔═════════════════════════════════════════════════════════════════════════╗"
	@echo "║    🚀 $(YELLOW)Transcendence Dev Orchestrator$(CYAN)                    ║"
	@echo "╠═════════════════════════════════════════════════════════════════════════╣"
	@echo "║ $(WHITE)Comandos generales$(CYAN)                                       ║"
	@echo "║  $(GREEN)make up$(CYAN)            → Levantar todo                      ║"
	@echo "║  $(GREEN)make down$(CYAN)          → Apagar todo                        ║"
	@echo "║  $(GREEN)make build$(CYAN)         → Construir imágenes                 ║"
	@echo "║  $(GREEN)make rebuild$(CYAN)       → Rebuild + up                       ║"
	@echo "║  $(GREEN)make logs$(CYAN)          → Logs de todo                       ║"
	@echo "║  $(GREEN)make ps$(CYAN)            → Estado de contenedores             ║"
	@echo "║  $(GREEN)make clean$(CYAN)         → Down + volúmenes                   ║"
	@echo "║  $(GREEN)make prune$(CYAN)         → Limpiar imágenes huérfanas         ║"
	@echo "╠═════════════════════════════════════════════════════════════════════════╣"
	@echo "║ $(WHITE)Servicios$(CYAN)                                                ║"
	@echo "║  $(GREEN)make up-<svc>/down-<svc>/restart-<svc>/rebuild-<svc>$(CYAN)    ║"
	@echo "║  $(GREEN)make logs-<svc>/ps-<svc>/sh-<svc>$(CYAN)                       ║"
	@echo "║  Ej.: up-nginx, rebuild-frontend, sh-game-ws                            ║"
	@echo "╠═════════════════════════════════════════════════════════════════════════╣"
	@echo "║ $(WHITE)Make internos por servicio$(CYAN)                               ║"
	@echo "║  $(GREEN)make make-frontend t=dev$(CYAN)  (host)                        ║"
	@echo "║  $(GREEN)make rmake-frontend t=build$(CYAN) (en contenedor)             ║"
	@echo "╠═════════════════════════════════════════════════════════════════════════╣"
	@echo "║ $(WHITE)Logs a archivo$(CYAN)                                           ║"
	@echo "║  $(GREEN)make logs-save$(CYAN)            → stack a logs/<ts>.log       ║"
	@echo "║  $(GREEN)make logs-save-<svc>$(CYAN)      → servicio a logs/<ts>.log    ║"
	@echo "║  $(GREEN)make logs-tee / logs-tee-<svc>$(CYAN) → stream + guardar       ║"
	@echo "╠═════════════════════════════════════════════════════════════════════════╣"
	@echo "║ $(WHITE)Utilidades$(CYAN)                                               ║"
	@echo "║  $(GREEN)make certs$(CYAN)         → Crear SSL autofirmado (dev)        ║"
	@echo "║  $(GREEN)make certs-clean$(CYAN)   → Borrar certs                       ║"
	@echo "║  $(GREEN)make nginx-test$(CYAN)    → Validar config Nginx               ║"
	@echo "║  $(GREEN)make nginx-reload$(CYAN)  → Reload Nginx                       ║"
	@echo "║  $(GREEN)make sh service=nginx$(CYAN) → Entrar con sh (modo clásico)    ║"
	@echo "║  $(GREEN)make status$(CYAN)        → Check HTTP(s)                      ║"
	@echo "║  $(GREEN)make status-monitor$(CYAN)→ Check endpoints monitoring         ║"
	@echo "╠═════════════════════════════════════════════════════════════════════════╣"
	@echo "║ $(WHITE)Cloudflare$(CYAN)                                               ║"
	@echo "║  $(GREEN)make tunnel-up$(CYAN)     → Iniciar túnel Cloudflare           ║"
	@echo "║  $(GREEN)make tunnel-down$(CYAN)   → Detener túnel Cloudflare           ║"
	@echo "║  $(GREEN)make cloudflare-certs$(CYAN) → Generar certificados SSL        ║"
	@echo "╚══════════════════════════════════════════════════════╝$(RESET)"

# ======================================
# GENERALES (stack)
# ======================================
up:
	@echo "$(GREEN)[UP]$(RESET) Levantando stack completo…"
	$(COMPOSE) up -d

down:
	@echo "$(RED)[DOWN]$(RESET) Apagando stack…"
	$(COMPOSE) down

build:
	@echo "$(BLUE)[BUILD]$(RESET) Construyendo imágenes…"
	$(COMPOSE) build

rebuild:
	@echo "$(YELLOW)[REBUILD]$(RESET) Rebuild completo…"
	$(COMPOSE) build --no-cache
	$(COMPOSE) up -d --force-recreate

logs:
	@echo "$(CYAN)[LOGS]$(RESET) Logs de todo el stack:"
	$(COMPOSE) logs -f

ps:
	@echo "$(WHITE)[STATUS]$(RESET) Contenedores:"
	$(COMPOSE) ps

clean:
	@echo "$(RED)[CLEAN]$(RESET) Down + volúmenes + orphans…"
	$(COMPOSE) down -v --remove-orphans

prune:
	@echo "$(RED)[PRUNE]$(RESET) Limpiando imágenes/volúmenes huérfanos…"
	docker system prune -af --volumes

# ======================================
# OPS POR SERVICIO (GENÉRICAS)
# Usan el nombre EXACTO del servicio en docker-compose.yml
# Ej.: make up-frontend / rebuild-game-ws / logs-nginx
# ======================================
up-%:
	@echo "$(GREEN)[UP:$*]$(RESET) Levantando servicio…"
	$(COMPOSE) up -d $*

down-%:
	@echo "$(RED)[DOWN:$*]$(RESET) Parando y limpiando servicio…"
	$(COMPOSE) stop $* || true
	$(COMPOSE) rm -f $* || true

restart-%:
	@echo "$(YELLOW)[RESTART:$*]$(RESET) Reiniciando sin deps…"
	$(COMPOSE) up -d --no-deps --force-recreate $*

rebuild-%:
	@echo "$(YELLOW)[REBUILD:$*]$(RESET) Rebuild + recreate…"
	$(COMPOSE) build --no-cache $*
	$(COMPOSE) up -d --force-recreate $*

logs-%:
	@echo "$(CYAN)[LOGS:$*]$(RESET) Mostrando logs…"
	$(COMPOSE) logs -f --tail=200 $*

ps-%:
	@echo "$(WHITE)[STATUS:$*]$(RESET) Contenedor:"
	$(COMPOSE) ps $*

sh-%:
	@echo "$(BLUE)[SHELL:$*]$(RESET) Abriendo shell…"
	$(COMPOSE) exec $* sh || $(COMPOSE) exec $* /bin/sh

# ======================================
# ALIAS legibles (opcionales)
# ======================================
frontend-up:    ; $(MAKE) up-frontend
backend-up:     ; $(MAKE) up-backend
game-up:        ; $(MAKE) up-game-ws
nginx-up:       ; $(MAKE) up-nginx

frontend-down:  ; $(MAKE) down-frontend
backend-down:   ; $(MAKE) down-backend
game-down:      ; $(MAKE) down-game-ws
nginx-down:     ; $(MAKE) down-nginx

# Logs por servicio (alias)
nginx-logs:     ; $(COMPOSE) logs -f nginx
backend-logs:   ; $(COMPOSE) logs -f backend
frontend-logs:  ; $(COMPOSE) logs -f frontend
game-logs:      ; $(COMPOSE) logs -f game-ws

# ======================================
# MAKE DE SERVICIOS (HOST)
# Ejecuta Makefiles locales en ./frontend ./backend ./game
# Uso: make make-frontend t=dev
# ======================================
make-frontend:
	@echo "$(GREEN)[FRONTEND:MAKE]$(RESET) Ejecutando '$(t)' en ./frontend"
	$(MAKE) -C ./frontend $(t)

make-backend:
	@echo "$(GREEN)[BACKEND:MAKE]$(RESET) Ejecutando '$(t)' en ./backend"
	$(MAKE) -C ./backend $(t)

make-game:
	@echo "$(GREEN)[GAME:MAKE]$(RESET) Ejecutando '$(t)' en ./game"
	$(MAKE) -C ./game $(t)

# ======================================
# MAKE DE SERVICIOS (DENTRO DEL CONTENEDOR)
# Requiere 'make' instalado en la imagen del servicio
# Uso: make rmake-frontend t=build
# ======================================
rmake-frontend:
	@echo "$(GREEN)[FRONTEND:RMAKE]$(RESET) Ejecutando '$(t)' dentro del contenedor"
	$(COMPOSE) run --rm frontend make $(t)

rmake-backend:
	@echo "$(GREEN)[BACKEND:RMAKE]$(RESET) Ejecutando '$(t)' dentro del contenedor"
	$(COMPOSE) run --rm backend make $(t)

rmake-game:
	@echo "$(GREEN)[GAME:RMAKE]$(RESET) Ejecutando '$(t)' dentro del contenedor"
	$(COMPOSE) run --rm game-ws make $(t)

# ======================================
# UTILIDADES
# ======================================

## Entrar con sh a un contenedor: make sh service=nginx (modo clásico)
sh:
ifndef service
	@echo "$(RED)ERROR:$(RESET) Debes indicar el contenedor. Ej: make sh service=nginx"
	@exit 1
else
	@echo "$(BLUE)[SHELL]$(RESET) Abriendo sh en $(service)…"
	docker exec -it $(service) sh || docker exec -it $(service) /bin/sh
endif

## Crear certificados autofirmados (dev) en scripts/certs
certs:
	@mkdir -p $(CERTS_DIR)
	@chmod 700 $(CERTS_DIR) || true
	@if [ ! -w "$(CERTS_DIR)" ]; then \
		echo "$(RED)[CERTS] Sin permisos en $(CERTS_DIR)$(RESET)"; \
		echo "Intenta: sudo chown -R $$USER:$$USER $(CERTS_DIR) && chmod -R u+rwX $(CERTS_DIR)"; \
		exit 1; \
	fi
	@if [ ! -f "$(CERTS_DIR)/privkey.pem" ] || [ ! -f "$(CERTS_DIR)/fullchain.pem" ]; then \
		echo "$(YELLOW)[CERTS] Generando SSL autofirmado en $(CERTS_DIR)…$(RESET)"; \
		openssl req -x509 -nodes -newkey rsa:2048 \
		  -keyout $(CERTS_DIR)/privkey.pem \
		  -out $(CERTS_DIR)/fullchain.pem \
		  -days 365 \
		  -subj "/C=ES/ST=Bizkaia/L=Bilbao/O=Transcendence/OU=Dev/CN=localhost"; \
		openssl dhparam -out $(CERTS_DIR)/dhparam.pem 2048; \
	else \
		echo "$(GREEN)[CERTS] Ya existen certificados$(RESET)"; \
	fi

certs-clean:
	@echo "$(RED)[CERTS]$(RESET) Eliminando certificados de $(CERTS_DIR)…"
	@rm -f $(CERTS_DIR)/privkey.pem $(CERTS_DIR)/fullchain.pem $(CERTS_DIR)/dhparam.pem

## Validar configuración Nginx dentro del contenedor (vía compose exec)
nginx-test:
	@echo "$(BLUE)[NGINX]$(RESET) Test de configuración…"
	$(COMPOSE) exec nginx nginx -t

## Reload de Nginx (sin reiniciar contenedor)
nginx-reload:
	@echo "$(BLUE)[NGINX]$(RESET) Reload…"
	$(COMPOSE) exec nginx nginx -s reload

## Comprobaciones rápidas de endpoints
status:
	@echo "$(WHITE)[STATUS]$(RESET) Comprobando HTTPS reverse-proxy en localhost…"
	-@curl -skI https://localhost/ | head -n 1
	-@curl -skI https://localhost/api/ | head -n 1
	-@curl -skI https://localhost/ws/ | head -n 1

status-monitor:
	@echo "$(WHITE)[STATUS]$(RESET) Monitoring:"
	-@curl -s http://localhost:9090/-/ready    | sed -n '1p'
	-@curl -s http://localhost:3001/login     | sed -n '1p'
	-@curl -s http://localhost:9100/metrics   | sed -n '1p'
	-@curl -s http://localhost:8081/metrics   | sed -n '1p'

# ======================================
# LOGS → ARCHIVO (snapshot y streaming)
# ======================================

# Guardar logs de TODO el stack en un archivo con timestamp
# Ej: make logs-save
logs-save:
	@ts=$$(date +%Y-%m-%d_%H-%M-%S); \
	echo "$(CYAN)[LOGS]$(RESET) Exportando logs del stack a $(LOGS_DIR)/stack-$$ts.log"; \
	mkdir -p $(LOGS_DIR); \
	$(COMPOSE) logs --no-color > "$(LOGS_DIR)/stack-$$ts.log"; \
	echo "$(GREEN)[OK]$(RESET) Guardados en $(LOGS_DIR)/stack-$$ts.log"

# Guardar logs de un servicio concreto en un archivo con timestamp
# Ej: make logs-save-frontend  |  make logs-save-nginx
logs-save-%:
	@svc="$*"; ts=$$(date +%Y-%m-%d_%H-%M-%S); \
	fname="$(LOGS_DIR)/$${svc}-$$ts.log"; \
	echo "$(CYAN)[LOGS:$${svc}]$(RESET) Exportando a $$fname"; \
	mkdir -p $(LOGS_DIR); \
	$(COMPOSE) logs --no-color "$${svc}" > "$$fname"; \
	echo "$(GREEN)[OK]$(RESET) Guardados en $$fname"

# Seguir logs en vivo (con copia a archivo): make logs-tee o logs-tee-nginx
logs-tee:
	@ts=$$(date +%Y-%m-%d_%H-%M-%S); \
	fname="$(LOGS_DIR)/stack-$$ts.log"; \
	echo "$(CYAN)[LOGS]$(RESET) Streaming + guardado en $$fname (Ctrl+C para salir)"; \
	mkdir -p $(LOGS_DIR); \
	$(COMPOSE) logs -f --tail=200 --no-color | tee "$$fname"

logs-tee-%:
	@svc="$*"; ts=$$(date +%Y-%m-%d_%H-%M-%S); \
	fname="$(LOGS_DIR)/$${svc}-$$ts.log"; \
	echo "$(CYAN)[LOGS:$${svc}]$(RESET) Streaming + guardado en $$fname (Ctrl+C para salir)"; \
	mkdir -p $(LOGS_DIR); \
	$(COMPOSE) logs -f --tail=200 --no-color "$${svc}" | tee "$$fname"

# ======================================
# SECURITY TARGETS
# ======================================
security-up:
	@echo "$(GREEN)[SECURITY]$(RESET) Starting with WAF..."
	$(COMPOSE) -f ./compose/docker-compose.waf.yml up -d

security-test:
	@echo "$(BLUE)[SECURITY]$(RESET) Running security tests..."
	$(COMPOSE) -f ./compose/docker-compose.waf.yml -f ./compose/docker-compose.tests.yml run --rm tester pytest -v tests/test_security.py --html=reports/report.html --junitxml=reports/junit.xml

security-down:
	@echo "$(RED)[SECURITY]$(RESET) Stopping WAF stack..."
	$(COMPOSE) -f ./compose/docker-compose.waf.yml down -v
# ======================================
# CLOUDFLARE
# ======================================

# Túnel de Cloudflare
tunnel-up:
	@echo "$(GREEN)[TUNNEL]$(RESET) Iniciando túnel de Cloudflare…"
	@./scripts/cloudflare/tunnel.sh transcendence-tunnel $${CLOUDFLARE_DOMAIN}

tunnel-down:
	@echo "$(RED)[TUNNEL]$(RESET) Deteniendo túnel de Cloudflare…"
	@cloudflared tunnel cleanup transcendence-tunnel

# Certificados SSL con Cloudflare
cloudflare-certs:
	@echo "$(BLUE)[CERTS]$(RESET) Generando certificados SSL con Cloudflare…"
	@./scripts/cloudflare/generate-certs.sh $${CLOUDFLARE_DOMAIN} $${CLOUDFLARE_EMAIL}# ======================================
# Testing
# ======================================
test: ## Smoke tests
	@printf "$(YELLOW)▶ Running smoke tests...$(RESET)\n"
	@echo "▶ HTTP→HTTPS..."
	@curl -skI http://localhost | grep -E '301|308' >/dev/null || (echo "$(RED)FAIL$(RESET)" && exit 1)
	@echo "▶ SPA 200..."
	@curl -skI https://localhost/ --insecure | grep '200' >/dev/null || (echo "$(RED)FAIL$(RESET)" && exit 1)
	@echo "▶ API reachable..."
	@curl -skI https://localhost/api/ --insecure | grep -E '200|401|403|404' >/dev/null || (echo "$(RED)FAIL$(RESET)" && exit 1)
	@printf "$(GREEN)✅ All tests passed!$(RESET)\n"

# ======================================
# Cloudflare Tunnel Demo
# ======================================
OVR := -f compose/docker-compose.tunnel.yml

demo-tunnel: ## Start demo with Cloudflare Tunnel
	@printf "$(YELLOW)▶ Starting Cloudflare Tunnel demo...$(RESET)\n"
	$(COMPOSE) $(OVR) up -d
	@sleep 2
	@$(COMPOSE) $(OVR) logs cloudflared | grep -m1 -Eo 'https://[a-z0-9-]+\.trycloudflare\.com' || true

stop-tunnel: ## Stop Cloudflare Tunnel demo
	@printf "$(YELLOW)▶ Stopping Cloudflare Tunnel...$(RESET)\n"
	$(COMPOSE) $(OVR) down -v --remove-orphans