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
RUN composer create-project laravel/laravel html "dev-furtive" --repository='{"type":"vcs","url":"git@github.com:skys215/brh9.git"}'
WORKDIR /app/html
RUN sed -i 's~DB_CONNECTION=mysql~DB_CONNECTION=sqlite~' .env && \
sed -i "s~DB_DATABASE=laravel~DB_DATABASE=$PWD/db.sqlite~" .env && \
chmod -R 777 bootstrap/ storage/ && \
php artisan dusk:install && \
ln -sf /usr/bin/chromedriver ./vendor/laravel/dusk/bin/chromedriver-linux && \
chmod -R 0755 vendor/laravel/dusk/bin/ && \
rm -rf tests/Browser/ExampleTest.php && \
touch db.sqlite && \
php artisan migrate && \
php artisan tinker --execute="\\App\\Models\\User::factory()->create(['name' => 'Super Admin', 'email' => 'admin@admin.com', 'password' => bcrypt('password')]);"

WORKDIR /app/html
RUN rm -rf /var/cache/apk/* && \
rm -rf /root/.cache && rm -rf /root/.local && rm -rf /root/.config

ENTRYPOINT ["tail"]
CMD ["-f","/dev/null"]

