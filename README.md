# Initial construction

## Development

```
make dev or reset-dev
docker exec -it web-container ash
bundle install --path vendor/bundle --jobs=4
yarn
bundle exec rake db:migrate
bundle exec foreman start
```

## Production

```
make prd or make reset-prd
```

# Credential

```
EDITOR="vi" bundle exec rails credentials:edit
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

# docker container login

```
docker exec -it web-container ash
docker exec -it db-container bash
```

# novel scraping

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
