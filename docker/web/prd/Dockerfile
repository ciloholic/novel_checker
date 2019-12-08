FROM node:12.13.1-alpine as node

RUN apk add --no-cache bash curl && \
    curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version 1.19.1


FROM ruby:2.6.5-alpine as builder

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /opt/yarn-* /opt/yarn
RUN ln -fs /usr/local/bin/node /usr/local/bin/nodejs && \
    ln -fs /opt/yarn/bin/yarn /usr/local/bin/yarn
RUN apk add --no-cache build-base libxml2-dev libxslt-dev mariadb-dev tzdata

ENV APP_ROOT /novel_checker
RUN mkdir $APP_ROOT
WORKDIR $APP_ROOT

COPY ./Gemfile $APP_ROOT
COPY ./Gemfile.lock $APP_ROOT
COPY ./package.json $APP_ROOT
COPY ./yarn.lock $APP_ROOT

ENV LANG ja_JP.UTF-8 \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3
RUN gem update --system && \
    gem install --no-document bundler:2.0.2
RUN bundle install
RUN yarn

ARG DB_HOST
ARG DB_DATABASE
ARG DB_USERNAME
ARG DB_PASSWORD
COPY . $APP_ROOT
RUN RAILS_ENV=production bundle exec rake assets:precompile


FROM ruby:2.6.5-alpine

ENV LANG ja_JP.UTF-8
RUN apk add --no-cache build-base libxml2-dev libxslt-dev mariadb-dev tzdata

ENV APP_ROOT /novel_checker
RUN mkdir $APP_ROOT
WORKDIR $APP_ROOT

COPY . $APP_ROOT
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder $APP_ROOT/public/assets $APP_ROOT/public/assets
COPY --from=builder $APP_ROOT/public/packs $APP_ROOT/public/packs
