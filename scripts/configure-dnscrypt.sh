#!/bin/bash

# DNSCrypt-Proxy Configuration Script
# Configures system DNS to use DNSCrypt-Proxy for encrypted DNS queries

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script must be run as root or with sudo${NC}"
    exit 1
fi

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}    DNSCrypt-Proxy DNS Configuration${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Step 1: Check if DNSCrypt-Proxy is installed
echo -e "${BLUE}[1/5]${NC} Checking DNSCrypt-Proxy installation..."
if [ ! -f /usr/local/bin/dnscrypt-proxy ]; then
    echo -e "${RED}✗ DNSCrypt-Proxy is not installed${NC}"
    echo "Please run the installation first: sudo ./trace-protocol.sh install"
    exit 1
fi
echo -e "${GREEN}✓ DNSCrypt-Proxy is installed${NC}"
echo ""

# Step 2: Stop and disable systemd-resolved (if running)
echo -e "${BLUE}[2/5]${NC} Checking for conflicting DNS services..."
if systemctl is-active --quiet systemd-resolved 2>/dev/null; then
    echo -e "${YELLOW}Stopping systemd-resolved (conflicts with DNSCrypt on port 53)...${NC}"
    systemctl stop systemd-resolved
    systemctl disable systemd-resolved
    echo -e "${GREEN}✓ systemd-resolved disabled${NC}"
else
    echo -e "${GREEN}✓ No conflicts detected${NC}"
fi
echo ""

# Step 3: Configure NetworkManager to use DNSCrypt-Proxy
echo -e "${BLUE}[3/5]${NC} Configuring NetworkManager DNS settings..."

# Create NetworkManager configuration to use 127.0.0.1
cat > /etc/NetworkManager/conf.d/dnscrypt.conf << 'EOF'
[main]
dns=none
systemd-resolved=false

[global-dns]
searches=

[global-dns-domain-*]
servers=127.0.0.1
EOF

echo -e "${GREEN}✓ NetworkManager configuration created${NC}"
echo ""

# Step 4: Update /etc/resolv.conf
echo -e "${BLUE}[4/5]${NC} Updating /etc/resolv.conf..."

# Backup original resolv.conf
if [ ! -f /etc/resolv.conf.backup ]; then
    cp /etc/resolv.conf /etc/resolv.conf.backup
    echo -e "${CYAN}  Original resolv.conf backed up to /etc/resolv.conf.backup${NC}"
fi

# Remove immutable flag if set
chattr -i /etc/resolv.conf 2>/dev/null || true

# Update resolv.conf
cat > /etc/resolv.conf << 'EOF'
# DNSCrypt-Proxy DNS Configuration
# DNS queries are encrypted via DNSCrypt-Proxy
nameserver 127.0.0.1
options edns0
EOF

# Make it immutable to prevent NetworkManager from overwriting
chattr +i /etc/resolv.conf

echo -e "${GREEN}✓ /etc/resolv.conf configured and locked${NC}"
echo ""

# Step 5: Restart services
echo -e "${BLUE}[5/5]${NC} Restarting services..."

# Restart DNSCrypt-Proxy
systemctl restart dnscrypt-proxy
sleep 2

# Restart NetworkManager
systemctl restart NetworkManager
sleep 2

echo -e "${GREEN}✓ Services restarted${NC}"
echo ""

# Verify configuration
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}    Verification${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check nameserver
NAMESERVER=$(grep '^nameserver' /etc/resolv.conf | awk '{print $2}' | head -1)
echo -e "${BLUE}Current nameserver:${NC} $NAMESERVER"

if [ "$NAMESERVER" = "127.0.0.1" ]; then
    echo -e "${GREEN}✓ DNS is configured to use DNSCrypt-Proxy${NC}"
else
    echo -e "${YELLOW}⚠ Nameserver is not 127.0.0.1${NC}"
fi
echo ""

# Check DNSCrypt-Proxy status
if systemctl is-active --quiet dnscrypt-proxy; then
    echo -e "${GREEN}✓ DNSCrypt-Proxy is running${NC}"
else
    echo -e "${RED}✗ DNSCrypt-Proxy is not running${NC}"
    echo "Start it with: sudo systemctl start dnscrypt-proxy"
fi
echo ""

# Test DNS resolution
echo -e "${BLUE}Testing DNS resolution...${NC}"
if command -v dig &>/dev/null; then
    DIG_OUTPUT=$(dig +short google.com @127.0.0.1 2>/dev/null | head -1)
    if [ -n "$DIG_OUTPUT" ]; then
        echo -e "${GREEN}✓ DNS resolution working: $DIG_OUTPUT${NC}"
        
        # Show which server handled the query
        DIG_SERVER=$(dig google.com 2>/dev/null | grep "SERVER:" | awk '{print $3}')
        if echo "$DIG_SERVER" | grep -q "127.0.0.1"; then
            echo -e "${GREEN}✓ Queries are going through DNSCrypt-Proxy ($DIG_SERVER)${NC}"
        else
            echo -e "${YELLOW}⚠ Queries may not be using DNSCrypt ($DIG_SERVER)${NC}"
        fi
    else
        echo -e "${YELLOW}⚠ DNS test inconclusive${NC}"
    fi
else
    echo -e "${BLUE}Install 'dnsutils' package to test with dig${NC}"
fi
echo ""

echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}DNSCrypt-Proxy DNS configuration complete!${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}Your DNS queries are now encrypted via DNSCrypt-Proxy 🔒${NC}"
echo ""
echo -e "${YELLOW}Note:${NC} If you need to restore original DNS settings:"
echo "  1. Remove immutable flag: sudo chattr -i /etc/resolv.conf"
echo "  2. Restore backup: sudo cp /etc/resolv.conf.backup /etc/resolv.conf"
echo "  3. Remove NetworkManager config: sudo rm /etc/NetworkManager/conf.d/dnscrypt.conf"
echo "  4. Restart NetworkManager: sudo systemctl restart NetworkManager"
echo ""

