all: dev
dev: prune build-dev up-dev ps-dev
prd: prune build-prd up-prd ps-prd
prune:
	docker system prune -f
# dev
reset-dev: clean-dev prune build-dev up-dev
ps-dev:
	docker-compose -f docker-compose-dev.yml ps
up-dev:
	docker-compose -f docker-compose-dev.yml up -d
build-dev:
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
	docker-compose -f docker-compose-prd.yml build
clean-prd:
	docker-compose -f docker-compose-prd.yml down -v
