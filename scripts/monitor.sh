#!/bin/bash

# Privacy & VPN Monitoring Script
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
    
    if systemctl is-active --quiet "$service" 2>/dev/null; then
        local uptime=$(systemctl show "$service" -p ActiveEnterTimestamp --value)
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
    
    if echo "$vpn_status" | grep -qi "connected"; then
        local server=$(echo "$vpn_status" | grep -i "server" | cut -d: -f2 | xargs)
        local ip=$(echo "$vpn_status" | grep -i "ip" | cut -d: -f2 | xargs)
        print_status "pass" "ProtonVPN is connected" "Server: $server | IP: $ip"
    else
        print_status "warn" "ProtonVPN is not connected" "Run: protonvpn-cli connect --fastest"
    fi
    
    # Check kill switch status
    local ks_status=$(protonvpn-cli ks --status 2>/dev/null || echo "unknown")
    if echo "$ks_status" | grep -qi "enabled\|on"; then
        print_status "pass" "Kill switch is enabled"
    else
        print_status "warn" "Kill switch is disabled" "Run: protonvpn-cli ks --on"
    fi
}

# Function to check firewall status
check_firewall() {
    if ! command -v ufw &>/dev/null; then
        print_status "fail" "UFW is not installed"
        return
    fi
    
    local ufw_status=$(sudo ufw status 2>/dev/null | head -1)
    
    if echo "$ufw_status" | grep -qi "active"; then
        local rules=$(sudo ufw status numbered 2>/dev/null | grep -c "^\[")
        print_status "pass" "UFW firewall is active" "$rules rules configured"
    else
        print_status "fail" "UFW firewall is inactive" "Run: sudo ufw enable"
    fi
}

# Function to check DNS configuration
check_dns() {
    if grep -q "nameserver 127.0.0.1" /etc/resolv.conf 2>/dev/null; then
        print_status "pass" "Local DNS is configured"
    else
        print_status "warn" "Local DNS is not configured" "Using system default DNS"
    fi
}

# Function to check MAC randomization
check_mac_randomization() {
    if grep -q 'macchanger' /etc/network/interfaces 2>/dev/null; then
        if grep -q '^[^#]*macchanger' /etc/network/interfaces 2>/dev/null; then
            print_status "pass" "MAC address randomization is enabled"
        else
            print_status "warn" "MAC address randomization is configured but commented out"
        fi
    else
        print_status "warn" "MAC address randomization is not configured"
    fi
}

# Function to check IP leak
check_ip_leak() {
    if command -v curl &>/dev/null; then
        local public_ip=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null)
        if [[ -n "$public_ip" ]]; then
            print_status "info" "Public IP address: $public_ip"
            
            # Check if using VPN
            if protonvpn-cli status 2>/dev/null | grep -qi "connected"; then
                print_status "pass" "IP is protected by VPN"
            else
                print_status "warn" "IP is NOT protected by VPN"
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
    echo "   Privacy & VPN Status Monitor"
    echo "=========================================="
    echo ""
    echo "Timestamp: $(date)"
    echo ""
    
    # Package Checks
    echo -e "${CYAN}━━━ Package Status ━━━${NC}"
    check_package "proton-vpn-gnome-desktop" "ProtonVPN"
    check_package "tor" "Tor"
    check_package "dnscrypt-proxy" "DNSCrypt-Proxy"
    check_package "macchanger" "MAC Changer"
    check_package "apparmor" "AppArmor"
    check_package "ufw" "UFW Firewall"
    check_package "bleachbit" "BleachBit"
    check_package "firejail" "Firejail"
    check_package "signal-desktop" "Signal"
    check_package "telegram-desktop" "Telegram"
    echo ""
    
    # Service Checks
    echo -e "${CYAN}━━━ Service Status ━━━${NC}"
    check_service "tor" "Tor"
    check_service "dnscrypt-proxy" "DNSCrypt-Proxy"
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

