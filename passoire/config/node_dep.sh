#!/bin/bash

# Logger Function
log() {
  local message="$1"
  local type="$2"
  local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
  local color
  local endcolor="\033[0m"

  case "$type" in
    "info") color="\033[38;5;79m" ;;
    "success") color="\033[1;32m" ;;
    "error") color="\033[1;31m" ;;
    *) color="\033[1;34m" ;;
  esac

  echo -e "${color}${timestamp} - ${message}${endcolor}"
}

# Error handler function  
handle_error() {
  local exit_code=$1
  local error_message="$2"
  log "Error: $error_message (Exit Code: $exit_code)" "error"
  exit $exit_code
}

# Check OS compatibility
check_os() {
    if ! [ -f "/etc/debian_version" ]; then
        handle_error "1" "This script is only supported on Debian-based systems."
    fi
}

# Install Node.js and dependencies
install_node() {
    local node_version=$1

    log "Installing Node.js v$node_version" "info"

    # Update and install required packages
    apt-get update -y || handle_error $? "Failed to run 'apt-get update'"
    apt-get install -y apt-transport-https ca-certificates curl gnupg || handle_error $? "Failed to install pre-requisites"

    # Add NodeSource GPG key
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /usr/share/keyrings/nodesource.gpg || handle_error $? "Failed to download and import NodeSource GPG key"

    # Add Node.js repository
    echo "deb [signed-by=/usr/share/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$node_version nodistro main" > /etc/apt/sources.list.d/nodesource.list || handle_error $? "Failed to configure Node.js repository"

    # Install Node.js
    apt-get update -y || handle_error $? "Failed to run 'apt-get update' after adding Node.js repository"
    apt-get install -y nodejs || handle_error $? "Failed to install Node.js"
}

# Install Node.js dependencies for crypto-helper
install_node_dependencies() {
    local app_dir="/passoire/crypto-helper"

    log "Installing Node.js dependencies in $app_dir" "info"

    if [ -f "$app_dir/package.json" ]; then
        cd "$app_dir" || handle_error $? "Failed to change directory to $app_dir"
        npm install || handle_error $? "Failed to install Node.js dependencies"
        log "Node.js dependencies installed successfully in $app_dir" "success"
    else
        log "No package.json found in $app_dir. Skipping dependency installation." "info"
    fi
}

# Define Node.js version
NODE_VERSION="18.x"

# Check OS compatibility
check_os

# Install Node.js and dependencies
install_node "$NODE_VERSION"

# Install Node.js application dependencies
install_node_dependencies
