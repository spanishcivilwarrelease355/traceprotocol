#!/bin/bash

# TraceProtocol - MAC Address Randomizer
# Randomizes MAC address on specified network interface

# Colors
RED='\033[38;5;196m'
GREEN='\033[38;5;46m'
YELLOW='\033[38;5;226m'  
WHITE='\033[1;37m'
BLUE='\033[38;5;27m'       
CYAN='\033[38;5;51m'       
MAGENTA='\033[38;5;201m'   
NC='\033[0m'


# File to store original MAC
MAC_BACKUP_FILE="/var/lib/traceprotocol/original_mac.txt"
INTERFACE_FILE="/var/lib/traceprotocol/interface.txt"

# Create directory if it doesn't exist
sudo mkdir -p /var/lib/traceprotocol
sudo chmod 755 /var/lib/traceprotocol

# Get the active network interface (excluding VPN interfaces)
get_active_interface() {
    # First check if we have a saved interface from install
    if [ -f "$INTERFACE_FILE" ]; then
        local saved_interface=$(cat "$INTERFACE_FILE")
        # Verify the saved interface still exists and is not a VPN interface
        if ip link show "$saved_interface" >/dev/null 2>&1 && ! echo "$saved_interface" | grep -qE "^(tun|tap|proton|wg|vpn)"; then
            echo "$saved_interface"
            return
        fi
    fi
    
    # Get physical network interfaces (exclude VPN, loopback, docker, etc.)
    INTERFACE=$(ip link show | grep -E "^[0-9]+: (eth|wlan|wlp|enp|ens)" | grep "state UP" | head -1 | awk -F: '{print $2}' | tr -d ' ')
    
    # If no UP interface, get any physical interface
    if [ -z "$INTERFACE" ]; then
        INTERFACE=$(ip link show | grep -E "^[0-9]+: (eth|wlan|wlp|enp|ens)" | head -1 | awk -F: '{print $2}' | tr -d ' ')
    fi
    
    # Fallback: get first non-VPN, non-loopback interface
    if [ -z "$INTERFACE" ]; then
        INTERFACE=$(ip link show | grep -v "lo:" | grep -vE "(tun|tap|proton|wg|vpn|docker|br-)" | grep "state UP" | awk -F: '{print $2}' | tr -d ' ' | head -1)
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
        # Try to get permanent MAC address first (permaddr)
        local mac=$(ip link show "$interface" | grep "link/ether" | grep -o "permaddr [0-9a-f:]*" | awk '{print $2}')
        
        # If permaddr not available, use current MAC
        if [ -z "$mac" ]; then
            mac=$(ip link show "$interface" | grep "link/ether" | awk '{print $2}')
        fi
        
        # Save it
        if [ -n "$mac" ]; then
            echo "$mac" | sudo tee "$MAC_BACKUP_FILE" > /dev/null
        fi
        
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
    
    echo -e "${YELLOW}Randomizing MAC address on $interface...${NC}"
    
    # Bring interface down
    sudo ip link set dev "$interface" down
    
    # Change MAC address
    sudo macchanger -r "$interface" > /dev/null 2>&1
    
    # Bring interface up
    sudo ip link set dev "$interface" up
    
}

# Restore original MAC
restore_mac() {
    local interface=$1
    local original_mac=$2
    
    echo -e "${YELLOW}Restoring original MAC address on $interface...${NC}"
    
    # Bring interface down
    sudo ip link set dev "$interface" down
    
    # Restore MAC
    sudo macchanger -m "$original_mac" "$interface" > /dev/null 2>&1
    
    # Bring interface up
    sudo ip link set dev "$interface" up
    
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
    echo -e "${MAGENTA}Interface:${NC}     ${WHITE}$INTERFACE${NC}"
    echo -e "${MAGENTA}Original MAC:${NC}  ${WHITE}$ORIGINAL_MAC${NC}"
    echo -e "${MAGENTA}Current MAC:${NC}   ${WHITE}$CURRENT_MAC${NC}"
    echo ""
    
    if [ "$1" = "randomize" ] || [ "$1" = "random" ]; then
        randomize_mac "$INTERFACE"
        NEW_MAC=$(get_current_mac "$INTERFACE")
        echo ""
        echo -e "${MAGENTA}New MAC:${NC}       ${WHITE}$NEW_MAC${NC}"
        echo ""
    elif [ "$1" = "restore" ]; then
        restore_mac "$INTERFACE" "$ORIGINAL_MAC"
        NEW_MAC=$(get_current_mac "$INTERFACE")
        echo ""
        echo -e "${MAGENTA}Current MAC:${NC}   ${WHITE}$NEW_MAC${NC}"
        echo ""
    else
        echo "Usage:"
        echo "  $0 randomize  - Randomize MAC address"
        echo "  $0 restore    - Restore original MAC address"
        echo ""
    fi
}

main "$@"

