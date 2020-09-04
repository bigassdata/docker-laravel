FROM php:7.3-cli-alpine

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
        sockets \
    && apk del -f .build-deps

# Add npm (LTS version)
RUN apk update && apk add \
    python3 \
    make \
    g++

# Add bash for some utility
RUN apk add --no-cache --upgrade bash

# php-fpm WORKDIR is /var/www/html
WORKDIR /app