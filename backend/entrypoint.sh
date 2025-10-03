#!/bin/sh

# Cambia la propiedad del directorio de la base de datos
chown -R www-data:www-data /var/www/html/database

# Ejecuta el comando principal del contenedor (se lo pasamos como argumento a este script con CMD)
exec "$@"