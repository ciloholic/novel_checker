FROM node:12.18-alpine as node

RUN apk add --no-cache bash curl && \
    curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version 1.22.4


FROM ruby:2.6.6-alpine

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /opt/yarn-* /opt/yarn
RUN ln -fs /opt/yarn/bin/yarn /usr/local/bin/yarn
RUN apk add --no-cache git build-base libxml2-dev libxslt-dev mariadb-dev tzdata bash less && \
    cp /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

ENV APP_ROOT /novel_checker
RUN mkdir $APP_ROOT
WORKDIR $APP_ROOT

ENV LANG=ja_JP.UTF-8 \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    BUNDLE_PATH=vendor/bundle \
    BUNDLE_APP_CONFIG=$APP_ROOT/.bundle
RUN gem update --system && \
    gem install --no-document bundler:2.1.4
RUN git config --global color.ui true && \
    git config --global core.pager 'less -RFX' && \
    git config --global alias.ll "log --pretty='format:%C(yellow)%h %C(green)%cd %C(reset)%s %C(magenta)%d %C(cyan)[%an]' --date=short --all --graph"
RUN echo $'alias ll="ls -lh"\n\
alias la="ls -lah"\n\
alias h="history"\n\
alias grep="grep --color=auto"\n\
HISTSIZE=50000\n\
HISTTIMEFORMAT="%Y/%m/%d %H:%M:%S "\n\
PS1="[\w]\\$ "\n\
export CLICOLOR=1\n\
export LSCOLORS=DxGxcxdxCxegedabagacad\n\
export LESS="-g -M -R -S -W -z-4 -x4"' > /root/.bashrc
