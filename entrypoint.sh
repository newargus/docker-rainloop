#!/bin/sh
APP_DIR="/var/www/html"

chown -R www-data:www-data /data
chown -R www-data:www-data $APP_DIR

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
