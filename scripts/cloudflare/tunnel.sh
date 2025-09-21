#!/bin/bash

# Colores para la salida
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Verifica si cloudflared está instalado
check_cloudflared() {
    if ! command -v cloudflared &> /dev/null; then
        echo -e "${YELLOW}Instalando cloudflared...${NC}"
        # Descarga el paquete más reciente de Cloudflare
        curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
        sudo dpkg -i cloudflared.deb
        rm cloudflared.deb
    fi
}

# Crea un nuevo túnel
create_tunnel() {
    local tunnel_name="$1"
    local domain="$2"

    echo -e "${YELLOW}Creando túnel '$tunnel_name' para $domain...${NC}"
    
    # Crear el túnel
    cloudflared tunnel create "$tunnel_name"
    
    # Obtener el ID del túnel
    TUNNEL_ID=$(cloudflared tunnel list | grep "$tunnel_name" | awk '{print $1}')
    
    # Crear la configuración del túnel
    cat > config.yml << EOF
tunnel: ${TUNNEL_ID}
credentials-file: /root/.cloudflared/${TUNNEL_ID}.json
ingress:
  - hostname: ${domain}
    service: http://localhost:80
  - hostname: "*.${domain}"
    service: http://localhost:80
  - service: http_status:404
EOF

    # Crear el DNS para el túnel
    echo -e "${YELLOW}Configurando DNS para $domain...${NC}"
    cloudflared tunnel route dns "$tunnel_name" "$domain"
    cloudflared tunnel route dns "$tunnel_name" "*.$domain"
}

# Inicia el túnel
start_tunnel() {
    local tunnel_name="$1"
    echo -e "${YELLOW}Iniciando túnel '$tunnel_name'...${NC}"
    cloudflared tunnel run "$tunnel_name"
}

# Función principal
main() {
    local tunnel_name="${1:-transcendence-tunnel}"
    local domain="${2}"

    if [ -z "$domain" ]; then
        echo -e "${RED}Error: Debes especificar un dominio${NC}"
        echo "Uso: $0 [tunnel_name] <domain>"
        exit 1
    fi

    # Verificar instalación de cloudflared
    check_cloudflared

    # Crear y configurar el túnel
    create_tunnel "$tunnel_name" "$domain"

    # Iniciar el túnel
    start_tunnel "$tunnel_name"
}

# Si el script se ejecuta directamente
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi