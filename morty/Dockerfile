####################################################################################################
## Builder
####################################################################################################
FROM golang:1.17-alpine AS builder

RUN apk add --no-cache \
    ca-certificates \
    git

WORKDIR /morty

ADD https://api.github.com/repos/dalf/morty/git/refs/head /cachebreak
RUN git clone https://github.com/dalf/morty.git /morty

# Build Morty
RUN go get -d -v \
    && gofmt -l ./ \
    && CGO_ENABLED=0 go build -ldflags '-extldflags "-static"' -tags timetzdata .

####################################################################################################
## Final image
####################################################################################################
FROM alpine:3.15

RUN apk add --no-cache \
    ca-certificates \
    tini

WORKDIR /morty

COPY --from=builder /morty/morty /morty/morty

# Add an unprivileged user and set directory permissions
RUN adduser --disabled-password --gecos "" --no-create-home morty \
    && chown -R morty:morty /morty

ENTRYPOINT ["/sbin/tini", "--"]

USER morty

CMD ["/morty/morty", "-timeout 6", "-ipv6"]

EXPOSE 3000

STOPSIGNAL SIGTERM

HEALTHCHECK \
    --start-period=30s \
    --interval=1m \
    --timeout=5s \
    CMD wget --spider --q http://localhost:3000/ || exit 1

# Image metadata
LABEL org.opencontainers.image.title=Morty
LABEL org.opencontainers.image.description="Web content sanitizer proxy as a service"
LABEL org.opencontainers.image.url=https://searx.silkky.cloud
LABEL org.opencontainers.image.vendor="Silkky.Cloud"
LABEL org.opencontainers.image.licenses=Unlicense
LABEL org.opencontainers.image.source="https://github.com/silkkycloud/docker-searx"