FROM nginx:alpine

# Copiar la configuración principal de nginx
COPY nginx.conf /etc/nginx/nginx.conf
# Copiar los virtual hosts
COPY conf.d /etc/nginx/conf.d

# Crear directorio de logs si no existe
RUN mkdir -p /var/log/nginx

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
