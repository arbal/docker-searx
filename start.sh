#!/bin/bash

set -euo pipedfail

# Make sure that there is a trailing slash at end of BASE_URL
export BASE_URL="${BASE_URL%/}/"

# Add environement variables
sed -i "s@env_base_url@$BASE_URL@g" /etc/searxng/settings.yml
sed -i "s@env_secret_key@$SECRET_KEY@g" /etc/searxng/settings.yml
sed -i "s@env_morty_key@$MORTY_KEY@g" /etc/searxng/settings.yml

# Start SearXNG
exec python3 /searxng/searx/webapp.py