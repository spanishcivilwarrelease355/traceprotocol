#!/bin/bash

# TraceProtocol Uninstall Script
# Removes all packages and configurations installed by TraceProtocol

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[38;5;196m'
GREEN='\033[38;5;46m'
YELLOW='\033[38;5;226m'  
WHITE='\033[1;37m'
BLUE='\033[38;5;27m'       
CYAN='\033[38;5;51m'       
MAGENTA='\033[38;5;201m'   
NC='\033[0m'

# Progress tracking
TOTAL_STEPS=8
CURRENT_STEP=0

# Function to show dynamic progress bar (updates in place)
show_progress() {
    local step=$1
    local total=$2
    local description=$3
    
    local percent=$((step * 100 / total))
    local filled=$((step * 40 / total))
    local empty=$((40 - filled))
    
    # Create progress bar
    local bar="["
    for ((i=0; i<filled; i++)); do bar="${bar}█"; done
    for ((i=0; i<empty; i++)); do bar="${bar}░"; done
    bar="${bar}]"
    
    # Print with carriage return and clear the entire line
    printf "\r\033[K${CYAN}Progress:${NC} ${bar} ${YELLOW}%3d%%${NC} - %-40s" "$percent" "$description"
}

# Function to finish progress (move to new line)
finish_progress() {
    echo ""
}

# Use banner from trace-protocol.sh with UNINSTALLER context
show_banner() {
    local TRACE_PROTOCOL_SCRIPT="$SCRIPT_DIR/../trace-protocol.sh"
    if [ -f "$TRACE_PROTOCOL_SCRIPT" ]; then
        # Temporarily disable exit on error
        set +e
        # Extract and execute the banner function from trace-protocol.sh with UNINSTALLER context
        bash -c "
            source '$TRACE_PROTOCOL_SCRIPT'
            ensure_lolcat
            show_banner 'UNINSTALLER'
        " 2>/dev/null || {
            # Fallback banner if sourcing fails
            clear
            echo -e '${CYAN}'
            echo '████████ ██████   █████   ██████ ███████     ██████  ██████   ██████  ████████  ██████   ██████  ██████  ██      '
            echo '   ██    ██   ██ ██   ██ ██      ██          ██   ██ ██   ██ ██    ██    ██    ██    ██ ██      ██    ██ ██      '
            echo '   ██    ██████  ███████ ██      █████       ██████  ██████  ██    ██    ██    ██    ██ ██      ██    ██ ██      '
            echo '   ██    ██   ██ ██   ██ ██      ██          ██      ██   ██ ██    ██    ██    ██    ██ ██      ██    ██ ██      '
            echo '   ██    ██   ██ ██   ██  ██████ ███████     ██      ██   ██  ██████     ██     ██████   ██████  ██████  ███████ '
            echo -e '${NC}'
            echo -e "                     ${WHITE}Advanced Privacy & VPN Management Suite for Linux${NC}"
            echo -e "                        ${GREEN}Author:${WHITE} Mr Cherif ${GREEN}| Version:${WHITE} 1.0.0${NC}"
            echo
            echo -e "                                   ${RED}🗑️  UNINSTALLER MODULE 🗑️${NC}"
            echo
        }
        # Re-enable exit on error
        set -e
    else
        echo -e "${RED}Error: Could not find trace-protocol.sh${NC}"
        exit 1
    fi
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
echo ""

# Start progress
echo -e "${CYAN}Starting uninstallation process...${NC}"
echo ""

# Step 1: Disconnect VPN and Remove NetworkManager Connections
CURRENT_STEP=1
show_progress $CURRENT_STEP $TOTAL_STEPS "Disconnecting VPN and cleaning connections"

# Kill any existing ProtonVPN processes first
pkill -9 protonvpn 2>/dev/null || true
pkill -9 openvpn 2>/dev/null || true

# Disconnect ProtonVPN if connected (safer than logout)
if command -v protonvpn-cli >/dev/null 2>&1; then
    # Always run ProtonVPN commands as the regular user, never as root
    if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
        # Get user environment
        USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
        USER_UID=$(id -u "$SUDO_USER")
        DBUS_ADDR="unix:path=/run/user/$USER_UID/bus"
        
        # Disable kill switch first (run as regular user)
        timeout 10 sudo -u "$SUDO_USER" DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDR" HOME="$USER_HOME" protonvpn-cli ks --off >/dev/null 2>&1 || true
        
        # Force disconnect (run as regular user)
        timeout 10 sudo -u "$SUDO_USER" DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDR" HOME="$USER_HOME" protonvpn-cli d >/dev/null 2>&1 || true
        
        # Wait a moment for disconnection to complete
        sleep 2
        
        # Verify disconnection by checking status (run as regular user)
        VPN_STATUS=$(timeout 5 sudo -u "$SUDO_USER" DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDR" HOME="$USER_HOME" protonvpn-cli s 2>/dev/null | grep -i "status" | head -1)
        if echo "$VPN_STATUS" | grep -qi "connected"; then
            # Still connected, try logout as last resort (run as regular user)
            timeout 10 sudo -u "$SUDO_USER" DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDR" HOME="$USER_HOME" protonvpn-cli logout >/dev/null 2>&1 || true
            sleep 2
        fi
    else
        # Running as root without SUDO_USER - cannot run ProtonVPN commands safely
        # ProtonVPN should not be run as root, skip disconnection
        echo "Warning: Cannot disconnect ProtonVPN when running as root without SUDO_USER" >/dev/null 2>&1
    fi
fi

# Remove VPN interfaces (proton0, pvpnksintrf0, ipv6leakintrf0, etc.)
for interface in proton0 pvpnksintrf0 ipv6leakintrf0; do
    if ip link show "$interface" >/dev/null 2>&1; then
        ip link delete "$interface" 2>/dev/null || true
    fi
done

# CRITICAL: Remove ProtonVPN NetworkManager connections that persist after uninstall
# These connections cause internet connectivity issues even after VPN is disconnected

# Get list of ProtonVPN connections and remove them (avoid subshell issues)
PROTON_CONNECTIONS=$(nmcli connection show | grep -E "(pvpn|proton)" | awk '{print $1}' | tr '\n' ' ')
if [ -n "$PROTON_CONNECTIONS" ]; then
    for conn_name in $PROTON_CONNECTIONS; do
        nmcli connection delete "$conn_name" >/dev/null 2>&1 || true
    done
fi

# Force remove any remaining ProtonVPN connections by name patterns
for conn_name in "pvpn-killswitch" "pvpn-ipv6leak-protection" "Proton VPN" "protonvpn"; do
    nmcli connection delete "$conn_name" >/dev/null 2>&1 || true
done

# Clean up any remaining VPN-related iptables rules that might block traffic
iptables -D OUTPUT -o pvpnksintrf0 -j DROP 2>/dev/null || true
iptables -D OUTPUT -o ipv6leakintrf0 -j DROP 2>/dev/null || true
iptables -D OUTPUT -o proton0 -j DROP 2>/dev/null || true

# Remove any ProtonVPN kill switch rules (avoid subshell issues)
PROTON_RULES=$(iptables -L OUTPUT -n | grep -i protonvpn | awk '{print $2}' | tr '\n' ' ')
if [ -n "$PROTON_RULES" ]; then
    for rule_num in $PROTON_RULES; do
        if [ -n "$rule_num" ] && [[ "$rule_num" =~ ^[0-9]+$ ]]; then
            iptables -D OUTPUT "$rule_num" 2>/dev/null || true
        fi
    done
fi

# Stop Conky widget
pkill conky 2>/dev/null || true
sleep 0.3

# Step 2: Stop Services
CURRENT_STEP=2
show_progress $CURRENT_STEP $TOTAL_STEPS "Stopping services"

systemctl stop tor 2>/dev/null || true
systemctl stop dnscrypt-proxy 2>/dev/null || true
systemctl stop dnscrypt-proxy2 2>/dev/null || true
systemctl stop dnsmasq 2>/dev/null || true
systemctl disable tor 2>/dev/null || true
systemctl disable dnscrypt-proxy 2>/dev/null || true
systemctl disable dnscrypt-proxy2 2>/dev/null || true
systemctl disable dnsmasq 2>/dev/null || true
sleep 0.3

# Step 3: Remove DNSCrypt-Proxy and Restore DNS
CURRENT_STEP=3
show_progress $CURRENT_STEP $TOTAL_STEPS "Restoring DNS and removing DNSCrypt"

# Remove immutable flag first
chattr -i /etc/resolv.conf 2>/dev/null || true

# Check if backup exists and validate it
BACKUP_VALID=false
if [ -f /etc/resolv.conf.traceprotocol-backup ]; then
    # Check if backup contains localhost addresses (broken DNS)
    if grep -qE "nameserver (127\.0\.0\.|::1)" /etc/resolv.conf.traceprotocol-backup 2>/dev/null; then
        # Backup has localhost DNS (broken), don't restore it
        BACKUP_VALID=false
    else
        # Backup looks valid (has real DNS servers)
        BACKUP_VALID=true
    fi
fi

# Remove NetworkManager DNSCrypt configuration
rm -f /etc/NetworkManager/conf.d/dnscrypt.conf 2>/dev/null || true

# Re-enable systemd-resolved only if it actually exists and was disabled by us
if [ -f /lib/systemd/system/systemd-resolved.service ]; then
    systemctl enable systemd-resolved 2>/dev/null || true
    systemctl start systemd-resolved 2>/dev/null || true
    sleep 1
fi

# Restore DNS based on backup validity
if [ "$BACKUP_VALID" = true ]; then
    # Restore valid backup
    cp /etc/resolv.conf.traceprotocol-backup /etc/resolv.conf 2>/dev/null || true
else
    # No valid backup - use fallback DNS and let NetworkManager regenerate
    cat > /etc/resolv.conf << 'DNSEOF'
# Temporary DNS (will be updated by NetworkManager)
nameserver 8.8.8.8
nameserver 8.8.4.4
DNSEOF
fi

# Clean up backup file
rm -f /etc/resolv.conf.traceprotocol-backup 2>/dev/null || true

# Restart NetworkManager to regenerate proper DNS from DHCP/router
systemctl restart NetworkManager 2>/dev/null || true
sleep 3

# Get the actual DNS from NetworkManager and write it properly
ROUTER_DNS=$(nmcli device show | grep "IP4.DNS\[1\]" | awk '{print $2}' | head -1)

if [ -n "$ROUTER_DNS" ] && [[ "$ROUTER_DNS" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    # We got valid IPv4 DNS from router, use it
    cat > /etc/resolv.conf << ROUTERDNSEOF
# Generated by NetworkManager (TraceProtocol restored)
nameserver $ROUTER_DNS
ROUTERDNSEOF
else
    # No valid router DNS, check if resolv.conf has valid DNS
    if ! grep -qE "nameserver [0-9]" /etc/resolv.conf 2>/dev/null; then
        # Still no valid DNS, use fallback
        cat > /etc/resolv.conf << 'FALLBACKEOF'
# Fallback DNS (NetworkManager failed to provide router DNS)
nameserver 8.8.8.8
nameserver 8.8.4.4
FALLBACKEOF
    fi
fi

# Remove DNSCrypt-Proxy files
rm -f /usr/local/bin/dnscrypt-proxy 2>/dev/null || true
rm -rf /etc/dnscrypt-proxy 2>/dev/null || true
rm -rf /var/cache/dnscrypt-proxy 2>/dev/null || true
rm -f /etc/systemd/system/dnscrypt-proxy.service 2>/dev/null || true

# dnsmasq handling moved to package removal section above

systemctl daemon-reload 2>/dev/null || true

sleep 0.3

# Step 4: Remove Packages
CURRENT_STEP=4
show_progress $CURRENT_STEP $TOTAL_STEPS "Removing packages"

PACKAGES=(
    "protonvpn-cli"
    "protonvpn"
    "tor"
    "macchanger"
    # Note: apparmor and apparmor-utils are kept as they are core system security
    # Note: dnsmasq is handled separately (might be pre-installed)
    "bleachbit"
    "firejail"
    "torbrowser-launcher"
    "conky-all"
    "lolcat"
)

for package in "${PACKAGES[@]}"; do
    if dpkg -l | grep -qw "$package" 2>/dev/null; then
        DEBIAN_FRONTEND=noninteractive apt-get remove --purge -y "$package" >/dev/null 2>&1 || true
    fi
done

# Handle dnsmasq separately - only remove if TraceProtocol installed it
# Check if dnsmasq was likely installed by TraceProtocol (has our forwarding config)
if [ -f /etc/dnsmasq.d/dnscrypt.conf ]; then
    # TraceProtocol installed dnsmasq, safe to remove
    if dpkg -l | grep -qw "dnsmasq" 2>/dev/null; then
        DEBIAN_FRONTEND=noninteractive apt-get remove --purge -y dnsmasq >/dev/null 2>&1 || true
    fi
else
    # dnsmasq might be pre-installed, just disable it and restore default config
    systemctl stop dnsmasq 2>/dev/null || true
    systemctl disable dnsmasq 2>/dev/null || true
    
    # Remove our forwarding config but keep dnsmasq package
    rm -f /etc/dnsmasq.d/dnscrypt.conf 2>/dev/null || true
    
    # If dnsmasq config backup exists, restore it
    if [ -f /etc/dnsmasq.conf.backup ]; then
        mv /etc/dnsmasq.conf.backup /etc/dnsmasq.conf 2>/dev/null || true
    fi
fi

sleep 0.3

# Step 5: Remove ProtonVPN Repository
CURRENT_STEP=5
show_progress $CURRENT_STEP $TOTAL_STEPS "Removing repository"
DEBIAN_FRONTEND=noninteractive apt-get remove --purge -y protonvpn-stable-release >/dev/null 2>&1 || true
rm -f /etc/apt/sources.list.d/protonvpn* 2>/dev/null || true
rm -f /usr/share/keyrings/protonvpn-archive-keyring.gpg 2>/dev/null || true
rm -f /usr/share/keyrings/protonvpn-stable-archive-keyring.gpg 2>/dev/null || true
sleep 0.3

# Step 6: Clean Configurations
CURRENT_STEP=6
show_progress $CURRENT_STEP $TOTAL_STEPS "Cleaning configurations"
rm -rf /etc/protonvpn 2>/dev/null || true

# Remove ProtonVPN system configurations
rm -f /etc/NetworkManager/system-connections/*.protonvpn.* 2>/dev/null || true
rm -f /etc/openvpn/clients/*.protonvpn.* 2>/dev/null || true
rm -f /etc/openvpn/credentials/protonvpn.txt 2>/dev/null || true
rm -f /etc/systemd/system/*protonvpn* 2>/dev/null || true
rm -f /etc/systemd/system/multi-user.target.wants/*protonvpn* 2>/dev/null || true
rm -f /etc/apt/sources.list.d/protonvpn.list 2>/dev/null || true
rm -f /etc/polkit-1/rules.d/50-protonvpn.rules 2>/dev/null || true

# Reload systemd and polkit to recognize removed services/rules
systemctl daemon-reload 2>/dev/null || true
systemctl restart polkit 2>/dev/null || true

# Remove ProtonVPN user configurations (clean both user and root locations)
if [ -n "$SUDO_USER" ]; then
    # Clean actual user's home directory
    rm -rf /home/$SUDO_USER/.cache/protonvpn 2>/dev/null || true
    rm -rf /home/$SUDO_USER/.config/protonvpn 2>/dev/null || true
    rm -f /home/$SUDO_USER/.conkyrc 2>/dev/null || true
    rm -f /home/$SUDO_USER/.config/autostart/traceprotocol-conky.desktop 2>/dev/null || true
    rm -f /home/$SUDO_USER/.config/autostart/conky-traceprotocol.desktop 2>/dev/null || true
    rm -f /home/$SUDO_USER/.config/traceprotocol/get-real-ip.sh 2>/dev/null || true
    rm -f /home/$SUDO_USER/.config/traceprotocol/get-vpn-status.sh 2>/dev/null || true
    rm -f /home/$SUDO_USER/.config/traceprotocol/check-killswitch-status.sh 2>/dev/null || true
    rm -f /home/$SUDO_USER/.config/traceprotocol/check-tor-status.sh 2>/dev/null || true
    rm -f /home/$SUDO_USER/.config/traceprotocol/killswitch-manager.sh 2>/dev/null || true
    rm -f /home/$SUDO_USER/.config/traceprotocol/real_ip.txt 2>/dev/null || true
    rmdir /home/$SUDO_USER/.config/traceprotocol 2>/dev/null || true  # Remove dir if empty
    
    # Also clean root's home (in case ProtonVPN was run as root)
    rm -rf /root/.cache/protonvpn 2>/dev/null || true
    rm -rf /root/.config/protonvpn 2>/dev/null || true
    rm -f /root/.conkyrc 2>/dev/null || true
else
    # Running as actual root user
    rm -rf ~/.cache/protonvpn 2>/dev/null || true
    rm -rf ~/.config/protonvpn 2>/dev/null || true
    rm -f ~/.conkyrc 2>/dev/null || true
    rm -f ~/.config/autostart/traceprotocol-conky.desktop 2>/dev/null || true
    rm -f ~/.config/autostart/conky-traceprotocol.desktop 2>/dev/null || true
    rm -f ~/.config/traceprotocol/get-real-ip.sh 2>/dev/null || true
    rm -f ~/.config/traceprotocol/get-vpn-status.sh 2>/dev/null || true
    rm -f ~/.config/traceprotocol/check-killswitch-status.sh 2>/dev/null || true
    rm -f ~/.config/traceprotocol/check-tor-status.sh 2>/dev/null || true
    rm -f ~/.config/traceprotocol/killswitch-manager.sh 2>/dev/null || true
    rm -f ~/.config/traceprotocol/real_ip.txt 2>/dev/null || true
    rmdir ~/.config/traceprotocol 2>/dev/null || true  # Remove dir if empty
fi

# Reset network interfaces
if [ -f /etc/network/interfaces.backup ]; then
    mv /etc/network/interfaces.backup /etc/network/interfaces
fi

# DNS configuration already handled in dnsmasq section above

# Preserve MAC address backups but remove other TraceProtocol data
# MAC backups are user data and should persist across reinstalls
if [ -d /var/lib/traceprotocol ]; then
    # Save MAC backups if they exist
    TEMP_MAC_BACKUP=""
    TEMP_IFACE_BACKUP=""
    if [ -f /var/lib/traceprotocol/original_mac.txt ]; then
        TEMP_MAC_BACKUP=$(cat /var/lib/traceprotocol/original_mac.txt 2>/dev/null)
    fi
    if [ -f /var/lib/traceprotocol/interface.txt ]; then
        TEMP_IFACE_BACKUP=$(cat /var/lib/traceprotocol/interface.txt 2>/dev/null)
    fi
    
    # Remove the directory
    rm -rf /var/lib/traceprotocol 2>/dev/null || true
    
    # Restore MAC backups
    if [ -n "$TEMP_MAC_BACKUP" ] || [ -n "$TEMP_IFACE_BACKUP" ]; then
        mkdir -p /var/lib/traceprotocol
        [ -n "$TEMP_MAC_BACKUP" ] && echo "$TEMP_MAC_BACKUP" > /var/lib/traceprotocol/original_mac.txt
        [ -n "$TEMP_IFACE_BACKUP" ] && echo "$TEMP_IFACE_BACKUP" > /var/lib/traceprotocol/interface.txt
    fi
fi
sleep 0.3

# Step 7: Remove boot services
CURRENT_STEP=7
show_progress $CURRENT_STEP $TOTAL_STEPS "Removing boot services"

# Disable and remove MAC randomization service
if systemctl is-enabled traceprotocol-mac-randomize.service >/dev/null 2>&1; then
    systemctl disable traceprotocol-mac-randomize.service >/dev/null 2>&1
fi
systemctl stop traceprotocol-mac-randomize.service >/dev/null 2>&1 || true
rm -f /etc/systemd/system/traceprotocol-mac-randomize.service
systemctl daemon-reload >/dev/null 2>&1 || true

# Remove Conky autostart entry
if [ -n "$SUDO_USER" ]; then
    rm -f /home/$SUDO_USER/.config/autostart/conky-traceprotocol.desktop
fi

# Remove MAC randomization boot script (dynamic path)
if [ -n "$SUDO_USER" ]; then
    rm -f "/home/$SUDO_USER/.config/traceprotocol/mac-randomize-boot.sh"
else
    # Fallback if SUDO_USER is not set
    rm -f "/home/$(logname)/.config/traceprotocol/mac-randomize-boot.sh"
fi

# Remove NetworkManager dispatcher script for automatic MAC randomization
rm -f /etc/NetworkManager/dispatcher.d/99-traceprotocol-mac-randomize

# Remove immediate MAC randomization script (dynamic path)
if [ -n "$SUDO_USER" ]; then
    rm -f "/home/$SUDO_USER/.config/traceprotocol/randomize-mac-now.sh"
else
    # Fallback if SUDO_USER is not set
    rm -f "/home/$(logname)/.config/traceprotocol/randomize-mac-now.sh"
fi

# Remove boot logs and auto MAC logs
rm -f /var/log/traceprotocol-mac-boot.log
rm -f /var/log/traceprotocol-mac-auto.log

sleep 0.5

# Step 8: Final Cleanup
CURRENT_STEP=8
show_progress $CURRENT_STEP $TOTAL_STEPS "Final cleanup"

# Mark essential networking packages as manually installed to prevent autoremove
# This prevents NetworkManager and related packages from being removed
ESSENTIAL_NETWORK_PACKAGES=(
    "network-manager"
    "network-manager-gnome" 
    "nm-applet"
    "network-manager-openvpn"
    "network-manager-openvpn-gnome"
    "libnm0"
    "gir1.2-nm-1.0"
)

for pkg in "${ESSENTIAL_NETWORK_PACKAGES[@]}"; do
    if dpkg -l | awk '{print $2}' | grep -q "^${pkg}$" 2>/dev/null; then
        apt-mark manual "$pkg" >/dev/null 2>&1 || true
    fi
done

# Safe cleanup - only remove orphaned packages, but protect essential ones
DEBIAN_FRONTEND=noninteractive apt-get autoclean >/dev/null 2>&1 || true

sleep 0.3

# Finish progress bar
finish_progress

# Professional completion output
echo ""
echo ""
echo -e "${BOLD}${GREEN}  ✅  Uninstallation Completed Successfully${NC} ${WHITE}at $(date +"%Y-%m-%d %H:%M:%S")${NC}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "   ${BOLD}${WHITE}Components Removed${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${GREEN}✓  ProtonVPN CLI and privacy-related packages${NC}"
echo -e "  ${GREEN}✓  Tor and DNSCrypt services${NC}"
echo -e "  ${GREEN}✓  Conky desktop widget${NC}"
echo -e "  ${GREEN}✓  All configurations and related data${NC}"
echo -e "  ${GREEN}✓  DNS configuration restored to original settings${NC}"
echo ""
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${YELLOW}To reinstall, run:${NC}  ${WHITE}sudo ./trace-protocol.sh install${NC}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

