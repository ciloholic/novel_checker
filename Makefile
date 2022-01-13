all: build up ps
reset: down prune build up ps
prune:
	docker system prune -f
ps:
	docker compose ps
up:
	docker compose up -d
stop:
	docker compose stop
build:
	docker compose build
down:
	docker compose down -v --remove-orphans
restart:
	docker compose restart
rubocop:
	docker compose exec web bundle exec rubocop -A
login:
	docker compose exec web bash
