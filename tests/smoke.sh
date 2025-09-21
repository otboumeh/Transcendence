#!/bin/bash
set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to check endpoint
check_endpoint() {
    local url=$1
    local name=$2
    local expected_status=${3:-200}
    
    echo -n "Testing $name... "
    status=$(curl -s -o /dev/null -w "%{http_code}" "$url")
    
    if [ "$status" -eq "$expected_status" ]; then
        echo -e "${GREEN}OK${NC}"
        return 0
    else
        echo -e "${RED}FAILED${NC} (got $status, expected $expected_status)"
        return 1
    fi
}

# Function to check WebSocket handshake
check_websocket() {
    local url=$1
    local name=$2
    
    echo -n "Testing $name WebSocket handshake... "
    upgrade_header=$(curl -si -N \
        -H "Connection: Upgrade" \
        -H "Upgrade: websocket" \
        -H "Sec-WebSocket-Key: SGVsbG8sIHdvcmxkIQ==" \
        -H "Sec-WebSocket-Version: 13" \
        "$url" | grep -i "Upgrade:")
    
    if [ $? -eq 0 ] && [[ $upgrade_header == *"websocket"* ]]; then
        echo -e "${GREEN}OK${NC}"
        return 0
    else
        echo -e "${RED}FAILED${NC}"
        return 1
    fi
}

# Main test suite
main() {
    local base_url=${1:-"http://localhost"}
    local failed=0
    
    # Test main SPA endpoint
    check_endpoint "$base_url/" "SPA root" || failed=1
    
    # Test static assets (CSS)
    check_endpoint "$base_url/dist/assets/index.css" "CSS assets" || failed=1
    
    # Test API health endpoint
    check_endpoint "$base_url/api/health" "API health" || failed=1
    
    # Test WebSocket endpoint
    check_websocket "$base_url/ws" "Game" || failed=1
    
    # Final result
    if [ $failed -eq 0 ]; then
        echo -e "\n${GREEN}SMOKE OK${NC}"
        exit 0
    else
        echo -e "\n${RED}SMOKE FAILED${NC}"
        exit 1
    fi
}

# Run tests
main "$@"