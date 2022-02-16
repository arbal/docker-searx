####################################################################################################
## Builder
####################################################################################################
FROM golang:1.17-alpine AS builder

RUN apk add --no-cache \
    ca-certificates \
    wget \
    tar

WORKDIR /filtron

ADD https://github.com/searxng/filtron/archive/master.tar.gz /tmp/filtron-master.tar.gz
RUN tar xvfz /tmp/filtron-master.tar.gz -C /tmp \
    && cp -r /tmp/filtron-master/. /filtron

# Build Filtron
RUN go get -d -v \
    && gofmt -l ./ \
    && CGO_ENABLED=0 go build -ldflags '-extldflags "-static"' -tags timetzdata .

RUN wget -O /filtron/rules.json https://raw.githubusercontent.com/searxng/searxng-docker/master/rules.json

####################################################################################################
## Final image
####################################################################################################
FROM alpine:3.15

RUN apk add --no-cache \
    ca-certificates \
    tini

WORKDIR /filtron

COPY --from=builder /filtron/filtron /filtron/filtron
COPY --from=builder /filtron/rules.json /filtron/rules.json

# Add an unprivileged user and set directory permissions
RUN adduser --disabled-password --gecos "" --no-create-home filtron \
    && chown -R filtron:filtron /filtron

ENTRYPOINT ["/sbin/tini", "--"]

USER filtron

CMD ["/filtron/filtron", "--rules", "/filtron/rules.json"]

EXPOSE 3000

STOPSIGNAL SIGTERM

HEALTHCHECK \
    --start-period=30s \
    --interval=1m \
    --timeout=5s \
    CMD wget --spider --q http://localhost:4040/ || exit 1

# Image metadata
LABEL org.opencontainers.image.title=Filtron
LABEL org.opencontainers.image.description="Reverse HTTP proxy to filter requests by different rules. Can be used between production webserver and the application server to prevent abuse of the application backend."
LABEL org.opencontainers.image.url=https://searx.silkky.cloud
LABEL org.opencontainers.image.vendor="Silkky.Cloud"
LABEL org.opencontainers.image.licenses=Unlicense
LABEL org.opencontainers.image.source="https://github.com/silkkycloud/docker-searx"