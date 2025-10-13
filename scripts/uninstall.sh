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
NC='\033[0m'

echo ""
echo "========================================"
echo "    TraceProtocol Uninstaller"
echo "========================================"
echo ""

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script must be run as root or with sudo${NC}"
    exit 1
fi

echo -e "${YELLOW}WARNING: This will remove all TraceProtocol packages and configurations!${NC}"
echo -e "${YELLOW}Press Ctrl+C to cancel, or Enter to continue...${NC}"
read

# Disconnect VPN first
echo -e "${BLUE}Disconnecting VPN...${NC}"
if command -v protonvpn-cli &>/dev/null; then
    protonvpn-cli disconnect 2>/dev/null || true
    protonvpn-cli ks --off 2>/dev/null || true
fi

# Stop services
echo -e "${BLUE}Stopping services...${NC}"
systemctl stop tor 2>/dev/null || true
systemctl stop dnscrypt-proxy 2>/dev/null || true
systemctl disable tor 2>/dev/null || true
systemctl disable dnscrypt-proxy 2>/dev/null || true

# Disable firewall
echo -e "${BLUE}Disabling firewall...${NC}"
ufw disable 2>/dev/null || true

# Remove packages
echo -e "${BLUE}Removing packages...${NC}"

PACKAGES=(
    "proton-vpn-gnome-desktop"
    "libayatana-appindicator3-1"
    "gir1.2-ayatanaappindicator3-0.1"
    "gnome-shell-extension-appindicator"
    "tor"
    "dnscrypt-proxy"
    "macchanger"
    "apparmor-utils"
    "bleachbit"
    "firejail"
    "dnsmasq"
    "torbrowser-launcher"
    "signal-desktop"
    "telegram-desktop"
)

for package in "${PACKAGES[@]}"; do
    echo -e "${BLUE}Removing $package...${NC}"
    apt remove --purge -y "$package" 2>/dev/null || echo -e "${YELLOW}Package $package not found or already removed${NC}"
done

# Remove ProtonVPN repository
echo -e "${BLUE}Removing ProtonVPN repository...${NC}"
apt remove --purge -y protonvpn-stable-release 2>/dev/null || true
rm -f /etc/apt/sources.list.d/protonvpn* 2>/dev/null || true

# Clean up configurations
echo -e "${BLUE}Cleaning up configurations...${NC}"
rm -rf /etc/protonvpn 2>/dev/null || true
rm -rf ~/.cache/protonvpn 2>/dev/null || true
rm -rf ~/.config/protonvpn 2>/dev/null || true

# Reset network interfaces
echo -e "${BLUE}Resetting network configurations...${NC}"
if [ -f /etc/network/interfaces.backup ]; then
    mv /etc/network/interfaces.backup /etc/network/interfaces
fi

# Remove DNS configuration
if [ -f /etc/dnsmasq.conf.backup ]; then
    mv /etc/dnsmasq.conf.backup /etc/dnsmasq.conf
else
    rm -f /etc/dnsmasq.conf 2>/dev/null || true
fi

# Autoremove unused packages
echo -e "${BLUE}Removing unused packages...${NC}"
apt autoremove -y
apt autoclean

echo ""
echo -e "${GREEN}Uninstallation completed!${NC}"
echo ""
echo -e "${YELLOW}Note: The following were NOT removed:${NC}"
echo "  - apparmor (core system security)"
echo "  - ufw (firewall - disabled but not removed)"
echo "  - iptables (core networking)"
echo "  - curl, wget (common utilities)"
echo ""
echo -e "${BLUE}TraceProtocol project files remain in:${NC}"
echo "  $SCRIPT_DIR/.."
echo ""

