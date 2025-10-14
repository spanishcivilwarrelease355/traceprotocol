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
    
    # Print with carriage return to update same line (clear rest of line with spaces)
    printf "\r${CYAN}Progress:${NC} ${bar} ${YELLOW}%3d%%${NC} - %-40s" "$percent" "$description..."
}

# Function to finish progress (move to new line)
finish_progress() {
    echo ""
}

# Function to log messages (silent - log file only during installation)
log() {
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] $1" >> "$LOG_FILE"
}

log_error() {
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] ERROR: $1" >> "$LOG_FILE"
}

log_warn() {
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] WARNING: $1" >> "$LOG_FILE"
}

log_info() {
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] INFO: $1" >> "$LOG_FILE"
}

# Function to show message on screen (use for final output only)
show_message() {
    echo -e "${GREEN}[$(date +%Y-%m-%d\ %H:%M:%S)]${NC} $1" | tee -a "$LOG_FILE"
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}This script must be run as root or with sudo${NC}"
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


echo ""
echo -e "${CYAN}Starting installation process...${NC}"
echo ""

# --- Step 1: System Update ---
CURRENT_STEP=1
show_progress $CURRENT_STEP $TOTAL_STEPS "Updating system packages"
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Updating system packages..." >> "$LOG_FILE"

# Update package list
apt update -qq >> "$LOG_FILE" 2>&1

# Use 'yes' to automatically answer prompts and upgrade
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Upgrading packages (this may take a while)..." >> "$LOG_FILE"
yes | apt upgrade -y -qq -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" >> "$LOG_FILE" 2>&1 || true

echo "[$(date +%Y-%m-%d\ %H:%M:%S)] System update completed" >> "$LOG_FILE"
sleep 0.5

# --- Step 2: Install Base Privacy Tools ---
CURRENT_STEP=2
show_progress $CURRENT_STEP $TOTAL_STEPS "Installing base privacy packages"
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Installing base privacy and security packages..." >> "$LOG_FILE"
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
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] INFO: Installing $package..." >> "$LOG_FILE"
    apt install -y -qq "$package" >> "$LOG_FILE" 2>&1 || echo "[$(date +%Y-%m-%d\ %H:%M:%S)] WARNING: Failed to install $package" >> "$LOG_FILE"
done

echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Base packages installation completed" >> "$LOG_FILE"
sleep 0.5

# --- Step 3: Install DNSCrypt-Proxy from GitHub ---
CURRENT_STEP=3
show_progress $CURRENT_STEP $TOTAL_STEPS "Installing DNSCrypt-Proxy"
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Installing DNSCrypt-Proxy from GitHub..." >> "$LOG_FILE"

DNSCRYPT_VERSION="2.1.5"
DNSCRYPT_ARCH="linux_x86_64"
DNSCRYPT_URL="https://github.com/DNSCrypt/dnscrypt-proxy/releases/download/${DNSCRYPT_VERSION}/dnscrypt-proxy-${DNSCRYPT_ARCH}-${DNSCRYPT_VERSION}.tar.gz"

echo "[$(date +%Y-%m-%d\ %H:%M:%S)] INFO: Downloading DNSCrypt-Proxy ${DNSCRYPT_VERSION}..." >> "$LOG_FILE"
cd /tmp
wget -q "$DNSCRYPT_URL" -O dnscrypt-proxy.tar.gz

if [ -f dnscrypt-proxy.tar.gz ]; then
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] INFO: Extracting DNSCrypt-Proxy..." >> "$LOG_FILE"
    tar -xzf dnscrypt-proxy.tar.gz
    
    cd linux-x86_64
    
    # Install binary
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] INFO: Installing DNSCrypt-Proxy binary..." >> "$LOG_FILE"
    cp -f dnscrypt-proxy /usr/local/bin/
    chmod +x /usr/local/bin/dnscrypt-proxy
    
    # Create config directory
    mkdir -p /etc/dnscrypt-proxy
    
    # Copy configuration
    cp -f example-dnscrypt-proxy.toml /etc/dnscrypt-proxy/dnscrypt-proxy.toml
    
    # Create systemd service
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] INFO: Creating DNSCrypt-Proxy systemd service..." >> "$LOG_FILE"
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
    
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] DNSCrypt-Proxy installed successfully from GitHub!" >> "$LOG_FILE"
else
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] WARNING: Failed to download DNSCrypt-Proxy. Skipping..." >> "$LOG_FILE"
fi
sleep 0.5

# --- Step 4: Install ProtonVPN CLI ---
CURRENT_STEP=4
show_progress $CURRENT_STEP $TOTAL_STEPS "Installing ProtonVPN CLI"
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Setting up ProtonVPN CLI..." >> "$LOG_FILE"

# Install dependencies
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] INFO: Installing ProtonVPN dependencies..." >> "$LOG_FILE"
apt install -y -qq gnupg2 apt-transport-https ca-certificates >> "$LOG_FILE" 2>&1

# Download and import ProtonVPN GPG key
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] INFO: Adding ProtonVPN GPG key..." >> "$LOG_FILE"
wget -qO /tmp/protonvpn_signing_key.asc https://repo.protonvpn.com/debian/public_key.asc
gpg --dearmor < /tmp/protonvpn_signing_key.asc > /usr/share/keyrings/protonvpn-stable-archive-keyring.gpg
rm -f /tmp/protonvpn_signing_key.asc

# Add ProtonVPN repository
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] INFO: Adding ProtonVPN repository..." >> "$LOG_FILE"
echo "deb [signed-by=/usr/share/keyrings/protonvpn-stable-archive-keyring.gpg] https://repo.protonvpn.com/debian stable main" > /etc/apt/sources.list.d/protonvpn.list

# Update package list
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] INFO: Updating package list..." >> "$LOG_FILE"
apt update -qq >> "$LOG_FILE" 2>&1

# Install ProtonVPN CLI
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] INFO: Installing ProtonVPN CLI..." >> "$LOG_FILE"
apt install -y -qq protonvpn-cli >> "$LOG_FILE" 2>&1

echo "[$(date +%Y-%m-%d\ %H:%M:%S)] ProtonVPN CLI installed successfully" >> "$LOG_FILE"
sleep 0.5

# --- Step 5: Configure Tor ---
CURRENT_STEP=5
show_progress $CURRENT_STEP $TOTAL_STEPS "Configuring Tor service"
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Configuring Tor service..." >> "$LOG_FILE"
systemctl enable tor >> "$LOG_FILE" 2>&1
systemctl start tor >> "$LOG_FILE" 2>&1
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Tor service enabled and started" >> "$LOG_FILE"
sleep 0.5

# --- Step 6: Configure DNSCrypt ---
CURRENT_STEP=6
show_progress $CURRENT_STEP $TOTAL_STEPS "Configuring DNSCrypt-Proxy"
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Configuring DNSCrypt-Proxy..." >> "$LOG_FILE"
# Enable and start the dnscrypt-proxy service
systemctl enable dnscrypt-proxy >> "$LOG_FILE" 2>&1
systemctl start dnscrypt-proxy >> "$LOG_FILE" 2>&1

# Check if it started successfully
if systemctl is-active --quiet dnscrypt-proxy; then
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] DNSCrypt-Proxy enabled and started successfully" >> "$LOG_FILE"
else
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] WARNING: DNSCrypt-Proxy service may not have started (check logs)" >> "$LOG_FILE"
fi

# Configure system DNS to use DNSCrypt-Proxy
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Configuring system DNS to use DNSCrypt-Proxy..." >> "$LOG_FILE"

# Backup original resolv.conf
if [ ! -f /etc/resolv.conf.traceprotocol-backup ]; then
    cp /etc/resolv.conf /etc/resolv.conf.traceprotocol-backup >> "$LOG_FILE" 2>&1
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Original resolv.conf backed up" >> "$LOG_FILE"
fi

# Stop systemd-resolved if running (conflicts with DNSCrypt on port 53)
if systemctl is-active --quiet systemd-resolved 2>/dev/null; then
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Stopping systemd-resolved (port 53 conflict)..." >> "$LOG_FILE"
    systemctl stop systemd-resolved >> "$LOG_FILE" 2>&1
    systemctl disable systemd-resolved >> "$LOG_FILE" 2>&1
fi

# Create NetworkManager configuration to use DNSCrypt-Proxy
mkdir -p /etc/NetworkManager/conf.d
cat > /etc/NetworkManager/conf.d/dnscrypt.conf << 'DNSEOF'
[main]
dns=none
systemd-resolved=false

[global-dns]
searches=

[global-dns-domain-*]
servers=127.0.0.1
DNSEOF

echo "[$(date +%Y-%m-%d\ %H:%M:%S)] NetworkManager configured to use DNSCrypt-Proxy" >> "$LOG_FILE"

# Remove immutable flag if set
chattr -i /etc/resolv.conf 2>/dev/null || true

# Update resolv.conf to use DNSCrypt-Proxy
cat > /etc/resolv.conf << 'RESOLVEOF'
# DNSCrypt-Proxy DNS Configuration (TraceProtocol)
# DNS queries are encrypted via DNSCrypt-Proxy
nameserver 127.0.0.1
options edns0
RESOLVEOF

# Make it immutable to prevent NetworkManager from overwriting
chattr +i /etc/resolv.conf 2>/dev/null || true

echo "[$(date +%Y-%m-%d\ %H:%M:%S)] System DNS configured to use 127.0.0.1 (DNSCrypt-Proxy)" >> "$LOG_FILE"

# Restart NetworkManager to apply DNS changes
systemctl restart NetworkManager >> "$LOG_FILE" 2>&1

sleep 0.5

# --- Step 7: Configure Firewall (UFW) - Configure but keep disabled ---
CURRENT_STEP=7
show_progress $CURRENT_STEP $TOTAL_STEPS "Configuring UFW firewall"
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Configuring UFW firewall rules..." >> "$LOG_FILE"
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

echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Firewall rules configured (will be enabled after VPN setup)" >> "$LOG_FILE"
sleep 0.5

# --- Step 8: Enable AppArmor ---
CURRENT_STEP=8
show_progress $CURRENT_STEP $TOTAL_STEPS "Enabling AppArmor security"
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Enabling AppArmor..." >> "$LOG_FILE"
systemctl enable apparmor >> "$LOG_FILE" 2>&1
systemctl start apparmor >> "$LOG_FILE" 2>&1
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] AppArmor enabled and started" >> "$LOG_FILE"
sleep 0.5

# --- Step 8: Install Secure Messaging Apps (SKIPPED) ---
# User opted out of installing messaging apps
# To install manually: apt install signal-desktop telegram-desktop

# --- Step 9: Save Original MAC Address ---
CURRENT_STEP=9
show_progress $CURRENT_STEP $TOTAL_STEPS "Saving original MAC address"
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Saving original MAC address..." >> "$LOG_FILE"

# Save original MAC address for later reference
mkdir -p /var/lib/traceprotocol

# Get the primary network interface
PRIMARY_INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)

if [ -n "$PRIMARY_INTERFACE" ]; then
    # Get permanent MAC address
    ORIGINAL_MAC=$(ethtool -P "$PRIMARY_INTERFACE" 2>/dev/null | awk '{print $3}')
    
    if [ -n "$ORIGINAL_MAC" ] && [ "$ORIGINAL_MAC" != "00:00:00:00:00:00" ]; then
        echo "$ORIGINAL_MAC" > /var/lib/traceprotocol/original_mac.txt
        echo "$PRIMARY_INTERFACE" > /var/lib/traceprotocol/primary_interface.txt
        echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Original MAC address saved: $ORIGINAL_MAC for $PRIMARY_INTERFACE" >> "$LOG_FILE"
    fi
fi
sleep 0.5

# --- Step 10: Create configuration file ---
CURRENT_STEP=10
show_progress $CURRENT_STEP $TOTAL_STEPS "Creating configuration files"
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Creating configuration file..." >> "$LOG_FILE"
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

echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Configuration file created at $SCRIPT_DIR/../privacy-tools.conf" >> "$LOG_FILE"
sleep 0.5

# --- Step 11: Create Conky Configuration ---
CURRENT_STEP=11
show_progress $CURRENT_STEP $TOTAL_STEPS "Creating Conky widget"
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Creating Conky desktop widget configuration..." >> "$LOG_FILE"

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
    
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Conky widget configuration created!" >> "$LOG_FILE"
else
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] WARNING: Could not determine user for Conky configuration" >> "$LOG_FILE"
fi
sleep 0.5

# --- Step 12: Cleanup ---
CURRENT_STEP=12
show_progress $CURRENT_STEP $TOTAL_STEPS "Cleaning up"
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Running cleanup..." >> "$LOG_FILE"
apt autoremove -y -qq >> "$LOG_FILE" 2>&1
apt clean -qq >> "$LOG_FILE" 2>&1
sleep 0.5

# --- Step 13: Start Conky Widget ---
CURRENT_STEP=13
show_progress $CURRENT_STEP $TOTAL_STEPS "Starting Conky widget"
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Starting Conky desktop widget..." >> "$LOG_FILE"

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
    
    sleep 1
    
    # Verify Conky is running
    if pgrep -u "$SUDO_USER" conky >/dev/null 2>&1; then
        echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Conky widget started successfully!" >> "$LOG_FILE"
    else
        echo "[$(date +%Y-%m-%d\ %H:%M:%S)] WARNING: Conky widget may not have started. It will auto-start on next login." >> "$LOG_FILE"
    fi
else
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] WARNING: Conky configuration not found. Widget will start on next login." >> "$LOG_FILE"
fi

# Finish progress bar
finish_progress

# Professional completion message
echo ""
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                                ║${NC}"
echo -e "${GREEN}║           ✓  Installation Completed Successfully!              ║${NC}"
echo -e "${GREEN}║                                                                ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  What Was Installed${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${GREEN}✓${NC}  ProtonVPN CLI"
echo -e "  ${GREEN}✓${NC}  Tor, DNSCrypt-Proxy (DNS: 127.0.0.1), AppArmor"
echo -e "  ${GREEN}✓${NC}  Privacy tools (macchanger, firejail, bleachbit)"
echo -e "  ${GREEN}✓${NC}  Conky desktop widget (top-right corner)"
echo -e "  ${GREEN}✓${NC}  UFW firewall (configured, not yet enabled)"
echo -e "  ${GREEN}✓${NC}  DNS encryption via DNSCrypt-Proxy (nameserver 127.0.0.1)"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  ⚠  IMPORTANT: Next Step Required${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${YELLOW}ProtonVPN needs to be configured (as normal user, not sudo):${NC}"
echo ""
echo -e "  ${GREEN}./trace-protocol.sh vpn-setup${NC}"
echo ""
echo -e "  This will:"
echo -e "    1. Login to ProtonVPN with your credentials"
echo -e "    2. Connect to the fastest VPN server"
echo -e "    3. Enable kill switch"
echo -e "    4. Optionally enable UFW firewall"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  Quick Commands${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  VPN Setup:      ${GREEN}./trace-protocol.sh vpn-setup${NC} (NO sudo!)"
echo -e "  Check Status:   ${GREEN}./trace-protocol.sh monitor${NC}"
echo -e "  All Commands:   ${GREEN}./trace-protocol.sh help${NC}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  Log file: ${BLUE}$LOG_FILE${NC}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

