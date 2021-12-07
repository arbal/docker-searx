####################################################################################################
## Final image
####################################################################################################
FROM alpine:3.15

ARG TIMESTAMP_SETTINGS=0
ARG TIMESTAMP_UWSGI=0
ARG VERSION_GITCOMMIT=unknown

ENV INSTANCE_NAME=searxng \
    AUTOCOMPLETE= \
    BASE_URL= \
    MORTY_KEY= \
    MORTY_URL= \
    SEARXNG_SETTINGS_PATH=/etc/searxng/settings.yml \
    UWSGI_SETTINGS_PATH=/etc/searxng/uwsgi.ini

RUN \
    apk add --no-cache -t build-dependencies \
        build-base \
        py3-setuptools \
        python3-dev \
        libffi-dev \
        libxslt-dev \
        libxml2-dev \
        openssl-dev \
        tar \
        git \
    && apk add --no-cache \
        ca-certificates \
        su-exec \
        python3 \
        py3-pip \
        libxml2 \
        libxslt \
        openssl \
        tini \
        uwsgi \
        uwsgi-python3 \
        brotli

WORKDIR /usr/local/searxng

ADD https://github.com/searxng/searxng/archive/master.tar.gz /tmp/searxng-master.tar.gz
RUN tar xvfz /tmp/searxng-master.tar.gz -C /tmp \
    && cp -r /tmp/searxng-master/requirements.txt /usr/local/searxng/requirements.txt

RUN pip3 install --upgrade pip wheel setuptools \
    && pip3 install --no-cache  --no-binary :all: -r requirements.txt \
    && apk del build-dependencies \
    && rm -rf /root/.cache

# Copy full source code
RUN cp -r /tmp/searxng-master/. /usr/local/searxng

# Copy configuration files
COPY ./settings.yml /etc/searxng/settings.yml
RUN cp -r /usr/local/searxng/dockerfiles/uwsgi.ini /etc/searxng/uwsgi.ini

# Add an unprivileged user and set directory permissions
RUN adduser --disabled-password --gecos "" --no-create-home searxng \
    && chown -R searxng:searxng /usr/local/searxng \
    && chown -R searxng:searxng /etc/searxng

RUN su searxng -c "/usr/bin/python3 -m compileall -q searx"; \
    touch -c --date=@${TIMESTAMP_SETTINGS} searx/settings.yml; \
    touch -c --date=@${TIMESTAMP_UWSGI} dockerfiles/uwsgi.ini; \
    find /usr/local/searxng/searx/static -a \( -name '*.html' -o -name '*.css' -o -name '*.js' \
    -o -name '*.svg' -o -name '*.ttf' -o -name '*.eot' \) \
    -type f -exec gzip -9 -k {} \+ -exec brotli --best {} \+

ENTRYPOINT ["/sbin/tini","--","/usr/local/searxng/dockerfiles/docker-entrypoint.sh"]

EXPOSE 8080

STOPSIGNAL SIGTERM

# Image metadata
LABEL org.opencontainers.image.title=SearXNG
LABEL org.opencontainers.image.description="Privacy-respecting, hackable metasearch engine"
LABEL org.opencontainers.image.url=https://searx.silkky.cloud
LABEL org.opencontainers.image.vendor="Silkky.Cloud"
LABEL org.opencontainers.image.licenses=Unlicense
LABEL org.opencontainers.image.source="https://github.com/silkkycloud/docker-searx"