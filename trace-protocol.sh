#!/bin/bash

# TraceProtocol - Privacy & VPN Management Suite
# A comprehensive tool for managing VPN and privacy tools on Linux

VERSION="1.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Ensure lolcat is installed and available
ensure_lolcat() {
    # Check common locations for lolcat
    if command -v lolcat >/dev/null 2>&1; then
        LOLCAT_CMD="lolcat"
    elif [ -x "/usr/games/lolcat" ]; then
        LOLCAT_CMD="/usr/games/lolcat"
    else
        echo -e "\033[1;33m⚡ Installing lolcat for colorful banners...\033[0m"
        if command -v apt >/dev/null 2>&1; then
            sudo apt update -qq >/dev/null 2>&1
            sudo apt install -y lolcat >/dev/null 2>&1
            LOLCAT_CMD="/usr/games/lolcat"
        elif command -v yum >/dev/null 2>&1; then
            sudo yum install -y lolcat >/dev/null 2>&1
            LOLCAT_CMD="lolcat"
        elif command -v pacman >/dev/null 2>&1; then
            sudo pacman -S --noconfirm lolcat >/dev/null 2>&1
            LOLCAT_CMD="lolcat"
        else
            echo -e "\033[1;31m⚠ Could not install lolcat automatically. Please install it manually.\033[0m"
            LOLCAT_CMD="cat"  # Fallback to regular cat
        fi
    fi
}

# Colors
RED='\033[38;5;196m'
GREEN='\033[38;5;46m'
YELLOW='\033[38;5;226m'  
WHITE='\033[1;37m'
BLUE='\033[38;5;27m'       
CYAN='\033[38;5;51m'       
MAGENTA='\033[38;5;201m'   
NC='\033[0m'


# Display banner with optional context
show_banner() {
    local context="$1"  # Optional context: "INSTALLER", "UNINSTALLER", etc.
    
    clear
    echo -e "${CYAN}"
    
    # Always use lolcat (it should be installed by ensure_lolcat)
    cat << "EOF" | $LOLCAT_CMD
████████ ██████   █████   ██████ ███████     ██████  ██████   ██████  ████████  ██████   ██████  ██████  ██      
   ██    ██   ██ ██   ██ ██      ██          ██   ██ ██   ██ ██    ██    ██    ██    ██ ██      ██    ██ ██      
   ██    ██████  ███████ ██      █████       ██████  ██████  ██    ██    ██    ██    ██ ██      ██    ██ ██      
   ██    ██   ██ ██   ██ ██      ██          ██      ██   ██ ██    ██    ██    ██    ██ ██      ██    ██ ██      
   ██    ██   ██ ██   ██  ██████ ███████     ██      ██   ██  ██████     ██     ██████   ██████  ██████  ███████                                                                                                                                                                                                                             
EOF
    echo -e "                                ${WHITE}Advanced Privacy & VPN Management Suite for Linux${NC}"
    echo -e "                                        ${GREEN}Author:${WHITE} Mr Cherif ${GREEN}| Version:${WHITE} 1.0${NC}"
    
    # Show context if provided
    if [ -n "$context" ]; then
        echo
        case "$context" in
            "INSTALLER")
                echo -e "                                               ${GREEN}🔧 INSTALLER MODULE 🔧${NC}" | $LOLCAT_CMD
                ;;
            "UNINSTALLER")
                echo -e "                                               ${RED}🗑️ UNINSTALLER MODULE 🗑️${NC}" | $LOLCAT_CMD
                ;;
            "HELP")
                echo -e "                                               ${BLUE}📖 HELP MODULE 📖${NC}" | $LOLCAT_CMD
                ;;
            "VERSION")
                echo -e "                                               ${PURPLE}ℹ️ VERSION MODULE ℹ️${NC}" | $LOLCAT_CMD
                ;;
            "VPN-LOGIN")
                echo -e "                                           ${YELLOW}🔐 VPN-LOGIN MODULE 🔐${NC}" | $LOLCAT_CMD
                ;;
            "VPN-LOGOUT")
                echo -e "                                           ${YELLOW}🔐 VPN-LOGOUT MODULE 🔐${NC}" | $LOLCAT_CMD
                ;;
            "VPN-CONNECT")
                echo -e "                                           ${YELLOW}🔐 VPN-CONNECT MODULE 🔐${NC}" | $LOLCAT_CMD
                ;;
            "VPN-DISCONNECT")
                echo -e "                                           ${YELLOW}🔐 VPN-DISCONNECT MODULE 🔐${NC}" | $LOLCAT_CMD
                ;;
            "MONITOR")
                echo -e "                                           ${CYAN}📊 MONITOR MODULE 📊${NC}" | $LOLCAT_CMD
                ;;
            "KILLSWITCH-ON")
                echo -e "                                           ${GREEN}🛡️  KILLSWITCH-ON MODULE 🛡️${NC}" | $LOLCAT_CMD
                ;;
            "KILLSWITCH-OFF")
                echo -e "                                           ${RED}⚠️  KILLSWITCH-OFF MODULE ⚠️${NC}" | $LOLCAT_CMD
                ;;
            "KILLSWITCH-STATUS")
                echo -e "                                           ${CYAN}📊 KILLSWITCH-STATUS MODULE 📊${NC}" | $LOLCAT_CMD
                ;;
            "VPN-STATUS")
                echo -e "                                           ${BLUE}📡 VPN-STATUS MODULE 📡${NC}" | $LOLCAT_CMD
                ;;
            "CLEAN-LOGS")
                echo -e "                                           ${YELLOW}🧹 CLEAN-LOGS MODULE 🧹${NC}" | $LOLCAT_CMD
                ;;
            "MAC-RANDOMIZE")
                echo -e "                                           ${BLUE}🔀 MAC-RANDOMIZE MODULE 🔀${NC}" | $LOLCAT_CMD
                ;;
            "MAC-RESTORE")
                echo -e "                                           ${GREEN}🔄 MAC-RESTORE MODULE 🔄${NC}" | $LOLCAT_CMD
                ;;
 
            *)
                echo -e "                                           ${CYAN}$context${NC}" | $LOLCAT_CMD
                ;;
        esac
    fi
    echo
}


# Display help
show_help() {
    show_banner "HELP"
    echo -e "${GREEN}USAGE:${NC}"
    echo -e "  ./trace-protocol.sh ${WHITE}[COMMAND]${NC}"
    echo ""
    echo -e "${GREEN}COMMANDS:${NC}"
    echo -e "  ${WHITE}install${NC}          ${GREEN}- Install all privacy tools and ProtonVPN${NC}"
    echo -e "  ${WHITE}uninstall${NC}        ${GREEN}- Uninstall all privacy tools${NC}"
    echo -e "  ${WHITE}monitor${NC}          ${GREEN}- Check status of all privacy tools${NC}"
    echo -e "  ${WHITE}vpn-connect${NC}      ${GREEN}- Connect to ProtonVPN (fastest server)${NC}"
    echo -e "  ${WHITE}vpn-disconnect${NC}   ${GREEN}- Disconnect from ProtonVPN${NC}"
    echo -e "  ${WHITE}vpn-status${NC}       ${GREEN}- Show ProtonVPN connection status${NC}"
    echo -e "  ${WHITE}vpn-login${NC}        ${GREEN}- Login to ProtonVPN account${NC}"
    echo -e "  ${WHITE}vpn-logout${NC}       ${GREEN}- Logout from ProtonVPN account${NC}"
    echo -e "  ${WHITE}killswitch-on${NC}    ${GREEN}- Enable VPN kill switch (requires sudo)${NC}"
    echo -e "  ${WHITE}killswitch-off${NC}   ${GREEN}- Disable VPN kill switch (requires sudo)${NC}"
    echo -e "  ${WHITE}killswitch-status${NC}${GREEN}- Check kill switch status${NC}"
    echo -e "  ${WHITE}mac-randomize${NC}    ${GREEN}- Randomize MAC address immediately${NC}"
    echo -e "  ${WHITE}mac-restore${NC}      ${GREEN}- Restore MAC address to original${NC}"
    echo -e "  ${WHITE}clean-logs${NC}       ${GREEN}- Clean all log files${NC}"
    echo -e "  ${WHITE}help${NC}             ${GREEN}- Show this help message${NC}"
    echo -e "  ${WHITE}version${NC}          ${GREEN}- Show version information${NC}"
    echo ""
    echo -e "${GREEN}EXAMPLES:${NC}"
    echo ""
    echo -e "${CYAN}Installation & Setup:${NC}"
    echo -e "  ${WHITE}sudo ./trace-protocol.sh install${NC}     ${MAGENTA}# Install the complete privacy suite${NC}"
    echo -e "  ${WHITE}sudo ./trace-protocol.sh uninstall${NC}   ${MAGENTA}# Remove all installed components${NC}"
    echo -e "  ${WHITE}./trace-protocol.sh monitor${NC}          ${MAGENTA}# Verify installation and system status${NC}"
    echo ""
    echo -e "${CYAN}VPN Management:${NC}"
    echo -e "  ${WHITE}./trace-protocol.sh vpn-login${NC}        ${MAGENTA}# Log in to ProtonVPN account${NC}"
    echo -e "  ${WHITE}./trace-protocol.sh vpn-connect${NC}      ${MAGENTA}# Connect to the fastest available server${NC}"
    echo ""
    echo -e "${CYAN}Privacy Tools:${NC}"
    echo -e "  ${WHITE}./trace-protocol.sh mac-randomize${NC}    ${MAGENTA}# Randomize network interface MAC address${NC}"
    echo ""
    echo -e "${CYAN}System Maintenance:${NC}"
    echo -e "  ${WHITE}./trace-protocol.sh clean-logs${NC}       ${MAGENTA}# Clean all log files${NC}"
}

# Show version
show_version() {
    show_banner "VERSION"
    echo -e "${GREEN}Version:${NC} $VERSION"
    echo -e "${GREEN}Project:${NC} Trace Protocol"
    echo -e "${GREEN}Author:${NC} Mr Cherif"
    echo -e "${GREEN}License:${NC} MIT"
    echo ""
}

# Check if script exists
check_script() {
    local script=$1
    if [[ ! -f "$SCRIPT_DIR/scripts/$script" ]]; then
        echo -e "${RED}Error: Script not found: scripts/$script${NC}"
        exit 1
    fi
}

# Install command
cmd_install() {
    show_banner "INSTALLER"
    check_script "install.sh"
    
    if [[ $EUID -ne 0 ]]; then
        sudo bash "$SCRIPT_DIR/scripts/install.sh"
    else
        bash "$SCRIPT_DIR/scripts/install.sh"
    fi
}

# Uninstall command
cmd_uninstall() {
    show_banner "UNINSTALLER"
    check_script "uninstall.sh"
    
    if [[ $EUID -ne 0 ]]; then
        sudo bash "$SCRIPT_DIR/scripts/uninstall.sh"
    else
        bash "$SCRIPT_DIR/scripts/uninstall.sh"
    fi
}

# Monitor command
cmd_monitor() {
    show_banner "MONITOR"
    check_script "monitor.sh"
    bash "$SCRIPT_DIR/scripts/monitor.sh"
}

# VPN connect command
cmd_vpn_connect() {
    show_banner "VPN-CONNECT"
    echo -e "${YELLOW}Connecting to ProtonVPN...${NC}"
    
    if ! command -v protonvpn-cli &>/dev/null; then
        echo -e "${RED}ProtonVPN CLI is not installed. Run: ./trace-protocol.sh install${NC}"
        exit 1
    fi
    
    # Randomize MAC address before VPN connect for enhanced privacy
    echo -e "${YELLOW}Randomizing MAC address for enhanced privacy...${NC}"
    if [ -f "$SCRIPT_DIR/scripts/mac-changer.sh" ]; then
        sudo bash "$SCRIPT_DIR/scripts/mac-changer.sh" randomize
        echo ""
    else
        echo -e "${RED}MAC changer script not found.${NC}"
    fi
    
    # Run ProtonVPN as regular user (not sudo)
    protonvpn-cli c -f
    echo ""
    
    # Check if actually connected
    VPN_STATUS=$(protonvpn-cli status 2>/dev/null)
    if echo "$VPN_STATUS" | grep -qi "Status.*Connected\|Connection.*Status.*Connected\|Server:" && ! echo "$VPN_STATUS" | grep -qi "No active.*connection"; then
        echo -e "${GREEN}VPN connection established!${NC}"
        # Show connection details if available
        if echo "$VPN_STATUS" | grep -q "Server:"; then
            echo -e "${CYAN}Connection Details:${NC}"
            echo "$VPN_STATUS" | grep -E "Server:|Country:|IP:" | sed 's/^/  /' | while read line; do
                if echo "$line" | grep -q "Server:"; then
                    server_value=$(echo "$line" | sed 's/.*Server:[[:space:]]*//')
                    echo -e "  ${MAGENTA}Server:${NC}${WHITE} $server_value${NC}"
                elif echo "$line" | grep -q "Country:"; then
                    country_value=$(echo "$line" | sed 's/.*Country:[[:space:]]*//')
                    echo -e "  ${MAGENTA}Country:${NC}${WHITE} $country_value${NC}"
                elif echo "$line" | grep -q "IP:"; then
                    ip_value=$(echo "$line" | sed 's/.*IP:[[:space:]]*//')
                    echo -e "  ${MAGENTA}IP:${NC}${WHITE} $ip_value${NC}"
                fi
            done
        fi
        echo ""
        echo -e "${YELLOW}To disconnect, use:${NC} ${WHITE}./trace-protocol.sh vpn-disconnect${NC}"
    else
        echo -e "${RED}VPN connection may have failed. Check with: protonvpn-cli status${NC}"
        echo -e "${YELLOW}Status output:${NC}"
        echo "$VPN_STATUS" | head -3
    fi
}

# VPN disconnect command
cmd_vpn_disconnect() {
    show_banner "VPN-DISCONNECT"
    echo -e "${YELLOW}Disconnecting from ProtonVPN...${NC}"
    
    if ! command -v protonvpn-cli &>/dev/null; then
        echo -e "${RED}ProtonVPN CLI is not installed.${NC}"
        exit 1
    fi
    
    # Run ProtonVPN as regular user (not sudo)
    protonvpn-cli d
    echo ""
    
    # Randomize MAC address after VPN disconnect
    echo -e "${YELLOW}Randomizing MAC address for enhanced privacy...${NC}"
    if [ -f "$SCRIPT_DIR/scripts/mac-changer.sh" ]; then
        sudo bash "$SCRIPT_DIR/scripts/mac-changer.sh" randomize
        echo ""
    else
        echo -e "${RED}MAC changer script not found.${NC}"
    fi
    
    echo -e "${YELLOW}To connect again, use:${NC} ${WHITE}./trace-protocol.sh vpn-connect${NC}"

}

# VPN status command
cmd_vpn_status() {
    show_banner "VPN-STATUS"

    if ! command -v protonvpn-cli &>/dev/null; then
        echo -e "${RED}ProtonVPN CLI is not installed.${NC}"
        exit 1
    fi

    echo ""
    STATUS_OUTPUT=$(protonvpn-cli status)
    
    # Color the status output with magenta labels and white values
    echo "$STATUS_OUTPUT" | while read line; do
        if echo "$line" | grep -q "IP:"; then
            ip_value=$(echo "$line" | sed 's/.*IP:[[:space:]]*//')
            echo -e "${MAGENTA}IP:${NC}${WHITE} $ip_value${NC}"
        elif echo "$line" | grep -q "Server:"; then
            server_value=$(echo "$line" | sed 's/.*Server:[[:space:]]*//')
            echo -e "${MAGENTA}Server:${NC}${WHITE} $server_value${NC}"
        elif echo "$line" | grep -q "Country:"; then
            country_value=$(echo "$line" | sed 's/.*Country:[[:space:]]*//')
            echo -e "${MAGENTA}Country:${NC}${WHITE} $country_value${NC}"
        elif echo "$line" | grep -q "Protocol:"; then
            protocol_value=$(echo "$line" | sed 's/.*Protocol:[[:space:]]*//')
            echo -e "${MAGENTA}Protocol:${NC}${WHITE} $protocol_value${NC}"
        elif echo "$line" | grep -q "Server Load:"; then
            load_value=$(echo "$line" | sed 's/.*Server Load:[[:space:]]*//')
            echo -e "${MAGENTA}Server Load:${NC}${WHITE} $load_value${NC}"
        elif echo "$line" | grep -q "Server Plan:"; then
            plan_value=$(echo "$line" | sed 's/.*Server Plan:[[:space:]]*//')
            echo -e "${MAGENTA}Server Plan:${NC}${WHITE} $plan_value${NC}"
        elif echo "$line" | grep -q "Kill switch:"; then
            killswitch_value=$(echo "$line" | sed 's/.*Kill switch:[[:space:]]*//')
            echo -e "${MAGENTA}Kill switch:${NC}${WHITE} $killswitch_value${NC}"
        elif echo "$line" | grep -q "Connection time:"; then
            time_value=$(echo "$line" | sed 's/.*Connection time:[[:space:]]*//')
            echo -e "${MAGENTA}Connection time:${NC}${WHITE} $time_value${NC}"
        else
            # For headers and separators, keep original formatting
            echo -e "$line"
        fi
    done
    echo ""

    if echo "$STATUS_OUTPUT" | grep -q "No active Proton VPN connection"; then
        # Not connected
        echo -e "${YELLOW}To connect, use:${NC} ${WHITE}./trace-protocol.sh vpn-connect${NC}"
    else
        # Connected
        echo -e "${YELLOW}To disconnect, use:${NC} ${WHITE}./trace-protocol.sh vpn-disconnect${NC}"
    fi

    echo ""
}

# VPN login command
cmd_vpn_login() {
    show_banner "VPN-LOGIN"
    check_script "vpn-login.sh"
    bash "$SCRIPT_DIR/scripts/vpn-login.sh"
}

# VPN logout command
cmd_vpn_logout() {
    show_banner "VPN-LOGOUT"
    echo -e "${YELLOW}Logging out from ProtonVPN...${NC}"
    
    if ! command -v protonvpn-cli &>/dev/null; then
        echo -e "${RED}ProtonVPN CLI is not installed.${NC}"
        exit 1
    fi
    
    protonvpn-cli logout
    echo ""
}

# Kill switch on
cmd_killswitch_on() {
    show_banner "KILLSWITCH-ON"
    
    # Check if running as root, if not, prompt for sudo
    if [ "$EUID" -ne 0 ]; then
        echo -e "${YELLOW}This command requires root privileges to modify iptables rules.${NC}"
        echo -e "${YELLOW}Please enter your password:${NC}"
        sudo "$0" killswitch-on
        exit $?
    fi
    
    # Use kill switch manager from scripts directory
    KILLSWITCH_MANAGER="$SCRIPT_DIR/scripts/killswitch-manager.sh"
    
    if [ -f "$KILLSWITCH_MANAGER" ]; then
        "$KILLSWITCH_MANAGER" enable
        echo ""
        echo -e "${YELLOW}To disable, use:${NC} ${WHITE}./trace-protocol.sh killswitch-off${NC}"
    else
        echo -e "${RED}Kill switch manager not found at: $KILLSWITCH_MANAGER${NC}"
        echo -e "${YELLOW}Run:${NC} ${WHITE}./trace-protocol.sh install${NC}"
    fi
}

# Kill switch off
cmd_killswitch_off() {
    show_banner "KILLSWITCH-OFF"
    
    # Check if running as root, if not, prompt for sudo
    if [ "$EUID" -ne 0 ]; then
        echo -e "${YELLOW}This command requires root privileges to modify iptables rules.${NC}"
        echo -e "${YELLOW}Please enter your password:${NC}"
        sudo "$0" killswitch-off
        exit $?
    fi
    
    # Use kill switch manager from scripts directory
    KILLSWITCH_MANAGER="$SCRIPT_DIR/scripts/killswitch-manager.sh"
    
    if [ -f "$KILLSWITCH_MANAGER" ]; then
        "$KILLSWITCH_MANAGER" disable
        echo ""
        echo -e "${YELLOW}To enable, use:${NC} ${WHITE}./trace-protocol.sh killswitch-on${NC}"
    else
        echo -e "${RED}Kill switch manager not found at: $KILLSWITCH_MANAGER${NC}"
        echo -e "${YELLOW}Run:${NC} ${WHITE}./trace-protocol.sh install${NC}"
    fi
}

# Kill switch status
cmd_killswitch_status() {
    show_banner "KILLSWITCH-STATUS"
    echo -e "${YELLOW}Checking kill switch status...${NC}"
    echo ""
    
    # Use kill switch manager from scripts directory
    KILLSWITCH_MANAGER="$SCRIPT_DIR/scripts/killswitch-manager.sh"
    
    if [ -f "$KILLSWITCH_MANAGER" ]; then
        "$KILLSWITCH_MANAGER" status
        echo ""
        echo -e "${YELLOW}To enable kill switch:${NC} ${WHITE}./trace-protocol.sh killswitch-on${NC}"
        echo -e "${YELLOW}To disable kill switch:${NC} ${WHITE}./trace-protocol.sh killswitch-off${NC}"
    else
        echo -e "${RED}Kill switch manager not found at: $KILLSWITCH_MANAGER${NC}"
        echo -e "${YELLOW}Run:${NC} ${WHITE}./trace-protocol.sh install${NC}"
    fi
}

# MAC address randomization
cmd_mac_randomize() {
    show_banner "MAC-RANDOMIZE"
    echo -e "${YELLOW}Randomizing MAC address...${NC}"
    echo ""
    
    # Check if mac-changer.sh exists
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    MAC_CHANGER_SCRIPT="$SCRIPT_DIR/scripts/mac-changer.sh"
    
    if [ ! -f "$MAC_CHANGER_SCRIPT" ]; then
        echo -e "${RED}MAC changer script not found at: $MAC_CHANGER_SCRIPT${NC}"
        exit 1
    fi
    
    # Execute MAC randomization
    if sudo bash "$MAC_CHANGER_SCRIPT" randomize; then
        echo ""
        echo -e "${GREEN}MAC address successfully randomized!${NC}"
        echo ""
        echo -e "${CYAN}Your MAC address will also be automatically randomized:${NC}"
        echo -e "${WHITE}  • At system boot${NC}"
        echo -e "${WHITE}  • On network connect/disconnect${NC}"
        echo -e "${WHITE}  • When connecting/disconnecting VPN${NC}"
        echo ""
        echo -e "${YELLOW}To restore MAC address to original, use: ${WHITE}./trace-protocol.sh mac-restore${NC}"

    else
        echo ""
        echo -e "${RED}Failed to randomize MAC address.${NC}"
        echo -e "${YELLOW}Check the output above for error details.${NC}"
        exit 1
    fi
}

# MAC address restoration
cmd_mac_restore() {
    show_banner "MAC-RESTORE"
    echo -e "${YELLOW}Restoring MAC address to original...${NC}"
    echo ""
    
    # Check if mac-changer.sh exists
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    MAC_CHANGER_SCRIPT="$SCRIPT_DIR/scripts/mac-changer.sh"
    
    if [ ! -f "$MAC_CHANGER_SCRIPT" ]; then
        echo -e "${RED}MAC changer script not found at: $MAC_CHANGER_SCRIPT${NC}"
        exit 1
    fi
    
    # Execute MAC restoration
    if sudo bash "$MAC_CHANGER_SCRIPT" restore; then
        echo ""
        echo -e "${GREEN}MAC address successfully restored to original!${NC}"
        echo ""
        echo -e "${CYAN}Note: MAC randomization will continue automatically:${NC}"
        echo -e "${WHITE}  • At system boot${NC}"
        echo -e "${WHITE}  • On network connect/disconnect${NC}"
        echo -e "${WHITE}  • When connecting/disconnecting VPN${NC}"
        echo ""
        echo -e "${YELLOW}To randomize MAC address again, use: ${WHITE}./trace-protocol.sh mac-randomize${NC}"
        echo ""
    else
        echo ""
        echo -e "${RED}Failed to restore MAC address.${NC}"
        echo -e "${YELLOW}Check the output above for error details.${NC}"
        exit 1
    fi
}

# Clean logs
cmd_clean_logs() {
    show_banner "CLEAN-LOGS"
    echo -e "${YELLOW}Cleaning all log files...${NC}"
    echo ""
    
    if [[ -d "$SCRIPT_DIR/logs" ]]; then
        # Count files before deletion
        local before_count=$(find "$SCRIPT_DIR/logs" -name "*.log" -type f | wc -l)
        
        if [ "$before_count" -gt 0 ]; then
            # Delete all log files
            find "$SCRIPT_DIR/logs" -name "*.log" -type f -delete
            echo -e "${GREEN}✓${NC} Deleted $before_count log file(s)"
            echo -e "${CYAN}ℹ${NC} All log files removed"
        else
            echo -e "${GREEN}✓${NC} No log files found to delete"
        fi
    else
        echo -e "${YELLOW}No logs directory found${NC}"
    fi
    echo ""
}

# Main command router
main() {
    # Ensure lolcat is installed first
    ensure_lolcat
    
    case "${1:-}" in
        install)
            cmd_install
            ;;
        uninstall)
            cmd_uninstall
            ;;
        monitor)
            cmd_monitor
            ;;
        vpn-connect)
            cmd_vpn_connect
            ;;
        vpn-disconnect)
            cmd_vpn_disconnect
            ;;
        vpn-status)
            cmd_vpn_status
            ;;
        vpn-login)
            cmd_vpn_login
            ;;
        vpn-logout)
            cmd_vpn_logout
            ;;
        killswitch-on)
            cmd_killswitch_on
            ;;
        killswitch-off)
            cmd_killswitch_off
            ;;
        killswitch-status)
            cmd_killswitch_status
            ;;
        mac-randomize)
            cmd_mac_randomize
            ;;
        mac-restore)
            cmd_mac_restore
            ;;
        clean-logs)
            cmd_clean_logs
            ;;
        version)
            show_version
            ;;
        help|--help|-h|"")
            show_help
            ;;
        *)
            echo -e "${RED}Error: Unknown command '${1}'${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function only if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

