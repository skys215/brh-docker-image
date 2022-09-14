FROM php:8.1-fpm-alpine

MAINTAINER skys215<skys215@gmail.com>

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories
RUN set -ex; apk add --no-cache bash libzip-dev sqlite-dev chromium chromium-chromedriver font-noto-cjk && \
 docker-php-ext-configure bcmath && \
    docker-php-ext-install bcmath zip pdo_sqlite

# install composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"  && \
    php composer-setup.php --install-dir=/usr/bin --filename=composer && \
   php -r "unlink('composer-setup.php');"

WORKDIR /app
RUN mkdir -p /app/json && \
 mkdir -p /app/html && \
 mkdir -p /app/docs
ADD run.sh run.sh

WORKDIR /app/html
ENTRYPOINT ["tail"]
CMD ["-f","/dev/null"]

