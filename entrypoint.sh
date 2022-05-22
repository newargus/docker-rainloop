#!/bin/sh
APP_DIR="/var/www/html"

chown -R www-data:www-data /data
chown -R www-data:www-data $APP_DIR
find $APP_DIR -type d -exec chmod 755 {}
find $APP_DIR -type f -exec chmod 644 {} 

/usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
