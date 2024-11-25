#!/bin/bash

# Start DB, web server, and ssh server
service mysql start
service ssh start

# Detect the installed PHP-FPM version dynamically
PHP_VERSION=$(php -r "echo PHP_VERSION;" | cut -d '.' -f 1,2)
PHP_FPM_SOCKET="unix:/var/run/php/php${PHP_VERSION}-fpm.sock"

# Replace the PHP-FPM socket placeholder in the Nginx config
sed -i "s|CONTAINER_PHP_SOCKET|${PHP_FPM_SOCKET}|g" /etc/nginx/sites-enabled/default

# Start PHP-FPM service
service php${PHP_VERSION}-fpm start

DB_NAME="passoire"
DB_USER="passoire"
DB_PASSWORD=$(head -n 1 /passoire/config/db_pw)

# Initialize database
echo "Creating MySQL database and user..."
mysql -u root -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
mysql -u root -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASSWORD}';"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO '${DB_USER}'@'localhost' WITH GRANT OPTION;"
mysql -u root -e "FLUSH PRIVILEGES;"
mysql -u root ${DB_NAME} < config/passoire.sql

# Adapt to our IP
echo "127.0.0.1 db" >> /etc/hosts

# Replace placeholders in application files
sed -i "s/CONTAINER_IP/$HOST/g" /passoire/web/crypto.php
sed -i "s/CONTAINER_IP/$HOST/g" /passoire/crypto-helper/server.js
sed -i "s/CONTAINER_IP/$HOST/g" /etc/nginx/sites-enabled/default

# Start Nginx
service nginx start

if [ -z "$HOST" ]; then
  HOST=$(hostname -i)
fi

echo "Web server running at http://$HOST"

touch /passoire/logs/crypto-helper.log

# Start crypto helper API
/passoire/crypto-helper/crypto-helper.sh start

# Monitor logs
tail -f /passoire/logs/crypto-helper.log /var/log/nginx/passoire-access.log /var/log/nginx/passoire-error.log
