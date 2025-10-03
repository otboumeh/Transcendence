# syntax=docker/dockerfile:1
FROM php:8.2-fpm-alpine

# Instalar dependencias necesarias
RUN apk add --no-cache \
    git \
    zip \
    unzip \
    sqlite-dev

# Instalar extensiones PHP necesarias
RUN docker-php-ext-install pdo pdo_mysql pdo_sqlite

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configurar directorio de trabajo
WORKDIR /var/www/html

# copiamos entrypoint.sh, nos damos permisos de ejecución y lo ejecutamos
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Copiar archivos del proyecto
COPY composer.* ./

# Instalar dependencias con Composer
RUN composer install --no-scripts --no-autoloader

# Copiar el resto de los archivos
COPY . .

# Generar autoloader optimizado
RUN composer dump-autoload --optimize

EXPOSE 9000
CMD ["php-fpm", "-F"]
