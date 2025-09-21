#!/bin/bash

# Colores para la salida
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Directorio para los certificados
CERT_DIR="/workspaces/Transcendence/scripts/certs"

# Verifica si certbot está instalado
check_certbot() {
    if ! command -v certbot &> /dev/null; then
        echo -e "${YELLOW}Instalando certbot...${NC}"
        sudo apt-get update
        sudo apt-get install -y certbot
    fi
}

# Genera el certificado usando el DNS challenge de Cloudflare
generate_cert() {
    local domain="$1"
    local email="$2"

    echo -e "${YELLOW}Generando certificado para $domain...${NC}"
    
    # Crear directorio si no existe
    mkdir -p "$CERT_DIR"
    
    # Generar el certificado usando el DNS challenge de Cloudflare
    sudo certbot certonly \
        --dns-cloudflare \
        --dns-cloudflare-credentials /root/.secrets/cloudflare.ini \
        -d "$domain" \
        -d "*.$domain" \
        --email "$email" \
        --agree-tos \
        --non-interactive \
        --preferred-challenges dns-01
    
    # Copiar los certificados al directorio del proyecto
    sudo cp /etc/letsencrypt/live/$domain/fullchain.pem "$CERT_DIR/"
    sudo cp /etc/letsencrypt/live/$domain/privkey.pem "$CERT_DIR/"
    
    # Generar el archivo dhparam.pem si no existe
    if [ ! -f "$CERT_DIR/dhparam.pem" ]; then
        echo -e "${YELLOW}Generando parámetros DH...${NC}"
        openssl dhparam -out "$CERT_DIR/dhparam.pem" 2048
    fi
    
    # Ajustar permisos
    sudo chown -R $(whoami):$(whoami) "$CERT_DIR"
    chmod 600 "$CERT_DIR"/*
}

# Función principal
main() {
    local domain="$1"
    local email="$2"

    if [ -z "$domain" ] || [ -z "$email" ]; then
        echo -e "${RED}Error: Debes especificar un dominio y un email${NC}"
        echo "Uso: $0 <domain> <email>"
        exit 1
    fi

    # Verificar instalación de certbot
    check_certbot

    # Generar certificado
    generate_cert "$domain" "$email"

    echo -e "${GREEN}¡Certificados generados con éxito!${NC}"
}

# Si el script se ejecuta directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi