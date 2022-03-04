####################################################################################################
## Final image
####################################################################################################
FROM alpine:3.15

ENV SEARXNG_SETTINGS_PATH="/data/settings.yml"

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

ADD https://api.github.com/repos/searxng/searxng/git/refs/head /cachebreak
RUN git clone https://github.com/searxng/searxng.git /searxng

WORKDIR /searxng

# Modified limiter.py plugin for Cloudflare use
COPY ./searx/limiter.py ./searx/plugins/limiter.py

# Install Python dependencies and get SearXNG version
RUN pip3 install --upgrade pip wheel setuptools \
    && pip3 install --no-cache -r requirements.txt \
    && python3 -c "import six; import searx.version; six.print_(searx.version.VERSION_STRING)" > VERSION \
    && python3 -m searx.version freeze \
    && apk del build-dependencies \
    && rm -rf /root/.cache

# Compile and compress static files
RUN python3 -m compileall -q searx \
    && find /searxng/searx/static -a \( -name '*.html' -o -name '*.css' -o -name '*.js' \
    -o -name '*.svg' -o -name '*.ttf' -o -name '*.eot' \) \
    -type f -exec gzip -9 -k {} \+ -exec brotli --best {} \+

# Add data directory
RUN mkdir -p /data

COPY ./searx/settings.yml /data/settings.yml
COPY ./searx/uwsgi.ini /data/uwsgi.ini
COPY ./searx/start.sh ./start.sh

RUN chmod +x ./start.sh

# Add an unprivileged user and set directory permissions
RUN adduser --disabled-password --gecos "" --no-create-home searx \
    && chown -R searx:searx /searxng \
    && chown -R searx:searx /data

ENTRYPOINT ["/sbin/tini", "--"]

USER searx

CMD ["/searxng/start.sh"]

VOLUME /data

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