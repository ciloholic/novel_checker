FROM node:13.5-alpine as node

RUN apk add --no-cache bash curl && \
    curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version 1.21.1


FROM ruby:2.6.5-alpine

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /opt/yarn-* /opt/yarn
RUN ln -fs /opt/yarn/bin/yarn /usr/local/bin/yarn
RUN apk add --no-cache git build-base libxml2-dev libxslt-dev mariadb-dev tzdata && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

ENV APP_ROOT /novel_checker
RUN mkdir $APP_ROOT
WORKDIR $APP_ROOT

ENV LANG=ja_JP.UTF-8 \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3
RUN gem update --system && \
    gem install --no-document bundler:2.0.2