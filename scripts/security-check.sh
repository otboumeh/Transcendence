#!/bin/bash

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🔒 Iniciando verificación de seguridad y accesibilidad...${NC}\n"

# Función para verificar endpoint
check_endpoint() {
    local name=$1
    local url=$2
    local method=${3:-GET}
    local expected_code=${4:-200}
    
    echo -n "Verificando $name... "
    
    response=$(curl -s -o /dev/null -w "%{http_code}" -X $method -k $url)
    
    if [ "$response" -eq "$expected_code" ]; then
        echo -e "${GREEN}✓ OK${NC} (HTTP $response)"
    else
        echo -e "${RED}✗ ERROR${NC} (HTTP $response, esperado $expected_code)"
    fi
}

# Verificar redirección HTTP a HTTPS
echo -e "\n${YELLOW}1. Verificando redirección HTTP a HTTPS${NC}"
check_endpoint "HTTP→HTTPS" "http://localhost" "GET" "301"

# Verificar HTTPS
echo -e "\n${YELLOW}2. Verificando HTTPS${NC}"
check_endpoint "HTTPS" "https://localhost" "GET" "200"

# Verificar API endpoints
echo -e "\n${YELLOW}3. Verificando endpoints de API${NC}"
check_endpoint "Health Check" "https://localhost/api/health" "GET" "200"
check_endpoint "API Users" "https://localhost/api/users.php" "GET" "401"
check_endpoint "API Auth" "https://localhost/api/auth/login.php" "POST" "400"

# Verificar WebSocket
echo -e "\n${YELLOW}4. Verificando WebSocket${NC}"
if command -v wscat &> /dev/null; then
    echo -n "Probando conexión WebSocket... "
    wscat -c wss://localhost/ws -n 1 &>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ OK${NC}"
    else
        echo -e "${RED}✗ ERROR${NC}"
    fi
else
    echo -e "${YELLOW}⚠ wscat no instalado, saltando prueba WebSocket${NC}"
fi

# Verificar servicios de monitoreo
echo -e "\n${YELLOW}5. Verificando servicios de monitoreo${NC}"
check_endpoint "Prometheus" "https://localhost/prometheus/" "GET" "401"
check_endpoint "Grafana" "https://localhost/grafana/" "GET" "302"

# Verificar Rate Limiting
echo -e "\n${YELLOW}6. Verificando Rate Limiting${NC}"
echo -n "Realizando 10 requests rápidas... "
success=0
for i in {1..10}; do
    response=$(curl -s -o /dev/null -w "%{http_code}" -k https://localhost/api/health)
    if [ "$response" -eq 429 ]; then
        echo -e "${GREEN}✓ Rate limit detectado${NC}"
        break
    fi
    ((success++))
done
if [ "$success" -eq 10 ]; then
    echo -e "${RED}✗ Rate limiting no detectado${NC}"
fi

# Verificar headers de seguridad
echo -e "\n${YELLOW}7. Verificando headers de seguridad${NC}"
headers=$(curl -s -I -k https://localhost)

check_header() {
    local header=$1
    local value=$2
    if echo "$headers" | grep -q "$header: $value"; then
        echo -e "$header: ${GREEN}✓ OK${NC}"
    else
        echo -e "$header: ${RED}✗ No encontrado o incorrecto${NC}"
    fi
}

check_header "Strict-Transport-Security" "max-age=31536000"
check_header "X-Frame-Options" "SAMEORIGIN"
check_header "X-Content-Type-Options" "nosniff"
check_header "X-XSS-Protection" "1; mode=block"

# Resumen final
echo -e "\n${YELLOW}Resumen de la verificación:${NC}"
echo "- Asegúrate de que todas las credenciales en .env sean seguras"
echo "- Verifica que los certificados SSL estén actualizados"
echo "- Comprueba los logs de acceso en /logs/nginx/"
echo "- Revisa las métricas en Grafana para detectar anomalías"