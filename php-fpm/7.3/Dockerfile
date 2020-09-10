FROM php:7.3-fpm-alpine

LABEL maintainer="Bill Kidwell <bill.kidwell@bigassfans.com>" company="Big Ass Fans"

RUN apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    curl-dev \
    libtool \
    libxml2-dev \
    && apk add --no-cache \
        curl \
        git \
        mysql-client \
        libintl \
        icu \
        icu-dev \
        libzip-dev \
    && docker-php-ext-install \
        bcmath \
        curl \
        iconv \
        mbstring \
        pdo \
        pdo_mysql \
        pcntl \
        tokenizer \
        xml \
        zip \
        intl \
        sockets \
    && curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer --version=1.9.3 \
    && apk del -f .build-deps

# Add npm (LTS version)
RUN apk update && apk add \
    python \
    make \
    g++ \
    nodejs \
    nodejs-npm

# Add bash for some utility
RUN apk add --no-cache --upgrade bash

# php-fpm WORKDIR is /var/www/html