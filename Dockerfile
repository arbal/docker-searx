####################################################################################################
## Final image
####################################################################################################
FROM python:3.10.0-alpine3.15

ENV SEARXNG_SETTINGS_PATH=/etc/searxng/settings.yml \
    UWSGI_SETTINGS_PATH=/etc/searxng/uwsgi.ini \
    BIND_ADDRESS=0.0.0.0:8080

RUN \
    # Add build dependencies
    apk add --no-cache -t build-dependencies \
        build-base \
        libffi-dev \
        libxslt-dev \
        libxml2 \
        openssl-dev \
        tar \
        git \
    # Add runtime dependencies
    && apk add --no-cache \
        ca-certificates \
        libxml2 \
        libxslt \
        openssl \
        tini \
        uwsgi \
        uwsgi-python3 \
        brotli \
        bash

WORKDIR /usr/local/searxng

ADD https://github.com/searxng/searxng/archive/master.tar.gz /tmp/searxng-master.tar.gz
RUN tar xvfz /tmp/searxng-master.tar.gz -C /tmp \
    && cp -r /tmp/searxng-master/requirements.txt /usr/local/searxng/requirements.txt

# Install dependencies
RUN pip3 install --upgrade pip wheel setuptools \
    && pip3 install --no-cache --no-binary :all: -r requirements.txt \
    && apk del build-dependencies

# Copy full source code
RUN cp -r /tmp/searxng-master/. /usr/local/searxng

# Build SearXNG
RUN python3 -m compileall -q searx \
    # Compress static files
    && find /usr/local/searxng/searx/static -a \( -name '*.html' -o -name '*.css' -o -name '*.js' \
    -o -name '*.svg' -o -name '*.ttf' -o -name '*.eot' \) \
    -type f -exec gzip -9 -k {} \+ -exec brotli --best {} \+

COPY ./settings.yml /etc/searxng/settings.yml
COPY ./start.sh /searxng/start.sh
RUN chmod +x /searxng/start.sh

RUN touch /var/run/uwsgi-logrotate

# Add an unprivileged user and set directory permissions
RUN adduser --disabled-password --gecos "" --no-create-home searxng \
    && chown -R searxng:searxng /usr/local/searxng \
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