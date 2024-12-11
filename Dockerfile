# Base Image
FROM ubuntu:24.04

# Arguments and Environment Variables
ARG TARGETPLATFORM
ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_ENV=production
ENV NODE_OPTIONS=--openssl-legacy-provider

# Add users and set up restricted shell
RUN useradd -ms /bin/bash passoire && \
    useradd -r -s /usr/sbin/nologin nodeuser && \
    # Create restricted shell that always fails
    echo '#!/bin/bash\nexit 1' > /bin/restricted_shell && \
    chmod 755 /bin/restricted_shell && \
    # Force nodeuser to use restricted shell
    usermod -s /bin/restricted_shell nodeuser && \
    # Restrict access to real shells
    chmod 700 /bin/bash && \
    chmod 700 /bin/sh

# Copy configuration and dependencies
COPY home/passoire/flag_1 /home/passoire/
COPY passoire/ /passoire/
COPY flag_2/ /root/

# Set working directory and strict permissions
WORKDIR /passoire
RUN chown -R nodeuser:nodeuser /passoire/crypto-helper && \
    chmod -R 750 /passoire/crypto-helper && \
    chmod 755 /passoire/config/*.sh && \
    # Add security limits for nodeuser
    echo "nodeuser hard nproc 50" >> /etc/security/limits.conf && \
    echo "nodeuser hard nofile 1024" >> /etc/security/limits.conf

# Install dependencies
RUN /passoire/config/node_dep.sh && apt-get update && apt-get install -y \
    apt-utils \
    bc \
    coreutils \
    jq \
    libcurl4-openssl-dev \
    libjson-c-dev \
    mariadb-server \
    nano \
    nginx \
    openssh-server \
    php-curl \
    php-gd \
    php-fpm \
    php-json \
    php-mbstring \
    php-mysql \
    php-zip \
    wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create `lls` command
RUN mv /usr/bin/ls /usr/bin/lls

# Expose ports
EXPOSE 80 3002 22

# Set the entrypoint command
CMD ["/passoire/init.sh"]
