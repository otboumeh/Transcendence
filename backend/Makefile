# ==============================
# FRONTEND MAKEFILE
# ==============================
COMPOSE = docker compose -f ../compose/docker-compose.yml

up:
	$(COMPOSE) up -d frontend

down:
	$(COMPOSE) stop frontend

logs:
	$(COMPOSE) logs -f frontend

bash:
	docker exec -it transcendence-frontend sh
