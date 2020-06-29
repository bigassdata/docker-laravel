FROM php:7.3-fpm-alpine as php-fpm-base

LABEL maintainer="Bill Kidwell <bill.kidwell@bigassfans.com>" company="Big Ass Fans"

RUN apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    curl-dev \
    imagemagick-dev \
    libtool \
    libxml2-dev \
    postgresql-dev \
    sqlite-dev \
    && apk add --no-cache \
        curl \
        git \
        imagemagick \
        mysql-client \
        postgresql-libs \
        libintl \
        icu \
        icu-dev \
        libzip-dev \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && docker-php-ext-install \
        bcmath \
        curl \
        iconv \
        mbstring \
        pdo \
        pdo_mysql \
        pdo_pgsql \
        pdo_sqlite \
        pcntl \
        tokenizer \
        xml \
        zip \
        intl \
    && curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer --version=1.9.3 \
    && apk del -f .build-deps

# Add bash for some utility
RUN apk add --no-cache --upgrade bash

# php-fpm WORKDIR is /var/www/html

FROM php-fpm-base as docker-laravel-supervisor

RUN apk add --update supervisor && rm  -rf /tmp/* /var/cache/apk/*

ADD conf/supervisord.conf /etc/supervisord.conf

# The purpose of this image is to be extended and have multiple processes in a single container.
# To do this, add configs to /etc/supervisor/conf.d/. Each layer can have its own processes.
ENTRYPOINT ["supervisord", "--nodaemon", "--configuration", "/etc/supervisord.conf"]