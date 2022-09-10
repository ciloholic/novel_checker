SHELL := /bin/bash
.DEFAULT_GOAL := all
.PHONY: $(shell egrep -oh ^[a-zA-Z0-9][a-zA-Z0-9_-]+: $(MAKEFILE_LIST) | sed 's/://')

all: ## ビルドから起動まで
	make build up ps
reset: ## リセットからビルド、起動まで
	make down prune build up ps
ssl: ## SSL証明書の再生成
	make ssl-delete ssl-generate

prune: ## 不要なDockerイメージを破棄
	docker system prune -f
ps: ## 起動中のコンテナを表示
	docker compose ps
up: ## コンテナを起動
	docker compose up -d
stop: ## コンテナを停止
	docker compose stop
build: ## コンテナをビルド
	docker compose build
down: ## コンテナを破棄
	docker compose down --remove-orphans
downv: ## コンテナとボリューム、ネットワークを破棄
	docker compose down -v --remove-orphans
restart: ## コンテナを再起動
	docker compose restart
rubocop: ## Rubocopを実行
	docker compose exec web bundle exec rubocop -AP
annotate: ## Annotateを実行
	docker compose exec web bundle exec annotate
login: ## Railsコンテナへログイン
	docker compose exec web bash
ssl-generate: ## SSL証明書を生成
	docker compose -f compose.mkcert.yml up -d
	sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ./.mkcert/rootCA.pem
	sudo security find-certificate -Z -c mkcert | grep SHA-1 | awk '{ print $$3 }' > ./.mkcert/.trusted-cert-hash
ssl-delete: ## SSL証明書を削除
	head -n 1 ./.mkcert/.trusted-cert-hash | xargs sudo security delete-certificate -Z
	rm -f ./.mkcert/* ./.mkcert/.trusted-cert-hash
help: ## ヘルプ
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9][a-zA-Z0-9_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
