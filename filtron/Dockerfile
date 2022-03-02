####################################################################################################
## Builder
####################################################################################################
FROM golang:1.17-alpine AS builder

RUN apk add --no-cache \
    ca-certificates \
    wget \
    git

WORKDIR /filtron

ADD https://api.github.com/repos/searxng/filtron/git/refs/head /cachebreak
RUN git clone https://github.com/searxng/filtron.git /filtron

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

CMD ["/filtron/filtron", "--rules", "/filtron/rules.json", "--listen", "0.0.0.0:4040", "--api", "0.0.0.0:4041"]

EXPOSE 4040

STOPSIGNAL SIGTERM

HEALTHCHECK \
    --start-period=30s \
    --interval=1m \
    --timeout=5s \
    CMD wget --spider --q http://localhost:4041/rules || exit 1

# Image metadata
LABEL org.opencontainers.image.title=Filtron
LABEL org.opencontainers.image.description="Reverse HTTP proxy to filter requests by different rules. Can be used between production webserver and the application server to prevent abuse of the application backend."
LABEL org.opencontainers.image.url=https://searx.silkky.cloud
LABEL org.opencontainers.image.vendor="Silkky.Cloud"
LABEL org.opencontainers.image.licenses=Unlicense
LABEL org.opencontainers.image.source="https://github.com/silkkycloud/docker-searx"