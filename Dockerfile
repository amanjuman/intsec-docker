# Base Image
FROM ubuntu:24.04

# Arguments and Environment Variables
ARG TARGETPLATFORM
ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_ENV=production
ENV NODE_OPTIONS=--openssl-legacy-provider

# Add user for the application
RUN useradd -ms /bin/bash passoire

# Copy configuration and dependencies
COPY home/passoire/flag_1 /home/passoire/
COPY passoire/ /passoire/
COPY flag_2/ /root/

# Set working directory
WORKDIR /passoire

# Install dependencies
RUN /passoire/config/node_dep.sh && apt-get update && apt-get install -y \
    apt-utils \
    bc \
    coreutils \
    jq \
    libcurl4-openssl-dev \
    libjson-c-dev \
    mysql-server \
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
RUN cp /usr/bin/ls /usr/bin/lls

# Adjust permissions and ownership
RUN [ -f /usr/bin/lls ] && mv /usr/bin/lls /usr/bin/ls || echo "lls does not exist, skipping move" && \
    chown -R passoire /passoire && \
    chown -R www-data:passoire /passoire/web && \
    chmod -R 750 /passoire/web && \
    chmod -R 770 /passoire/web/uploads

# Expose ports
EXPOSE 80
EXPOSE 22

# Set the entrypoint command
CMD ["/passoire/init.sh"]
