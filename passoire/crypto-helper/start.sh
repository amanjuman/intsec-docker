#!/bin/bash

# Create restricted user if not exists
id -u nodeuser &>/dev/null || useradd -r -s /usr/sbin/nologin nodeuser

# Create restricted shell
echo '#!/bin/bash\nexit 1' > /bin/restricted_shell
chmod 755 /bin/restricted_shell

# Set proper permissions
chown -R nodeuser:nodeuser /passoire/crypto-helper
chmod -R 750 /passoire/crypto-helper

# Run Node.js as nodeuser
su - nodeuser -s /bin/bash -c "node /passoire/crypto-helper/server.js" 