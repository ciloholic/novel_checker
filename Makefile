all: dev
dev: build-dev up-dev ps-dev
prd: build-prd up-prd ps-prd
prune:
	docker system prune -f
login:
	docker exec -it web-container bash
# dev
reset-dev: clean-dev prune build-dev up-dev
ps-dev:
	docker-compose -f docker-compose-dev.yml ps
up-dev:
	docker-compose -f docker-compose-dev.yml up -d
build-dev:
	ln -sf ./docker/env/dev.env .env
	docker-compose -f docker-compose-dev.yml build
clean-dev:
	docker-compose -f docker-compose-dev.yml down -v
# prd
reset-prd: clean-prd prune build-prd up-prd
ps-prd:
	docker-compose -f docker-compose-prd.yml ps
up-prd:
	docker-compose -f docker-compose-prd.yml up -d
build-prd:
	ln -sf ./docker/env/prd.env .env
	docker-compose -f docker-compose-prd.yml build
clean-prd:
	docker-compose -f docker-compose-prd.yml down -v
