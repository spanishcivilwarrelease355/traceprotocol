#!/bin/bash

# TraceProtocol - ProtonVPN Login Script
# This script handles ProtonVPN authentication with smart login detection

# Colors
RED='\033[38;5;196m'
GREEN='\033[38;5;46m'
YELLOW='\033[38;5;226m'  
WHITE='\033[1;37m'
BLUE='\033[38;5;27m'       
CYAN='\033[38;5;51m'       
MAGENTA='\033[38;5;201m'   
NC='\033[0m'


# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo -e "${RED}ERROR: Do NOT run vpn-login with sudo!${NC}"
    echo -e "${YELLOW}ProtonVPN should be run as your normal user.${NC}"
    echo ""
    echo -e "${CYAN}Run it as your normal user:${NC}"
    echo "  ./trace-protocol.sh vpn-login"
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

echo -e "${BLUE}Checking login status...${NC}"
echo ""

# Reliable method: Check ProtonVPN cache directory
LOGIN_DETECTED=false

# Check if cache directory exists and has files other than logs folder
if [ -d ~/.cache/protonvpn ]; then
    # Count files/folders that are NOT named "logs"
    NON_LOG_COUNT=$(ls ~/.cache/protonvpn 2>/dev/null | grep -v "^logs$" | wc -l)
    if [ "$NON_LOG_COUNT" -gt 0 ]; then
        LOGIN_DETECTED=true
    fi
fi

if [ "$LOGIN_DETECTED" = true ]; then
    echo -e "${GREEN}✓ Already logged in to ProtonVPN${NC}"
    echo ""
    echo -e "${CYAN}Current login status:${NC}"
    echo -e "${GREEN}Session active and ready for VPN connections${NC}"
    echo ""
    echo -e "${CYAN}Available commands:${NC}"
    echo -e "${WHITE}  ./trace-protocol.sh vpn-connect    ${CYAN}# Connect to fastest server${NC}"
    echo -e "${WHITE}  ./trace-protocol.sh vpn-setup      ${CYAN}# Full VPN setup wizard${NC}"
    echo -e "${WHITE}  ./trace-protocol.sh vpn-status     ${CYAN}# Check connection status${NC}"
    echo -e "${WHITE}  ./trace-protocol.sh killswitch-on  ${CYAN}# Enable kill switch${NC}"
    echo ""
else
    echo -e "${YELLOW}Not logged in. Please enter your ProtonVPN credentials:${NC}"
    echo ""
    read -p "Enter your Proton VPN Username: " pvpn_username
    
    if [ -z "$pvpn_username" ]; then
        echo -e "${RED}No username provided.${NC}"
        exit 1
    fi
    
    echo ""

    
    # Capture the login output to check for "already logged in" message
    LOGIN_OUTPUT=$(protonvpn-cli login "$pvpn_username" 2>&1)
    LOGIN_RESULT=$?
    echo -e "${CYAN}Logging in to ProtonVPN...${NC}"
    echo ""
    if [ $LOGIN_RESULT -eq 0 ] || echo "$LOGIN_OUTPUT" | grep -qi "already.*logged.*in\|session.*exists"; then
        echo ""
        echo -e "✓ Login successful!"
        echo ""
        echo -e "${CYAN}You can now connect to VPN using:${NC}"
        echo -e "${WHITE}  ./trace-protocol.sh vpn-connect    ${CYAN}# Connect to fastest server${NC}"
        echo -e "${WHITE}  ./trace-protocol.sh vpn-status     ${CYAN}# Check connection status${NC}"
        echo ""

    else
        echo ""
        echo "$LOGIN_OUTPUT"
        echo ""
        echo -e "${RED}✗ Login failed. Please check your credentials.${NC}"
        echo ""
        echo -e "${YELLOW}Common issues:${NC}"
        echo -e "${WHITE}• Incorrect username or password${NC}"
        echo -e "${WHITE}• Account not active or expired${NC}"
        echo -e "${WHITE}• Network connectivity issues${NC}"
        echo ""
        echo -e "${CYAN}Try again with:${NC}"
        echo -e "${WHITE}  ./trace-protocol.sh vpn-login${NC}"
        echo ""
        exit 1
    fi
fi
