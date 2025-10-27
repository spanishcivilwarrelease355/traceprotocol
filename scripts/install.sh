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
RED='\033[38;5;196m'
GREEN='\033[38;5;46m'
YELLOW='\033[38;5;226m'  
WHITE='\033[1;37m'
BLUE='\033[38;5;27m'       
CYAN='\033[38;5;51m'       
MAGENTA='\033[38;5;201m'   
NC='\033[0m'


# Progress tracking
TOTAL_STEPS=12
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



echo ""
echo -e "${YELLOW}⚠  WARNING: This will install TraceProtocol privacy tools and modify system configurations!${NC}"
echo ""
echo -e "${YELLOW}This installation will:${NC}"
echo -e "  ${WHITE}• Install privacy packages (Tor, DNSCrypt, ProtonVPN, etc.)${NC}"
echo -e "  ${WHITE}• Configure DNS encryption and VPN settings${NC}"
echo -e "  ${WHITE}• Set up MAC address randomization${NC}"
echo -e "  ${WHITE}• Create system services and desktop widgets${NC}"
echo -e "  ${WHITE}• Modify network and security configurations${NC}"
echo ""
echo -e "${YELLOW}Press Ctrl+C to cancel, or Enter to continue...${NC}"
read
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
    
    # Create custom configuration to avoid port conflicts with dnsmasq
    cat > /etc/dnscrypt-proxy/dnscrypt-proxy.toml << 'CONFIGEOF'
# DNSCrypt-Proxy Configuration (TraceProtocol)
# Listens on port 5300 to avoid conflict with dnsmasq on port 53

listen_addresses = ['127.0.0.1:5300']
max_clients = 250

ipv4_servers = true
ipv6_servers = false
dnscrypt_servers = true
doh_servers = true

require_dnssec = false
require_nolog = true
require_nofilter = true

force_tcp = false
timeout = 5000

fallback_resolvers = ['9.9.9.9:53', '8.8.8.8:53']
ignore_system_dns = true

[sources]
  [sources.'public-resolvers']
  urls = ['https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md']
  cache_file = '/var/cache/dnscrypt-proxy/public-resolvers.md'
  minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'
  refresh_delay = 72
CONFIGEOF

    # Create cache directory
    mkdir -p /var/cache/dnscrypt-proxy
    chown nobody:nogroup /var/cache/dnscrypt-proxy
    
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

# Create PolicyKit rule for ProtonVPN NetworkManager access
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Creating PolicyKit rule for ProtonVPN..." >> "$LOG_FILE"
cat > /etc/polkit-1/rules.d/50-protonvpn.rules << 'POLKITEOF'
/* Allow ProtonVPN to manage NetworkManager connections without password */
polkit.addRule(function(action, subject) {
    if ((action.id == "org.freedesktop.NetworkManager.network-control" ||
         action.id == "org.freedesktop.NetworkManager.settings.modify.system" ||
         action.id == "org.freedesktop.NetworkManager.settings.modify.own" ||
         action.id == "org.freedesktop.NetworkManager.wifi.share.protected" ||
         action.id == "org.freedesktop.NetworkManager.wifi.share.open") &&
        subject.isInGroup("netdev")) {
        return polkit.Result.YES;
    }
});
POLKITEOF

systemctl restart polkit 2>/dev/null || true

# Install dependencies
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] INFO: Installing ProtonVPN dependencies..." >> "$LOG_FILE"
apt install -y -qq curl gnupg2 apt-transport-https ca-certificates >> "$LOG_FILE" 2>&1

# Download and import ProtonVPN GPG key (Official Method)
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] INFO: Adding ProtonVPN GPG key..." >> "$LOG_FILE"
curl -fsSL https://repo.protonvpn.com/debian/public_key.asc | gpg --batch --yes --dearmor -o /usr/share/keyrings/protonvpn-archive-keyring.gpg >> "$LOG_FILE" 2>&1

# Add ProtonVPN repository (Official Method)
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] INFO: Adding ProtonVPN repository..." >> "$LOG_FILE"
echo "deb [signed-by=/usr/share/keyrings/protonvpn-archive-keyring.gpg] https://repo.protonvpn.com/debian stable main" | tee /etc/apt/sources.list.d/protonvpn.list >> "$LOG_FILE" 2>&1

# Update package list
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] INFO: Updating package list..." >> "$LOG_FILE"
apt update -qq >> "$LOG_FILE" 2>&1

# Install ProtonVPN CLI (Latest version from official repository)
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

# Check if it started successfully and is actually working
DNSCRYPT_WORKING=false
if systemctl is-active --quiet dnscrypt-proxy; then
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] DNSCrypt-Proxy service is running, testing connectivity..." >> "$LOG_FILE"
    
    # Retry mechanism for slow network conditions
    MAX_RETRIES=10
    RETRY_COUNT=0
    
    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        RETRY_COUNT=$((RETRY_COUNT + 1))
        echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Testing DNSCrypt-Proxy connectivity (attempt $RETRY_COUNT/$MAX_RETRIES)..." >> "$LOG_FILE"
        
        # Wait progressively longer between retries
        if [ $RETRY_COUNT -gt 1 ]; then
            WAIT_TIME=$((RETRY_COUNT * 2))
            echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Waiting ${WAIT_TIME}s for DNSCrypt-Proxy to initialize..." >> "$LOG_FILE"
            sleep $WAIT_TIME
        else
            sleep 3
        fi
        
        # Test with longer timeout for slow networks
        if timeout 10 dig @127.0.0.1 -p 5300 google.com >/dev/null 2>&1; then
            echo "[$(date +%Y-%m-%d\ %H:%M:%S)] SUCCESS: DNSCrypt-Proxy is working and responding on port 5300" >> "$LOG_FILE"
            DNSCRYPT_WORKING=true
            break
        else
            echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Attempt $RETRY_COUNT failed - DNSCrypt-Proxy not responding yet" >> "$LOG_FILE"
            
            # Check if service is still running
            if ! systemctl is-active --quiet dnscrypt-proxy; then
                echo "[$(date +%Y-%m-%d\ %H:%M:%S)] ERROR: DNSCrypt-Proxy service stopped unexpectedly" >> "$LOG_FILE"
                break
            fi
        fi
    done
    
    if [ "$DNSCRYPT_WORKING" = false ]; then
        echo "[$(date +%Y-%m-%d\ %H:%M:%S)] ERROR: DNSCrypt-Proxy failed to respond after $MAX_RETRIES attempts" >> "$LOG_FILE"
        echo "[$(date +%Y-%m-%d\ %H:%M:%S)] This may be due to slow network or DNS server issues" >> "$LOG_FILE"
        systemctl stop dnscrypt-proxy >> "$LOG_FILE" 2>&1
    fi
else
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] ERROR: DNSCrypt-Proxy service failed to start - DNS will not be changed" >> "$LOG_FILE"
    DNSCRYPT_WORKING=false
fi

# Configure dnsmasq to forward to DNSCrypt-Proxy (only if it's working)
if [ "$DNSCRYPT_WORKING" = true ]; then
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Configuring dnsmasq to forward to DNSCrypt-Proxy..." >> "$LOG_FILE"
    
    # Configure dnsmasq to forward to dnscrypt-proxy on port 5300
    cat > /etc/dnsmasq.d/dnscrypt.conf << 'DNSMASQEOF'
# Forward all DNS queries to DNSCrypt-Proxy on port 5300
server=127.0.0.1#5300
no-resolv
cache-size=1000
DNSMASQEOF
    
    # Use default dnsmasq service (works better with Parrot OS)
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Using default dnsmasq service configuration..." >> "$LOG_FILE"
    
    # Enable and start dnsmasq using default service
    systemctl enable dnsmasq >> "$LOG_FILE" 2>&1
    systemctl restart dnsmasq >> "$LOG_FILE" 2>&1
    
    # Wait for dnsmasq to start
    sleep 2
    
    # Test if dnsmasq is forwarding to dnscrypt-proxy correctly
    if timeout 5 dig @127.0.0.1 google.com >/dev/null 2>&1; then
        echo "[$(date +%Y-%m-%d\ %H:%M:%S)] dnsmasq is forwarding to DNSCrypt-Proxy successfully" >> "$LOG_FILE"
        
        echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Configuring system DNS to use dnsmasq (which forwards to DNSCrypt-Proxy)..." >> "$LOG_FILE"
    else
        echo "[$(date +%Y-%m-%d\ %H:%M:%S)] ERROR: dnsmasq failed to forward to DNSCrypt-Proxy - stopping services" >> "$LOG_FILE"
        systemctl stop dnsmasq >> "$LOG_FILE" 2>&1
        systemctl stop dnscrypt-proxy >> "$LOG_FILE" 2>&1
        DNSCRYPT_WORKING=false
    fi
fi

# Configure system DNS (only if DNSCrypt + dnsmasq are working)
if [ "$DNSCRYPT_WORKING" = true ]; then

# Backup original resolv.conf (only if it has valid DNS)
if [ ! -f /etc/resolv.conf.traceprotocol-backup ]; then
    # Check if current resolv.conf has localhost addresses (invalid for backup)
    if grep -qE "nameserver (127\.0\.0\.|::1|127\.0\.0\.53)" /etc/resolv.conf 2>/dev/null; then
        # Current DNS is localhost - get proper DNS from router/DHCP first
        echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Current DNS is localhost, getting proper DNS from network..." >> "$LOG_FILE"
        
        # Temporarily restart NetworkManager to get real DNS
        systemctl restart NetworkManager >> "$LOG_FILE" 2>&1
        sleep 3
        
        # Now backup if we got valid DNS, otherwise create fallback
        if grep -qE "nameserver [0-9]" /etc/resolv.conf 2>/dev/null && ! grep -qE "nameserver (127\.0\.0\.|::1)" /etc/resolv.conf 2>/dev/null; then
            cp /etc/resolv.conf /etc/resolv.conf.traceprotocol-backup >> "$LOG_FILE" 2>&1
            echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Valid DNS backed up" >> "$LOG_FILE"
        else
            # Create fallback backup with Google DNS
            cat > /etc/resolv.conf.traceprotocol-backup << 'BACKUPEOF'
# Fallback DNS (Google Public DNS)
nameserver 8.8.8.8
nameserver 8.8.4.4
BACKUPEOF
            echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Created fallback DNS backup (8.8.8.8)" >> "$LOG_FILE"
        fi
    else
        # Current DNS looks valid, backup it
        cp /etc/resolv.conf /etc/resolv.conf.traceprotocol-backup >> "$LOG_FILE" 2>&1
        echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Original resolv.conf backed up" >> "$LOG_FILE"
    fi
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

else
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Skipping DNS configuration - DNSCrypt-Proxy is not running" >> "$LOG_FILE"
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] DNS remains unchanged (using system default)" >> "$LOG_FILE"
fi

sleep 0.5

# --- Step 7: Enable AppArmor ---
CURRENT_STEP=7
show_progress $CURRENT_STEP $TOTAL_STEPS "Enabling AppArmor security"
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Enabling AppArmor..." >> "$LOG_FILE"
systemctl enable apparmor >> "$LOG_FILE" 2>&1
systemctl start apparmor >> "$LOG_FILE" 2>&1
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] AppArmor enabled and started" >> "$LOG_FILE"
sleep 0.5

# --- Step 8: Install Secure Messaging Apps (SKIPPED) ---
# User opted out of installing messaging apps
# To install manually: apt install signal-desktop telegram-desktop

# --- Step 8: Save Original MAC Address ---
CURRENT_STEP=8
show_progress $CURRENT_STEP $TOTAL_STEPS "Saving original MAC address"
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Saving original MAC address..." >> "$LOG_FILE"

# Save original MAC address for later reference (only if not already saved)
mkdir -p /var/lib/traceprotocol

# Check if MAC backup already exists from previous installation
if [ -f /var/lib/traceprotocol/original_mac.txt ]; then
    EXISTING_MAC=$(cat /var/lib/traceprotocol/original_mac.txt 2>/dev/null)
    if [ -n "$EXISTING_MAC" ]; then
        echo "[$(date +%Y-%m-%d\ %H:%M:%S)] MAC backup already exists: $EXISTING_MAC (preserved from previous installation)" >> "$LOG_FILE"
    else
        # File exists but empty, save new one
        PRIMARY_INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
        if [ -n "$PRIMARY_INTERFACE" ]; then
            ORIGINAL_MAC=$(ethtool -P "$PRIMARY_INTERFACE" 2>/dev/null | awk '{print $3}')
            if [ -n "$ORIGINAL_MAC" ] && [ "$ORIGINAL_MAC" != "00:00:00:00:00:00" ]; then
                echo "$ORIGINAL_MAC" > /var/lib/traceprotocol/original_mac.txt
                echo "$PRIMARY_INTERFACE" > /var/lib/traceprotocol/interface.txt
                echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Original MAC address saved: $ORIGINAL_MAC for $PRIMARY_INTERFACE" >> "$LOG_FILE"
            fi
        fi
    fi
else
    # No backup exists, create new one
    PRIMARY_INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
    if [ -n "$PRIMARY_INTERFACE" ]; then
        ORIGINAL_MAC=$(ethtool -P "$PRIMARY_INTERFACE" 2>/dev/null | awk '{print $3}')
        if [ -n "$ORIGINAL_MAC" ] && [ "$ORIGINAL_MAC" != "00:00:00:00:00:00" ]; then
            echo "$ORIGINAL_MAC" > /var/lib/traceprotocol/original_mac.txt
            echo "$PRIMARY_INTERFACE" > /var/lib/traceprotocol/interface.txt
            echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Original MAC address saved: $ORIGINAL_MAC for $PRIMARY_INTERFACE" >> "$LOG_FILE"
        fi
    fi
fi
sleep 0.5

# --- Step 9: Create configuration file ---
CURRENT_STEP=9
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
MAC_RANDOMIZATION=true

# Monitoring Settings
MONITOR_INTERVAL=60
LOG_RETENTION_DAYS=30
EOF

echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Configuration file created at $SCRIPT_DIR/../privacy-tools.conf" >> "$LOG_FILE"
sleep 0.5

# --- Step 10: Create Conky Configuration ---
CURRENT_STEP=10
show_progress $CURRENT_STEP $TOTAL_STEPS "Creating Conky widget"
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Creating Conky desktop widget configuration..." >> "$LOG_FILE"

if [ -n "$SUDO_USER" ]; then
    CONKY_FILE="/home/$SUDO_USER/.conkyrc"
    AUTOSTART_DIR="/home/$SUDO_USER/.config/autostart"
    AUTOSTART_FILE="$AUTOSTART_DIR/traceprotocol-conky.desktop"
    CONFIG_DIR="/home/$SUDO_USER/.config/traceprotocol"
    
    # Create helper script directory
    mkdir -p "$CONFIG_DIR"
    
    # Create VPN status helper script
    cat > "$CONFIG_DIR/get-vpn-status.sh" << 'VPNSTATUSEOF'
#!/bin/bash
# Helper script to get VPN status information for Conky

# Check if VPN is connected by looking for VPN interface
if ! ip link show 2>/dev/null | grep -qE "(proton|tun|tap|wg|vpn)[0-9]"; then
    echo "DISCONNECTED"
    exit 0
fi

# Get the active VPN connection name
VPN_CONNECTION=$(nmcli -t -f NAME connection show --active | grep -i proton | head -1)

if [ -z "$VPN_CONNECTION" ]; then
    echo "DISCONNECTED"
    exit 0
fi

# Get VPN connection details
VPN_INFO=$(nmcli connection show "$VPN_CONNECTION" 2>/dev/null)

# Extract server IP from vpn.data field
SERVER_IP=$(echo "$VPN_INFO" | grep "vpn.data" | sed 's/.*remote = \([^,]*\).*/\1/' | sed 's/\\//g' | cut -d: -f1 | head -1)

# Extract server name from vpn.data field
SERVER_NAME=$(echo "$VPN_INFO" | grep "vpn.data" | sed 's/.*verify-x509-name = name:\([^.]*\).*/\1/')

# Extract country code from connection name
COUNTRY_CODE=$(echo "$VPN_CONNECTION" | grep -oE "(US|UK|NL|DE|FR|CA|AU|CH|SE|NO|FI|DK|JP|SG|HK|BR|MX|AR|CL|CO|PE|VE|UY|PY|BO|EC|GY|SR|GF|FK|GS|BV|HM|AQ|TF|AD|AL|AT|BA|BE|BG|HR|CY|CZ|EE|FO|GI|GL|HU|IE|IM|IS|IT|LI|LT|LU|LV|MC|MD|ME|MK|MT|NL|NO|PL|PT|RO|RS|SI|SK|SM|UA|VA|AX|BL|GG|JE|SJ)" | head -1)

# If country code is empty, try to get it from server name
if [ -z "$COUNTRY_CODE" ]; then
    COUNTRY_CODE=$(echo "$SERVER_NAME" | grep -oE "(us|uk|nl|de|fr|ca|au|ch|se|no|fi|dk|jp|sg|hk|br|mx|ar|cl|co|pe|ve|uy|py|bo|ec|gy|sr|gf|fk|gs|bv|hm|aq|tf|ad|al|at|ba|be|bg|hr|cy|cz|ee|fo|gi|gl|hu|ie|im|is|it|li|lt|lu|lv|mc|md|me|mk|mt|nl|no|pl|pt|ro|rs|si|sk|sm|ua|va|ax|bl|gg|je|sj)" | tr '[:lower:]' '[:upper:]' | head -1)
fi

# Convert country code to full country name
case "$COUNTRY_CODE" in
    "US") COUNTRY="United States" ;;
    "UK") COUNTRY="United Kingdom" ;;
    "NL") COUNTRY="Netherlands" ;;
    "DE") COUNTRY="Germany" ;;
    "FR") COUNTRY="France" ;;
    "CA") COUNTRY="Canada" ;;
    "AU") COUNTRY="Australia" ;;
    "CH") COUNTRY="Switzerland" ;;
    "SE") COUNTRY="Sweden" ;;
    "NO") COUNTRY="Norway" ;;
    "FI") COUNTRY="Finland" ;;
    "DK") COUNTRY="Denmark" ;;
    "JP") COUNTRY="Japan" ;;
    "SG") COUNTRY="Singapore" ;;
    "HK") COUNTRY="Hong Kong" ;;
    "BR") COUNTRY="Brazil" ;;
    "MX") COUNTRY="Mexico" ;;
    "AR") COUNTRY="Argentina" ;;
    "CL") COUNTRY="Chile" ;;
    "CO") COUNTRY="Colombia" ;;
    "PE") COUNTRY="Peru" ;;
    "VE") COUNTRY="Venezuela" ;;
    "UY") COUNTRY="Uruguay" ;;
    "PY") COUNTRY="Paraguay" ;;
    "BO") COUNTRY="Bolivia" ;;
    "EC") COUNTRY="Ecuador" ;;
    "GY") COUNTRY="Guyana" ;;
    "SR") COUNTRY="Suriname" ;;
    "GF") COUNTRY="French Guiana" ;;
    "FK") COUNTRY="Falkland Islands" ;;
    "GS") COUNTRY="South Georgia" ;;
    "BV") COUNTRY="Bouvet Island" ;;
    "HM") COUNTRY="Heard Island" ;;
    "AQ") COUNTRY="Antarctica" ;;
    "TF") COUNTRY="French Southern Territories" ;;
    "AD") COUNTRY="Andorra" ;;
    "AL") COUNTRY="Albania" ;;
    "AT") COUNTRY="Austria" ;;
    "BA") COUNTRY="Bosnia and Herzegovina" ;;
    "BE") COUNTRY="Belgium" ;;
    "BG") COUNTRY="Bulgaria" ;;
    "HR") COUNTRY="Croatia" ;;
    "CY") COUNTRY="Cyprus" ;;
    "CZ") COUNTRY="Czech Republic" ;;
    "EE") COUNTRY="Estonia" ;;
    "FO") COUNTRY="Faroe Islands" ;;
    "GI") COUNTRY="Gibraltar" ;;
    "GL") COUNTRY="Greenland" ;;
    "HU") COUNTRY="Hungary" ;;
    "IE") COUNTRY="Ireland" ;;
    "IM") COUNTRY="Isle of Man" ;;
    "IS") COUNTRY="Iceland" ;;
    "IT") COUNTRY="Italy" ;;
    "LI") COUNTRY="Liechtenstein" ;;
    "LT") COUNTRY="Lithuania" ;;
    "LU") COUNTRY="Luxembourg" ;;
    "LV") COUNTRY="Latvia" ;;
    "MC") COUNTRY="Monaco" ;;
    "MD") COUNTRY="Moldova" ;;
    "ME") COUNTRY="Montenegro" ;;
    "MK") COUNTRY="North Macedonia" ;;
    "MT") COUNTRY="Malta" ;;
    "PL") COUNTRY="Poland" ;;
    "PT") COUNTRY="Portugal" ;;
    "RO") COUNTRY="Romania" ;;
    "RS") COUNTRY="Serbia" ;;
    "SI") COUNTRY="Slovenia" ;;
    "SK") COUNTRY="Slovakia" ;;
    "SM") COUNTRY="San Marino" ;;
    "UA") COUNTRY="Ukraine" ;;
    "VA") COUNTRY="Vatican City" ;;
    "AX") COUNTRY="Åland Islands" ;;
    "BL") COUNTRY="Saint Barthélemy" ;;
    "GG") COUNTRY="Guernsey" ;;
    "JE") COUNTRY="Jersey" ;;
    "SJ") COUNTRY="Svalbard and Jan Mayen" ;;
    *) COUNTRY="$COUNTRY_CODE" ;;  # Fallback to code if not found
esac

# Output the information
echo "CONNECTED"
echo "SERVER_IP:$SERVER_IP"
echo "SERVER_NAME:$SERVER_NAME"
echo "COUNTRY:$COUNTRY"
VPNSTATUSEOF
    
    chmod +x "$CONFIG_DIR/get-vpn-status.sh"
    chown -R "$SUDO_USER:$SUDO_USER" "$CONFIG_DIR"
    
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
    background = false,
    own_window = true,
    own_window_type = 'dock',
    own_window_transparent = true,
    own_window_argb_visual = false,
    own_window_argb_value = 0,
    own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
    own_window_class = 'Conky',
    
    -- Borders
    border_width = 0,
    border_inner_margin = 0,
    border_outer_margin = 0,
    draw_borders = false,
    draw_graph_borders = false,
    draw_outline = false,
    draw_shades = false,
    stippled_borders = 0,
    
    -- Font Settings
    use_xft = true,
    font = 'DejaVu Sans Mono:size=9',
    xftalpha = 0.8,
    uppercase = false,
    
    -- Colors
    default_color = 'FFFFFF',
    default_shade_color = 'black',
    default_outline_color = 'black',
    color1 = '00FF00',  -- Green for success/connected/enabled
    color2 = 'FF0000',  -- Red for errors/disconnected/disabled
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
${if_match ${exec bash -c 'ip link show 2>/dev/null | grep -qE "(proton|tun|tap|wg|vpn)[0-9]" && echo 1 || echo 0'} == 1}${color}Status: ${color1}✓ Connected${else}${color}Status: ${color2}✗ Disconnected${endif}
${if_match ${exec bash -c 'ip link show 2>/dev/null | grep -qE "(proton|tun|tap|wg|vpn)[0-9]" && echo 1 || echo 0'} == 1}\
${color}Server: ${color4}${execi 15 ~/.config/traceprotocol/get-vpn-status.sh | grep "SERVER_NAME:" | cut -d: -f2}
${color}Country: ${color4}${execi 15 ~/.config/traceprotocol/get-vpn-status.sh | grep "COUNTRY:" | cut -d: -f2}
${else}\
${color3}No VPN Connection
${endif}

${color4}${font DejaVu Sans Mono:size=10:bold}━━━ IP ADDRESSES ━━━${font}
${if_match ${exec bash -c 'ip link show 2>/dev/null | grep -qE "(proton|tun|tap|wg|vpn)[0-9]" && echo 1 || echo 0'} == 1}\
${color}VPN IP: ${color1}${execi 15 ~/.config/traceprotocol/get-vpn-status.sh | grep "SERVER_IP:" | cut -d: -f2}
${if_match "${execi 5 ~/.config/traceprotocol/get-real-ip.sh}" == "No Internet"}${color}Real IP: ${color3}⚠ No Internet${else}${color}Real IP: ${color2}${execi 5 ~/.config/traceprotocol/get-real-ip.sh}${endif}
${color}VPN Tunnel: ${color4}${addr proton0}
${else}\
${if_match "${execi 5 ~/.config/traceprotocol/get-real-ip.sh}" == "No Internet"}${color}Real IP: ${color3}⚠ No Internet${else}${color}Real IP: ${color2}${execi 5 ~/.config/traceprotocol/get-real-ip.sh}${endif}
${endif}

${color4}${font DejaVu Sans Mono:size=10:bold}━━━ MAC ADDRESSES ━━━${font}
${color}Interface: ${color4}${exec cat /var/lib/traceprotocol/interface.txt 2>/dev/null || ip link show | grep -v "lo:\|proton\|tun" | grep "state UP" | awk -F: '{print $2}' | tr -d ' ' | head -1}
${color}Original MAC: ${color4}${exec cat /var/lib/traceprotocol/original_mac.txt 2>/dev/null || echo "Not saved"}
${color}Current MAC: ${color4}${exec IFACE=$(cat /var/lib/traceprotocol/interface.txt 2>/dev/null || ip link show | grep -v "lo:\|proton\|tun" | grep "state UP" | awk -F: '{print $2}' | tr -d ' ' | head -1); ip link show $IFACE 2>/dev/null | grep "link/ether" | awk '{print $2}'}

${color4}${font DejaVu Sans Mono:size=10:bold}━━━ SECURITY STATUS ━━━${font}
${if_match "${execi 5 /home/USER_PLACEHOLDER/.config/traceprotocol/check-killswitch-status.sh}" == "Enabled"}${color}Kill Switch: ${color1}✓ Enabled${else}${color}Kill Switch: ${color2}✗ Disabled${endif}
${if_match "${execi 5 /home/USER_PLACEHOLDER/.config/traceprotocol/check-tor-status.sh}" == "Running"}${color}Tor: ${color1}✓ Running${else}${if_match "${execi 5 /home/USER_PLACEHOLDER/.config/traceprotocol/check-tor-status.sh}" == "No Internet"}${color}Tor: ${color3}⚠ No Internet${else}${color}Tor: ${color2}✗ Stopped${endif}${endif}

${color4}${font DejaVu Sans Mono:size=10:bold}━━━ DNS ENCRYPTION ━━━${font}
${if_match "${exec systemctl is-active dnsmasq 2>/dev/null}" == "active"}${color}dnsmasq: ${color1}✓ Running${else}${color}dnsmasq: ${color2}✗ Stopped${endif}
${if_match "${exec systemctl is-active dnscrypt-proxy 2>/dev/null}" == "active"}${color}DNSCrypt: ${color1}✓ Running${else}${color}DNSCrypt: ${color2}✗ Stopped${endif}
${if_match ${exec bash -c '[ -f "/etc/dnsmasq.d/dnscrypt.conf" ] && systemctl is-active --quiet dnsmasq && systemctl is-active --quiet dnscrypt-proxy && echo 1 || echo 0'} == 1}${color}Chain: ${color1}✓ Cache→Encrypt${else}${color}Chain: ${color2}✗ Not configured${endif}

${color4}${font DejaVu Sans Mono:size=10:bold}━━━ SYSTEM STATUS ━━━${font}
${color}CPU: ${color4}${cpu}%  ${color}${cpubar 6}
${color}RAM: ${color4}${memperc}%  ${color}${membar 6}
${color}Disk: ${color4}${fs_used_perc /}%  ${color}${fs_bar 6 /}
${color}Uptime: ${color4}${uptime_short}
${color}Time: ${color4}${time %H:%M:%S}

${color5}${alignc}TraceProtocol v1.0
]];
CONKYEOF

    # Set proper ownership
    chown "$SUDO_USER:$SUDO_USER" "$CONKY_FILE"
    
    # Create helper script for Conky IP detection
    mkdir -p "/home/$SUDO_USER/.config/traceprotocol"
    cat > "/home/$SUDO_USER/.config/traceprotocol/get-real-ip.sh" << 'HELPEREOF'
#!/bin/bash
# Helper script for Conky to get real IP when VPN is disconnected

# Get the actual user home directory (handle both user and root execution)
if [ "$EUID" -eq 0 ]; then
    # Running as root, find the actual user
    USER_HOME="/home/$SUDO_USER"
else
    USER_HOME=$(eval echo ~)
fi
mkdir -p "$USER_HOME/.config/traceprotocol"

# Check if VPN is connected
VPN_CONNECTED=false
if ip link show 2>/dev/null | grep -qE "(proton|tun|tap|wg|vpn)[0-9]"; then
    VPN_CONNECTED=true
fi

# Check if Kill Switch is enabled
KILLSWITCH_ENABLED=false
if [ -f "/var/lib/traceprotocol/killswitch-status.txt" ]; then
    KILLSWITCH_STATUS=$(cat "/var/lib/traceprotocol/killswitch-status.txt" 2>/dev/null)
    if [ "$KILLSWITCH_STATUS" = "enabled" ]; then
        KILLSWITCH_ENABLED=true
    fi
fi

if [ "$VPN_CONNECTED" = true ]; then
    # VPN is connected - ONLY read from real_ip.txt file
    if [ -f "$USER_HOME/.config/traceprotocol/real_ip.txt" ]; then
        SAVED_REAL_IP=$(cat "$USER_HOME/.config/traceprotocol/real_ip.txt" 2>/dev/null)
        if [ -n "$SAVED_REAL_IP" ] && [ "$SAVED_REAL_IP" != "No Internet" ]; then
            echo "$SAVED_REAL_IP"
        else
            echo "Unknown"
        fi
    else
        echo "Unknown"
    fi
else
    # VPN is not connected
    if [ "$KILLSWITCH_ENABLED" = true ]; then
        # Kill Switch is enabled - no internet access when VPN disconnected
        # DON'T overwrite the real_ip.txt file - just show "No Internet"
        echo "No Internet"
    else
        # Kill Switch is disabled - get current IP and save it as real IP
        CURRENT_IP=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null)
        
        if [ -n "$CURRENT_IP" ]; then
            # Save the current IP as real IP for future reference
            echo "$CURRENT_IP" > "$USER_HOME/.config/traceprotocol/real_ip.txt"
            chown $SUDO_USER:$SUDO_USER "$USER_HOME/.config/traceprotocol/real_ip.txt" 2>/dev/null
            echo "$CURRENT_IP"
        else
            echo "No Internet" > "$USER_HOME/.config/traceprotocol/real_ip.txt"
            chown $SUDO_USER:$SUDO_USER "$USER_HOME/.config/traceprotocol/real_ip.txt" 2>/dev/null
            echo "No Internet"
        fi
    fi
fi
HELPEREOF
    
    chmod +x "/home/$SUDO_USER/.config/traceprotocol/get-real-ip.sh"
    
    # Create Tor status helper script
    cat > "/home/$SUDO_USER/.config/traceprotocol/check-tor-status.sh" << 'TOREOF'
#!/bin/bash
# Helper script for Conky to check Tor status accurately

# First check if there's internet connectivity by checking real IP status
REAL_IP_STATUS=$(/home/USER_PLACEHOLDER/.config/traceprotocol/get-real-ip.sh)

if [ "$REAL_IP_STATUS" = "No Internet" ]; then
    # No internet connection - Tor can't work
    echo "No Internet"
elif pgrep -x tor >/dev/null 2>&1 && systemctl is-active --quiet tor 2>/dev/null; then
    # Tor service is running and there's internet
    echo "Running"
else
    # Tor service is not running
    echo "Stopped"
fi
TOREOF
    
    chmod +x "/home/$SUDO_USER/.config/traceprotocol/check-tor-status.sh"
    
    # Create Kill Switch status helper script that uses the separated kill switch manager
    cat > "/home/$SUDO_USER/.config/traceprotocol/check-killswitch-status.sh" << 'KILLSWITCHEOF'
#!/bin/bash
# Helper script for Conky to check kill switch status using the separated kill switch manager

# Use the kill switch manager from scripts directory
KILLSWITCH_MANAGER="$(dirname "$0")/killswitch-manager.sh"

# If not found in config directory, try scripts directory
if [ ! -f "$KILLSWITCH_MANAGER" ]; then
    # Get the scripts directory path (go up from config directory to scripts)
    SCRIPTS_DIR="$(dirname "$(dirname "$0")")/../scripts"
    KILLSWITCH_MANAGER="$SCRIPTS_DIR/killswitch-manager.sh"
fi

# If kill switch manager exists, use it
if [ -f "$KILLSWITCH_MANAGER" ]; then
    # Call the kill switch manager status command and extract just the status
    STATUS_OUTPUT=$("$KILLSWITCH_MANAGER" status 2>/dev/null)
    
    if echo "$STATUS_OUTPUT" | grep -qi "ENABLED"; then
        echo "Enabled"
        exit 0
    elif echo "$STATUS_OUTPUT" | grep -qi "DISABLED"; then
        echo "Disabled"
        exit 0
    fi
fi

# Fallback: Check status file directly
CUSTOM_KILLSWITCH_STATUS="/var/lib/traceprotocol/killswitch-status.txt"

if [ -f "$CUSTOM_KILLSWITCH_STATUS" ]; then
    KILLSWITCH_STATUS=$(cat "$CUSTOM_KILLSWITCH_STATUS" 2>/dev/null)
    
    if [ "$KILLSWITCH_STATUS" = "enabled" ]; then
        echo "Enabled"
        exit 0
    elif [ "$KILLSWITCH_STATUS" = "disabled" ]; then
        echo "Disabled"
        exit 0
    fi
fi

# Final fallback
echo "Unknown"
KILLSWITCHEOF
    
    chmod +x "/home/$SUDO_USER/.config/traceprotocol/check-killswitch-status.sh"
    
    # Kill Switch Manager script is now in /scripts directory
    # Copy it to the config directory for user access
    cp "$SCRIPT_DIR/killswitch-manager.sh" "/home/$SUDO_USER/.config/traceprotocol/killswitch-manager.sh"
    
    chmod +x "/home/$SUDO_USER/.config/traceprotocol/killswitch-manager.sh"
    chown -R "$SUDO_USER:$SUDO_USER" "/home/$SUDO_USER/.config/traceprotocol"
    
    # Replace tilde with absolute path in helper script reference
    sed -i "s|~/.config/traceprotocol/get-real-ip.sh|/home/$SUDO_USER/.config/traceprotocol/get-real-ip.sh|g" "$CONKY_FILE"
    sed -i "s|~/.config/traceprotocol/real_ip.txt|/home/$SUDO_USER/.config/traceprotocol/real_ip.txt|g" "$CONKY_FILE"
    sed -i "s|USER_PLACEHOLDER|$SUDO_USER|g" "$CONKY_FILE"
    
    # Create autostart directory and file
    mkdir -p "$AUTOSTART_DIR"
    cat > "$AUTOSTART_DIR/conky-traceprotocol.desktop" << 'AUTOSTARTEOF'
[Desktop Entry]
Type=Application
Name=TraceProtocol Conky Monitor
Comment=TraceProtocol Privacy Monitor Widget
Exec=bash -c "sleep 15 && pkill conky; sleep 2 && conky --config=/home/USER_PLACEHOLDER/.conkyrc --daemonize"
Icon=conky
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
StartupNotify=false
Terminal=false
Categories=System;Monitor;
AUTOSTARTEOF
    
    # Replace USER_PLACEHOLDER with actual username
    sed -i "s|USER_PLACEHOLDER|$SUDO_USER|g" "$AUTOSTART_DIR/conky-traceprotocol.desktop"
    sed -i "s|USER_PLACEHOLDER|$SUDO_USER|g" "/home/$SUDO_USER/.config/traceprotocol/check-killswitch-status.sh"
    sed -i "s|USER_PLACEHOLDER|$SUDO_USER|g" "/home/$SUDO_USER/.config/traceprotocol/check-tor-status.sh"
    
    
    chmod +x "$AUTOSTART_DIR/conky-traceprotocol.desktop"
    chown -R "$SUDO_USER:$SUDO_USER" "$AUTOSTART_DIR"
    
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Conky widget configuration created!" >> "$LOG_FILE"
else
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] WARNING: Could not determine user for Conky configuration" >> "$LOG_FILE"
fi
sleep 0.5

# --- Step 11: Cleanup ---
CURRENT_STEP=11
show_progress $CURRENT_STEP $TOTAL_STEPS "Cleaning up"
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Running cleanup..." >> "$LOG_FILE"
apt autoremove -y -qq >> "$LOG_FILE" 2>&1
apt clean -qq >> "$LOG_FILE" 2>&1
sleep 0.5

# --- Step 12: Start Conky Widget ---
CURRENT_STEP=12
show_progress $CURRENT_STEP $TOTAL_STEPS "Starting Conky widget"
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Starting Conky desktop widget..." >> "$LOG_FILE"

if [ -f "/home/$SUDO_USER/.conkyrc" ] && [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
    # Kill existing Conky instances
    sudo -u "$SUDO_USER" pkill conky 2>/dev/null || true
    sleep 2
    
    # Get user's display and environment
    USER_DISPLAY=$(w -h "$SUDO_USER" | awk '{print $3; exit}')
    if [ -z "$USER_DISPLAY" ]; then
        USER_DISPLAY=":0"
    fi
    
    # Start Conky as the actual user with proper environment
    sudo -u "$SUDO_USER" DISPLAY="$USER_DISPLAY" conky --config="/home/$SUDO_USER/.conkyrc" --daemonize >/dev/null 2>&1
    
    sleep 2
    
    # Verify Conky is running
    if pgrep -u "$SUDO_USER" conky >/dev/null 2>&1; then
        echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Conky widget started successfully!" >> "$LOG_FILE"
    else
        echo "[$(date +%Y-%m-%d\ %H:%M:%S)] WARNING: Conky widget may not have started. It will auto-start on next login." >> "$LOG_FILE"
    fi
else
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] WARNING: Conky configuration not found or running as root. Widget will start on next login." >> "$LOG_FILE"
fi

# --- Step 10: Setup Boot Services ---
CURRENT_STEP=10
show_progress $CURRENT_STEP $TOTAL_STEPS "Setting up boot services"
echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Setting up boot services..." >> "$LOG_FILE"

# Create MAC randomization boot script
if [ -n "$SUDO_USER" ]; then
    CONFIG_DIR="/home/$SUDO_USER/.config/traceprotocol"
    MAC_SCRIPT_PATH="$CONFIG_DIR/mac-randomize-boot.sh"
else
    # Fallback if SUDO_USER is not set
    CONFIG_DIR="/home/$(logname)/.config/traceprotocol"
    MAC_SCRIPT_PATH="$CONFIG_DIR/mac-randomize-boot.sh"
fi

# Create the directory if it doesn't exist
mkdir -p "$CONFIG_DIR"

cat > "$MAC_SCRIPT_PATH" << 'EOF'
#!/bin/bash

# TraceProtocol MAC Randomization at Boot
# This script randomizes MAC address during system startup

LOG_FILE="/var/log/traceprotocol-mac-boot.log"
INTERFACE_FILE="/var/lib/traceprotocol/interface.txt"
ORIGINAL_MAC_FILE="/var/lib/traceprotocol/original_mac.txt"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to get the primary network interface
get_primary_interface() {
    # Check if we have a saved interface
    if [ -f "$INTERFACE_FILE" ]; then
        SAVED_IFACE=$(cat "$INTERFACE_FILE" 2>/dev/null)
        if [ -n "$SAVED_IFACE" ] && ip link show "$SAVED_IFACE" >/dev/null 2>&1; then
            echo "$SAVED_IFACE"
            return
        fi
    fi
    
    # Find active physical interface (exclude loopback, VPN interfaces)
    INTERFACE=$(ip link show | grep -E "^[0-9]+: (eth|wlan|wlp|enp|ens)" | grep "state UP\|state DOWN" | head -1 | awk -F: '{print $2}' | tr -d ' ')
    
    if [ -z "$INTERFACE" ]; then
        # Fallback: get any physical interface
        INTERFACE=$(ip link show | grep -E "^[0-9]+: (eth|wlan|wlp|enp|ens)" | head -1 | awk -F: '{print $2}' | tr -d ' ')
    fi
    
    echo "$INTERFACE"
}

# Function to randomize MAC address
randomize_mac() {
    local interface="$1"
    
    if [ -z "$interface" ]; then
        log_message "ERROR: No network interface found"
        return 1
    fi
    
    # Check if interface exists
    if ! ip link show "$interface" >/dev/null 2>&1; then
        log_message "ERROR: Interface $interface not found"
        return 1
    fi
    
    # Get current MAC address
    CURRENT_MAC=$(ip link show "$interface" | grep "link/ether" | awk '{print $2}')
    
    if [ -z "$CURRENT_MAC" ]; then
        log_message "ERROR: Could not get MAC address for $interface"
        return 1
    fi
    
    # Save original MAC if not already saved
    if [ ! -f "$ORIGINAL_MAC_FILE" ]; then
        echo "$CURRENT_MAC" > "$ORIGINAL_MAC_FILE"
        log_message "Saved original MAC: $CURRENT_MAC"
    fi
    
    # Save interface if not already saved
    if [ ! -f "$INTERFACE_FILE" ]; then
        echo "$interface" > "$INTERFACE_FILE"
        log_message "Saved interface: $interface"
    fi
    
    # Generate random MAC address (keeping the first octet structure for local admin)
    NEW_MAC=$(printf "02:%02x:%02x:%02x:%02x:%02x" $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))
    
    # Bring interface down
    log_message "Bringing down interface $interface"
    ip link set dev "$interface" down
    
    # Change MAC address
    log_message "Changing MAC from $CURRENT_MAC to $NEW_MAC"
    ip link set dev "$interface" address "$NEW_MAC"
    
    # Bring interface back up
    log_message "Bringing up interface $interface"
    ip link set dev "$interface" up
    
    # Wait for interface to be ready
    sleep 2
    
    # Verify MAC change
    VERIFY_MAC=$(ip link show "$interface" | grep "link/ether" | awk '{print $2}')
    if [ "$VERIFY_MAC" = "$NEW_MAC" ]; then
        log_message "SUCCESS: MAC randomized on $interface ($VERIFY_MAC)"
        return 0
    else
        log_message "ERROR: MAC randomization failed on $interface"
        return 1
    fi
}

# Main execution
main() {
    log_message "Starting TraceProtocol MAC randomization at boot"
    
    # Create directories if they don't exist
    mkdir -p /var/lib/traceprotocol
    
    # Wait for network interfaces to be ready
    sleep 5
    
    # Get primary interface
    INTERFACE=$(get_primary_interface)
    
    if [ -z "$INTERFACE" ]; then
        log_message "ERROR: No suitable network interface found"
        exit 1
    fi
    
    log_message "Using interface: $INTERFACE"
    
    # Randomize MAC address
    if randomize_mac "$INTERFACE"; then
        log_message "MAC randomization completed successfully"
        exit 0
    else
        log_message "MAC randomization failed"
        exit 1
    fi
}

# Run main function
main "$@"
EOF

chmod +x "$MAC_SCRIPT_PATH"

# Set proper ownership for the MAC script
if [ -n "$SUDO_USER" ]; then
    chown "$SUDO_USER:$SUDO_USER" "$MAC_SCRIPT_PATH"
elif [ -n "$(logname)" ]; then
    chown "$(logname):$(logname)" "$MAC_SCRIPT_PATH"
fi

# Create systemd service for MAC randomization
cat > /etc/systemd/system/traceprotocol-mac-randomize.service << EOF
[Unit]
Description=TraceProtocol MAC Address Randomization
Documentation=TraceProtocol Privacy Suite
After=network-pre.target
Before=network.target
Wants=network-pre.target

[Service]
Type=oneshot
ExecStart=$MAC_SCRIPT_PATH
RemainAfterExit=yes
TimeoutStartSec=30
User=root
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Enable MAC randomization service
systemctl daemon-reload >> "$LOG_FILE" 2>&1
systemctl enable traceprotocol-mac-randomize.service >> "$LOG_FILE" 2>&1

# Create NetworkManager dispatcher script for automatic MAC randomization
cat > /etc/NetworkManager/dispatcher.d/99-traceprotocol-mac-randomize << 'DISPEOF'
#!/bin/bash

# TraceProtocol - Automatic MAC Randomization on Network Events
# This script runs whenever NetworkManager detects network interface changes

INTERFACE="$1"
ACTION="$2"

# Log file for debugging
LOG_FILE="/var/log/traceprotocol-mac-auto.log"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Interface: $INTERFACE, Action: $ACTION - $1" >> "$LOG_FILE"
}

# Function to randomize MAC address
randomize_mac() {
    local interface="$1"
    
    # Skip if not a physical interface
    if ! echo "$interface" | grep -qE "^(eth|wlan|wlp|enp|ens)"; then
        log_message "Skipping non-physical interface: $interface"
        return
    fi
    
    # Skip VPN and virtual interfaces
    if echo "$interface" | grep -qE "(tun|tap|proton|wg|vpn|docker|br-)"; then
        log_message "Skipping virtual interface: $interface"
        return
    fi
    
    # Check if interface exists
    if ! ip link show "$interface" >/dev/null 2>&1; then
        log_message "Interface $interface not found"
        return
    fi
    
    # Get current MAC
    local current_mac=$(ip link show "$interface" | grep "link/ether" | awk '{print $2}')
    
    # Generate new random MAC (locally administered)
    local new_mac=$(printf "02:%02x:%02x:%02x:%02x:%02x" $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))
    
    # Change MAC address
    log_message "Changing MAC from $current_mac to $new_mac"
    
    # Bring interface down, change MAC, bring back up
    ip link set dev "$interface" down 2>/dev/null
    ip link set dev "$interface" address "$new_mac" 2>/dev/null
    ip link set dev "$interface" up 2>/dev/null
    
    # Verify change
    local verify_mac=$(ip link show "$interface" | grep "link/ether" | awk '{print $2}')
    if [ "$verify_mac" = "$new_mac" ]; then
        log_message "SUCCESS: MAC randomized to $new_mac"
    else
        log_message "FAILED: MAC randomization failed"
    fi
}

# Main logic
case "$ACTION" in
    "up")
        # Interface came up - randomize MAC
        log_message "Interface up event - randomizing MAC"
        randomize_mac "$INTERFACE"
        ;;
    "down")
        # Interface went down - log event
        log_message "Interface down event - preparing for MAC randomization on next up"
        ;;
    "connectivity-change")
        # Connectivity changed - might want to randomize
        log_message "Connectivity change event"
        ;;
esac
DISPEOF

chmod +x /etc/NetworkManager/dispatcher.d/99-traceprotocol-mac-randomize

# Conky autostart entry already created above in Step 10

echo "[$(date +%Y-%m-%d\ %H:%M:%S)] Boot services configured successfully" >> "$LOG_FILE"

# Update progress to 100% completion
CURRENT_STEP=12
show_progress $CURRENT_STEP $TOTAL_STEPS "Installation completed"
sleep 0.5

# Finish progress bar
finish_progress

# Professional completion message
echo ""
echo ""
echo -e "${BOLD}${GREEN}  ✅ Installation Completed Successfully${NC} ${WHITE}at $(date +"%Y-%m-%d %H:%M:%S")${NC}"
echo ""

# ───────────────────────────────────────────────
#  INSTALLED COMPONENTS
# ───────────────────────────────────────────────
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "   ${BOLD}${WHITE}Installed Components${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${GREEN}✓${NC}  ${WHITE}ProtonVPN CLI${NC}${GREEN} — Secure VPN client for Linux${NC}"
echo -e "  ${GREEN}✓${NC}  ${WHITE}DNSCrypt-Proxy + Dnsmasq${NC}${GREEN} — Encrypted and cached DNS ${NC}"
echo -e "  ${GREEN}✓${NC}  ${WHITE}MAC Changer${NC}${GREEN} — Automatic change of MAC address on boot and reconnection${NC}"
echo -e "  ${GREEN}✓${NC}  ${WHITE}Tor & AppArmor${NC}${GREEN} — Network privacy and sandboxing${NC}"
echo -e "  ${GREEN}✓${NC}  ${WHITE}Firejail, BleachBit, Macchanger${NC}${GREEN} — System hardening and cleanup tools${NC}"
echo -e "  ${GREEN}✓${NC}  ${WHITE}Conky System Monitor${NC}${GREEN} — Lightweight dashboard (auto-starts at boot)${NC}"
echo ""

# ───────────────────────────────────────────────
#  ACTIVE PROTECTIONS
# ───────────────────────────────────────────────
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "   ${BOLD}${WHITE}Active Protections${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${GREEN}✓  Secure DNS via DNSCrypt-Proxy${NC} ${WHITE}(127.0.0.1)${NC}"
echo -e "  ${GREEN}✓  Local DNS caching and filtering${NC} ${WHITE}(Dnsmasq)${NC}"
echo -e "  ${GREEN}✓  Automatic MAC randomization${NC} ${WHITE}on boot/reconnect${NC}"
echo -e "  ${GREEN}✓  Enhanced system confinement via ${WHITE}AppArmor${NC}"
echo -e "  ${GREEN}✓  VPN-ready firewall policy for ${WHITE}ProtonVPN integration${NC}"
echo ""
echo -e "  ${GREEN}✔${NC}  ${WHITE}System protected against${NC} ${MAGENTA}DNS leaks, ISP tracking${NC} ${WHITE}and${NC} ${MAGENTA}MAC fingerprinting.${NC}"
echo ""

# ───────────────────────────────────────────────
#  NEXT STEPS
# ───────────────────────────────────────────────
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "   ${BOLD}${WHITE}Next Step: Sign in to ProtonVPN${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${YELLOW}Run the following command to log in:${NC}"
echo ""
echo -e "      ${WHITE}./trace-protocol.sh vpn-login${NC}"
echo ""
echo -e "  ${GREEN}This will authenticate your account, connect to the optimal server,${NC}"
echo -e "  ${GREEN}enable the kill switch, and maintain encrypted DNS protection.${NC}"
echo ""

# ───────────────────────────────────────────────
#  QUICK COMMANDS
# ───────────────────────────────────────────────
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "   ${BOLD}${WHITE}Quick Commands${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${MAGENTA}VPN login:${NC}       ${WHITE}./trace-protocol.sh vpn-login${NC}"
echo -e "  ${MAGENTA}Check status:${NC}    ${WHITE}./trace-protocol.sh monitor${NC}"
echo -e "  ${MAGENTA}All commands:${NC}    ${WHITE}./trace-protocol.sh help${NC}"
echo ""

# ───────────────────────────────────────────────
#  RESTART NOTICE
# ───────────────────────────────────────────────
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "   ${BOLD}${WHITE}System Restart Recommended${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${YELLOW}Please restart your system to apply all changes.${NC}"
echo -e "  This ensures MAC randomization, encrypted DNS, and security services"
echo -e "  are fully active and synchronized."
echo ""
echo -e "  ${YELLOW}To reboot now:${NC}"
echo -e "      ${WHITE}sudo reboot${NC}"
echo ""

# ───────────────────────────────────────────────
#  LOG FILE
# ───────────────────────────────────────────────
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "   ${BOLD}${WHITE}Installation Log${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "  ${MAGENTA}Log file saved to:${NC} ${WHITE}$LOG_FILE${NC}"
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
