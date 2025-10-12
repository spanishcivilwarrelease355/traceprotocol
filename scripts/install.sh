#!/bin/bash

# Privacy & VPN Tools Installation Script
# Installs ProtonVPN CLI and essential privacy tools for Parrot OS / Debian-based systems

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/../logs/install_$(date +%Y%m%d_%H%M%S).log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to log messages
log() {
    echo -e "${GREEN}[$(date +%Y-%m-%d\ %H:%M:%S)]${NC} $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[$(date +%Y-%m-%d\ %H:%M:%S)] ERROR:${NC} $1" | tee -a "$LOG_FILE"
}

log_warn() {
    echo -e "${YELLOW}[$(date +%Y-%m-%d\ %H:%M:%S)] WARNING:${NC} $1" | tee -a "$LOG_FILE"
}

log_info() {
    echo -e "${BLUE}[$(date +%Y-%m-%d\ %H:%M:%S)] INFO:${NC} $1" | tee -a "$LOG_FILE"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        log_error "This script must be run as root or with sudo"
        exit 1
    fi
}

# Create logs directory
mkdir -p "$SCRIPT_DIR/../logs"

echo ""
echo "========================================"
echo "  Privacy & VPN Tools Installer"
echo "========================================"
echo ""

log "Starting installation process..."

# --- Step 1: System Update ---
log "Updating system packages..."
apt update >> "$LOG_FILE" 2>&1 && apt upgrade -y >> "$LOG_FILE" 2>&1
log "System update completed"

# --- Step 2: Install Base Privacy Tools ---
log "Installing base privacy and security packages..."
PACKAGES=(
    "tor"
    "dnscrypt-proxy"
    "macchanger"
    "apparmor"
    "apparmor-utils"
    "bleachbit"
    "firejail"
    "curl"
    "wget"
    "ufw"
    "iptables"
    "dnsmasq"
    "torbrowser-launcher"
)

for package in "${PACKAGES[@]}"; do
    log_info "Installing $package..."
    apt install -y "$package" >> "$LOG_FILE" 2>&1 || log_warn "Failed to install $package"
done

log "Base packages installation completed"

# --- Step 3: Install ProtonVPN CLI ---
log "Setting up ProtonVPN CLI..."

# Download and install ProtonVPN repository
log_info "Downloading ProtonVPN repository package..."
cd /tmp
wget -q https://repo.protonvpn.com/debian/dists/stable/main/binary-all/protonvpn-stable-release_1.0.3-3_all.deb

log_info "Installing ProtonVPN repository..."
dpkg -i protonvpn-stable-release_1.0.3-3_all.deb >> "$LOG_FILE" 2>&1

log_info "Updating package list..."
apt update >> "$LOG_FILE" 2>&1

log_info "Installing ProtonVPN packages..."
apt install -y proton-vpn-gnome-desktop >> "$LOG_FILE" 2>&1
apt install -y libayatana-appindicator3-1 gir1.2-ayatanaappindicator3-0.1 gnome-shell-extension-appindicator >> "$LOG_FILE" 2>&1 || log_warn "Some GUI packages failed to install (normal on non-GNOME systems)"

# Cleanup
rm -f /tmp/protonvpn-stable-release_1.0.3-3_all.deb

log "ProtonVPN CLI installed successfully"

# --- Step 4: Configure Tor ---
log "Configuring Tor service..."
systemctl enable tor >> "$LOG_FILE" 2>&1
systemctl start tor >> "$LOG_FILE" 2>&1
log "Tor service enabled and started"

# --- Step 5: Configure DNSCrypt ---
log "Configuring DNSCrypt-Proxy..."
systemctl enable dnscrypt-proxy >> "$LOG_FILE" 2>&1
systemctl start dnscrypt-proxy >> "$LOG_FILE" 2>&1
log "DNSCrypt-Proxy enabled and started"

# --- Step 6: Configure Firewall (UFW) ---
log "Configuring UFW firewall..."
ufw --force enable >> "$LOG_FILE" 2>&1
ufw default deny incoming >> "$LOG_FILE" 2>&1
ufw default allow outgoing >> "$LOG_FILE" 2>&1
log "Firewall configured and enabled"

# --- Step 7: Enable AppArmor ---
log "Enabling AppArmor..."
systemctl enable apparmor >> "$LOG_FILE" 2>&1
systemctl start apparmor >> "$LOG_FILE" 2>&1
log "AppArmor enabled and started"

# --- Step 8: Install Secure Messaging Apps ---
log "Installing secure messaging applications..."
apt install -y signal-desktop telegram-desktop >> "$LOG_FILE" 2>&1 || log_warn "Some messaging apps failed to install (check repositories)"

# --- Step 9: Configure MAC Address Randomization ---
log "Configuring MAC address randomization..."
if [ -f /etc/network/interfaces ]; then
    if ! grep -q 'macchanger' /etc/network/interfaces; then
        echo "" >> /etc/network/interfaces
        echo "# MAC address randomization" >> /etc/network/interfaces
        echo "# Uncomment for your network interface" >> /etc/network/interfaces
        echo "# pre-up /usr/bin/macchanger -r eth0" >> /etc/network/interfaces
        log "MAC address randomization configured (commented out - edit /etc/network/interfaces to enable)"
    else
        log_info "MAC address randomization already configured"
    fi
fi

# --- Step 10: Configure DNS-over-HTTPS ---
log "Configuring DNS-over-HTTPS with dnsmasq..."
if [ ! -f /etc/dnsmasq.conf.backup ]; then
    cp /etc/dnsmasq.conf /etc/dnsmasq.conf.backup 2>/dev/null || true
fi

cat > /etc/dnsmasq.conf << 'EOF'
# DNS-over-HTTPS Configuration
server=127.0.0.1#5053
listen-address=127.0.0.1
bind-interfaces
EOF

log "DNS-over-HTTPS configured"

# --- Step 11: Create configuration file ---
log "Creating configuration file..."
cat > "$SCRIPT_DIR/../privacy-tools.conf" << 'EOF'
# Privacy Tools Configuration
# Edit this file to customize your setup

# VPN Settings
VPN_ENABLED=true
VPN_AUTOCONNECT=false

# Privacy Settings
TOR_ENABLED=true
DNSCRYPT_ENABLED=true
MAC_RANDOMIZATION=false

# Monitoring Settings
MONITOR_INTERVAL=60
LOG_RETENTION_DAYS=30
EOF

log "Configuration file created at $SCRIPT_DIR/../privacy-tools.conf"

# --- Cleanup ---
log "Running cleanup..."
apt autoremove -y >> "$LOG_FILE" 2>&1
apt clean >> "$LOG_FILE" 2>&1

echo ""
echo "========================================"
log "${GREEN}Installation completed successfully!${NC}"
echo "========================================"
echo ""
log_info "Next steps:"
echo "  1. Login to ProtonVPN: protonvpn-cli login"
echo "  2. Connect to VPN: protonvpn-cli connect --fastest"
echo "  3. Enable kill switch: protonvpn-cli killswitch --on"
echo "  4. Run the monitor: ./privacy-manager.sh monitor"
echo ""
log_info "Log file saved to: $LOG_FILE"
echo ""
log_warn "Note: A system reboot is recommended to apply all changes."

