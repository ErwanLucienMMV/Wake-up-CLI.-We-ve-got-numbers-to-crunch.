
COMPOSE = docker compose
SERVICE = codex

IMAGE = local/codex-sandbox:1.0
PROJECT = $(shell $(COMPOSE) config --format json | \
	python3 -c 'import json,sys; print(json.load(sys.stdin)["name"])')

VOLUMES = $(PROJECT)_codex_home $(PROJECT)_codex_workspace

.PHONY: all up build down stop restart shell codex logs \
        clean vclean fclean re

# Default: build and launch the container
all: up

up:
	$(COMPOSE) up -d --build

# Build image without starting the container
build:
	$(COMPOSE) build

# Stop and remove the container, preserve volumes
down:
	$(COMPOSE) down

# Stop container without removing it
stop:
	$(COMPOSE) stop

# Restart the container
restart:
	$(COMPOSE) restart

# Open a shell inside the container
shell:
	$(COMPOSE) exec $(SERVICE) bash

# Launch Codex CLI interactively
codex:
	$(COMPOSE) exec $(SERVICE) codex

# Follow container logs
logs:
	$(COMPOSE) logs -f

# Remove container and image, preserve volumes
clean:
	$(COMPOSE) down --rmi all

# Remove container and volumes, preserve image
vclean:
	$(COMPOSE) down --volumes

# Remove container, image and volumes
fclean:
	$(COMPOSE) down --rmi all --volumes

# Rebuild while keeping persistent data
re: clean all
