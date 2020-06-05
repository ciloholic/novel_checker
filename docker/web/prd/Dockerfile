FROM node:12.18-alpine as node

RUN apk add --no-cache bash curl && \
    curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version 1.22.4


FROM ruby:2.6.6-alpine as builder

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /opt/yarn-* /opt/yarn
RUN ln -fs /opt/yarn/bin/yarn /usr/local/bin/yarn
RUN apk add --no-cache git build-base libxml2-dev libxslt-dev mariadb-dev tzdata  && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

ENV APP_ROOT /novel_checker
RUN mkdir $APP_ROOT
WORKDIR $APP_ROOT

COPY ./Gemfile $APP_ROOT
COPY ./Gemfile.lock $APP_ROOT
COPY ./package.json $APP_ROOT
COPY ./yarn.lock $APP_ROOT

ENV LANG=ja_JP.UTF-8 \
    RAILS_ENV=production \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3
RUN gem update --system && \
    gem install --no-document bundler:2.1.4 && \
    bundle config set frozen 'true' && \
    bundle config set without 'development test'
RUN bundle install && \
    rm -rf /usr/local/bundle/cache/*.gem && \
    find /usr/local/bundle/gems/ -name '*.c' -delete && \
    find /usr/local/bundle/gems/ -name '*.o' -delete
RUN yarn --frozen-lockfile

COPY . $APP_ROOT
RUN RAILS_ENV=production bundle exec rake assets:precompile


FROM ruby:2.6.6-alpine

ENV LANG=ja_JP.UTF-8 \
    RAILS_SERVE_STATIC_FILES=true
RUN apk add --no-cache build-base libxml2-dev libxslt-dev mariadb-dev tzdata && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
RUN gem update --system && \
    gem install --no-document bundler:2.1.4

ENV APP_ROOT /novel_checker
RUN mkdir $APP_ROOT
WORKDIR $APP_ROOT

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /opt/yarn-* /opt/yarn
COPY --from=builder $APP_ROOT $APP_ROOT
COPY --from=builder /usr/local/bundle /usr/local/bundle
RUN ln -fs /opt/yarn/bin/yarn /usr/local/bin/yarn

EXPOSE 80
CMD ["bundle", "exec", "rails", "s", "-b", "0.0.0.0", "-p", "80", "-e", "production"]
