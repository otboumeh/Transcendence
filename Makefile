SHELL := /bin/bash
compose := docker compose -f compose/docker-compose.yml

up:
	$(compose) up -d --build

down:
	$(compose) down -v

logs:
	$(compose) logs -f --tail=120

ps:
	$(compose) ps

restart: down up

certs:
	bash scripts/make-certs.sh
