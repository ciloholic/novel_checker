ARG RUBY_VERSION
FROM ruby:$RUBY_VERSION

ARG NODE_MAJOR
ARG YARN_VERSION
ARG BUNDLER_VERSION
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -yq dist-upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends git curl gnupg2 && \
    curl -sL https://deb.nodesource.com/setup_$NODE_MAJOR.x | bash - && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo 'deb http://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list && \
    apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential \
    mariadb-client \
    libmariadb-dev \
    nodejs \
    yarn=$YARN_VERSION-1 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    truncate -s 0 /var/log/*log

RUN mkdir /novel_checker
WORKDIR /novel_checker

RUN gem update --system && \
    gem install bundler:$BUNDLER_VERSION
