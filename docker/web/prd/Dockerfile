FROM ruby:2.6.5-alpine

ENV LANG ja_JP.UTF-8

RUN apk add --update-cache --no-cache \
    build-base \
    bash \
    curl \
    curl-dev \
    libxml2-dev \
    libxslt-dev \
    linux-headers \
    mysql-dev \
    nodejs \
    openssh \
    ruby-dev \
    ruby-json \
    tzdata \
    yaml \
    yaml-dev \
    zlib-dev \
    imagemagick && \
    curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version 1.19.1 && \
    ln -s '/root/.yarn/bin/yarn' /usr/local/bin/yarn

RUN mkdir /novel_checker
WORKDIR /novel_checker

COPY ./Gemfile /novel_checker
COPY ./Gemfile.lock /novel_checker
COPY ./package.json /novel_checker
COPY ./yarn.lock /novel_checker
RUN gem install bundler -v 2.0.2
RUN bundle install --jobs=4
RUN yarn

COPY . /novel_checker
RUN RAILS_ENV=production bundle exec rake assets:precompile
