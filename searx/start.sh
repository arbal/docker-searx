#!/usr/bin/env bash

if [[ -v HOSTNAME ]]; then
  sed -i "s@ENV_HOSTNAME@$HOSTNAME@g" /data/settings.yml
else
  echo "No hostname!"
  exit 1;
fi

if [[ -v SECRET_KEY ]]; then
  sed -i "s@ENV_SECRET_KEY@$SECRET_KEY@g" /data/settings.yml
else
  echo "No secret key!"
  exit 1;
fi

if [[ -v MORTY_KEY ]]; then
  sed -i "s@ENV_MORTY_KEY@$MORTY_KEY@g" /data/settings.yml
else
  echo "No morty key!"
  exit 1;
fi

sleep 2s

exec uwsgi --master --http-socket "0.0.0.0:8080" "/data/uwsgi.ini"