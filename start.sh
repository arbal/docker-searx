#!/bin/sh

export DEFAULT_BIND_ADDRESS="0.0.0.0:8080"
export BIND_ADDRESS="${BIND_ADDRESS:-${DEFAULT_BIND_ADDRESS}}"
export BASE_URL="${BASE_URL%/}"

# Compress static files
find /usr/local/searxng/searx/static -a \( -name '*.html' -o -name '*.css' -o -name '*.js' -o -name '*.svg' -o -name '*.ttf' -o -name '*.eot' \) -type f -exec gzip -9 -k {} \+ -exec brotli --best {} \+

# Start uwsgi
exec uwsgi --master --http-socket "${BIND_ADDRESS}" "${UWSGI_SETTINGS_PATH}"
exec /usr/bin/python3 -m compileall -q 