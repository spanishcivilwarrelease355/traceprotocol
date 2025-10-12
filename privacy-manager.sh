#!/bin/bash

# Privacy Manager - Main Control Script
# A comprehensive tool for managing VPN and privacy tools on Linux

VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Display banner
show_banner() {
    clear
    echo -e "${CYAN}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║              Privacy & VPN Manager v1.0.0                 ║
║                                                           ║
║          Comprehensive Privacy Protection Suite          ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"
}

# Display help
show_help() {
    show_banner
    echo -e "${GREEN}USAGE:${NC}"
    echo "  ./privacy-manager.sh [COMMAND]"
    echo ""
    echo -e "${GREEN}COMMANDS:${NC}"
    echo -e "  ${CYAN}install${NC}          - Install all privacy tools and ProtonVPN"
    echo -e "  ${CYAN}monitor${NC}          - Check status of all privacy tools"
    echo -e "  ${CYAN}monitor-live${NC}     - Continuously monitor status (refreshes every 30s)"
    echo -e "  ${CYAN}vpn-connect${NC}      - Connect to ProtonVPN (fastest server)"
    echo -e "  ${CYAN}vpn-disconnect${NC}   - Disconnect from ProtonVPN"
    echo -e "  ${CYAN}vpn-status${NC}       - Show ProtonVPN connection status"
    echo -e "  ${CYAN}vpn-login${NC}        - Login to ProtonVPN account"
    echo -e "  ${CYAN}killswitch-on${NC}    - Enable VPN kill switch"
    echo -e "  ${CYAN}killswitch-off${NC}   - Disable VPN kill switch"
    echo -e "  ${CYAN}start-services${NC}   - Start all privacy services"
    echo -e "  ${CYAN}stop-services${NC}    - Stop all privacy services"
    echo -e "  ${CYAN}clean-logs${NC}       - Clean old log files"
    echo -e "  ${CYAN}help${NC}             - Show this help message"
    echo -e "  ${CYAN}version${NC}          - Show version information"
    echo ""
    echo -e "${GREEN}EXAMPLES:${NC}"
    echo "  ./privacy-manager.sh install       # Install all tools"
    echo "  ./privacy-manager.sh monitor       # Check system status"
    echo "  ./privacy-manager.sh vpn-connect   # Connect to VPN"
    echo ""
}

# Show version
show_version() {
    show_banner
    echo -e "${GREEN}Version:${NC} $VERSION"
    echo -e "${GREEN}Author:${NC} Privacy Tools Project"
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
    show_banner
    echo -e "${YELLOW}Starting installation...${NC}"
    echo ""
    check_script "install.sh"
    
    if [[ $EUID -ne 0 ]]; then
        sudo bash "$SCRIPT_DIR/scripts/install.sh"
    else
        bash "$SCRIPT_DIR/scripts/install.sh"
    fi
}

# Monitor command
cmd_monitor() {
    check_script "monitor.sh"
    bash "$SCRIPT_DIR/scripts/monitor.sh"
}

# Live monitor command
cmd_monitor_live() {
    check_script "monitor.sh"
    echo -e "${CYAN}Starting live monitor (Press Ctrl+C to exit)...${NC}"
    echo ""
    
    while true; do
        bash "$SCRIPT_DIR/scripts/monitor.sh"
        echo ""
        echo -e "${YELLOW}Refreshing in 30 seconds...${NC}"
        sleep 30
    done
}

# VPN connect command
cmd_vpn_connect() {
    show_banner
    echo -e "${YELLOW}Connecting to ProtonVPN...${NC}"
    
    if ! command -v protonvpn-cli &>/dev/null; then
        echo -e "${RED}ProtonVPN CLI is not installed. Run: ./privacy-manager.sh install${NC}"
        exit 1
    fi
    
    protonvpn-cli connect --fastest
    echo ""
    echo -e "${GREEN}VPN connection established!${NC}"
}

# VPN disconnect command
cmd_vpn_disconnect() {
    show_banner
    echo -e "${YELLOW}Disconnecting from ProtonVPN...${NC}"
    
    if ! command -v protonvpn-cli &>/dev/null; then
        echo -e "${RED}ProtonVPN CLI is not installed.${NC}"
        exit 1
    fi
    
    protonvpn-cli disconnect
    echo ""
    echo -e "${GREEN}VPN disconnected!${NC}"
}

# VPN status command
cmd_vpn_status() {
    show_banner
    
    if ! command -v protonvpn-cli &>/dev/null; then
        echo -e "${RED}ProtonVPN CLI is not installed.${NC}"
        exit 1
    fi
    
    echo -e "${CYAN}━━━ ProtonVPN Status ━━━${NC}"
    echo ""
    protonvpn-cli status
    echo ""
}

# VPN login command
cmd_vpn_login() {
    show_banner
    echo -e "${YELLOW}Logging into ProtonVPN...${NC}"
    echo ""
    
    if ! command -v protonvpn-cli &>/dev/null; then
        echo -e "${RED}ProtonVPN CLI is not installed. Run: ./privacy-manager.sh install${NC}"
        exit 1
    fi
    
    protonvpn-cli login
}

# Kill switch on
cmd_killswitch_on() {
    show_banner
    echo -e "${YELLOW}Enabling VPN kill switch...${NC}"
    
    if ! command -v protonvpn-cli &>/dev/null; then
        echo -e "${RED}ProtonVPN CLI is not installed.${NC}"
        exit 1
    fi
    
    protonvpn-cli ks --on
    echo ""
    echo -e "${GREEN}Kill switch enabled!${NC}"
}

# Kill switch off
cmd_killswitch_off() {
    show_banner
    echo -e "${YELLOW}Disabling VPN kill switch...${NC}"
    
    if ! command -v protonvpn-cli &>/dev/null; then
        echo -e "${RED}ProtonVPN CLI is not installed.${NC}"
        exit 1
    fi
    
    protonvpn-cli ks --off
    echo ""
    echo -e "${YELLOW}Kill switch disabled!${NC}"
}

# Start services
cmd_start_services() {
    show_banner
    echo -e "${YELLOW}Starting privacy services...${NC}"
    echo ""
    
    services=("tor" "dnscrypt-proxy" "apparmor")
    
    for service in "${services[@]}"; do
        echo -e "${CYAN}Starting $service...${NC}"
        sudo systemctl start "$service" 2>/dev/null && echo -e "${GREEN}✓${NC} $service started" || echo -e "${RED}✗${NC} Failed to start $service"
    done
    
    echo ""
    echo -e "${GREEN}Services started!${NC}"
}

# Stop services
cmd_stop_services() {
    show_banner
    echo -e "${YELLOW}Stopping privacy services...${NC}"
    echo ""
    
    services=("tor" "dnscrypt-proxy")
    
    for service in "${services[@]}"; do
        echo -e "${CYAN}Stopping $service...${NC}"
        sudo systemctl stop "$service" 2>/dev/null && echo -e "${GREEN}✓${NC} $service stopped" || echo -e "${RED}✗${NC} Failed to stop $service"
    done
    
    echo ""
    echo -e "${YELLOW}Services stopped!${NC}"
}

# Clean logs
cmd_clean_logs() {
    show_banner
    echo -e "${YELLOW}Cleaning old log files...${NC}"
    echo ""
    
    if [[ -d "$SCRIPT_DIR/logs" ]]; then
        # Delete logs older than 30 days
        find "$SCRIPT_DIR/logs" -name "*.log" -type f -mtime +30 -delete
        
        local count=$(find "$SCRIPT_DIR/logs" -name "*.log" -type f | wc -l)
        echo -e "${GREEN}✓${NC} Log cleanup completed"
        echo -e "${CYAN}ℹ${NC} $count log files remaining"
    else
        echo -e "${YELLOW}No logs directory found${NC}"
    fi
    echo ""
}

# Main command router
main() {
    case "${1:-}" in
        install)
            cmd_install
            ;;
        monitor)
            cmd_monitor
            ;;
        monitor-live)
            cmd_monitor_live
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
        killswitch-on)
            cmd_killswitch_on
            ;;
        killswitch-off)
            cmd_killswitch_off
            ;;
        start-services)
            cmd_start_services
            ;;
        stop-services)
            cmd_stop_services
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

# Run main function
main "$@"

