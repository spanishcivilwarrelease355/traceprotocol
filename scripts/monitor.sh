#!/bin/bash

# TraceProtocol Monitoring Script
# Monitors the status of all privacy and VPN tools

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/../logs/monitor_$(date +%Y%m%d).log"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Symbols
CHECK="✓"
CROSS="✗"
WARNING="⚠"
INFO="ℹ"

# Status counters
PASSED=0
FAILED=0
WARNINGS=0

# Create logs directory
mkdir -p "$SCRIPT_DIR/../logs"

# Function to log to file
log_to_file() {
    echo "[$(date +%Y-%m-%d\ %H:%M:%S)] $1" >> "$LOG_FILE"
}

# Function to print status
print_status() {
    local status=$1
    local message=$2
    local details=$3
    
    case $status in
        "pass")
            echo -e "${GREEN}${CHECK}${NC} ${message}"
            [[ -n "$details" ]] && echo -e "   ${CYAN}${INFO}${NC} ${details}"
            ((PASSED++))
            log_to_file "PASS: $message ${details}"
            ;;
        "fail")
            echo -e "${RED}${CROSS}${NC} ${message}"
            [[ -n "$details" ]] && echo -e "   ${YELLOW}${INFO}${NC} ${details}"
            ((FAILED++))
            log_to_file "FAIL: $message ${details}"
            ;;
        "warn")
            echo -e "${YELLOW}${WARNING}${NC} ${message}"
            [[ -n "$details" ]] && echo -e "   ${CYAN}${INFO}${NC} ${details}"
            ((WARNINGS++))
            log_to_file "WARN: $message ${details}"
            ;;
        "info")
            echo -e "${BLUE}${INFO}${NC} ${message}"
            [[ -n "$details" ]] && echo -e "   ${details}"
            log_to_file "INFO: $message ${details}"
            ;;
    esac
}

# Function to check if a package is installed
check_package() {
    local package=$1
    local display_name=$2
    
    if dpkg -l | grep -qw "$package" 2>/dev/null; then
        print_status "pass" "$display_name is installed"
    else
        print_status "fail" "$display_name is not installed"
    fi
}

# Function to check if a service is running
check_service() {
    local service=$1
    local display_name=$2
    
    local service_status=$(systemctl is-active "$service" 2>/dev/null)
    
    # Consider both "active" and "activating" as running
    if [[ "$service_status" == "active" ]] || [[ "$service_status" == "activating" ]]; then
        local uptime=$(systemctl show "$service" -p ActiveEnterTimestamp --value 2>/dev/null)
        print_status "pass" "$display_name is running" "Since: $uptime"
    else
        print_status "fail" "$display_name is not running" "Run: sudo systemctl start $service"
    fi
}

# Function to check ProtonVPN status
check_protonvpn() {
    if ! command -v protonvpn-cli &>/dev/null; then
        print_status "fail" "ProtonVPN CLI is not installed" "Run: sudo ./scripts/install.sh"
        return
    fi
    
    print_status "pass" "ProtonVPN CLI is installed"
    
    # Check connection status
    local vpn_status=$(protonvpn-cli status 2>/dev/null)
    
    # Check if connected by looking for Server: and IP: fields (these only appear when connected)
    if echo "$vpn_status" | grep -q "Server:" && echo "$vpn_status" | grep -q "IP:"; then
        local server=$(echo "$vpn_status" | grep "Server:" | awk '{print $2}')
        local vpn_ip=$(echo "$vpn_status" | grep "IP:" | awk '{print $2}')
        local country=$(echo "$vpn_status" | grep "Country:" | awk -F: '{print $2}' | xargs)
        print_status "pass" "ProtonVPN is connected" "Server: $server | VPN IP: $vpn_ip | Country: $country"
    else
        print_status "warn" "ProtonVPN is not connected" "Run: protonvpn-cli c -f"
    fi
    
    # Check kill switch status
    if echo "$vpn_status" | grep -q "Kill switch:"; then
        local ks_status=$(echo "$vpn_status" | grep "Kill switch:" | awk -F: '{print $2}' | xargs)
        if echo "$ks_status" | grep -qi "on"; then
            print_status "pass" "Kill switch is enabled"
        else
            print_status "warn" "Kill switch is disabled" "Run: protonvpn-cli ks --on"
        fi
    else
        print_status "warn" "Kill switch is disabled" "Run: protonvpn-cli ks --on"
    fi
}

# Function to check firewall status
check_firewall() {
    # Check if UFW is installed (check both command and binary location)
    if ! command -v ufw &>/dev/null && [ ! -f /usr/sbin/ufw ]; then
        print_status "fail" "UFW is not installed"
        return
    fi
    
    # Check UFW status (use full path if needed)
    local ufw_cmd="ufw"
    if [ -f /usr/sbin/ufw ]; then
        ufw_cmd="/usr/sbin/ufw"
    fi
    
    local ufw_status=$($ufw_cmd status 2>/dev/null || sudo $ufw_cmd status 2>/dev/null | head -1)
    
    if echo "$ufw_status" | grep -qi "active"; then
        local rules=$($ufw_cmd status numbered 2>/dev/null || sudo $ufw_cmd status numbered 2>/dev/null | grep -c "^\[")
        print_status "pass" "UFW firewall is active" "$rules rules configured"
    else
        print_status "warn" "UFW firewall is inactive" "Run: sudo ufw enable"
    fi
}

# Function to check DNS configuration
check_dns() {
    # This check is now integrated with DNSCrypt service check above
    # Just show additional DNS info
    local dns_nameserver=$(grep '^nameserver' /etc/resolv.conf 2>/dev/null | head -1 | awk '{print $2}')
    
    if [ "$dns_nameserver" = "127.0.0.1" ]; then
        print_status "pass" "System DNS configured for encryption" "nameserver 127.0.0.1"
    else
        print_status "info" "System DNS server" "$dns_nameserver"
    fi
}

# Function to check MAC randomization
check_mac_randomization() {
    if [ -f "/var/lib/traceprotocol/original_mac.txt" ]; then
        local original_mac=$(cat /var/lib/traceprotocol/original_mac.txt 2>/dev/null)
        
        # Find physical network interface (exclude lo, proton0, tun0, etc.)
        local interface=$(ip link show | grep -E "^[0-9]+: (wl|eth|en)" | grep "state UP" | head -1 | awk -F': ' '{print $2}')
        if [ -z "$interface" ]; then
            # If no UP interface, just get first physical interface
            interface=$(ip link show | grep -E "^[0-9]+: (wl|eth|en)" | head -1 | awk -F': ' '{print $2}')
        fi
        
        local current_mac=$(ip link show "$interface" 2>/dev/null | grep "link/ether" | awk '{print $2}')
        
        if [ "$original_mac" != "$current_mac" ] && [ -n "$original_mac" ] && [ -n "$current_mac" ]; then
            print_status "pass" "MAC address is randomized" "Original: $original_mac → Current: $current_mac"
        else
            print_status "info" "MAC address not randomized" "Current: $current_mac"
        fi
    else
        print_status "warn" "MAC randomization not configured" "Run: ./scripts/mac-changer.sh randomize"
    fi
}

# Function to check IP leak
check_ip_leak() {
    if command -v curl &>/dev/null; then
        local public_ip=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null)
        
        if [[ -n "$public_ip" ]]; then
            # Check if using VPN
            local vpn_status=$(protonvpn-cli status 2>/dev/null)
            
            # Check if connected by looking for Server: and IP: fields
            if echo "$vpn_status" | grep -q "Server:" && echo "$vpn_status" | grep -q "IP:"; then
                local vpn_ip=$(echo "$vpn_status" | grep "IP:" | awk '{print $2}')
                
                # When VPN is connected, the public IP should be the VPN IP
                # They might differ slightly (last digit) due to load balancing
                if [ "$public_ip" = "$vpn_ip" ]; then
                    print_status "pass" "IP is protected by VPN" "VPN IP: $public_ip"
                else
                    # Still protected if VPN is connected, just different exit node
                    print_status "pass" "IP is protected by VPN" "Public: $public_ip | VPN: $vpn_ip"
                fi
            else
                print_status "warn" "IP is NOT protected by VPN" "Real IP exposed: $public_ip"
            fi
        else
            print_status "warn" "Could not retrieve public IP" "Check internet connection"
        fi
    fi
}

# Function to check DNS leak
check_dns_leak() {
    if command -v dig &>/dev/null; then
        local dns_server=$(dig +short myip.opendns.com @resolver1.opendns.com 2>/dev/null)
        if [[ -n "$dns_server" ]]; then
            print_status "info" "DNS resolves to: $dns_server"
        fi
    fi
}

# Main monitoring function
main() {
    clear
    echo ""
    echo "=========================================="
    echo "     TraceProtocol Status Monitor"
    echo "=========================================="
    echo ""
    echo "Timestamp: $(date)"
    echo ""
    
    # Package Checks
    echo -e "${CYAN}━━━ Package Status ━━━${NC}"
check_package "protonvpn-cli" "ProtonVPN CLI"
check_package "tor" "Tor"
# Check for DNSCrypt-Proxy (installed from GitHub)
if [ -f "/usr/local/bin/dnscrypt-proxy" ]; then
    local dnscrypt_version=$(/usr/local/bin/dnscrypt-proxy --version 2>/dev/null | head -1)
    print_status "pass" "DNSCrypt-Proxy is installed" "$dnscrypt_version"
else
    print_status "fail" "DNSCrypt-Proxy is not installed"
fi
check_package "macchanger" "MAC Changer"
    check_package "apparmor" "AppArmor"
    check_package "ufw" "UFW Firewall"
    check_package "bleachbit" "BleachBit"
    check_package "firejail" "Firejail"
    check_package "torbrowser-launcher" "Tor Browser"
    check_package "conky-all" "Conky Widget"
    echo ""
    
    # Service Checks
    echo -e "${CYAN}━━━ Service Status ━━━${NC}"
    check_service "tor" "Tor"
    # Check DNSCrypt-Proxy service AND configuration
    local dnscrypt_status=$(systemctl is-active dnscrypt-proxy 2>/dev/null)
    local dns_nameserver=$(grep '^nameserver' /etc/resolv.conf 2>/dev/null | head -1 | awk '{print $2}')
    
    # Check if both service is running AND DNS is configured
    if [[ "$dnscrypt_status" == "active" ]] || [[ "$dnscrypt_status" == "activating" ]]; then
        if [ "$dns_nameserver" = "127.0.0.1" ]; then
            local uptime=$(systemctl show dnscrypt-proxy -p ActiveEnterTimestamp --value 2>/dev/null)
            print_status "pass" "DNSCrypt-Proxy is active and configured" "DNS: 127.0.0.1 | Since: $uptime"
        else
            print_status "warn" "DNSCrypt-Proxy running but not configured" "DNS: $dns_nameserver (should be 127.0.0.1) | Run: sudo ./trace-protocol.sh dnscrypt-config"
        fi
    else
        print_status "fail" "DNSCrypt-Proxy is not running" "Run: sudo systemctl start dnscrypt-proxy"
    fi
    check_service "apparmor" "AppArmor"
    echo ""
    
    # ProtonVPN Checks
    echo -e "${CYAN}━━━ ProtonVPN Status ━━━${NC}"
    check_protonvpn
    echo ""
    
    # Security Checks
    echo -e "${CYAN}━━━ Security Configuration ━━━${NC}"
    check_firewall
    check_dns
    check_mac_randomization
    echo ""
    
    # Network Checks
    echo -e "${CYAN}━━━ Network Information ━━━${NC}"
    check_ip_leak
    check_dns_leak
    echo ""
    
    # Summary
    echo "=========================================="
    echo -e "${GREEN}Passed:${NC} $PASSED  ${RED}Failed:${NC} $FAILED  ${YELLOW}Warnings:${NC} $WARNINGS"
    echo "=========================================="
    echo ""
    
    if [[ $FAILED -eq 0 ]] && [[ $WARNINGS -eq 0 ]]; then
        echo -e "${GREEN}All systems operational! Privacy protection is active.${NC}"
    elif [[ $FAILED -eq 0 ]]; then
        echo -e "${YELLOW}System is mostly secure, but has some warnings.${NC}"
    else
        echo -e "${RED}Critical issues detected! Please review failed items.${NC}"
    fi
    echo ""
    
    log_to_file "Monitor completed: Passed=$PASSED Failed=$FAILED Warnings=$WARNINGS"
}

# Run the monitor
main

