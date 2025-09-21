#!/bin/bash

# Colores para mensajes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir mensajes de estado
print_status() {
    echo -e "${YELLOW}[*] $1${NC}"
}

print_success() {
    echo -e "${GREEN}[✓] $1${NC}"
}

print_error() {
    echo -e "${RED}[✗] $1${NC}"
}

# Verificar requisitos del sistema
check_requirements() {
    print_status "Verificando requisitos del sistema..."
    
    # Verificar Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker no está instalado"
        exit 1
    fi
    
    # Verificar Docker Compose
    if ! command -v docker compose &> /dev/null; then
        print_error "Docker Compose no está instalado"
        exit 1
    fi
    
    print_success "Requisitos del sistema verificados"
}

# Configurar directorios necesarios
setup_directories() {
    print_status "Configurando directorios..."
    
    # Crear directorios necesarios si no existen
    mkdir -p backend/srcs/database
    mkdir -p scripts/certs
    mkdir -p logs/nginx
    
    print_success "Directorios configurados"
}

# Generar archivos de entorno si no existen
setup_env_files() {
    print_status "Configurando archivos de entorno..."
    
    # Verificar y crear .env si no existe
    if [ ! -f ".env" ]; then
        cp .env.example .env 2>/dev/null || touch .env
        print_success "Archivo .env creado"
    fi
    
    print_success "Archivos de entorno configurados"
}

# Inicializar la base de datos
init_database() {
    print_status "Inicializando base de datos..."
    
    if [ -f "backend/srcs/database/schema.sql" ]; then
        print_success "Esquema de base de datos encontrado"
    else
        print_error "No se encontró el esquema de base de datos"
        exit 1
    fi
}

# Función principal
main() {
    print_status "Iniciando configuración del proyecto Transcendence..."
    
    check_requirements
    setup_directories
    setup_env_files
    init_database
    
    # Ejecutar make init para completar la instalación
    print_status "Ejecutando make init..."
    make init
    
    print_success "¡Configuración completada!"
    print_status "Puedes iniciar el proyecto con: make up"
}

# Ejecutar la función principal
main