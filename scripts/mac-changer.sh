#!/bin/bash

# TraceProtocol - MAC Address Randomizer
# Randomizes MAC address on specified network interface

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# File to store original MAC
MAC_BACKUP_FILE="/var/lib/traceprotocol/original_mac.txt"
INTERFACE_FILE="/var/lib/traceprotocol/interface.txt"

# Create directory if it doesn't exist
sudo mkdir -p /var/lib/traceprotocol
sudo chmod 755 /var/lib/traceprotocol

# Get the active network interface
get_active_interface() {
    # Get default route interface
    INTERFACE=$(ip route | grep default | awk '{print $5}' | head -1)
    
    if [ -z "$INTERFACE" ]; then
        # Fallback: get first non-loopback interface
        INTERFACE=$(ip link show | grep -v "lo:" | grep "state UP" | awk -F: '{print $2}' | tr -d ' ' | head -1)
    fi
    
    echo "$INTERFACE"
}

# Get original MAC address
get_original_mac() {
    local interface=$1
    
    # Check if we have saved original MAC
    if [ -f "$MAC_BACKUP_FILE" ]; then
        cat "$MAC_BACKUP_FILE"
    else
        # Get current MAC and save it as original
        local mac=$(ip link show "$interface" | grep "link/ether" | awk '{print $2}')
        echo "$mac" | sudo tee "$MAC_BACKUP_FILE" > /dev/null
        echo "$mac"
    fi
}

# Get current MAC address
get_current_mac() {
    local interface=$1
    ip link show "$interface" | grep "link/ether" | awk '{print $2}'
}

# Randomize MAC address
randomize_mac() {
    local interface=$1
    
    echo -e "${BLUE}Randomizing MAC address on $interface...${NC}"
    
    # Bring interface down
    sudo ip link set dev "$interface" down
    
    # Change MAC address
    sudo macchanger -r "$interface" > /dev/null 2>&1
    
    # Bring interface up
    sudo ip link set dev "$interface" up
    
    echo -e "${GREEN}✓ MAC address randomized!${NC}"
}

# Restore original MAC
restore_mac() {
    local interface=$1
    local original_mac=$2
    
    echo -e "${BLUE}Restoring original MAC address on $interface...${NC}"
    
    # Bring interface down
    sudo ip link set dev "$interface" down
    
    # Restore MAC
    sudo macchanger -m "$original_mac" "$interface" > /dev/null 2>&1
    
    # Bring interface up
    sudo ip link set dev "$interface" up
    
    echo -e "${GREEN}✓ Original MAC address restored!${NC}"
}

# Main execution
main() {
    INTERFACE=$(get_active_interface)
    
    if [ -z "$INTERFACE" ]; then
        echo -e "${RED}Error: Could not detect network interface${NC}"
        exit 1
    fi
    
    # Save interface name
    echo "$INTERFACE" | sudo tee "$INTERFACE_FILE" > /dev/null
    
    ORIGINAL_MAC=$(get_original_mac "$INTERFACE")
    CURRENT_MAC=$(get_current_mac "$INTERFACE")
    
    echo ""
    echo -e "${CYAN}TraceProtocol MAC Address Manager${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo -e "${BLUE}Interface:${NC}     $INTERFACE"
    echo -e "${BLUE}Original MAC:${NC}  $ORIGINAL_MAC"
    echo -e "${BLUE}Current MAC:${NC}   $CURRENT_MAC"
    echo ""
    
    if [ "$1" = "randomize" ] || [ "$1" = "random" ]; then
        randomize_mac "$INTERFACE"
        NEW_MAC=$(get_current_mac "$INTERFACE")
        echo ""
        echo -e "${GREEN}New MAC:${NC}       $NEW_MAC"
        echo ""
    elif [ "$1" = "restore" ]; then
        restore_mac "$INTERFACE" "$ORIGINAL_MAC"
        NEW_MAC=$(get_current_mac "$INTERFACE")
        echo ""
        echo -e "${GREEN}Current MAC:${NC}   $NEW_MAC"
        echo ""
    else
        echo "Usage:"
        echo "  $0 randomize  - Randomize MAC address"
        echo "  $0 restore    - Restore original MAC address"
        echo ""
    fi
}

main "$@"

