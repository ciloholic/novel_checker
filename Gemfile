# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.1.2'

gem 'active_decorator'
gem 'administrate'
gem 'bcrypt', '~> 3.1.7'
gem 'bootsnap', require: false
gem 'cssbundling-rails'
gem 'dotenv-rails'
gem 'jbuilder'
gem 'jsbundling-rails'
gem 'meta-tags'
gem 'nokogiri'
gem 'novel_scraping', git: 'https://github.com/ciloholic/novel_scraping.git', branch: 'main'
gem 'parallel'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'
gem 'rails', '~> 7.0.2', '>= 7.0.2.3'
gem 'sprockets-rails'
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem 'annotate'
  gem 'better_errors'
  gem 'binding_of_caller'
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
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
