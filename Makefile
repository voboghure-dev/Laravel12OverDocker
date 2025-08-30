# Laravel Docker Makefile
# Usage:
# make build      → Build containers with dynamic UID/GID
# make up         → Start containers (after build)
# make down       → Stop containers
# make restart    → Restart containers
# make bash       → Open PHP container shell
# make artisan cmd="migrate" → Run artisan command
# make composer cmd="update" → Run composer command
# make npm cmd="install"     → Run npm command inside PHP container

# Variables (host UID/GID)
UID := $(shell id -u)
GID := $(shell id -g)

# Build containers with dynamic UID/GID
build:
	docker compose build --build-arg UID=$(UID) --build-arg GID=$(GID)

# Start containers (after build)
up:
	UID=$(UID) GID=$(GID) docker compose up -d

# Stop containers
down:
	docker compose down

# Restart containers
restart: down up

# Clean only this project: containers, images, volumes, cache
clean:
	@echo "Stopping and removing project containers, images, and volumes..."
	docker compose down --rmi all --volumes --remove-orphans
	@echo "Pruning build cache for this project only..."
	docker builder prune -f --filter label=com.docker.compose.project=${COMPOSE_PROJECT_NAME}

# Access PHP container shell
bash:
	UID=$(UID) GID=$(GID) docker compose exec php-apache bash

# Run artisan commands (example: make artisan cmd="migrate")
artisan:
	docker compose exec php-apache php artisan $(cmd)

# Run composer commands (example: make composer cmd="install")
composer:
	docker compose exec php-apache composer $(cmd)

# Run npm commands (example: make npm cmd="run dev")
npm:
	docker compose exec php-apache npm $(cmd)
