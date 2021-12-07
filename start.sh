#!/bin/bash

set -euo pipefail

# Make sure that there is a trailing slash at end of BASE_URL
export BASE_URL="${BASE_URL%/}/"

# Add environement variables
if [ ! -z "${BASE_URL}" ]; then
    sed -i "s@env_base_url@$BASE_URL@g" /etc/searxng/settings.yml
else
    echo "You need to add the BASE_URL environment variable!"
    exit 1
fi
if [ ! -z "${SECRET_KEY}" ]; then
    sed -i "s@env_secret_key@$SECRET_KEY@g" /etc/searxng/settings.yml
else
    echo "You need to add the SECRET_KEY environment variable!"
    exit 1
fi
if [ ! -z "${MORTY_KEY}" ]; then
    sed -i "s@env_morty_key@$MORTY_KEY@g" /etc/searxng/settings.yml
else
    echo "You need to add the MORTY_KEY environment variable!"
    exit 1
fi

# Copy latest uwsgi configuration
cp -r /usr/local/searxng/dockerfiles/uwsgi.ini /etc/searxng/uwsgi.ini

# Start SearXNG
printf 'Starting SearXNG... %s\n' "${BASE_URL}"
sleep 3s
printf 'Listen on %s\n' "${BIND_ADDRESS}"
exec uwsgi --master --http-socket "${BIND_ADDRESS}" "${UWSGI_SETTINGS_PATH}"