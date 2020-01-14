all: dev
dev: build-dev up-dev ps-dev
prd: build-prd up-prd ps-prd
prune:
	docker system prune -f
login:
	docker exec -it web-container bash
# dev
reset-dev: down-dev prune build-dev up-dev ps-dev
ps-dev:
	docker-compose -f docker-compose-dev.yml ps
up-dev:
	docker-compose -f docker-compose-dev.yml up -d
build-dev:
	docker-compose -f docker-compose-dev.yml build
down-dev:
	docker-compose -f docker-compose-dev.yml down -v
# prd
reset-prd: down-prd prune build-prd up-prd ps-prd
ps-prd:
	docker-compose -f docker-compose-prd.yml ps
up-prd:
	docker-compose -f docker-compose-prd.yml up -d
build-prd:
	docker-compose -f docker-compose-prd.yml build
down-prd:
	docker-compose -f docker-compose-prd.yml down -v
