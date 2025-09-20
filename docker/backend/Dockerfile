# syntax=docker/dockerfile:1
FROM php:8.2-fpm-alpine
RUN docker-php-ext-install pdo pdo_mysql
WORKDIR /var/www/html
COPY . .
EXPOSE 9000
CMD ["php-fpm", "-F"]
