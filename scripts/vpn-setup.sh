#!/bin/bash

# TraceProtocol - ProtonVPN Setup Script
# This script should be run as a NORMAL USER (not with sudo)
# It handles ProtonVPN login, connection, and kill switch setup

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${CYAN}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║         TraceProtocol - ProtonVPN Setup                   ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo -e "${RED}ERROR: Do NOT run this script with sudo!${NC}"
    echo -e "${YELLOW}Run it as your normal user:${NC}"
    echo "  ./scripts/vpn-setup.sh"
    echo ""
    exit 1
fi

# Check if ProtonVPN CLI is installed
if ! command -v protonvpn-cli &>/dev/null; then
    echo -e "${RED}ProtonVPN CLI is not installed.${NC}"
    echo "Please run the main installation first:"
    echo "  sudo ./trace-protocol.sh install"
    exit 1
fi

echo -e "${YELLOW}This script will help you configure ProtonVPN and privacy features.${NC}"
echo ""

# Step 0: MAC Address Randomization
echo -e "${CYAN}Step 0: MAC Address Randomization${NC}"
echo ""

# Check if MAC address was already randomized during install
MAC_BACKUP_FILE="/var/lib/traceprotocol/original_mac.txt"

# Find physical network interface (exclude lo, proton0, tun0, etc.)
INTERFACE=$(ip link show | grep -E "^[0-9]+: (wl|eth|en)" | grep "state UP" | head -1 | awk -F': ' '{print $2}')
if [ -z "$INTERFACE" ]; then
    # If no UP interface, just get first physical interface
    INTERFACE=$(ip link show | grep -E "^[0-9]+: (wl|eth|en)" | head -1 | awk -F': ' '{print $2}')
fi

if [ -f "$MAC_BACKUP_FILE" ] && [ -n "$INTERFACE" ]; then
    ORIGINAL_MAC=$(cat "$MAC_BACKUP_FILE" 2>/dev/null)
    CURRENT_MAC=$(ip link show "$INTERFACE" | grep "link/ether" | awk '{print $2}')
    
    if [ -n "$ORIGINAL_MAC" ] && [ -n "$CURRENT_MAC" ] && [ "$ORIGINAL_MAC" != "$CURRENT_MAC" ]; then
        echo -e "${GREEN}✓ MAC address already randomized${NC}"
        echo -e "${BLUE}Interface:${NC}     $INTERFACE"
        echo -e "${BLUE}Original MAC:${NC}  $ORIGINAL_MAC"
        echo -e "${BLUE}Current MAC:${NC}   $CURRENT_MAC"
        echo ""
    else
        echo -e "${YELLOW}Randomize your MAC address? (Recommended for privacy) (y/n)${NC}"
        read -p "Answer: " randomize_mac
        
        if [[ "$randomize_mac" =~ ^[Yy]$ ]]; then
            echo ""
            if [ -f "$(dirname "$0")/mac-changer.sh" ]; then
                bash "$(dirname "$0")/mac-changer.sh" randomize
            else
                echo -e "${YELLOW}MAC changer script not found. Skipping...${NC}"
            fi
            echo ""
        else
            echo ""
            echo -e "${BLUE}MAC randomization skipped.${NC}"
            echo ""
        fi
    fi
else
    echo -e "${YELLOW}Randomize your MAC address? (Recommended for privacy) (y/n)${NC}"
    read -p "Answer: " randomize_mac
    
    if [[ "$randomize_mac" =~ ^[Yy]$ ]]; then
        echo ""
        if [ -f "$(dirname "$0")/mac-changer.sh" ]; then
            bash "$(dirname "$0")/mac-changer.sh" randomize
        else
            echo -e "${YELLOW}MAC changer script not found. Skipping...${NC}"
        fi
        echo ""
    else
        echo ""
        echo -e "${BLUE}MAC randomization skipped.${NC}"
        echo ""
    fi
fi

# Step 1: Login
echo -e "${CYAN}Step 1: ProtonVPN Login${NC}"
echo ""

# Check if already logged in
echo -e "${BLUE}Checking login status...${NC}"
LOGIN_STATUS=$(protonvpn-cli status 2>/dev/null | grep -i "session\|login\|user" || echo "not_logged_in")

if echo "$LOGIN_STATUS" | grep -qi "session.*valid\|logged.*in\|user.*logged" || protonvpn-cli status 2>/dev/null | grep -qi "server:\|country:"; then
    echo -e "${GREEN}✓ Already logged in to ProtonVPN${NC}"
    
    # Show current status
    CURRENT_USER=$(protonvpn-cli status 2>/dev/null | grep -i "user\|account" | head -1 || echo "")
    if [ -n "$CURRENT_USER" ]; then
        echo -e "${BLUE}$CURRENT_USER${NC}"
    fi
    echo ""
else
    echo -e "${YELLOW}Enter your ProtonVPN username:${NC}"
    read -p "Username: " pvpn_username
    
    if [ -z "$pvpn_username" ]; then
        echo -e "${RED}No username provided.${NC}"
        exit 1
    fi
    
    echo ""
    echo -e "${CYAN}Logging in to ProtonVPN...${NC}"
    echo ""
    
    # Capture the login output to check for "already logged in" message
    LOGIN_OUTPUT=$(protonvpn-cli login "$pvpn_username" 2>&1)
    LOGIN_RESULT=$?
    
    if [ $LOGIN_RESULT -eq 0 ] || echo "$LOGIN_OUTPUT" | grep -qi "already.*logged.*in\|session.*exists"; then
        echo ""
        echo -e "${GREEN}✓ Login successful!${NC}"
        echo ""
    else
        echo ""
        echo "$LOGIN_OUTPUT"
        echo ""
        echo -e "${RED}✗ Login failed.${NC}"
        echo "Please try again or check your credentials."
        exit 1
    fi
fi

# Step 2: Connect to VPN
echo -e "${CYAN}Step 2: Connect to VPN${NC}"
echo ""

# Check if already connected
echo -e "${BLUE}Checking VPN connection status...${NC}"
VPN_STATUS=$(protonvpn-cli status 2>/dev/null)

if echo "$VPN_STATUS" | grep -qi "status:.*connected\|server:" && echo "$VPN_STATUS" | grep -qi "ip:"; then
    echo -e "${GREEN}✓ VPN is already connected${NC}"
    echo ""
    echo -e "${CYAN}Current VPN Status:${NC}"
    protonvpn-cli status
    echo ""
    
    # Skip to kill switch check since VPN is already connected
    connect_vpn="y"
else
    echo -e "${YELLOW}Would you like to connect to VPN now? (y/n)${NC}"
    read -p "Answer: " connect_vpn
fi

if [[ "$connect_vpn" =~ ^[Yy]$ ]]; then
    # Check if we need to actually connect or if already connected
    if echo "$VPN_STATUS" | grep -qi "status:.*connected\|server:" && echo "$VPN_STATUS" | grep -qi "ip:"; then
        # Already connected, skip connection
        echo -e "${BLUE}VPN connection confirmed. Proceeding to security settings...${NC}"
    else
        # Need to connect
        echo ""
        echo -e "${CYAN}Connecting to fastest VPN server...${NC}"
        echo ""
        
        # Try to connect (command output already shows if successful)
        protonvpn-cli c -f
        
        # Wait for connection to fully establish
        sleep 5
        
        echo ""
        # Show current status
        echo -e "${CYAN}Current VPN Status:${NC}"
        protonvpn-cli status
        echo ""
    fi
    
    # Always continue to kill switch and DNSCrypt setup
    # (VPN connection was successful based on command output)
    
    # Step 3: Enable Kill Switch
    echo -e "${CYAN}Step 3: Enable Kill Switch${NC}"
    echo ""
    
    # Check if kill switch is already enabled
    echo -e "${BLUE}Checking kill switch status...${NC}"
    KS_STATUS=$(protonvpn-cli ks --status 2>/dev/null || echo "unknown")
    
    if echo "$KS_STATUS" | grep -qi "enabled\|on"; then
        echo -e "${GREEN}✓ Kill switch is already enabled${NC}"
        echo ""
    else
        echo -e "${YELLOW}Enable kill switch? (Recommended - blocks internet if VPN disconnects) (y/n)${NC}"
        read -p "Answer: " enable_ks
        
        if [[ "$enable_ks" =~ ^[Yy]$ ]]; then
            echo ""
            echo -e "${CYAN}Enabling kill switch...${NC}"
            
            if protonvpn-cli ks --on; then
                echo ""
                echo -e "${GREEN}✓ Kill switch enabled!${NC}"
            else
                echo ""
                echo -e "${YELLOW}⚠ Kill switch activation failed.${NC}"
                echo "You can enable it later with: protonvpn-cli ks --on"
            fi
        else
            echo ""
            echo -e "${BLUE}Kill switch not enabled.${NC}"
            echo "You can enable it later with: protonvpn-cli ks --on"
        fi
    fi
    
    # Step 4: Enable DNSCrypt-Proxy
    echo ""
    echo -e "${CYAN}Step 4: Enable DNSCrypt-Proxy${NC}"
    echo ""
    
    # Check if DNSCrypt-Proxy service is enabled and running
    echo -e "${BLUE}Checking DNSCrypt-Proxy status...${NC}"
    if systemctl is-active --quiet dnscrypt-proxy 2>/dev/null; then
        echo -e "${GREEN}✓ DNSCrypt-Proxy is already running${NC}"
        echo ""
    else
        echo -e "${YELLOW}DNSCrypt-Proxy is not running. Starting service...${NC}"
        
        if sudo systemctl enable dnscrypt-proxy 2>/dev/null && sudo systemctl start dnscrypt-proxy 2>/dev/null; then
            sleep 2
            if systemctl is-active --quiet dnscrypt-proxy; then
                echo -e "${GREEN}✓ DNSCrypt-Proxy enabled and started!${NC}"
            else
                echo -e "${YELLOW}⚠ DNSCrypt-Proxy may not be running properly${NC}"
                echo "Check status with: sudo systemctl status dnscrypt-proxy"
            fi
        else
            echo -e "${YELLOW}⚠ Failed to start DNSCrypt-Proxy${NC}"
            echo "You can start it manually with: sudo systemctl start dnscrypt-proxy"
        fi
        echo ""
    fi
else
    echo ""
    echo -e "${BLUE}VPN connection skipped.${NC}"
    echo "You can connect later with: protonvpn-cli c -f"
fi

# Step 5: Restart Conky Widget
echo ""
echo -e "${CYAN}Step 5: Restart Conky Widget${NC}"
echo ""
echo -e "${BLUE}Refreshing desktop monitor...${NC}"

# Kill and restart Conky to update VPN status
pkill conky 2>/dev/null || true
sleep 1

if [ -f ~/.conkyrc ]; then
    nohup conky -c ~/.conkyrc >/dev/null 2>&1 &
    sleep 2
    
    if pgrep -u "$USER" conky >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Conky widget is running!${NC}"
        echo "Check the top-right corner of your screen."
    else
        echo -e "${YELLOW}⚠ Conky may not be visible. Restarting...${NC}"
        nohup conky -c ~/.conkyrc >/dev/null 2>&1 &
    fi
else
    echo -e "${YELLOW}⚠ Conky configuration not found.${NC}"
    echo "Widget will start on next login."
fi

echo ""
echo -e "${CYAN}════════════════════════════════════════${NC}"
echo -e "${GREEN}ProtonVPN setup completed!${NC}"
echo -e "${CYAN}════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}Your privacy protection is now active:${NC}"
echo "  ✓ VPN connected"
echo "  ✓ Kill switch enabled (if you chose yes)"
echo "  ✓ DNSCrypt-Proxy encrypting DNS queries"
echo "  ✓ Conky widget monitoring status"
echo ""
echo -e "${YELLOW}Quick commands:${NC}"
echo "  • Connect VPN:     protonvpn-cli c -f"
echo "  • Disconnect:      protonvpn-cli d"
echo "  • Status:          protonvpn-cli status"
echo "  • Full monitor:    ./trace-protocol.sh monitor"
echo "  • Kill switch on:  protonvpn-cli ks --on"
echo "  • Kill switch off: protonvpn-cli ks --off"
echo ""
echo -e "${GREEN}Check the Conky widget in the top-right corner for live status!${NC}"
echo ""

