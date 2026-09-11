#!/bin/sh
set -eu

cd /var/www/html

mkdir -p \
    storage/app/public \
    storage/framework/cache/data \
    storage/framework/sessions \
    storage/framework/views \
    storage/logs \
    bootstrap/cache

rm -rf public/storage
ln -s ../storage/app/public public/storage
chown -R www-data:www-data storage bootstrap/cache

php artisan package:discover --ansi
php artisan config:clear
php artisan view:cache

exec "$@"

