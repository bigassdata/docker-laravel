FROM php:7.3-fpm-alpine

LABEL maintainer="Jason Bishop<jason.bishop@bigassfans.com>" company="Big Ass Fans"

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
    # iconv \
    mbstring \
    pdo \
    pdo_mysql \
    pcntl \
    tokenizer \
    xml \
    zip \
    intl \
    sockets \
    && git clone --depth 1 --branch v1.1.1 https://github.com/BitOne/php-meminfo.git /usr/src/php/ext/meminfo \
    && docker-php-ext-configure meminfo --enable-meminfo \
    && docker-php-ext-install meminfo \
    && docker-php-ext-enable meminfo \
    && rm -rf /usr/src/php/ext/meminfo \
    && curl -s https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer --version=1.9.3 \
    && apk del -f .build-deps

# Copy our local, customized ini to the image
COPY php.ini-production "$PHP_INI_DIR/php.ini"

# Tools we need in addition to nodejs
RUN apk update && apk add \
    make \
    g++ \
    bash

# node, and npm at specific versions
RUN apk add  --no-cache \
    --repository http://dl-cdn.alpinelinux.org/alpine/v3.10/main/ \
    nodejs=10.24.1-r0 \
    npm=10.24.1-r0 \
    python

# php-fpm WORKDIR is /var/www/html
