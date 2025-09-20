# syntax=docker/dockerfile:1
FROM nginx:1.27-alpine
# Borra default y copia tu config
RUN rm -rf /etc/nginx/conf.d/*
COPY nginx.conf /etc/nginx/nginx.conf
COPY conf.d/ /etc/nginx/conf.d/
EXPOSE 80 443
