####################################################################################################
## Final image
####################################################################################################
FROM alpine:3.15

ENV SEARXNG_SETTINGS_PATH="/config/settings.yml"

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
    bash \
    && apk add --no-cache -t build-dependencies \
    build-base \
    py3-setuptools \
    python3-dev \
    libffi-dev \
    libxslt-dev \
    libxml2-dev \
    openssl-dev \
    tar \
    git

ADD https://api.github.com/repos/silkkycloud/searxng/git/refs/head /cachebreak
RUN git clone https://github.com/silkkycloud/searxng.git /searxng

WORKDIR /searxng

# Install Python dependencies
RUN pip3 install --upgrade pip wheel setuptools \
    && pip3 install --no-cache -r requirements.txt

# Get SearXNG version
RUN python3 -c "import six; import searx.version; six.print_(searx.version.VERSION_STRING)" > VERSION \
    && python3 -m searx.version freeze

# Delete build dependencies
RUN apk del build-dependencies \
    && rm -rf /root/.cache

# Compile and compress static files
RUN python3 -m compileall -q searx \
    && find /searxng/searx/static -a \( -name '*.html' -o -name '*.css' -o -name '*.js' \
    -o -name '*.svg' -o -name '*.ttf' -o -name '*.eot' \) \
    -type f -exec gzip -9 -k {} \+ -exec brotli --best {} \+

# Copy configuration files
RUN mkdir -p /config
COPY ./searxng/settings.yml /config/settings.yml
COPY ./searxng/uwsgi.ini /config/uwsgi.ini
COPY ./searxng/start.sh ./start.sh
RUN chmod +x ./start.sh

# Add an unprivileged user and set directory permissions
RUN adduser --disabled-password --gecos "" --no-create-home searxng \
    && chown -R searxng:searxng /searxng \
    && chown -R searxng:searxng /config

ENTRYPOINT ["/sbin/tini", "--"]

USER searxng

CMD ["/searxng/start.sh"]

EXPOSE 8080

STOPSIGNAL SIGTERM

HEALTHCHECK \
    --start-period=30s \
    --interval=1m \
    --timeout=5s \
    CMD wget --spider --q http://localhost:8080 || exit 1

# Image metadata
LABEL org.opencontainers.image.title=SearXNG
LABEL org.opencontainers.image.description="SearXNG is a free internet metasearch engine which aggregates results from various search services and databases."
LABEL org.opencontainers.image.url=https://searx.silkky.cloud
LABEL org.opencontainers.image.vendor="Silkky.Cloud"
LABEL org.opencontainers.image.licenses=Unlicense
LABEL org.opencontainers.image.source="https://github.com/silkkycloud/docker-searx"