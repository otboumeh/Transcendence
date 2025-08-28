FROM php:8.2-cli

WORKDIR /app

# Copiar únicamente composer.json primero, para aprovechar el cache de capas si instalas dependencias después
COPY composer.json /app/

# Copiar el código del WebSocket
COPY src /app/src

# Exponer el puerto WebSocket
EXPOSE 8080

# Ejecutar el servidor WebSocket
CMD ["php", "src/ws_server.php"]
