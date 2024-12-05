#!/bin/bash

# Fix Flag 2
chown root:root /root/flag_2
chmod 600 /root/flag_2

# Fix Flag 6
chown -R www-data:www-data /passoire/web
find /passoire/web -type d -exec chmod 0755 {} \;
find /passoire/web -type f -exec chmod 0644 {} \;
chmod 000 /passoire/web/uploads/flag_6;

# Fix Flag 9
chown -R www-data:www-data /passoire/crypto-helper
find /passoire/crypto-helper -type d -exec chmod 0755 {} \;
find /passoire/crypto-helper -type f -exec chmod 0644 {} \;
chmod 000 /passoire/crypto-helper/flag_9;
