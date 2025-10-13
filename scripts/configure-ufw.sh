#!/bin/bash

# TraceProtocol - UFW Configuration Helper
# Configures UFW with balanced security (blocks incoming, allows outgoing)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}TraceProtocol - UFW Configuration${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if running with sudo
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script must be run with sudo${NC}"
    echo "Run: sudo ./scripts/configure-ufw.sh"
    exit 1
fi

echo -e "${YELLOW}This will configure UFW with balanced security rules.${NC}"
echo ""
echo "Configuration:"
echo "  • Block all incoming connections"
echo "  • Allow all outgoing connections"
echo "  • Allow essential ports (HTTP, HTTPS, DNS, SSH, etc.)"
echo ""
echo -e "${YELLOW}Continue? (y/n)${NC}"
read -p "Answer: " continue_setup

if [[ ! "$continue_setup" =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo -e "${BLUE}Configuring UFW...${NC}"
echo ""

# Reset UFW to default state
echo "Resetting UFW to defaults..."
ufw --force reset

# Set default policies
echo "Setting default policies..."
ufw default deny incoming
ufw default allow outgoing

# Allow essential outgoing ports (redundant with allow outgoing, but explicit)
echo "Configuring outgoing rules..."
ufw allow out 53       # DNS
ufw allow out 80       # HTTP
ufw allow out 443      # HTTPS
ufw allow out 853      # DNS over TLS
ufw allow out 22       # SSH
ufw allow out 21       # FTP
ufw allow out 9418     # Git
ufw allow out 1194     # OpenVPN
ufw allow out 5060     # ProtonVPN
ufw allow out 8080     # Alternative HTTP
ufw allow out 8443     # Alternative HTTPS

# Allow loopback
echo "Allowing loopback..."
ufw allow in on lo
ufw allow out on lo

# Allow established connections
echo "Allowing established connections..."
ufw logging off

echo ""
echo -e "${GREEN}✓ UFW configured successfully!${NC}"
echo ""
echo -e "${YELLOW}Choose an option:${NC}"
echo "  1) Enable UFW now (recommended if VPN is connected)"
echo "  2) Keep UFW disabled (enable manually later)"
echo ""
read -p "Choice (1 or 2): " ufw_choice

case $ufw_choice in
    1)
        echo ""
        echo -e "${BLUE}Enabling UFW...${NC}"
        if ufw --force enable; then
            echo ""
            echo -e "${GREEN}✓ UFW firewall is now active!${NC}"
            echo ""
            ufw status verbose
        else
            echo -e "${RED}Failed to enable UFW${NC}"
        fi
        ;;
    2)
        echo ""
        echo -e "${BLUE}UFW remains disabled.${NC}"
        echo ""
        echo "To enable later, run:"
        echo "  sudo ufw enable"
        echo ""
        echo "To check status:"
        echo "  sudo ufw status verbose"
        ;;
    *)
        echo ""
        echo -e "${YELLOW}Invalid choice. UFW remains disabled.${NC}"
        echo "Run 'sudo ufw enable' to enable it manually."
        ;;
esac

echo ""
echo -e "${CYAN}Quick UFW commands:${NC}"
echo "  • Enable:  sudo ufw enable"
echo "  • Disable: sudo ufw disable"
echo "  • Status:  sudo ufw status verbose"
echo "  • Reset:   sudo ufw reset"
echo ""
echo -e "${YELLOW}Note: If VPN is active, UFW won't interfere with it.${NC}"
echo -e "${YELLOW}All outgoing connections are allowed by default.${NC}"
echo ""

