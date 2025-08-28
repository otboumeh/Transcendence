FROM php:8.2-fpm

# Copiar configuración de PHP
COPY php.ini /usr/local/etc/php/

# Copiar el código de la aplicación
COPY src /var/www/html

# Ajustar permisos
RUN chown -R www-data:www-data /var/www/html

# Configurar la ruta de estado de PHP‑FPM para el exporter
# RUN sed -i 's/^;*pm\\.status_path.*/pm.status_path = \\/status/' /usr/local/etc/php-fpm.d/www.conf

EXPOSE 9000

CMD ["php-fpm"]
