# development

```
bundle install --path vendor/bundle --jobs=4
yarn
bundle exec rake db:migrate
```

# credentials

```
EDITOR="vi" bundle exec rails credentials:edit
bundle exec rails credentials:show
```

# annotate

```
bundle exec annotate
```

# rubocop

```
bundle exec rubocop -a
```

# webpack

```
bundle exec foreman start
```

# docker-compose

```
docker exec -it web-container bash
docker exec -it db-container bash
```

# novel_scraping

```
bundle exec rake novel_scraping:link_check
```

```
bundle exec rake novel_scraping:all_site
```

```
bundle exec rake novel_scraping:arcadia
bundle exec rake novel_scraping:narou
bundle exec rake novel_scraping:hameln
bundle exec rake novel_scraping:akatsuki
```
