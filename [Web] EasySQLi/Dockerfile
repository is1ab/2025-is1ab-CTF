FROM php:8.2-apache

RUN apt-get update && \
    apt-get install -y libsqlite3-dev && \
    docker-php-ext-install pdo pdo_sqlite && \
    rm -rf /var/lib/apt/lists/*

COPY setup_db.php /tmp/setup_db.php

RUN mkdir -p /db && php /tmp/setup_db.php && rm /tmp/setup_db.php

COPY src/ /var/www/html/

RUN chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html
