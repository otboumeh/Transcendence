#!/bin/bash

# Colores para la salida
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color
YELLOW='\033[1;33m'

# Función para probar una URL
test_url() {
    local url=$1
    local description=$2
    echo -e "\n${YELLOW}Testing $description...${NC}"
    
    # Usar curl con timeout de 5 segundos y seguir redirecciones
    if curl -f -s -S -k --max-time 5 -L "$url" > /dev/null; then
        echo -e "${GREEN}✓ $url is accessible${NC}"
        return 0
    else
        echo -e "${RED}✗ $url is not accessible${NC}"
        return 1
    fi
}

# URLs a probar
echo "Starting URL validation..."

# Frontend
test_url "http://localhost/frontend/" "Frontend (HTTP)"
test_url "https://localhost/frontend/" "Frontend (HTTPS)"

# Backend API
test_url "http://localhost/api/health" "Backend API Health Check (HTTP)"
test_url "https://localhost/api/health" "Backend API Health Check (HTTPS)"

# Monitoring
test_url "http://localhost/prometheus/" "Prometheus"
test_url "http://localhost/grafana/" "Grafana"
test_url "http://localhost/cadvisor/" "cAdvisor"

# Nginx Status
test_url "http://localhost/status" "Nginx Status"

echo -e "\n${YELLOW}URL validation complete${NC}"
