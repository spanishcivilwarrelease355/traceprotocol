#!/bin/bash

# TraceProtocol Monitoring Script
# Monitors the status of all privacy and VPN tools

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/../logs/monitor_$(date +%Y%m%d).log"

# Colors for output (needed before sudo check)
RED='\033[38;5;196m'
GREEN='\033[38;5;46m'
YELLOW='\033[38;5;226m'  
WHITE='\033[1;37m'
BLUE='\033[38;5;27m'       
CYAN='\033[38;5;51m'       
MAGENTA='\033[38;5;201m'   
NC='\033[0m'

# Check if running with sudo, if not, restart with sudo
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}Monitor script requires sudo privileges to check services and fix issues.${NC}"
    echo -e "${CYAN}Restarting with sudo...${NC}"
    echo ""
    exec sudo "$0" "$@"
fi

# Ensure logs directory exists and has proper permissions
LOGS_DIR="$SCRIPT_DIR/../logs"
if [ ! -d "$LOGS_DIR" ]; then
    mkdir -p "$LOGS_DIR"
fi
# Ensure the logs directory is writable by the current user
if [ ! -w "$LOGS_DIR" ]; then
    echo "Warning: Logs directory is not writable. Monitor output will not be logged."
    LOG_FILE="/dev/null"
fi

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
            echo -e "${GREEN}${CHECK} ${message}${NC}"
            [[ -n "$details" ]] && echo -e "   ${CYAN}${INFO}${NC} ${details}"
            ((PASSED++))
            log_to_file "PASS: $message ${details}"
            ;;
        "fail")
            echo -e "${RED}${CROSS} ${message}${NC}"
            [[ -n "$details" ]] && echo -e "   ${YELLOW}${INFO}${NC} ${details}"
            ((FAILED++))
            log_to_file "FAIL: $message ${details}"
            ;;
        "warn")
            echo -e "${YELLOW}${WARNING} ${message}${NC}"
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
    
    # Check only package name column (2nd field), not description
    if dpkg -l | awk '{print $2}' | grep -q "^${package}$" 2>/dev/null; then
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
        print_status "pass" "$display_name is running" "${MAGENTA}Since:${NC} ${WHITE}$uptime${NC}"
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
    
    # Check connection status (run as regular user, not root)
    local vpn_status=""
    local vpn_connected=false
    
    # Method 1: Check for VPN interfaces (most reliable)
    if ip link show 2>/dev/null | grep -qE "(proton|tun|tap)[0-9]"; then
        vpn_connected=true
        print_status "pass" "ProtonVPN is connected" "VPN interface detected"
    else
        # Method 2: Try ProtonVPN CLI status (may fail due to D-Bus issues)
        if [ "$SUDO_USER" ]; then
            # Running as root via sudo, use runuser with proper environment
            vpn_status=$(runuser -l "$SUDO_USER" -c "export DBUS_SESSION_BUS_ADDRESS=\$(echo \$DBUS_SESSION_BUS_ADDRESS); protonvpn-cli status" 2>/dev/null)
        else
            # Running as regular user
            vpn_status=$(protonvpn-cli status 2>/dev/null)
        fi
        
        # Check if connected by looking for Server: and IP: fields (these only appear when connected)
        if echo "$vpn_status" | grep -q "Server:" && echo "$vpn_status" | grep -q "IP:"; then
            local server=$(echo "$vpn_status" | grep "Server:" | awk '{print $2}')
            local vpn_ip=$(echo "$vpn_status" | grep "IP:" | awk '{print $2}')
            local country=$(echo "$vpn_status" | grep "Country:" | awk -F: '{print $2}' | xargs)
            vpn_connected=true
            print_status "pass" "ProtonVPN is connected" "Server: $server | VPN IP: $vpn_ip | Country: $country"
        fi
    fi
    
    # If still not connected, show warning
    if [ "$vpn_connected" = false ]; then
        print_status "warn" "ProtonVPN is not connected" "Run: ${WHITE}./trace-protocol.sh vpn-connect${NC}"
    fi
    
    # Check custom kill switch status (TraceProtocol)
    local ks_file="/var/lib/traceprotocol/killswitch-status.txt"
    local ks_manager="$(dirname "${BASH_SOURCE[0]}")/killswitch-manager.sh"
    
    # Check if kill switch system is installed
    if [ -f "$ks_file" ] || [ -x "$ks_manager" ]; then
        # Kill switch system exists, check status
        local ks_status=""
        
        if [ -f "$ks_file" ]; then
            # Use status file if available
            ks_status=$(cat "$ks_file" 2>/dev/null)
        elif [ -x "$ks_manager" ]; then
            # Fallback to manager script
            ks_status=$($ks_manager status 2>/dev/null)
        fi
        
        # Check if enabled
        if echo "$ks_status" | grep -qi "enabled"; then
            print_status "pass" "kill switch is enabled"
        else
            print_status "warn" "kill switch is disabled" "Run: ${WHITE}./trace-protocol.sh killswitch-on${NC}"
        fi
    else
        # Kill switch system not installed
        print_status "warn" "Custom kill switch not detected" "Run: ${WHITE}./trace-protocol.sh killswitch-on${NC}"
    fi
}

# Function to check DNS configuration
check_dns() {
    # This check is now integrated with DNSCrypt service check above
    # Just show additional DNS info
    local dns_nameserver=$(grep '^nameserver' /etc/resolv.conf 2>/dev/null | head -1 | awk '{print $2}')
    
    if [ "$dns_nameserver" = "127.0.0.1" ]; then
        print_status "pass" "System DNS configured for encryption" "${MAGENTA}Nameserver:${NC} ${WHITE}127.0.0.1${NC}"
    else
        print_status "info" "System DNS server" "${MAGENTA}Nameserver:${NC} ${WHITE}$dns_nameserver${NC}"
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
            print_status "pass" "MAC address is randomized" "${MAGENTA}Original:${NC} ${WHITE}$original_mac${NC} → ${MAGENTA}Current:${NC} ${WHITE}$current_mac${NC}"
        else
            print_status "info" "MAC address not randomized" "${MAGENTA}Current:${NC} ${WHITE}$current_mac${NC}"
        fi
    else
        print_status "warn" "MAC randomization not configured" "Run: ${WHITE}./trace-protocol.sh mac-randomize${NC}"
    fi
}

# Function to check IP leak
check_ip_leak() {
    if command -v curl &>/dev/null; then
        local current_ip=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null)
        
        if [[ -n "$current_ip" ]]; then
            # Check if using VPN by looking for VPN interfaces and ProtonVPN status
            local vpn_connected=false
            local vpn_server=""
            
            # Method 1: Check for VPN interfaces
            if ip link show 2>/dev/null | grep -qE "(proton|tun|tap)[0-9]"; then
                vpn_connected=true
            fi
            
            # Method 2: Check ProtonVPN status (more reliable)
            local vpn_status=""
            if [ "$SUDO_USER" ]; then
                # Running as root via sudo, use runuser to properly switch to regular user
                vpn_status=$(runuser -l "$SUDO_USER" -c "protonvpn-cli status" 2>/dev/null)
            else
                # Running as regular user
                vpn_status=$(protonvpn-cli status 2>/dev/null)
            fi
            if echo "$vpn_status" | grep -q "Server:" && echo "$vpn_status" | grep -q "IP:"; then
                vpn_connected=true
                vpn_server=$(echo "$vpn_status" | grep "Server:" | awk '{print $2}')
            fi
            
            if [ "$vpn_connected" = true ]; then
                # VPN is connected - current_ip is the VPN IP
                # Read the saved real IP from file (use proper user home directory)
                local real_ip=""
                local user_config_dir=""
                if [ -n "$SUDO_USER" ]; then
                    user_config_dir="/home/$SUDO_USER/.config/traceprotocol"
                else
                    user_config_dir="$(eval echo ~$(logname))/.config/traceprotocol"
                fi
                
                if [ -f "$user_config_dir/real_ip.txt" ]; then
                    real_ip=$(cat "$user_config_dir/real_ip.txt" 2>/dev/null)
                fi
                
                if [ -n "$real_ip" ] && [ "$real_ip" != "Checking..." ] && [ "$real_ip" != "$current_ip" ]; then
                    print_status "pass" "IP is protected by VPN" "${MAGENTA}Real IP:${NC} ${WHITE}$real_ip${NC} | ${MAGENTA}VPN IP:${NC} ${WHITE}$current_ip${NC}"
                else
                    print_status "pass" "IP is protected by VPN" "${MAGENTA}VPN IP:${NC} ${WHITE}$current_ip (via $vpn_server)${NC} | ${MAGENTA}Real IP:${NC} ${WHITE}Unknown (connect VPN first)${NC}"
                fi
            else
                # VPN not connected - current_ip IS the real IP
                # Save it immediately and display
                local really_disconnected=true
                
                # Triple check VPN is really off
                if ip link show 2>/dev/null | grep -qE "(proton|tun|tap)[0-9]"; then
                    really_disconnected=false
                fi
                
                local vpn_check_status=""
                if [ "$SUDO_USER" ]; then
                    vpn_check_status=$(runuser -l "$SUDO_USER" -c "protonvpn-cli status" 2>/dev/null)
                else
                    vpn_check_status=$(protonvpn-cli status 2>/dev/null)
                fi
                if echo "$vpn_check_status" | grep -q "Server:\|Country:\|IP:"; then
                    really_disconnected=false
                fi
                
                # Save and display current IP as real IP (use proper user home directory)
                if [ "$really_disconnected" = true ]; then
                    local user_config_dir=""
                    if [ -n "$SUDO_USER" ]; then
                        user_config_dir="/home/$SUDO_USER/.config/traceprotocol"
                    else
                        user_config_dir="$(eval echo ~$(logname))/.config/traceprotocol"
                    fi
                    
                    mkdir -p "$user_config_dir" 2>/dev/null
                    echo "$current_ip" > "$user_config_dir/real_ip.txt" 2>/dev/null
                    print_status "warn" "IP is NOT protected by VPN" "${MAGENTA}Real IP exposed:${NC} ${WHITE}$current_ip${NC}"
                else
                    print_status "warn" "IP is NOT protected by VPN" "${MAGENTA}Current IP:${NC} ${WHITE}$current_ip${NC} (VPN status unclear)"
                fi
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
            print_status "info" "${MAGENTA}DNS resolves to:${NC} ${WHITE}$dns_server${NC}"
        fi
    fi
}

# Function to fix DNSCrypt-Proxy configuration
fix_dnscrypt() {
    echo -e "${YELLOW}Attempting to fix DNSCrypt-Proxy configuration...${NC}"
    log_to_file "Starting DNSCrypt-Proxy fix attempt"
    
    # Check if DNSCrypt-Proxy binary exists
    if [ ! -f "/usr/local/bin/dnscrypt-proxy" ]; then
        print_status "fail" "DNSCrypt-Proxy binary not found" "Run: sudo ./scripts/install.sh"
        return 1
    fi
    
    # Check if service file exists
    if [ ! -f "/etc/systemd/system/dnscrypt-proxy.service" ]; then
        print_status "fail" "DNSCrypt-Proxy service file not found" "Run: sudo ./scripts/install.sh"
        return 1
    fi
    
    print_status "info" "DNSCrypt-Proxy files found, attempting to start service..."
    
    # Start DNSCrypt-Proxy service
    if systemctl start dnscrypt-proxy 2>/dev/null; then
        print_status "info" "DNSCrypt-Proxy service started"
        
        # Wait and test with retry mechanism (same as install script)
        local MAX_RETRIES=10
        local RETRY_COUNT=0
        local DNSCRYPT_WORKING=false
        
        while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
            RETRY_COUNT=$((RETRY_COUNT + 1))
            print_status "info" "Testing DNSCrypt-Proxy connectivity (attempt $RETRY_COUNT/$MAX_RETRIES)..."
            
            # Wait progressively longer between retries
            if [ $RETRY_COUNT -gt 1 ]; then
                local WAIT_TIME=$((RETRY_COUNT * 2))
                print_status "info" "Waiting ${WAIT_TIME}s for DNSCrypt-Proxy to initialize..."
                sleep $WAIT_TIME
            else
                sleep 3
            fi
            
            # Test with longer timeout for slow networks
            if timeout 10 dig @127.0.0.1 -p 5300 google.com >/dev/null 2>&1; then
                print_status "pass" "SUCCESS: DNSCrypt-Proxy is working and responding on port 5300"
                DNSCRYPT_WORKING=true
                break
            else
                print_status "warn" "Attempt $RETRY_COUNT failed - DNSCrypt-Proxy not responding yet"
                
                # Check if service is still running
                if ! systemctl is-active --quiet dnscrypt-proxy; then
                    print_status "fail" "DNSCrypt-Proxy service stopped unexpectedly"
                    break
                fi
            fi
        done
        
        if [ "$DNSCRYPT_WORKING" = true ]; then
            # Now configure dnsmasq if it's not working
            if ! systemctl is-active --quiet dnsmasq; then
                print_status "info" "Starting dnsmasq service..."
                if systemctl start dnsmasq 2>/dev/null; then
                    print_status "pass" "dnsmasq service started"
                else
                    print_status "fail" "Failed to start dnsmasq service"
                    return 1
                fi
            fi
            
            # Test the complete DNS chain
            if timeout 5 dig @127.0.0.1 google.com >/dev/null 2>&1; then
                print_status "pass" "DNS encryption chain is now working!"
                print_status "info" "${MAGENTA}dnsmasq:${NC} ${WHITE}53${NC} → ${MAGENTA}DNSCrypt:${NC} ${WHITE}5300${NC} → Encrypted DNS"
                log_to_file "DNSCrypt-Proxy fix completed successfully"
                return 0
            else
                print_status "warn" "DNSCrypt working but dnsmasq chain broken"
                return 1
            fi
        else
            print_status "fail" "DNSCrypt-Proxy failed to respond after $MAX_RETRIES attempts"
            print_status "info" "This may be due to slow network or DNS server issues"
            log_to_file "DNSCrypt-Proxy fix failed after $MAX_RETRIES attempts"
            return 1
        fi
    else
        print_status "fail" "Failed to start DNSCrypt-Proxy service"
        log_to_file "Failed to start DNSCrypt-Proxy service"
        return 1
    fi
}

# Function to check Tor status (simplified logic)
check_tor() {
    # Check if Tor package is installed
    if ! dpkg -l | awk '{print $2}' | grep -q "^tor$" 2>/dev/null; then
        print_status "fail" "Tor is not installed" "Run: sudo apt install tor"
        return
    fi
    
    # Check internet connectivity first
    local current_ip=$(curl -s --max-time 5 https://api.ipify.org 2>/dev/null)
    if [ -z "$current_ip" ]; then
        print_status "warn" "Tor: No Internet connection" "Check network connectivity"
        return
    fi
    
    # Check if Tor service is running
    if pgrep -x tor >/dev/null 2>&1 && systemctl is-active --quiet tor 2>/dev/null; then
        print_status "pass" "Tor is running" "Service active, ${MAGENTA}SOCKS proxy:${NC} ${WHITE}127.0.0.1:9050${NC}"
    else
        print_status "fail" "Tor is stopped" "Run: sudo systemctl start tor"
    fi
}

# Main monitoring function
main() {
    echo ""
   
    echo ""
    echo -e "${WHITE}Timestamp:${NC} $(date)"
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
    check_package "dnsmasq" "dnsmasq (DNS Cache/Forwarder)"
    check_package "apparmor" "AppArmor"
    check_package "bleachbit" "BleachBit"
    check_package "firejail" "Firejail"
    check_package "torbrowser-launcher" "Tor Browser"
    check_package "conky-all" "Conky Widget"
    echo ""
    
    # Service Checks
    echo -e "${CYAN}━━━ Service Status ━━━${NC}"
    check_tor
    # Check combined dnsmasq + DNSCrypt-Proxy setup
    local dnscrypt_status=$(systemctl is-active dnscrypt-proxy 2>/dev/null)
    local dnsmasq_status=$(systemctl is-active dnsmasq 2>/dev/null)
    local dns_nameserver=$(grep '^nameserver' /etc/resolv.conf 2>/dev/null | head -1 | awk '{print $2}')
    local forwarding_config="/etc/dnsmasq.d/dnscrypt.conf"
    local dnscrypt_needs_fix=false
    
    # Check if the complete chain is working
    if [[ "$dnscrypt_status" == "active" ]] && [[ "$dnsmasq_status" == "active" ]] && [ -f "$forwarding_config" ]; then
        # Test if the chain actually works
        if timeout 3 dig @127.0.0.1 google.com >/dev/null 2>&1 && timeout 3 dig @127.0.0.1 -p 5300 google.com >/dev/null 2>&1; then
            if [ "$dns_nameserver" = "127.0.0.1" ]; then
                print_status "pass" "DNS Encryption Chain Active" "${MAGENTA}dnsmasq:${NC} ${WHITE}53${NC} → ${MAGENTA}DNSCrypt:${NC} ${WHITE}5300${NC} → Encrypted DNS"
            else
                print_status "warn" "DNS Encryption ready but not configured" "DNS: $dns_nameserver (should be 127.0.0.1)"
            fi
        else
            print_status "warn" "DNS Encryption services running but chain broken" "Attempting automatic fix..."
            dnscrypt_needs_fix=true
        fi
    elif [[ "$dnscrypt_status" == "active" ]] && [[ "$dnsmasq_status" != "active" ]]; then
        print_status "warn" "DNSCrypt running but dnsmasq not active" "Attempting automatic fix..."
        dnscrypt_needs_fix=true
    elif [[ "$dnscrypt_status" != "active" ]] && [[ "$dnsmasq_status" == "active" ]]; then
        print_status "warn" "dnsmasq running but DNSCrypt not active" "Attempting automatic fix..."
        dnscrypt_needs_fix=true
    elif [[ "$dnscrypt_status" != "active" ]] && [[ "$dnsmasq_status" != "active" ]]; then
        # Check if DNSCrypt files exist (was installed but not running)
        if [ -f "/usr/local/bin/dnscrypt-proxy" ] && [ -f "/etc/systemd/system/dnscrypt-proxy.service" ]; then
            print_status "warn" "DNS Encryption services stopped" "Attempting automatic fix..."
            dnscrypt_needs_fix=true
        else
            print_status "fail" "DNS Encryption not configured" "Run: sudo ./scripts/install.sh"
        fi
    fi
    
    # Attempt automatic fix if needed
    if [ "$dnscrypt_needs_fix" = true ]; then
        echo ""
        print_status "info" "Auto-fixing DNSCrypt-Proxy configuration..."
        if fix_dnscrypt; then
            print_status "pass" "DNS Encryption Chain Fixed!" "${MAGENTA}dnsmasq:${NC} ${WHITE}53${NC} → ${MAGENTA}DNSCrypt:${NC} ${WHITE}5300${NC} → Encrypted DNS"
        else
            print_status "fail" "Auto-fix failed" "Manual intervention required"
        fi
        echo ""
    fi
    check_service "apparmor" "AppArmor"
    echo ""
    
    # ProtonVPN Checks
    echo -e "${CYAN}━━━ ProtonVPN Status ━━━${NC}"
    check_protonvpn
    echo ""
    
    # Security Checks
    echo -e "${CYAN}━━━ Security Configuration ━━━${NC}"
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
    echo -e "${GREEN}Passed: $PASSED${NC}  ${RED}Failed: $FAILED${NC}  ${YELLOW}Warnings: $WARNINGS${NC}"
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

