# Base image version
FROM php:8.1.6-fpm-alpine as php

# build stage - Web Site
FROM alpine:3.15 as dl
WORKDIR /app
ARG TAG_VERSION
RUN apk add --no-cache wget unzip
RUN wget https://github.com/RainLoop/rainloop-webmail/releases/download/${TAG_VERSION}/rainloop-${TAG_VERSION//v/}.zip && \
	unzip -d src rainloop-${TAG_VERSION//v/}.zip && find .

# build stage - PHP Modules

FROM php as php-ext-pdo
RUN docker-php-ext-install -j"$(nproc)" pdo

FROM php as php-ext-pdo_mysql
RUN docker-php-ext-install -j"$(nproc)" pdo_mysql

FROM php as php-ext-opcache
RUN docker-php-ext-install -j"$(nproc)" opcache

FROM php as php-ext-intl 
RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    icu-dev && \
  docker-php-ext-configure intl
RUN docker-php-ext-install -j"$(nproc)" intl 

FROM php as php-ext-gd
RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    libwebp-dev \
    libjpeg-turbo \
    libpng-dev \
    libxpm-dev \
    freetype-dev \
    libpng-dev && \
  docker-php-ext-configure gd \
    --with-webp=/usr/include/ \
    --with-png=/usr/include/ \
    --with-zlib=/usr/include/ \
    --with-freetype=/usr/include/  \
    --with-jpeg=/usr/include/ && \
  docker-php-ext-install -j"$(nproc)" gd

FROM php as php-ext-zip
RUN docker-php-ext-install -j"$(nproc)" zip


# FROM php as php-ext-zip
# RUN \
#  echo "**** install packages ****" && \
# apk add --no-cache \
#    libzip-dev \
#    zip  && \
#  docker-php-ext-configure zip --with-libzip && \
#  docker-php-ext-install -j"$(nproc)" zip

FROM php
ARG VERSION
LABEL build_version="Version:- ${VERSION}"
LABEL maintainer="newargus"
ARG TZ
ENV TZ $(TZ)

COPY --from=php-ext-pdo /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/
COPY --from=php-ext-pdo /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/

COPY --from=php-ext-pdo_mysql /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/
COPY --from=php-ext-pdo_mysql /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/

COPY --from=php-ext-opcache /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/
COPY --from=php-ext-opcache /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/

COPY --from=php-ext-intl /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/
COPY --from=php-ext-intl /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/

COPY --from=php-ext-gd /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/
COPY --from=php-ext-gd /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/

COPY --from=php-ext-zip /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/
COPY --from=php-ext-zip /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/

WORKDIR /var/www/html
COPY --from=dl /app .
COPY ./entrypoint.sh /entrypoint.sh
COPY ./config/custom.ini /usr/local/etc/php/conf.d/custom.ini
COPY ./config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./config/app.conf  /etc/apache2/conf.d/app.conf

RUN \
  echo "**** install packages ****" && \
  apk add --no-cache \
    nano \
    mariadb-client \
    libwebp-dev \
    libjpeg-turbo \
    libpng-dev \
    libxpm-dev \
    freetype-dev \
    libpng-dev \
    icu-libs \
    jpegoptim \
    optipng \
    pngquant \
    gifsicle \
    supervisor \
    apache2 \
    apache2-ctl \
    apache2-proxy \
    tzdata \
    libzip-dev \
    icu-dev

RUN \   
  echo "**** cleanup ****" && \
  rm -rf /tmp/* && \
  chown www-data -R . && \
  chmod +x /entrypoint.sh

RUN \   
  echo "**** configure supervisord ****" && \
  sed -i '/LoadModule rewrite_module/s/^#//g' /etc/apache2/httpd.conf && \
  sed -i 's#AllowOverride [Nn]one#AllowOverride All#' /etc/apache2/httpd.conf && \
  sed -i '$iLoadModule proxy_module modules/mod_proxy.so' /etc/apache2/httpd.conf

RUN \    
  mkdir -p "/data" && mkdir -p "/data/sessions"  && \
  chown www-data:www-data /data && \
  chmod 0777 /data

VOLUME [ "/data" ]
ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 80 9000