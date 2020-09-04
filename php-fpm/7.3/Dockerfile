FROM php:7.3-fpm-alpine

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

# aws-env to get environment variables from AWS SSM
RUN wget https://github.com/Droplr/aws-env/raw/master/bin/aws-env-linux-amd64 -O /bin/aws-env && \
  chmod +x /bin/aws-env

# php-fpm WORKDIR is /var/www/html