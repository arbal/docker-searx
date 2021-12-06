#!/bin/bash

set -euo pipefail

# Make sure that there is a trailing slash at end of BASE_URL
export BASE_URL="${BASE_URL%/}/"

# Add environement variables
if [ ! -z "${BASE_URL}" ]; then
    sed -i "s@env_base_url@$BASE_URL@g" /etc/searxng/settings.yml
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

# Start SearXNG
exec python3 /searxng/searx/webapp.py