#!/bin/sh
set -eu

cd /var/www/html

mkdir -p \
    storage/app/public \
    storage/framework/cache/data \
    storage/framework/sessions \
    storage/framework/views \
    storage/logs \
    bootstrap/cache \
    resources/js/locales

rm -rf public/storage
ln -s ../storage/app/public public/storage
touch .env || true
chown -R www-data:www-data storage bootstrap/cache resources/js/locales .env
chmod -R 775 storage bootstrap/cache resources/js/locales

php artisan package:discover --ansi
php artisan config:clear
php artisan view:cache

exec "$@"

