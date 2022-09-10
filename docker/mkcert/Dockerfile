FROM golang:1-alpine

WORKDIR /mkcert

RUN apk add --no-cache git
RUN git clone https://github.com/FiloSottile/mkcert . && \
    go build -ldflags "-X main.Version=$(git describe --tags)" -o /bin/mkcert && \
    rm -fr *
CMD mkcert -install && \
    mkcert "novel.lvh.me" && \
    cp -f /root/.local/share/mkcert/rootCA.pem .
