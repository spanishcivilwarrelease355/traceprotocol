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

# Disconnect VPN first (as actual user, not root)
echo -e "${BLUE}Disconnecting VPN...${NC}"
if command -v protonvpn-cli &>/dev/null; then
    if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
        # Run as the actual user who ran sudo, suppress all output
        sudo -u "$SUDO_USER" bash -c "protonvpn-cli disconnect >/dev/null 2>&1" || true
        sleep 1
        sudo -u "$SUDO_USER" bash -c "protonvpn-cli ks --off >/dev/null 2>&1" || true
        echo -e "${GREEN}VPN disconnected${NC}"
    else
        echo -e "${YELLOW}Skipping VPN disconnect (run with sudo)${NC}"
    fi
else
    echo -e "${YELLOW}ProtonVPN CLI not found${NC}"
fi

# Stop Conky widget
echo -e "${BLUE}Stopping Conky widget...${NC}"
pkill conky 2>/dev/null || true

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
    if dpkg -l | grep -qw "$package" 2>/dev/null; then
        echo -e "${BLUE}Removing $package...${NC}"
        apt remove --purge -y "$package" >> /dev/null 2>&1 || true
    fi
done

echo -e "${GREEN}Packages removed${NC}"

# Remove ProtonVPN repository
echo -e "${BLUE}Removing ProtonVPN repository...${NC}"
apt remove --purge -y protonvpn-stable-release 2>/dev/null || true
rm -f /etc/apt/sources.list.d/protonvpn* 2>/dev/null || true

# Clean up configurations
echo -e "${BLUE}Cleaning up configurations...${NC}"
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
echo -e "${BLUE}Cleaning up unused packages...${NC}"
apt autoremove -y >> /dev/null 2>&1
apt autoclean >> /dev/null 2>&1
echo -e "${GREEN}Cleanup complete${NC}"

echo ""
echo "========================================"
echo -e "${GREEN}Uninstallation completed!${NC}"
echo "========================================"
echo ""
echo -e "${BLUE}What was removed:${NC}"
echo "  ✓ ProtonVPN and all privacy packages"
echo "  ✓ All configurations and data"
echo "  ✓ Conky widget"
echo "  ✓ Service configurations"
echo ""
echo -e "${YELLOW}Note: Core system packages were kept:${NC}"
echo "  • apparmor (system security)"
echo "  • ufw (firewall - disabled)"
echo "  • iptables (networking)"
echo "  • curl, wget (utilities)"
echo ""
echo -e "${BLUE}TraceProtocol project files:${NC}"
echo "  Location: $SCRIPT_DIR/.."
echo "  Status: Intact (only installed packages removed)"
echo ""
echo -e "${GREEN}You can reinstall anytime with:${NC}"
echo "  sudo ./privacy-manager.sh install"
echo ""

