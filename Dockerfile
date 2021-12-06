####################################################################################################
## Builder
####################################################################################################
FROM python:3.10-alpine3.15 AS builder

RUN apk add --no-cache \
    build-base \
    libffi-dev \
    libxslt-dev \
    libxml2-dev \
    openssl-dev \
    tar \
    git

WORKDIR /searxng

ADD https://github.com/searxng/searxng/archive/master.tar.gz /tmp/searxng-master.tar.gz
RUN tar xvfz /tmp/searxng-master.tar.gz -C /tmp \
    && cp -r /tmp/searxng-master/. /searxng

RUN pip3 install --upgrade pip wheel setuptools \
    && pip3 install --no-cache --no-binary :all: -r requirements.txt

####################################################################################################
## Final image
####################################################################################################
FROM alpine:3.15

ENV INSTANCE_NAME=Silkky.Cloud \
    AUTOCOMPLETE=duckduckgo \
    SEARXNG_SETTINGS_PATH=/etc/searxng/settings.yml \
    UWSGI_SETTINGS_PATH=/etc/searxng/uwsgi.ini    

RUN apk add --no-cache \
    ca-certificates \
    python3 \
    py3-pip \
    libxml2 \
    libxslt \
    openssl \
    tini \
    uwsgi \
    uwsgi-python3 \
    brotli \
    bash

WORKDIR /searxng

COPY --from=builder /searxng /searxng

# Create persistent data directory
RUN mkdir -p /etc/searxng \
    && mkdir -p /var/run/uwsgi-logrotate

# Add start script
COPY ./start.sh /searxng/start.sh
RUN chmod +x /searxng/start.sh
# Add Searxng settings
COPY ./settings.yml /etc/searxng/settings.yml
COPY ./uwsgi.ini /etc/searxng/uwsgi.ini

# Add an unprivileged user and set directory permissions
RUN adduser --disabled-password --gecos "" --no-create-home searxng \
    && chown -R searxng:searxng /searxng \
    && chown -R searxng:searxng /etc/searxng \
    && chown -R searxng:searxng /var/log/uwsgi \
    && chown -R searxng:searxng /var/run/uwsgi-logrotate

ENTRYPOINT ["/sbin/tini", "--"]

USER searxng

CMD ["./start.sh"]

EXPOSE 8080

STOPSIGNAL SIGTERM

HEALTHCHECK \
    --start-period=30s \
    --interval=1m \
    --timeout=5s \
    CMD wget --spider --q http://localhost:8080/ || exit 1

# Image metadata
LABEL org.opencontainers.image.title=SearXNG
LABEL org.opencontainers.image.description="Privacy-respecting, hackable metasearch engine"
LABEL org.opencontainers.image.url=https://searx.silkky.cloud
LABEL org.opencontainers.image.vendor="Silkky.Cloud"
LABEL org.opencontainers.image.licenses=Unlicense
LABEL org.opencontainers.image.source="https://github.com/silkkycloud/docker-searx"