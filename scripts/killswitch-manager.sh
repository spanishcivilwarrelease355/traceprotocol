#!/bin/bash
# Custom Kill Switch Manager for TraceProtocol
# Dynamically detects VPN and physical interfaces to block internet when VPN disconnects
# Supports dnsmasq on port 53 and dnscrypt-proxy on 127.0.0.1:5300

# Colors
RED='\033[38;5;196m'
GREEN='\033[38;5;46m'
YELLOW='\033[38;5;226m'
WHITE='\033[1;37m'
BLUE='\033[38;5;27m'
CYAN='\033[38;5;51m'
MAGENTA='\033[38;5;201m'
NC='\033[0m'

# Configuration
IPTABLES_BACKUP="/var/lib/traceprotocol/iptables-backup.txt"
IP6TABLES_BACKUP="/var/lib/traceprotocol/ip6tables-backup.txt"
KILLSWITCH_STATUS="/var/lib/traceprotocol/killswitch-status.txt"
PHYSICAL_INTERFACE_FILE="/var/lib/traceprotocol/interface.txt"
VPN_INTERFACE_FILE="/var/lib/traceprotocol/vpn-interface.txt"
LOG_FILE="/var/log/traceprotocol-killswitch.log"

# Create directory and log file
sudo mkdir -p /var/lib/traceprotocol
sudo chmod 755 /var/lib/traceprotocol
sudo touch "$LOG_FILE"
sudo chmod 644 "$LOG_FILE"

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | sudo tee -a "$LOG_FILE"
}

# Function to backup current iptables rules
backup_iptables() {
    log_message "Backing up current iptables rules..."
    sudo iptables-save > "$IPTABLES_BACKUP"
    sudo ip6tables-save > "$IP6TABLES_BACKUP"
    sudo chown root:root "$IPTABLES_BACKUP" "$IP6TABLES_BACKUP"
    sudo chmod 600 "$IPTABLES_BACKUP" "$IP6TABLES_BACKUP"
}

# Function to restore iptables rules
restore_iptables() {
    if [ -f "$IPTABLES_BACKUP" ]; then
        log_message "Restoring iptables rules..."
        sudo iptables-restore < "$IPTABLES_BACKUP"
    else
        log_message "No IPv4 backup found, flushing all rules..."
        sudo iptables -F
        sudo iptables -X
        sudo iptables -t nat -F
        sudo iptables -t nat -X
        sudo iptables -t mangle -F
        sudo iptables -t mangle -X
    fi
    if [ -f "$IP6TABLES_BACKUP" ]; then
        sudo ip6tables-restore < "$IP6TABLES_BACKUP"
    else
        log_message "No IPv6 backup found, flushing all rules..."
        sudo ip6tables -F
        sudo ip6tables -X
        sudo ip6tables -t nat -F
        sudo ip6tables -t nat -X
        sudo ip6tables -t mangle -F
        sudo ip6tables -t mangle -X
    fi
}

# Function to detect VPN interface
detect_vpn_interface() {
    log_message "Detecting VPN interface..."
    # First try to get from saved VPN interface file
    if [ -f "$VPN_INTERFACE_FILE" ]; then
        SAVED_VPN_INTERFACE=$(cat "$VPN_INTERFACE_FILE" 2>/dev/null)
        if [ -n "$SAVED_VPN_INTERFACE" ] && ip link show "$SAVED_VPN_INTERFACE" >/dev/null 2>&1; then
            VPN_INTERFACE="$SAVED_VPN_INTERFACE"
            log_message "Using saved VPN interface: $VPN_INTERFACE"
            echo "Using saved VPN interface: $VPN_INTERFACE"
            return
        fi
    fi

    # Detect VPN interface (tun, tap, proton, wg, vpn)
    VPN_INTERFACE=$(ip link show | grep -E "^[0-9]+: (tun|tap|proton|wg|vpn)" | grep -vE "(docker|br-)" | head -1 | awk -F: '{print $2}' | tr -d ' ')
    
    if [ -z "$VPN_INTERFACE" ]; then
        log_message "Warning: No VPN interface detected. Blocking all non-essential traffic."
        echo -e "${YELLOW}Warning: No VPN interface detected. Blocking all non-essential traffic.${NC}"
    else
        log_message "Detected VPN interface: $VPN_INTERFACE"
        echo "Detected VPN interface: $VPN_INTERFACE"
        # Save the detected VPN interface
        echo "$VPN_INTERFACE" > "$VPN_INTERFACE_FILE"
        sudo chown root:root "$VPN_INTERFACE_FILE"
        sudo chmod 644 "$VPN_INTERFACE_FILE"
    fi
}

# Function to enable kill switch
enable_killswitch() {
    echo -e "${YELLOW}Enabling kill switch...${NC}"
    log_message "Enabling kill switch..."
    
    # Backup current rules
    backup_iptables
    
    # Get primary physical network interface (exclude VPN interfaces)
    if [ -f "$PHYSICAL_INTERFACE_FILE" ]; then
        SAVED_INTERFACE=$(cat "$PHYSICAL_INTERFACE_FILE" 2>/dev/null)
        if [ -n "$SAVED_INTERFACE" ] && ip link show "$SAVED_INTERFACE" >/dev/null 2>&1; then
            PRIMARY_INTERFACE="$SAVED_INTERFACE"
        fi
    fi
    
    if [ -z "$PRIMARY_INTERFACE" ]; then
        PRIMARY_INTERFACE=$(ip link show | grep -E "^[0-9]+: (eth|wlan|wlp|enp|ens)" | grep -vE "(tun|tap|proton|wg|vpn|docker|br-)" | head -1 | awk -F: '{print $2}' | tr -d ' ')
    fi
    
    if [ -z "$PRIMARY_INTERFACE" ]; then
        log_message "Error: Could not determine primary physical network interface"
        echo -e "${RED}Error: Could not determine primary physical network interface${NC}"
        exit 1
    fi
    
    log_message "Using physical interface: $PRIMARY_INTERFACE"
    echo "Using physical interface: $PRIMARY_INTERFACE"
    
    # Detect VPN interface
    detect_vpn_interface
    
    # Clear existing rules for IPv4
    sudo iptables -F
    sudo iptables -X
    sudo iptables -t nat -F
    sudo iptables -t nat -X
    sudo iptables -t mangle -F
    sudo iptables -t mangle -X
    log_message "Cleared IPv4 rules"
    
    # Set default policies for IPv4
    sudo iptables -P INPUT DROP
    sudo iptables -P OUTPUT DROP
    sudo iptables -P FORWARD DROP
    log_message "Set IPv4 default policies to DROP"
    
    # Clear existing rules for IPv6
    sudo ip6tables -F
    sudo ip6tables -X
    sudo ip6tables -t nat -F
    sudo ip6tables -t nat -X
    sudo ip6tables -t mangle -F
    sudo ip6tables -t mangle -X
    log_message "Cleared IPv6 rules"
    
    # Set default policies for IPv6
    sudo ip6tables -P INPUT DROP
    sudo ip6tables -P OUTPUT DROP
    sudo ip6tables -P FORWARD DROP
    log_message "Set IPv6 default policies to DROP"
    
    # IPv4 Rules
    
    # Allow loopback (for dnsmasq and dnscrypt-proxy on 127.0.0.1)
    sudo iptables -A INPUT -i lo -j ACCEPT
    sudo iptables -A OUTPUT -o lo -j ACCEPT
    log_message "Allowed loopback traffic (IPv4)"
    
    # Allow established/related globally (critical for VPN replies)
    sudo iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    sudo iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    log_message "Allowed established/related traffic (IPv4)"
    
    # Allow VPN interface (if detected)
    if [ -n "$VPN_INTERFACE" ]; then
        sudo iptables -A INPUT -i "$VPN_INTERFACE" -j ACCEPT
        sudo iptables -A OUTPUT -o "$VPN_INTERFACE" -j ACCEPT
        log_message "Allowed traffic on VPN interface: $VPN_INTERFACE (IPv4)"
    fi
    
    # Allow dnscrypt-proxy upstream queries (ports 53, 443 for DoH, 853 for DoT)
    if [ -n "$VPN_INTERFACE" ]; then
        sudo iptables -A OUTPUT -o "$VPN_INTERFACE" -p udp --dport 53 -j ACCEPT
        sudo iptables -A OUTPUT -o "$VPN_INTERFACE" -p tcp --dport 53 -j ACCEPT
        sudo iptables -A OUTPUT -o "$VPN_INTERFACE" -p udp --dport 443 -j ACCEPT
        sudo iptables -A OUTPUT -o "$VPN_INTERFACE" -p tcp --dport 443 -j ACCEPT
        sudo iptables -A OUTPUT -o "$VPN_INTERFACE" -p udp --dport 853 -j ACCEPT
        sudo iptables -A OUTPUT -o "$VPN_INTERFACE" -p tcp --dport 853 -j ACCEPT
        log_message "Allowed dnscrypt-proxy upstream traffic on ports 53, 443, 853 via $VPN_INTERFACE (IPv4)"
    fi
    
    # Allow DHCP
    sudo iptables -A OUTPUT -p udp --dport 67:68 -j ACCEPT
    sudo iptables -A INPUT -p udp --dport 67:68 -j ACCEPT
    log_message "Allowed DHCP traffic (IPv4)"
    
    # Allow VPN server connections through physical interface (only UDP to prevent leaks)
    sudo iptables -A OUTPUT -o "$PRIMARY_INTERFACE" -p udp --dport 1194 -j ACCEPT
    sudo iptables -A OUTPUT -o "$PRIMARY_INTERFACE" -p udp --dport 443 -j ACCEPT
    sudo iptables -A OUTPUT -o "$PRIMARY_INTERFACE" -p udp --dport 80 -j ACCEPT
    sudo iptables -A OUTPUT -o "$PRIMARY_INTERFACE" -p udp --dport 51820 -j ACCEPT # For WireGuard
    log_message "Allowed VPN server connections on UDP ports 1194, 443, 80, 51820 via $PRIMARY_INTERFACE (IPv4)"
    
    # Block ALL other traffic on physical interface
    sudo iptables -A OUTPUT -o "$PRIMARY_INTERFACE" -j DROP
    log_message "Blocked all other traffic on $PRIMARY_INTERFACE (IPv4)"
    
    # IPv6 Rules (minimal, since dnscrypt-proxy disables IPv6)
    
    # Allow loopback
    sudo ip6tables -A INPUT -i lo -j ACCEPT
    sudo ip6tables -A OUTPUT -o lo -j ACCEPT
    log_message "Allowed loopback traffic (IPv6)"
    
    # Allow established/related globally
    sudo ip6tables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    sudo ip6tables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    log_message "Allowed established/related traffic (IPv6)"
    
    # Allow VPN interface (if detected)
    if [ -n "$VPN_INTERFACE" ]; then
        sudo ip6tables -A INPUT -i "$VPN_INTERFACE" -j ACCEPT
        sudo ip6tables -A OUTPUT -o "$VPN_INTERFACE" -j ACCEPT
        log_message "Allowed traffic on VPN interface: $VPN_INTERFACE (IPv6)"
    fi
    
    # Allow DHCPv6
    sudo ip6tables -A OUTPUT -p udp --dport 546:547 -j ACCEPT
    sudo ip6tables -A INPUT -p udp --dport 546:547 -j ACCEPT
    log_message "Allowed DHCPv6 traffic (IPv6)"
    
    # Allow VPN server connections through physical interface (only UDP to prevent leaks)
    sudo ip6tables -A OUTPUT -o "$PRIMARY_INTERFACE" -p udp --dport 1194 -j ACCEPT
    sudo ip6tables -A OUTPUT -o "$PRIMARY_INTERFACE" -p udp --dport 443 -j ACCEPT
    sudo ip6tables -A OUTPUT -o "$PRIMARY_INTERFACE" -p udp --dport 80 -j ACCEPT
    sudo ip6tables -A OUTPUT -o "$PRIMARY_INTERFACE" -p udp --dport 51820 -j ACCEPT
    log_message "Allowed VPN server connections on UDP ports 1194, 443, 80, 51820 via $PRIMARY_INTERFACE (IPv6)"
    
    # Block ALL other traffic on physical interface
    sudo ip6tables -A OUTPUT -o "$PRIMARY_INTERFACE" -j DROP
    log_message "Blocked all other traffic on $PRIMARY_INTERFACE (IPv6)"
    
    # Save status
    echo "enabled" > "$KILLSWITCH_STATUS"
    sudo chown root:root "$KILLSWITCH_STATUS"
    sudo chmod 644 "$KILLSWITCH_STATUS"
    log_message "Kill switch enabled"
    
    echo -e "${GREEN}Kill switch enabled! Internet will be blocked when VPN disconnects.${NC}"
    echo -e "${YELLOW}Note: You need to connect to VPN to access the internet.${NC}"
    echo -e "${YELLOW}Check${NC} ${WHITE}/var/log/traceprotocol-killswitch.log${NC} ${YELLOW}for details.${NC}"
}

# Function to disable kill switch
disable_killswitch() {
    echo -e "${YELLOW}Disabling kill switch...${NC}"
    echo ""

    log_message "Disabling kill switch..."
    
    # Restore iptables rules
    restore_iptables
    
    # Clear VPN interface file
    if [ -f "$VPN_INTERFACE_FILE" ]; then
        sudo rm "$VPN_INTERFACE_FILE"
        log_message "Cleared VPN interface file"
    fi
    
    # Save status
    echo "disabled" > "$KILLSWITCH_STATUS"
    sudo chown root:root "$KILLSWITCH_STATUS"
    sudo chmod 644 "$KILLSWITCH_STATUS"
    log_message "Kill switch disabled"
    
    echo -e "${GREEN}Kill switch disabled! Internet access restored.${NC}"
}

# Function to check kill switch status
check_status() {
    if [ -f "$KILLSWITCH_STATUS" ]; then
        STATUS=$(cat "$KILLSWITCH_STATUS")
        if [ "$STATUS" = "enabled" ]; then
            echo -e "${GREEN}Kill switch is ENABLED${NC}"
            if [ -f "$VPN_INTERFACE_FILE" ]; then
                VPN_IF=$(cat "$VPN_INTERFACE_FILE")
                echo -e "${MAGENTA}VPN interface:${NC} ${WHITE}$VPN_IF${NC}"
            else
                echo -e "${YELLOW}No VPN interface saved${NC}"
            fi
            if [ -f "$PHYSICAL_INTERFACE_FILE" ]; then
                PHYS_IF=$(cat "$PHYSICAL_INTERFACE_FILE")
                echo -e "${MAGENTA}Physical interface:${NC} ${WHITE}$PHYS_IF${NC}"
            fi
        else
            echo -e "${RED}Kill switch is DISABLED${NC}"
        fi
    else
        echo -e "${YELLOW}Kill switch status unknown${NC}"
    fi
    echo -e "${YELLOW}Check${NC} ${WHITE}/var/log/traceprotocol-killswitch.log${NC} ${YELLOW}for details.${NC}"
}

# Main script logic
case "$1" in
    "enable")
        enable_killswitch
        ;;
    "disable")
        disable_killswitch
        ;;
    "status")
        check_status
        ;;
    *)
        echo "Usage: $0 {enable|disable|status}"
        echo "  enable  - Enable kill switch (block internet when VPN disconnects)"
        echo "  disable - Disable kill switch (restore normal internet access)"
        echo "  status  - Check current kill switch status"
        exit 1
        ;;
esac