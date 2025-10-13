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
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Progress tracking
TOTAL_STEPS=13
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
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} Step ${step}/${total} - ${percent}% Complete $(printf '%54s' '') ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC} ${bar} ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC} ${description}$(printf '%*s' $((62-${#description})) '') ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

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

show_banner() {
    clear
    echo -e "${CYAN}"
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

                                                                                ░█░█▄░█░▄▀▀░▀█▀▒▄▀▄░█▒░░█▒░▒██▀▒█▀▄
                                                                                ░█░█▒▀█▒▄██░▒█▒░█▀█▒█▄▄▒█▄▄░█▄▄░█▀▄

EOF
    echo -e "${NC}"
}


log "Starting installation process..."

# --- Step 1: System Update ---
CURRENT_STEP=1
show_progress $CURRENT_STEP $TOTAL_STEPS "Updating system packages"
log "Updating system packages..."

# Update package list
apt update -qq >> "$LOG_FILE" 2>&1

# Use 'yes' to automatically answer prompts and upgrade
log "Upgrading packages (this may take a while)..."
yes | apt upgrade -y -qq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" >> "$LOG_FILE" 2>&1 || true

log "System update completed"

# --- Step 2: Install Base Privacy Tools ---
CURRENT_STEP=2
show_progress $CURRENT_STEP $TOTAL_STEPS "Installing base privacy and security packages"
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
)

for package in "${PACKAGES[@]}"; do
    log_info "Installing $package..."
    apt install -y -qq "$package" >> "$LOG_FILE" 2>&1 || log_warn "Failed to install $package"
done

log "Base packages installation completed"

# --- Step 2b: Install DNSCrypt-Proxy from GitHub ---
CURRENT_STEP=3
show_progress $CURRENT_STEP $TOTAL_STEPS "Installing DNSCrypt-Proxy from GitHub"
log "Installing DNSCrypt-Proxy from GitHub..."

DNSCRYPT_VERSION="2.1.5"
DNSCRYPT_ARCH="linux_x86_64"
DNSCRYPT_URL="https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/${DNSCRYPT_VERSION}/dnscrypt-proxy-${DNSCRYPT_ARCH}-${DNSCRYPT_VERSION}.tar.gz"

log_info "Downloading DNSCrypt-Proxy ${DNSCRYPT_VERSION}..."
cd /tmp
wget -q "$DNSCRYPT_URL" -O dnscrypt-proxy.tar.gz

if [ -f dnscrypt-proxy.tar.gz ]; then
    log_info "Extracting DNSCrypt-Proxy..."
    tar -xzf dnscrypt-proxy.tar.gz
    
    cd linux-x86_64
    
    # Install binary
    log_info "Installing DNSCrypt-Proxy binary..."
    cp -f dnscrypt-proxy /usr/local/bin/
    chmod +x /usr/local/bin/dnscrypt-proxy
    
    # Create config directory
    mkdir -p /etc/dnscrypt-proxy
    
    # Copy configuration
    cp -f example-dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml
    
    # Create systemd service
    log_info "Creating DNSCrypt-Proxy systemd service..."
    cat > /etc/systemd/system/dnscrypt-proxy.service << 'DNSCRYPTEOF'
[Unit]
Description=DNSCrypt-Proxy
Documentation=https://github.com/DNSCrypt/dnscrypt-proxy
Wants=network-online.target nss-lookup.target
Before=nss-lookup.target
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml
Restart=on-failure
RestartSec=10
User=nobody
Group=nogroup

[Install]
WantedBy=multi-user.target
DNSCRYPTEOF
    
    # Cleanup
    cd /tmp
    rm -rf linux-x86_64 dnscrypt-proxy.tar.gz
    
    # Reload systemd
    systemctl daemon-reload
    
    log "${GREEN}DNSCrypt-Proxy installed successfully from GitHub!${NC}"
else
    log_warn "Failed to download DNSCrypt-Proxy. Skipping..."
fi

# --- Step 4: Install ProtonVPN CLI ---
CURRENT_STEP=4
show_progress $CURRENT_STEP $TOTAL_STEPS "Installing ProtonVPN CLI"
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

# --- Step 5: Configure Tor ---
CURRENT_STEP=5
show_progress $CURRENT_STEP $TOTAL_STEPS "Configuring Tor service"
log "Configuring Tor service..."
systemctl enable tor >> "$LOG_FILE" 2>&1
systemctl start tor >> "$LOG_FILE" 2>&1
log "Tor service enabled and started"

# --- Step 6: Configure DNSCrypt ---
CURRENT_STEP=6
show_progress $CURRENT_STEP $TOTAL_STEPS "Configuring DNSCrypt-Proxy"
log "Configuring DNSCrypt-Proxy..."
# Enable and start the dnscrypt-proxy service
systemctl enable dnscrypt-proxy >> "$LOG_FILE" 2>&1
systemctl start dnscrypt-proxy >> "$LOG_FILE" 2>&1

# Check if it started successfully
if systemctl is-active --quiet dnscrypt-proxy; then
    log "DNSCrypt-Proxy enabled and started successfully"
else
    log_warn "DNSCrypt-Proxy service may not have started (check logs)"
fi

# --- Step 7: Configure Firewall (UFW) - Configure but keep disabled ---
CURRENT_STEP=7
show_progress $CURRENT_STEP $TOTAL_STEPS "Configuring UFW firewall rules"
log "Configuring UFW firewall rules..."
# Configure UFW rules but keep it DISABLED for now
# It will be enabled after ProtonVPN is connected
ufw --force reset >> "$LOG_FILE" 2>&1
ufw default deny incoming >> "$LOG_FILE" 2>&1
ufw default allow outgoing >> "$LOG_FILE" 2>&1

# Allow essential outgoing connections
ufw allow out 53 >> "$LOG_FILE" 2>&1       # DNS
ufw allow out 80 >> "$LOG_FILE" 2>&1       # HTTP
ufw allow out 443 >> "$LOG_FILE" 2>&1      # HTTPS
ufw allow out 1194 >> "$LOG_FILE" 2>&1     # OpenVPN
ufw allow out 5060 >> "$LOG_FILE" 2>&1     # ProtonVPN alt port
ufw allow out 9418 >> "$LOG_FILE" 2>&1     # Git
ufw allow out 22 >> "$LOG_FILE" 2>&1       # SSH
ufw allow out 21 >> "$LOG_FILE" 2>&1       # FTP
ufw allow out 20 >> "$LOG_FILE" 2>&1       # FTP Data
ufw allow out 25 >> "$LOG_FILE" 2>&1       # SMTP
ufw allow out 587 >> "$LOG_FILE" 2>&1      # SMTP Submission
ufw allow out 465 >> "$LOG_FILE" 2>&1      # SMTPS
ufw allow out 993 >> "$LOG_FILE" 2>&1      # IMAPS
ufw allow out 995 >> "$LOG_FILE" 2>&1      # POP3S

# Allow established connections
ufw logging off >> "$LOG_FILE" 2>&1

log "Firewall rules configured (will be enabled after VPN setup)"

# --- Step 8: Enable AppArmor ---
CURRENT_STEP=8
show_progress $CURRENT_STEP $TOTAL_STEPS "Enabling AppArmor security"
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

# --- Step 9: Save Original MAC Address ---
CURRENT_STEP=9
show_progress $CURRENT_STEP $TOTAL_STEPS "Saving original MAC address"
log "Saving original MAC address..."

# Create TraceProtocol directory
mkdir -p /var/lib/traceprotocol
chmod 755 /var/lib/traceprotocol

# Get all network interfaces (exclude lo, proton, tun, tap)
FOUND_MAC=false
for iface in $(ip link show | awk -F: '/state UP/ {gsub(/ /, "", $2); if ($2 !~ /^(lo|proton|tun|tap)/) print $2}'); do
    # Get the full link info for this interface
    LINK_INFO=$(ip link show "$iface" | grep "link/ether")
    
    if [ -n "$LINK_INFO" ]; then
        # Try to get permanent MAC address (permaddr) - this is the hardware MAC
        PERM_MAC=$(echo "$LINK_INFO" | grep -o "permaddr [0-9a-f:][0-9a-f:]*" | awk '{print $2}')
        
        # Get current MAC address
        CURRENT_MAC=$(echo "$LINK_INFO" | awk '{print $2}')
        
        if [ -n "$PERM_MAC" ]; then
            # Save permanent MAC as original (the real hardware MAC)
            echo "$PERM_MAC" > /var/lib/traceprotocol/original_mac.txt
            echo "$iface" > /var/lib/traceprotocol/interface.txt
            log "Original MAC saved: $PERM_MAC (Interface: $iface) [Hardware MAC from permaddr]"
            FOUND_MAC=true
            break
        elif [ -n "$CURRENT_MAC" ]; then
            # Fallback: save current MAC
            echo "$CURRENT_MAC" > /var/lib/traceprotocol/original_mac.txt
            echo "$iface" > /var/lib/traceprotocol/interface.txt
            log "Original MAC saved: $CURRENT_MAC (Interface: $iface) [No permaddr available]"
            FOUND_MAC=true
            break
        fi
    fi
done

if [ "$FOUND_MAC" = false ]; then
    log_warn "Could not save original MAC address"
fi

# --- Step 10: Create Conky Configuration ---
CURRENT_STEP=10
show_progress $CURRENT_STEP $TOTAL_STEPS "Creating Conky desktop widget"
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
    own_window_transparent = true,
    own_window_argb_visual = true,
    own_window_argb_value = 0,
    own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
    
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
${color}Status: ${exec bash -c 'if protonvpn-cli status 2>/dev/null | grep -q "Server:"; then echo "${color1}✓ Connected"; else echo "${color2}✗ Disconnected"; fi'}
${if_match ${exec bash -c 'protonvpn-cli status 2>/dev/null | grep -q "Server:" && echo 1 || echo 0'} == 1}\
${color}Server: ${color4}${execi 30 protonvpn-cli status 2>/dev/null | grep "Server:" | awk '{print $2}'}
${color}VPN IP: ${color4}${execi 30 protonvpn-cli status 2>/dev/null | grep "IP:" | awk '{print $2}'}
${color}Country: ${color4}${execi 30 protonvpn-cli status 2>/dev/null | grep "Country:" | awk '{print $2}'}
${color}Load: ${color4}${execi 30 protonvpn-cli status 2>/dev/null | grep "Server Load:" | awk '{print $3}'}
${else}\
${color3}No VPN Connection
${color}Real IP: ${color2}${execi 60 curl -s https://api.ipify.org 2>/dev/null || echo "Checking..."}
${endif}

${color4}${font DejaVu Sans Mono:size=10:bold}━━━ IP ADDRESSES ━━━${font}
${color}Public IP: ${color4}${execi 60 curl -s https://api.ipify.org 2>/dev/null || echo "Checking..."}
${color}VPN Tunnel: ${color4}${addr proton0}

${color4}${font DejaVu Sans Mono:size=10:bold}━━━ MAC ADDRESSES ━━━${font}
${color}Interface: ${color4}${exec cat /var/lib/traceprotocol/interface.txt 2>/dev/null || ip link show | grep -v "lo:\|proton\|tun" | grep "state UP" | awk -F: '{print $2}' | tr -d ' ' | head -1}
${color}Original MAC: ${color4}${exec cat /var/lib/traceprotocol/original_mac.txt 2>/dev/null || echo "Not saved"}
${color}Current MAC: ${color4}${exec IFACE=$(cat /var/lib/traceprotocol/interface.txt 2>/dev/null || ip link show | grep -v "lo:\|proton\|tun" | grep "state UP" | awk -F: '{print $2}' | tr -d ' ' | head -1); ip link show $IFACE 2>/dev/null | grep "link/ether" | awk '{print $2}'}

${color4}${font DejaVu Sans Mono:size=10:bold}━━━ SECURITY STATUS ━━━${font}
${color}Kill Switch: ${exec bash -c 'ks=$(protonvpn-cli status 2>/dev/null | grep "Kill switch:"); if echo "$ks" | grep -qi "On"; then echo "${color1}✓ Enabled"; else echo "${color3}○ Disabled"; fi'}
${color}Tor: ${if_running tor}${color1}✓ Running${else}${color2}✗ Stopped${endif}
${color}DNSCrypt: ${exec bash -c 'if systemctl is-active --quiet dnscrypt-proxy 2>/dev/null; then echo "${color1}✓ Active"; else echo "${color2}✗ Inactive"; fi'}
${color}Firewall: ${exec bash -c 'if sudo ufw status 2>/dev/null | grep -qi "Status: active"; then echo "${color1}✓ Active"; else echo "${color2}✗ Inactive"; fi'}

${color4}${font DejaVu Sans Mono:size=10:bold}━━━ SYSTEM STATUS ━━━${font}
${color}CPU: ${color4}${cpu}%  ${color}${cpubar 6}
${color}RAM: ${color4}${memperc}%  ${color}${membar 6}
${color}Disk: ${color4}${fs_used_perc /}%  ${color}${fs_bar 6 /}
${color}Uptime: ${color4}${uptime_short}
${color}Time: ${color4}${time %H:%M:%S}

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
Exec=sh -c "sleep 10 && conky -c $HOME/.conkyrc"
Icon=security-high
Terminal=false
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
X-KDE-autostart-after=panel
X-MATE-Autostart-enabled=true
X-XFCE-Autostart-enabled=true
Categories=System;Monitor;Security;
StartupNotify=false
StartupWMClass=Conky
AUTOSTARTEOF
    
    chmod +x "$AUTOSTART_FILE"
    chown -R "$SUDO_USER:$SUDO_USER" "$AUTOSTART_DIR"
    
    log "${GREEN}Conky widget configuration created!${NC}"
else
    log_warn "Could not determine user for Conky configuration"
fi

# --- Step 11: Cleanup ---
CURRENT_STEP=11
show_progress $CURRENT_STEP $TOTAL_STEPS "Cleaning up temporary files"
log "Running cleanup..."
apt autoremove -y -qq >> "$LOG_FILE" 2>&1
apt clean -qq >> "$LOG_FILE" 2>&1

# --- Step 12: ProtonVPN Setup Information ---
CURRENT_STEP=12
show_progress $CURRENT_STEP $TOTAL_STEPS "ProtonVPN setup preparation"
echo ""
echo "========================================"
log "${BLUE}ProtonVPN Configuration${NC}"
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
    echo -e "${GREEN}  ./trace-protocol.sh vpn-setup${NC}"
    echo ""
    echo -e "${YELLOW}(WITHOUT sudo - as your normal user)${NC}"
    echo ""
    echo "This will:"
    echo "  1. Login to ProtonVPN with your credentials"
    echo "  2. Connect to the fastest VPN server"
    echo "  3. Enable the kill switch"
    echo "  4. Enable UFW firewall"
    echo ""
    echo -e "${YELLOW}Note: UFW firewall is configured but DISABLED${NC}"
    echo "      It will be enabled after VPN connection"
    echo ""
    echo -e "${CYAN}════════════════════════════════════════${NC}"
    echo ""
    
    # Wait a moment so user can read the message
    sleep 3
else
    log_error "ProtonVPN CLI not found. Please check installation."
fi

# --- Step 13: Start Conky Widget ---
CURRENT_STEP=13
show_progress $CURRENT_STEP $TOTAL_STEPS "Starting Conky desktop widget"
echo ""
log "Starting Conky desktop widget..."

if [ -f "/home/$SUDO_USER/.conkyrc" ] && [ -n "$SUDO_USER" ]; then
    # Kill existing Conky instances
    sudo -u "$SUDO_USER" pkill conky 2>/dev/null || true
    sleep 1
    
    # Get user's display and environment
    USER_DISPLAY=$(w -h "$SUDO_USER" | awk '{print $3; exit}')
    if [ -z "$USER_DISPLAY" ]; then
        USER_DISPLAY=":0"
    fi
    
    # Start Conky as the actual user with proper environment
    sudo -u "$SUDO_USER" DISPLAY="$USER_DISPLAY" nohup conky -c "/home/$SUDO_USER/.conkyrc" >/dev/null 2>&1 &
    
    sleep 2
    
    # Verify Conky is running
    if pgrep -u "$SUDO_USER" conky >/dev/null 2>&1; then
        log "${GREEN}Conky widget started successfully!${NC}"
        log_info "Look at the top-right corner of your screen for the TraceProtocol monitor"
    else
        log_warn "Conky widget may not have started. It will auto-start on next login."
    fi
else
    log_warn "Conky configuration not found. Widget will start on next login."
fi

echo ""
echo "========================================"
log "${GREEN}Installation completed successfully!${NC}"
echo "========================================"
echo ""
log_info "TraceProtocol base installation is complete!"
echo ""
echo -e "${YELLOW}⚠ NEXT STEP REQUIRED:${NC}"
echo ""
echo -e "${GREEN}Run the VPN setup (WITHOUT sudo):${NC}"
echo "  ./trace-protocol.sh vpn-setup"
echo ""
echo "This will configure ProtonVPN, connect to VPN, and enable firewall."
echo ""
log_info "What's installed:"
echo "  ✓ ProtonVPN CLI"
echo "  ✓ Tor, DNSCrypt, AppArmor"
echo "  ✓ Privacy tools (macchanger, firejail, bleachbit)"
echo "  ✓ Conky desktop widget"
echo "  ✓ UFW firewall (configured, not yet enabled)"
echo ""
log_info "Quick commands:"
echo "  • Setup VPN: ./trace-protocol.sh vpn-setup (NO sudo!)"
echo "  • Check status: ./trace-protocol.sh monitor"
echo "  • View all commands: ./trace-protocol.sh help"
echo ""
log_info "Desktop Widget:"
echo "  • Conky monitor is running in the top-right corner"
echo "  • Auto-starts on login"
echo "  • Restart: pkill conky && conky -c ~/.conkyrc &"
echo ""
log_info "Log file saved to: $LOG_FILE"
echo ""
echo -e "${YELLOW}════════════════════════════════════════${NC}"
echo -e "${YELLOW}   DON'T REBOOT YET!${NC}"
echo -e "${YELLOW}════════════════════════════════════════${NC}"
echo ""
echo "Please run the VPN setup first:"
echo -e "${GREEN}  ./trace-protocol.sh vpn-setup${NC}"
echo ""
echo "After VPN setup is complete, you can reboot if needed."
echo ""

