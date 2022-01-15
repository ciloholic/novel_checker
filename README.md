# Development

```
bundle exec rake db:migrate
bundle exec rails assets:precompile assets:clean
bundle exec foreman start
```

# Novel scraping

```
bundle exec rake novel_scraping:link_check
bundle exec rake novel_scraping:no_renewal_check
bundle exec rake novel_scraping:all_site
```

```
bundle exec rake novel_scraping:arcadia
bundle exec rake novel_scraping:narou
bundle exec rake novel_scraping:hameln
bundle exec rake novel_scraping:akatsuki
```
