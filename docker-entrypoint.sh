#!/bin/sh

# Make sure that there is a trailing slash at end of BASE_URL
export BASE_URL="${BASE_URL%/}/"
export DEFAULT_BIND_ADDRESS="0.0.0.0:8080"
export BIND_ADDRESS="${BIND_ADDRESS:-${DEFAULT_BIND_ADDRESS}}"

touch /var/run/uwsgi-logrotate
chown -R searxng:searxng /var/log/uwsgi /var/run/uwsgi-logrotate
unset MORTY_KEY

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
if [ ! -z "${INSTANCE_NAME}}" ]; then
    sed -i "s@env_instance_name@$INSTANCE_NAME@g" /etc/searxng/settings.yml
fi
if [ ! -z "${CONTACT_URL}}" ]; then
    sed -i "s@env_contact_url@$CONTACT_URL@g" /etc/searxng/settings.yml
fi

# Start uwsgi
printf 'Listen on %s\n' "${BIND_ADDRESS}"
exec su-exec searxng:searxng uwsgi --master --http-socket "${BIND_ADDRESS}" "${UWSGI_SETTINGS_PATH}"