#!/bin/bash

set -euo pipefail

export DEFAULT_BIND_ADDRESS="0.0.0.0:8080"
export BIND_ADDRESS="${BIND_ADDRESS:-${DEFAULT_BIND_ADDRESS}}"

# Compress static files
find /searxng/searx/static -a \( -name '*.html' -o -name '*.css' -o -name '*.js' -o -name '*.svg' -o -name '*.ttf' -o -name '*.eot' \) -type f -exec gzip -9 -k {} \+ -exec brotli --best {} \+

# Add Environment variables to config
sed -e "s@baseurlvar@$BASE_URL@g" /etc/searxng/settings.yml
sed -e "s@secretkeyvar@$SECRET_KEY@g" /etc/searxng/settings.yml
sed -e "s@mortyproxykeyvar@$MORTY_KEY@g" /etc/searxng/settings.yml

echo "Starting Searx..."
sleep 3s

# Start Searx
exec uwsgi --master --http-socket "${BIND_ADDRESS}" "${UWSGI_SETTINGS_PATH}"
exec /usr/bin/python3 -m compileall -q searx