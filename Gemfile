# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '4.0.1'

gem 'active_decorator'
gem 'administrate'
gem 'bcrypt'
gem 'bootsnap', require: false
gem 'cssbundling-rails'
gem 'dotenv-rails'
gem 'faker'
gem 'faraday'
gem 'jbuilder'
gem 'jsbundling-rails'
gem 'meta-tags'
gem 'nokogiri'
gem 'novel_scraping', git: 'https://github.com/ciloholic/novel_scraping.git', branch: 'main'
gem 'parallel'
gem 'pg'
gem 'puma'
gem 'rails', '~> 8.0'
gem 'sprockets-rails'
gem 'tzinfo-data', platforms: %i[windows jruby]
gem 'whenever', require: false

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri windows]
end

group :development do
  gem 'annotaterb'
  gem 'better_errors'
  # gem 'binding_of_caller'
  gem 'byebug', platforms: %i[mri windows]
  gem 'foreman'
  gem 'listen'
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-rspec', require: false
  gem 'spring'
  gem 'spring-watcher-listen'
  gem 'web-console'
end
