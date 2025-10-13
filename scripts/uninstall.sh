#!/bin/bash

# TraceProtocol Uninstall Script
# Removes all packages and configurations installed by TraceProtocol

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Progress tracking
TOTAL_STEPS=8
CURRENT_STEP=0

# Function to show progress bar
show_progress() {
    local step=$1
    local total=$2
    local description=$3
    
    local percent=$((step * 100 / total))
    local filled=$((step * 50 / total))
    local empty=$((50 - filled))
    
    # Create progress bar
    local bar=""
    for ((i=0; i<filled; i++)); do bar="${bar}█"; done
    for ((i=0; i<empty; i++)); do bar="${bar}░"; done
    
    echo ""
    echo -e "${RED}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║${NC} Step ${step}/${total} - ${percent}% Complete $(printf '%54s' '') ${RED}║${NC}"
    echo -e "${RED}║${NC} ${bar} ${RED}║${NC}"
    echo -e "${RED}║${NC} ${description}$(printf '%*s' $((62-${#description})) '') ${RED}║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════════╝${NC}"
}

show_banner() {
    clear
    echo -e "${RED}"
    cat << "EOF"

    ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░    
    ░           ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░        ░░░░░░░░░░░░░░░░░░░░░░░░   ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░   ░░░░░░░░░░
    ▒▒▒▒▒   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒   ▒▒▒▒   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒   ▒▒▒▒▒▒▒▒▒▒
    ▒▒▒▒▒   ▒▒▒▒▒  ▒    ▒▒▒▒   ▒▒▒▒▒▒▒▒    ▒▒▒▒   ▒▒▒▒▒▒▒▒▒▒▒   ▒▒▒▒   ▒  ▒    ▒▒▒▒   ▒▒▒▒▒    ▒  ▒▒▒▒   ▒▒▒▒▒▒▒▒    ▒▒▒▒   ▒▒▒▒▒   ▒▒▒▒▒▒▒▒▒▒
    ▓▓▓▓▓   ▓▓▓▓▓▓   ▓▓▓▓▓   ▓▓   ▓▓▓   ▓▓▓▓▓  ▓▓▓   ▓▓▓▓▓▓▓▓        ▓▓▓▓   ▓▓▓▓▓   ▓▓   ▓▓▓▓   ▓▓▓▓   ▓▓   ▓▓▓   ▓▓▓▓▓   ▓▓   ▓▓   ▓▓▓▓▓▓▓▓▓▓ 
    ▓▓▓▓▓   ▓▓▓▓▓▓   ▓▓▓▓   ▓▓▓   ▓▓   ▓▓▓▓▓         ▓▓▓▓▓▓▓▓   ▓▓▓▓▓▓▓▓▓   ▓▓▓▓   ▓▓▓▓   ▓▓▓   ▓▓▓   ▓▓▓▓   ▓   ▓▓▓▓▓   ▓▓▓▓   ▓   ▓▓▓▓▓▓▓▓▓▓ 
    ▓▓▓▓▓   ▓▓▓▓▓▓   ▓▓▓▓   ▓▓▓   ▓▓▓   ▓▓▓▓  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓   ▓▓▓▓▓▓▓▓▓   ▓▓▓▓▓   ▓▓   ▓▓▓▓   ▓ ▓▓   ▓▓   ▓▓▓   ▓▓▓▓▓   ▓▓   ▓▓   ▓▓▓▓▓▓▓▓▓▓ 
    █████   █████    ██████   █    ████    ███     ██████████   ████████    ███████   ████████   █████   ████████    ████   █████         ████
    ██████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████████

                                                                            ░█▒█░█▄░█░█░█▄░█░▄▀▀░▀█▀▒▄▀▄░█▒░░█▒░▒██▀▒█▀▄
                                                                            ░▀▄█░█▒▀█░█░█▒▀█▒▄██░▒█▒░█▀█▒█▄▄▒█▄▄░█▄▄░█▀▄


EOF
    echo -e "${NC}"
}

# Check if running as root FIRST (before banner)
if [[ $EUID -ne 0 ]]; then
    echo ""
    echo -e "${RED}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ERROR: This script requires sudo privileges!  ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Please run:${NC}"
    echo -e "  ${GREEN}sudo ./trace-protocol.sh uninstall${NC}"
    echo ""
    exit 1
fi

# Show banner
show_banner

echo -e "${YELLOW}⚠  WARNING: This will remove all TraceProtocol packages and configurations!${NC}"
echo ""
echo -e "${YELLOW}Press Ctrl+C to cancel, or Enter to continue...${NC}"
read

# Step 1: Disconnect VPN
CURRENT_STEP=1
show_progress $CURRENT_STEP $TOTAL_STEPS "Disconnecting VPN and stopping Conky"

# Check if proton0 interface exists (quick check)
if ip link show proton0 >/dev/null 2>&1; then
    echo -e "${YELLOW}VPN tunnel detected. Disconnecting...${NC}"
    
    if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
        # Get user environment
        USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
        USER_UID=$(id -u "$SUDO_USER")
        DBUS_ADDR="unix:path=/run/user/$USER_UID/bus"
        
        # Kill any existing ProtonVPN processes first
        pkill -9 protonvpn 2>/dev/null || true
        
        # Disable kill switch first (with timeout and environment)
        timeout 3 sudo -u "$SUDO_USER" DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDR" HOME="$USER_HOME" protonvpn-cli ks --off >/dev/null 2>&1 || true
        
        # Force disconnect with timeout
        timeout 3 sudo -u "$SUDO_USER" DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDR" HOME="$USER_HOME" protonvpn-cli d >/dev/null 2>&1 || true
        
        # If still connected, kill OpenVPN processes
        pkill -9 openvpn 2>/dev/null || true
        
        # Remove VPN interface
        ip link delete proton0 2>/dev/null || true
        
        echo -e "${GREEN}VPN disconnected${NC}"
    else
        # Kill OpenVPN and remove interface anyway
        pkill -9 openvpn 2>/dev/null || true
        ip link delete proton0 2>/dev/null || true
        echo -e "${GREEN}VPN tunnel removed${NC}"
    fi
else
    echo -e "${BLUE}No VPN connection detected. Skipping disconnect.${NC}"
fi

# Stop Conky widget
pkill conky 2>/dev/null || true
echo -e "${GREEN}✓ Conky widget stopped${NC}"

# Step 2: Stop Services
CURRENT_STEP=2
show_progress $CURRENT_STEP $TOTAL_STEPS "Stopping privacy services"
systemctl stop tor 2>/dev/null || true
systemctl stop dnscrypt-proxy 2>/dev/null || true
systemctl stop dnscrypt-proxy2 2>/dev/null || true
systemctl disable tor 2>/dev/null || true
systemctl disable dnscrypt-proxy 2>/dev/null || true
systemctl disable dnscrypt-proxy2 2>/dev/null || true
echo -e "${GREEN}✓ Services stopped and disabled${NC}"

# Step 3: Remove DNSCrypt-Proxy
CURRENT_STEP=3
show_progress $CURRENT_STEP $TOTAL_STEPS "Removing DNSCrypt-Proxy"
rm -f /usr/local/bin/dnscrypt-proxy 2>/dev/null || true
rm -rf /etc/dnscrypt-proxy 2>/dev/null || true
rm -f /etc/systemd/system/dnscrypt-proxy.service 2>/dev/null || true
systemctl daemon-reload 2>/dev/null || true
echo -e "${GREEN}✓ DNSCrypt-Proxy removed${NC}"

# Step 4: Disable Firewall
CURRENT_STEP=4
show_progress $CURRENT_STEP $TOTAL_STEPS "Disabling UFW firewall"
ufw disable 2>/dev/null || true
echo -e "${GREEN}✓ Firewall disabled${NC}"

# Step 5: Remove Packages
CURRENT_STEP=5
show_progress $CURRENT_STEP $TOTAL_STEPS "Removing privacy packages"

PACKAGES=(
    "protonvpn-cli"
    "protonvpn"
    "tor"
    "dnscrypt-proxy"
    "dnscrypt-proxy2"
    "macchanger"
    "apparmor-utils"
    "bleachbit"
    "firejail"
    "dnsmasq"
    "torbrowser-launcher"
    "conky-all"
)

for package in "${PACKAGES[@]}"; do
    if dpkg -l | grep -qw "$package" 2>/dev/null; then
        apt remove --purge -y "$package" >> /dev/null 2>&1 || true
    fi
done
echo -e "${GREEN}✓ All packages removed${NC}"

# Step 6: Remove ProtonVPN Repository
CURRENT_STEP=6
show_progress $CURRENT_STEP $TOTAL_STEPS "Removing ProtonVPN repository"
apt remove --purge -y protonvpn-stable-release 2>/dev/null || true
rm -f /etc/apt/sources.list.d/protonvpn* 2>/dev/null || true
rm -f /usr/share/keyrings/protonvpn-stable-archive-keyring.gpg 2>/dev/null || true
echo -e "${GREEN}✓ ProtonVPN repository removed${NC}"

# Step 7: Clean Configurations
CURRENT_STEP=7
show_progress $CURRENT_STEP $TOTAL_STEPS "Cleaning up configurations"
rm -rf /etc/protonvpn 2>/dev/null || true

# Remove ProtonVPN user configurations
if [ -n "$SUDO_USER" ]; then
    rm -rf /home/$SUDO_USER/.cache/protonvpn 2>/dev/null || true
    rm -rf /home/$SUDO_USER/.config/protonvpn 2>/dev/null || true
    rm -f /home/$SUDO_USER/.conkyrc 2>/dev/null || true
    rm -f /home/$SUDO_USER/.config/autostart/traceprotocol-conky.desktop 2>/dev/null || true
else
    rm -rf ~/.cache/protonvpn 2>/dev/null || true
    rm -rf ~/.config/protonvpn 2>/dev/null || true
    rm -f ~/.conkyrc 2>/dev/null || true
    rm -f ~/.config/autostart/traceprotocol-conky.desktop 2>/dev/null || true
fi

# Reset network interfaces
if [ -f /etc/network/interfaces.backup ]; then
    mv /etc/network/interfaces.backup /etc/network/interfaces
fi

# Remove DNS configuration
if [ -f /etc/dnsmasq.conf.backup ]; then
    mv /etc/dnsmasq.conf.backup /etc/dnsmasq.conf
else
    rm -f /etc/dnsmasq.conf 2>/dev/null || true
fi

# Remove TraceProtocol data directory
rm -rf /var/lib/traceprotocol 2>/dev/null || true

echo -e "${GREEN}✓ All configurations cleaned${NC}"

# Step 8: Final Cleanup
CURRENT_STEP=8
show_progress $CURRENT_STEP $TOTAL_STEPS "Final cleanup and autoremove"
apt autoremove -y >> /dev/null 2>&1
apt autoclean >> /dev/null 2>&1
echo -e "${GREEN}✓ Unused packages removed${NC}"

# Completion
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}                                                                ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}           ${GREEN}✓ Uninstallation Completed Successfully!${NC}             ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}                                                                ${GREEN}║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}━━━ What Was Removed ━━━${NC}"
echo ""
echo -e "  ${GREEN}✓${NC} ProtonVPN CLI and all privacy packages"
echo -e "  ${GREEN}✓${NC} Tor, DNSCrypt, AppArmor services"
echo -e "  ${GREEN}✓${NC} Conky desktop widget"
echo -e "  ${GREEN}✓${NC} All service configurations"
echo -e "  ${GREEN}✓${NC} User data and credentials"
echo -e "  ${GREEN}✓${NC} MAC address backups"
echo ""
echo -e "${CYAN}━━━ System Packages Kept ━━━${NC}"
echo ""
echo -e "  ${BLUE}•${NC} AppArmor (core system security)"
echo -e "  ${BLUE}•${NC} UFW (firewall - now disabled)"
echo -e "  ${BLUE}•${NC} iptables (core networking)"
echo -e "  ${BLUE}•${NC} curl, wget (utilities)"
echo ""
echo -e "${CYAN}━━━ TraceProtocol Project ━━━${NC}"
echo ""
echo -e "  ${BLUE}Location:${NC} $SCRIPT_DIR/.."
echo -e "  ${BLUE}Status:${NC}   Intact (scripts and documentation preserved)"
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}  Ready to reinstall? Run:                                     ${GREEN}║${NC}"
echo -e "${GREEN}║${NC}  ${YELLOW}sudo ./trace-protocol.sh install${NC}                             ${GREEN}║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

