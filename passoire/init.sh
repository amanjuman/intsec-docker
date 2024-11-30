#!/bin/bash

# Enable SSH Access for Root user
sed -i 's/^#*\(PermitRootLogin\).*/\1 yes/' /etc/ssh/sshd_config
sed -i 's/^#*\(PasswordAuthentication\).*/\1 no/' /etc/ssh/sshd_config
sed -i 's/^#*\(PubkeyAuthentication\).*/\1 yes/' /etc/ssh/sshd_config

# Add SSH Key
/passoire/ssh.sh

# Start ssh service
service ssh start

# Generate Diffie-Hellman keys
openssl dhparam -dsaparam -out /etc/ssl/dhparam.pem 2048

# Remove existing Nginx configuration
echo "Removing default Nginx configuration"
rm -f /etc/nginx/nginx.conf
echo "Removing Nginx Default vhost configuration"
rm -f /etc/nginx/sites-enabled/default

# Copy the custom Nginx configuration
echo "Copying custom Nginx configuration"
cp /passoire/config/nginx.conf /etc/nginx/
echo "Copying Passoire Nginx vhost configuration"
cp /passoire/config/passoire-nginx.conf /etc/nginx/conf.d/

# Detect the installed PHP-FPM version dynamically
PHP_VERSION=$(php -r "echo PHP_VERSION;" | cut -d '.' -f 1,2)
PHP_FPM_SOCKET="unix:/var/run/php/php${PHP_VERSION}-fpm.sock"

# Replace the PHP-FPM socket placeholder in the Nginx config
sed -i "s|CONTAINER_PHP_SOCKET|${PHP_FPM_SOCKET}|g" /etc/nginx/conf.d/passoire-nginx.conf

# Start PHP-FPM service
service php${PHP_VERSION}-fpm start

# Start DB server
service mysql start

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

if [ -z "$HOST" ]; then
  HOST=$(hostname -i)
fi

# Replace placeholders in application files
sed -i "s/CONTAINER_IP/$HOST/g" /passoire/web/crypto.php
sed -i "s/CONTAINER_IP/$HOST/g" /passoire/crypto-helper/server.js
sed -i "s/CONTAINER_IP/$HOST/g" /etc/nginx/conf.d/passoire-nginx.conf

# Fix directory permission
chown -R passoire:www-data /passoire/web
find /passoire/web -type d -exec chmod 0755 {} \;
find /passoire/web -type f -exec chmod 0644 {} \;
chmod 000 /passoire/web/uploads/flag_6;

# Start Nginx service
service nginx start

echo "Web server running at http://$HOST"

touch /passoire/logs/crypto-helper.log

# Start crypto helper API
/passoire/crypto-helper/crypto-helper.sh start

# Call the flag hardening script
/passoire/flag.sh

# Monitor logs
tail -f /passoire/logs/crypto-helper.log /var/log/nginx/passoire-access.log /var/log/nginx/passoire-error.log
