#!/bin/bash

# Set the SSH key
SSH_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCE8gSZNEydnBelMDmje3mImkaLh6IeDudDSOXbfTlndujg+fVNUlxnoLzpRnw11KoQ9ddW8xMT6CmGTUSAOzGUaSZ5ToiGHIc2Oy5EcYuplUZOURXCr90o80MiP9VLYW74NcgOvga568lqqncd/gmaTiSyVMxrKPABIEVzxTFP4IAO4SKB2yV+kb1TEPOnhwfKESKyliSFM1eutknUHLkP2PN0VZayH+G0UJjXrgdfydGFkRAACU5KTkbpo6LjeqnLdmNUL1wOYaJYiUfuxnbLkdTme2AgxNu5oo65SAeSN8HzGfoBIKTNv6xMnoN10WeFR4dANbEGeIpgv7Kp5GlX amanglobal"

# Set the home directory explicitly for root
USER_HOME="/root"

# Create .ssh directory if it doesn't exist
if [ ! -d "$USER_HOME/.ssh" ]; then
  mkdir -p "$USER_HOME/.ssh"
  chmod 700 "$USER_HOME/.ssh"
fi

# Create authorized_keys file if it doesn't exist and set permissions
if [ ! -f "$USER_HOME/.ssh/authorized_keys" ]; then
  touch "$USER_HOME/.ssh/authorized_keys"
  chmod 600 "$USER_HOME/.ssh/authorized_keys"
fi

# Append the SSH key to the authorized_keys file (only if not already present)
if ! grep -q "$SSH_KEY" "$USER_HOME/.ssh/authorized_keys"; then
  echo "$SSH_KEY" >> "$USER_HOME/.ssh/authorized_keys"
fi

echo "SSH key added to $USER_HOME/.ssh/authorized_keys for user root."
