#!/bin/bash

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Directorio de configuración
CONFIG_DIR="/workspaces/Transcendence/config"
mkdir -p "$CONFIG_DIR"

# Generar una contraseña aleatoria segura
generate_password() {
    openssl rand -base64 32
}

# Generar un token JWT seguro
generate_jwt_secret() {
    openssl rand -hex 64
}

echo -e "${YELLOW}Generando credenciales seguras...${NC}"

# Generar .env desde .env.example con valores seguros
if [ -f .env.example ]; then
    echo -e "${YELLOW}Generando .env desde .env.example...${NC}"
    cp .env.example .env
    
    # Reemplazar valores sensibles con valores seguros
    sed -i "s/change_this_to_a_secure_secret_key/$(generate_jwt_secret)/" .env
    sed -i "s/secret_password_change_me/$(generate_password)/" .env
    sed -i "s/change_this_to_secure_api_key/$(generate_password)/" .env
    sed -i "s/change_this_to_secure_csrf_token/$(generate_jwt_secret)/" .env
    sed -i "s/change_this_password/$(generate_password)/" .env
    
    echo -e "${GREEN}✓ Archivo .env generado con credenciales seguras${NC}"
fi

# Generar archivo de contraseñas para Nginx/Prometheus
echo -e "${YELLOW}Generando credenciales para Prometheus...${NC}"
PROMETHEUS_PASSWORD=$(generate_password)
echo "admin:$(openssl passwd -apr1 $PROMETHEUS_PASSWORD)" > nginx/.htpasswd
echo -e "${GREEN}✓ Credenciales de Prometheus generadas${NC}"
echo "Usuario: admin"
echo "Contraseña: $PROMETHEUS_PASSWORD"

# Guardar credenciales en un archivo seguro
echo -e "${YELLOW}Guardando credenciales en archivo seguro...${NC}"
CREDENTIALS_FILE="$CONFIG_DIR/credentials.txt"
echo "# Credenciales generadas $(date)" > "$CREDENTIALS_FILE"
echo "# ¡MANTENER ESTE ARCHIVO SEGURO!" >> "$CREDENTIALS_FILE"
echo "Prometheus:" >> "$CREDENTIALS_FILE"
echo "  Usuario: admin" >> "$CREDENTIALS_FILE"
echo "  Contraseña: $PROMETHEUS_PASSWORD" >> "$CREDENTIALS_FILE"

echo -e "${GREEN}✓ Credenciales guardadas en $CREDENTIALS_FILE${NC}"
echo -e "${YELLOW}IMPORTANTE: Guarda una copia segura de las credenciales y elimina $CREDENTIALS_FILE${NC}"