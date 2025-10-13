#!/bin/bash

# TraceProtocol Installation Script
# Installs ProtonVPN CLI and essential privacy tools for Parrot OS / Debian-based systems

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/../logs/install_$(date +%Y%m%d_%H%M%S).log"

# Make all apt operations non-interactive
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none
export NEEDRESTART_MODE=a

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
echo "      TraceProtocol Installer"
echo "========================================"
echo ""

log "Starting installation process..."

# --- Step 1: System Update ---
log "Updating system packages..."

# Update package list
apt update -qq >> "$LOG_FILE" 2>&1

# Use 'yes' to automatically answer prompts and upgrade
log "Upgrading packages (this may take a while)..."
yes | apt upgrade -y -qq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" >> "$LOG_FILE" 2>&1 || true

log "System update completed"

# --- Step 2: Install Base Privacy Tools ---
log "Installing base privacy and security packages..."
PACKAGES=(
    "tor"
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
    "conky-all"
    "dnsutils"
    "coreutils"
    "dnscrypt-proxy2"
)

for package in "${PACKAGES[@]}"; do
    log_info "Installing $package..."
    apt install -y -qq "$package" >> "$LOG_FILE" 2>&1 || log_warn "Failed to install $package"
done

log "Base packages installation completed"

# --- Step 3: Install ProtonVPN CLI ---
log "Setting up ProtonVPN CLI..."

# Install dependencies
log_info "Installing ProtonVPN dependencies..."
apt install -y -qq gnupg2 apt-transport-https ca-certificates >> "$LOG_FILE" 2>&1

# Download and import ProtonVPN GPG key
log_info "Adding ProtonVPN GPG key..."
wget -qO /tmp/protonvpn_signing_key.asc https://repo.protonvpn.com/debian/public_key.asc
gpg --dearmor < /tmp/protonvpn_signing_key.asc > /usr/share/keyrings/protonvpn-stable-archive-keyring.gpg
rm -f /tmp/protonvpn_signing_key.asc

# Add ProtonVPN repository
log_info "Adding ProtonVPN repository..."
echo "deb [signed-by=/usr/share/keyrings/protonvpn-stable-archive-keyring.gpg] https://repo.protonvpn.com/debian stable main" > /etc/apt/sources.list.d/protonvpn.list

# Update package list
log_info "Updating package list..."
apt update -qq >> "$LOG_FILE" 2>&1

# Install ProtonVPN CLI
log_info "Installing ProtonVPN CLI..."
apt install -y -qq protonvpn-cli >> "$LOG_FILE" 2>&1

log "ProtonVPN CLI installed successfully"

# --- Step 4: Configure Tor ---
log "Configuring Tor service..."
systemctl enable tor >> "$LOG_FILE" 2>&1
systemctl start tor >> "$LOG_FILE" 2>&1
log "Tor service enabled and started"

# --- Step 5: Configure DNSCrypt ---
log "Configuring DNSCrypt-Proxy..."
# Try both dnscrypt-proxy and dnscrypt-proxy2 service names
systemctl enable dnscrypt-proxy 2>/dev/null || systemctl enable dnscrypt-proxy2 >> "$LOG_FILE" 2>&1
systemctl start dnscrypt-proxy 2>/dev/null || systemctl start dnscrypt-proxy2 >> "$LOG_FILE" 2>&1
log "DNSCrypt-Proxy enabled and started"

# --- Step 6: Configure Firewall (UFW) - Enable it first ---
log "Configuring UFW firewall..."
# Enable UFW before ProtonVPN setup
ufw --force enable >> "$LOG_FILE" 2>&1
ufw default deny incoming >> "$LOG_FILE" 2>&1
ufw default allow outgoing >> "$LOG_FILE" 2>&1
# Allow DNS for ProtonVPN
ufw allow out 53 >> "$LOG_FILE" 2>&1
ufw allow out 443 >> "$LOG_FILE" 2>&1
log "Firewall configured and enabled"

# --- Step 7: Enable AppArmor ---
log "Enabling AppArmor..."
systemctl enable apparmor >> "$LOG_FILE" 2>&1
systemctl start apparmor >> "$LOG_FILE" 2>&1
log "AppArmor enabled and started"

# --- Step 8: Install Secure Messaging Apps (SKIPPED) ---
# User opted out of installing messaging apps
# To install manually: apt install signal-desktop telegram-desktop

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

# --- Step 11b: Create Conky Configuration ---
log "Creating Conky desktop widget configuration..."

if [ -n "$SUDO_USER" ]; then
    CONKY_FILE="/home/$SUDO_USER/.conkyrc"
    AUTOSTART_DIR="/home/$SUDO_USER/.config/autostart"
    AUTOSTART_FILE="$AUTOSTART_DIR/traceprotocol-conky.desktop"
    
    # Create Conky configuration
    cat > "$CONKY_FILE" << 'CONKYEOF'
conky.config = {
    -- Window Settings
    alignment = 'top_right',
    gap_x = 20,
    gap_y = 50,
    minimum_width = 350,
    maximum_width = 350,
    
    -- Transparency and Window Properties
    background = true,
    own_window = true,
    own_window_type = 'desktop',
    own_window_transparent = false,
    own_window_argb_visual = true,
    own_window_argb_value = 180,
    own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
    own_window_colour = '000000',
    
    -- Borders
    border_width = 1,
    draw_borders = false,
    draw_graph_borders = true,
    draw_outline = false,
    draw_shades = true,
    
    -- Font Settings
    use_xft = true,
    font = 'DejaVu Sans Mono:size=9',
    xftalpha = 0.8,
    uppercase = false,
    
    -- Colors
    default_color = 'white',
    default_shade_color = 'black',
    default_outline_color = 'black',
    color1 = '00FF00',  -- Green for success
    color2 = 'FF0000',  -- Red for errors
    color3 = 'FFFF00',  -- Yellow for warnings
    color4 = '00FFFF',  -- Cyan for info
    color5 = 'FF8800',  -- Orange for highlights
    
    -- Update Settings
    update_interval = 5.0,
    cpu_avg_samples = 2,
    net_avg_samples = 2,
    
    -- Display Settings
    double_buffer = true,
    no_buffers = true,
    out_to_console = false,
    out_to_stderr = false,
    extra_newline = false,
    
    -- Text Settings
    stippled_borders = 0,
    override_utf8_locale = true,
    format_human_readable = true,
};

conky.text = [[
${color5}${font DejaVu Sans Mono:size=12:bold}╔═══════════════════════════════════╗${font}
${color5}${font DejaVu Sans Mono:size=12:bold}║      TraceProtocol Monitor      ║${font}
${color5}${font DejaVu Sans Mono:size=12:bold}╚═══════════════════════════════════╝${font}

${color4}${font DejaVu Sans Mono:size=10:bold}━━━ VPN STATUS ━━━${font}
${color}${exec bash -c 'if command -v protonvpn-cli &>/dev/null; then status=$(protonvpn-cli status 2>/dev/null); if echo "$status" | grep -qi "connected"; then echo "${color1}✓ Connected"; else echo "${color2}✗ Disconnected"; fi; else echo "${color3}⚠ Not Installed"; fi'}

${if_match ${exec bash -c 'protonvpn-cli status 2>/dev/null | grep -qi "connected" && echo 1 || echo 0'} == 1}\
${color}Server: ${color4}${execi 30 protonvpn-cli status 2>/dev/null | grep "Server:" | cut -d: -f2 | xargs}
${color}IP: ${color4}${execi 30 protonvpn-cli status 2>/dev/null | grep "IP:" | cut -d: -f2 | xargs}
${color}Country: ${color4}${execi 60 curl -s https://ipapi.co/country_name/ 2>/dev/null || echo "Unknown"}
${else}\
${color3}No VPN Connection Active
${endif}

${color4}${font DejaVu Sans Mono:size=10:bold}━━━ SECURITY STATUS ━━━${font}
${color}Kill Switch: ${exec bash -c 'if command -v protonvpn-cli &>/dev/null; then ks=$(protonvpn-cli ks --status 2>/dev/null); if echo "$ks" | grep -qi "enabled\|on"; then echo "${color1}✓ Enabled"; else echo "${color3}○ Disabled"; fi; else echo "${color2}✗ N/A"; fi'}

${color}Tor Service: ${if_running tor}${color1}✓ Running${else}${color2}✗ Stopped${endif}

${color}DNSCrypt: ${if_running dnscrypt-proxy}${color1}✓ Active${else}${color2}✗ Inactive${endif}

${color}AppArmor: ${if_running apparmord}${color1}✓ Enabled${else}${color3}○ Disabled${endif}

${color}Firewall: ${exec bash -c 'if sudo ufw status 2>/dev/null | grep -qi "active"; then echo "${color1}✓ Active"; else echo "${color2}✗ Inactive"; fi'}

${color4}${font DejaVu Sans Mono:size=10:bold}━━━ NETWORK INFO ━━━${font}
${color}Public IP: ${color4}${execi 60 curl -s https://api.ipify.org 2>/dev/null || echo "Checking..."}

${color}DNS Server: ${color4}${execi 300 dig +short myip.opendns.com @resolver1.opendns.com 2>/dev/null || echo "N/A"}

${color}Interface: ${color4}${gw_iface}
${color}Local IP: ${color4}${addr ${gw_iface}}

${color4}${font DejaVu Sans Mono:size=10:bold}━━━ SYSTEM STATUS ━━━${font}
${color}CPU: ${color4}${cpu}%  ${color}${cpubar 6}
${color}RAM: ${color4}${memperc}%  ${color}${membar 6}
${color}Disk: ${color4}${fs_used_perc /}%  ${color}${fs_bar 6 /}

${color}Uptime: ${color4}${uptime_short}
${color}Time: ${color4}${time %H:%M:%S}  ${color}Date: ${color4}${time %Y-%m-%d}

${color5}${alignc}TraceProtocol v1.0.0
]];
CONKYEOF

    # Set proper ownership
    chown "$SUDO_USER:$SUDO_USER" "$CONKY_FILE"
    
    # Create autostart directory and file
    mkdir -p "$AUTOSTART_DIR"
    cat > "$AUTOSTART_FILE" << 'AUTOSTARTEOF'
[Desktop Entry]
Type=Application
Name=TraceProtocol Monitor
Comment=TraceProtocol VPN and Privacy Status Monitor
Exec=sh -c "sleep 15 && conky -c ~/.conkyrc"
Icon=security-high
Terminal=false
Hidden=false
X-GNOME-Autostart-enabled=true
X-KDE-autostart-after=panel
X-MATE-Autostart-enabled=true
Categories=System;Monitor;Security;
StartupNotify=false
AUTOSTARTEOF
    
    chmod +x "$AUTOSTART_FILE"
    chown -R "$SUDO_USER:$SUDO_USER" "$AUTOSTART_DIR"
    
    log "${GREEN}Conky widget configuration created!${NC}"
else
    log_warn "Could not determine user for Conky configuration"
fi

# --- Cleanup ---
log "Running cleanup..."
apt autoremove -y -qq >> "$LOG_FILE" 2>&1
apt clean -qq >> "$LOG_FILE" 2>&1

# --- Step 12: Automatic ProtonVPN Setup ---
echo ""
echo "========================================"
log "${BLUE}Automatic ProtonVPN Configuration${NC}"
echo "========================================"
echo ""

if command -v protonvpn-cli &>/dev/null; then
    log "${GREEN}ProtonVPN CLI is installed successfully!${NC}"
    echo ""
    
    # Make sure vpn-setup.sh exists and is executable
    VPN_SETUP_SCRIPT="$SCRIPT_DIR/vpn-setup.sh"
    if [ -f "$VPN_SETUP_SCRIPT" ] && [ -n "$SUDO_USER" ]; then
        chmod +x "$VPN_SETUP_SCRIPT"
        chown "$SUDO_USER:$SUDO_USER" "$VPN_SETUP_SCRIPT"
    fi
    
    echo -e "${CYAN}════════════════════════════════════════${NC}"
    echo -e "${YELLOW}IMPORTANT: ProtonVPN Setup Required${NC}"
    echo -e "${CYAN}════════════════════════════════════════${NC}"
    echo ""
    echo -e "${YELLOW}ProtonVPN cannot be configured while running as root.${NC}"
    echo ""
    echo -e "${BLUE}After this installation completes, please run:${NC}"
    echo ""
    echo -e "${GREEN}  ./privacy-manager.sh vpn-setup${NC}"
    echo ""
    echo -e "${YELLOW}(WITHOUT sudo - as your normal user)${NC}"
    echo ""
    echo "This will:"
    echo "  1. Login to ProtonVPN with your credentials"
    echo "  2. Connect to the fastest VPN server"
    echo "  3. Enable the kill switch"
    echo ""
    echo -e "${CYAN}════════════════════════════════════════${NC}"
    echo ""
    
    # Wait a moment so user can read the message
    sleep 3
else
    log_error "ProtonVPN CLI not found. Please check installation."
fi

# --- Step 13: Start Conky Widget ---
echo ""
log "Starting Conky desktop widget..."

if [ -f "/home/$SUDO_USER/.conkyrc" ]; then
    # Kill existing Conky instances
    pkill conky 2>/dev/null || true
    sleep 1
    
    # Start Conky as the actual user (not root)
    if [ -n "$SUDO_USER" ]; then
        sudo -u "$SUDO_USER" DISPLAY=:0 conky -c "/home/$SUDO_USER/.conkyrc" &
        log "${GREEN}Conky widget started!${NC}"
        log_info "Look at the top-right corner of your screen for the TraceProtocol monitor"
    fi
else
    log_warn "Conky configuration not found. Widget will start on next login."
fi

echo ""
echo "========================================"
log "${GREEN}Installation completed successfully!${NC}"
echo "========================================"
echo ""
log_info "TraceProtocol is now installed and configured!"
echo ""
log_info "ProtonVPN Setup:"
echo "  • If you skipped VPN setup, run (WITHOUT sudo):"
echo "    ./scripts/vpn-setup.sh"
echo ""
log_info "Quick commands:"
echo "  • Check status: ./privacy-manager.sh monitor"
echo "  • Connect VPN: protonvpn-cli c -f"
echo "  • Disconnect VPN: protonvpn-cli d"
echo "  • VPN status: protonvpn-cli status"
echo "  • View all commands: ./privacy-manager.sh help"
echo ""
log_info "Desktop Widget:"
echo "  • Conky monitor is running in the top-right corner"
echo "  • Auto-starts on login"
echo "  • Restart: pkill conky && conky -c ~/.conkyrc &"
echo ""
log_info "Log file saved to: $LOG_FILE"
echo ""
log_warn "Note: A system reboot is recommended to apply all changes."
echo ""

