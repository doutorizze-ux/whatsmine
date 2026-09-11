FROM node:22-alpine AS frontend

WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY resources ./resources
COPY public ./public
COPY vite.config.js tailwind.config.js postcss.config.js jsconfig.json ./
RUN npm run build

FROM php:8.3-fpm-bookworm AS runtime

ENV APP_HOME=/var/www/html \
    COMPOSER_ALLOW_SUPERUSER=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates curl git nginx supervisor unzip \
        libfreetype6-dev libicu-dev libjpeg62-turbo-dev libonig-dev \
        libpng-dev libwebp-dev libxml2-dev libzip-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j"$(nproc)" \
        bcmath exif gd intl mbstring opcache pcntl pdo_mysql sockets zip \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && rm -rf /var/lib/apt/lists/* /tmp/pear

COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

WORKDIR ${APP_HOME}
COPY composer.json composer.lock ./
RUN mkdir -p app/Modules/Integrations/database/seeders \
    && composer install --no-dev --no-interaction --no-progress --prefer-dist --no-scripts \
    && composer clear-cache

COPY . .
COPY --from=frontend /app/public/build ./public/build
COPY docker/production/nginx.conf /etc/nginx/nginx.conf
COPY docker/production/supervisord.conf /etc/supervisor/conf.d/whatsmine.conf
COPY docker/production/php.ini /usr/local/etc/php/conf.d/99-whatsmine.ini
COPY docker/production/entrypoint.sh /usr/local/bin/whatsmine-entrypoint

RUN chmod +x /usr/local/bin/whatsmine-entrypoint \
    && mkdir -p storage/app/public storage/framework/cache/data storage/framework/sessions storage/framework/views storage/logs bootstrap/cache resources/js/locales \
    && chown -R www-data:www-data ${APP_HOME} \
    && chmod -R 775 storage bootstrap/cache resources/js/locales \
    && composer dump-autoload --no-dev --classmap-authoritative --no-interaction --no-scripts

EXPOSE 80
ENTRYPOINT ["/usr/local/bin/whatsmine-entrypoint"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
