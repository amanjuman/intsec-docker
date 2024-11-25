# Base Image
FROM ubuntu:24.04

# Arguments and Environment Variables
ARG TARGETPLATFORM
ENV DEBIAN_FRONTEND=noninteractive
ENV NODE_ENV=production
ENV NODE_OPTIONS=--openssl-legacy-provider

# Add a user `admin` with the home directory and set the password
RUN useradd -m -s /bin/bash admin && \
    echo 'admin:$6$qqluE.ZYy2z8UiSN$hpxHcW/olIisj/TYv6DY8bmgavSXIQJxAUdtFgaqH9HzstfIt6cBcPYT3buRm8SR7GPGK5JMIScGbKc2kqdsL1' | chpasswd -e && \
    chown -R admin:admin /home/admin

# Add user for the application
RUN useradd -ms /bin/bash passoire

# Copy configuration and dependencies
COPY home/admin/flag_14 /home/admin/
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
    nodejs \
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

# Move and adjust permissions
RUN [ -f /usr/bin/lls ] && mv /usr/bin/lls /usr/bin/ls || echo "lls does not exist, skipping move" && \
    chmod 777 /passoire/web/uploads && \
    chown -R passoire /passoire

# Expose ports
EXPOSE 3002
EXPOSE 3306
EXPOSE 80
EXPOSE 22

# Set the entrypoint command
CMD ["/passoire/init.sh"]
