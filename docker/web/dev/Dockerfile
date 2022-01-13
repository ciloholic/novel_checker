ARG RUBY_VERSION_ARG

FROM ruby:$RUBY_VERSION_ARG-alpine

ARG BUNDLER_VERSION_ARG

RUN apk add --no-cache git build-base postgresql-dev postgresql-client tzdata bash less yarn && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

WORKDIR /app

COPY package.json yarn.lock Gemfile Gemfile.lock .

RUN yarn

ENV LANG=ja_JP.UTF-8 \
    GEM_HOME=/bundle \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    RAILS_SERVE_STATIC_FILES=true
ENV BUNDLE_PATH $GEM_HOME
ENV BUNDLE_APP_CONFIG=$BUNDLE_PATH \
    BUNDLE_BIN=$BUNDLE_PATH/bin
ENV PATH /app/bin:$BUNDLE_BIN:$PATH
RUN gem update --system && \
    gem install --no-document bundler -v $BUNDLER_VERSION_ARG && \
    bundle install
