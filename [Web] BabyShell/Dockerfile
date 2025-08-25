FROM ubuntu:20.04

# Ubuntu Mirror TW
RUN sed 's@archive.ubuntu.com@free.nchc.org.tw@' -i /etc/apt/sources.list

# Setup user
RUN useradd www

# Install system packeges
RUN apt-get update && apt-get install -y supervisor nginx lsb-release wget software-properties-common

# Add repos
RUN add-apt-repository ppa:ondrej/php
RUN apt-get update

# Install PHP dependencies
RUN apt update && apt install php7.4-fpm -y

# Configure php-fpm and nginx
COPY config/fpm.conf /etc/php/7.4/fpm/php-fpm.conf
COPY config/supervisord.conf /etc/supervisord.conf
COPY config/nginx.conf /etc/nginx/nginx.conf

# Copy challenge files
COPY challenge /www

# Copy flag
COPY flag /

# Setup permissions
RUN chown -R www:www /www /var/lib/nginx

# Expose the port nginx is listening on
EXPOSE 80

# Generate random flag filename and start supervisord
COPY --chown=root entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]