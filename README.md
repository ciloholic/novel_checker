# Initial construction

## Development

```
make dev or reset-dev
docker exec -it web-container bash
bundle install
yarn
bundle exec rake db:migrate
bundle exec rails assets/precompile assets:clean
bundle exec foreman start
```

## Production

```
make prd or make reset-prd
```

# Credential

```
bundle exec rails credentials:edit
bundle exec rails credentials:show
```

# Annotate

```
bundle exec annotate
```

# Rubocop

```
bundle exec rubocop -a
```

# Docker container login

```
docker exec -it web-container bash
docker exec -it db-container bash
```

# Novel scraping

```
bundle exec rake novel_scraping:link_check
bundle exec rake novel_scraping:all_site
```

```
bundle exec rake novel_scraping:arcadia
bundle exec rake novel_scraping:narou
bundle exec rake novel_scraping:hameln
bundle exec rake novel_scraping:akatsuki
```

# Amazon ECR push

```
cat ~/.aws/config
export AWS_DEFAULT_PROFILE=ciloholic
$(aws ecr get-login --no-include-email --region ap-northeast-1)
```
