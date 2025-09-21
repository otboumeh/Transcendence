#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Default environment
ENV=${1:-development}

# Base directory
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."

# Function to check if a file exists
check_file() {
    if [ ! -f "$1" ]; then
        echo -e "${RED}Error: File $1 not found${NC}"
        exit 1
    fi
}

# Function to load environment files
load_env() {
    local env_file="$1"
    check_file "$env_file"
    echo -e "${GREEN}Loading $env_file...${NC}"
    export $(cat "$env_file" | grep -v '^#' | xargs)
}

# Main script
echo -e "${YELLOW}Initializing Transcendence environment for: $ENV${NC}"

# Check required files
check_file "$BASE_DIR/.env"
check_file "$BASE_DIR/.env.$ENV"
check_file "$BASE_DIR/.env.secrets"

# Load environment files in order
load_env "$BASE_DIR/.env"
load_env "$BASE_DIR/.env.$ENV"
load_env "$BASE_DIR/.env.secrets"

# Export APP_ENV for docker-compose
export APP_ENV=$ENV

# Generate SSL certificates if they don't exist and we're in development
if [ "$ENV" = "development" ] && [ ! -f "$BASE_DIR/scripts/certs/certificate.crt" ]; then
    echo -e "${YELLOW}Generating development SSL certificates...${NC}"
    cd "$BASE_DIR/scripts" && ./make-certs.sh
fi

# Start docker-compose with the specified environment
echo -e "${GREEN}Starting services for $ENV environment...${NC}"
cd "$BASE_DIR/compose" && docker-compose down && docker-compose up -d

echo -e "${GREEN}Environment initialization complete!${NC}"

# Display service access information
echo -e "\n${YELLOW}Service Access Information:${NC}"
echo -e "Frontend: http://localhost:${FRONTEND_PORT:-3000}"
echo -e "Backend API: http://localhost:${BACKEND_PORT:-9000}"
echo -e "WebSocket: ws://localhost:${WS_PORT:-8080}"
echo -e "Grafana: http://localhost:${GRAFANA_PORT:-3000}"
echo -e "Prometheus: http://localhost:${PROMETHEUS_PORT:-9090}\n"