#!/usr/bin/env bash
set -e
mkdir -p nginx/certs
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
 -keyout nginx/certs/privkey.pem \
 -out nginx/certs/fullchain.pem \
 -subj "/C=ES/ST=NA/L=NA/O=ft/OU=dev/CN=localhost"
echo "✅ Certificados en nginx/certs/"
