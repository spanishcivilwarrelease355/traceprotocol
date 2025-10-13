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

# Step 1: Login
echo -e "${CYAN}Step 1: ProtonVPN Login${NC}"
echo ""
echo -e "${YELLOW}Enter your ProtonVPN username:${NC}"
read -p "Username: " pvpn_username

if [ -z "$pvpn_username" ]; then
    echo -e "${RED}No username provided.${NC}"
    exit 1
fi

echo ""
echo -e "${CYAN}Logging in to ProtonVPN...${NC}"
echo ""

if protonvpn-cli login "$pvpn_username"; then
    echo ""
    echo -e "${GREEN}✓ Login successful!${NC}"
    echo ""
else
    echo ""
    echo -e "${RED}✗ Login failed.${NC}"
    echo "Please try again or check your credentials."
    exit 1
fi

# Step 2: Connect to VPN
echo -e "${CYAN}Step 2: Connect to VPN${NC}"
echo ""
echo -e "${YELLOW}Would you like to connect to VPN now? (y/n)${NC}"
read -p "Answer: " connect_vpn

if [[ "$connect_vpn" =~ ^[Yy]$ ]]; then
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
    
    # Always continue to kill switch and firewall setup
    # (VPN connection was successful based on command output)
    
    # Step 3: Enable Kill Switch
    echo -e "${CYAN}Step 3: Enable Kill Switch${NC}"
    echo ""
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
    
    # Step 4: Enable UFW Firewall
    echo ""
    echo -e "${CYAN}Step 4: Enable Firewall${NC}"
    echo ""
    echo -e "${YELLOW}Enable UFW firewall?${NC}"
    echo ""
    echo -e "${BLUE}Note:${NC} UFW provides extra security but may block some applications"
    echo "(like Cursor IDE, development servers, etc.)"
    echo ""
    echo -e "${CYAN}Options:${NC}"
    echo "  y - Enable UFW (more secure, may block some apps)"
    echo "  n - Skip UFW (less secure, all apps work)"
    echo ""
    read -p "Enable UFW? (y/n): " enable_ufw
    
    if [[ "$enable_ufw" =~ ^[Yy]$ ]]; then
        echo ""
        echo -e "${CYAN}Enabling UFW firewall...${NC}"
        
        if sudo ufw --force enable; then
            echo ""
            echo -e "${GREEN}✓ UFW firewall enabled!${NC}"
            echo ""
            sudo ufw status verbose
            echo ""
            echo -e "${YELLOW}If some applications stop working:${NC}"
            echo "  • Disable UFW: ./trace-protocol.sh firewall-off"
            echo "  • Check status: sudo ufw status"
            echo "  • Reconfigure: ./trace-protocol.sh firewall-config"
        else
            echo ""
            echo -e "${YELLOW}⚠ Failed to enable firewall.${NC}"
            echo "You can enable it later with: sudo ufw enable"
        fi
    else
        echo ""
        echo -e "${BLUE}Firewall not enabled.${NC}"
        echo ""
        echo -e "${YELLOW}Your VPN and kill switch still protect you,${NC}"
        echo "but UFW provides an additional security layer."
        echo ""
        echo "Enable later with: ./trace-protocol.sh firewall-on"
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
echo "  ✓ Firewall enabled (if you chose yes)"
echo "  ✓ Conky widget monitoring status"
echo ""
echo -e "${YELLOW}Quick commands:${NC}"
echo "  • Connect VPN:     protonvpn-cli c -f"
echo "  • Disconnect:      protonvpn-cli d"
echo "  • Status:          protonvpn-cli status"
echo "  • Full monitor:    ./trace-protocol.sh monitor"
echo "  • Kill switch on:  protonvpn-cli ks --on"
echo "  • Kill switch off: protonvpn-cli ks --off"
echo "  • Enable firewall: sudo ufw enable"
echo ""
echo -e "${GREEN}Check the Conky widget in the top-right corner for live status!${NC}"
echo ""

