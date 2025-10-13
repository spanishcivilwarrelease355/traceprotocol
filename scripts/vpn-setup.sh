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
    echo "  sudo ./privacy-manager.sh install"
    exit 1
fi

echo -e "${YELLOW}This script will help you configure ProtonVPN.${NC}"
echo ""

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
    
    if protonvpn-cli c -f; then
        sleep 3
        
        # Verify connection
        if protonvpn-cli status 2>/dev/null | grep -qi "connected"; then
            echo ""
            echo -e "${GREEN}✓ VPN connected successfully!${NC}"
            echo ""
            
            # Show status
            echo -e "${CYAN}Current VPN Status:${NC}"
            protonvpn-cli status
            echo ""
            
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
        else
            echo ""
            echo -e "${RED}✗ VPN connection failed. Please check your connection.${NC}"
        fi
    else
        echo ""
        echo -e "${RED}✗ Failed to connect to VPN.${NC}"
        echo "You can try again with: protonvpn-cli c -f"
    fi
else
    echo ""
    echo -e "${BLUE}VPN connection skipped.${NC}"
    echo "You can connect later with: protonvpn-cli c -f"
fi

echo ""
echo -e "${CYAN}════════════════════════════════════════${NC}"
echo -e "${GREEN}ProtonVPN setup completed!${NC}"
echo -e "${CYAN}════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Quick commands:${NC}"
echo "  • Connect VPN:    protonvpn-cli c -f"
echo "  • Disconnect:     protonvpn-cli d"
echo "  • Status:         protonvpn-cli status"
echo "  • Kill switch on: protonvpn-cli ks --on"
echo "  • Kill switch off: protonvpn-cli ks --off"
echo ""

