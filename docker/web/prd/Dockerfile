ARG RUBY_VERSION
FROM ruby:$RUBY_VERSION

ARG NODE_MAJOR
ARG YARN_VERSION
ARG BUNDLER_VERSION
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -yq dist-upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends curl gnupg2 && \
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

COPY ./Gemfile /novel_checker
COPY ./Gemfile.lock /novel_checker
COPY ./package.json /novel_checker
COPY ./yarn.lock /novel_checker
ENV LANG ja_JP.UTF-8 \
    GEM_HOME=/bundle \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3
ENV BUNDLE_PATH $GEM_HOME
ENV BUNDLE_APP_CONFIG=$BUNDLE_PATH \
    BUNDLE_BIN=$BUNDLE_PATH/bin
ENV PATH /app/bin:$BUNDLE_BIN:$PATH
RUN gem update --system && \
    gem install bundler:$BUNDLER_VERSION
RUN bundle install
RUN yarn

ARG RAILS_ENV
ARG DB_HOST
ARG DB_DATABASE
ARG DB_USERNAME
ARG DB_PASSWORD
COPY . /novel_checker
RUN RAILS_ENV=$RAILS_ENV rake assets:precompile
