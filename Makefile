# Laravel Docker Makefile
# Usage:
# make up        → Start containers
# make down      → Stop containers
# make restart   → Restart containers
# make bash      → Open PHP container shell
# make artisan cmd="migrate" → Run artisan command
# make composer cmd="update" → Run composer command
# make npm cmd="install"     → Run npm command inside PHP container

# Start containers
up:
	docker compose up -d --build

# Stop containers
down:
	docker compose down

# Restart containers
restart:
	docker compose down && docker compose up -d

# Access PHP container shell
bash:
	docker exec -it pos-with-laravel-apache-php bash

# Run artisan commands
artisan:
	docker exec -it pos-with-laravel-apache-php php artisan $(cmd)

# Run composer commands
composer:
	docker exec -it pos-with-laravel-apache-php composer $(cmd)

# Run npm commands
npm:
	docker exec -it pos-with-laravel-apache-php npm $(cmd)
