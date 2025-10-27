# TraceProtocol 🔒

**A Bash-based Privacy & VPN Management Suite for Linux**

TraceProtocol is a comprehensive Bash-based command-line tool for secure network configuration, privacy enhancement, and system automation on Linux systems. Built with security in mind, it provides a unified interface for managing VPN connections, DNS encryption, MAC address randomization, and advanced privacy tools.

[![Shell Script](https://img.shields.io/badge/Shell-Bash-blue.svg)](https://www.gnu.org/software/bash/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Linux-green.svg)](https://www.linux.org/)
[![Privacy](https://img.shields.io/badge/Privacy-First-red.svg)](https://www.privacyguides.org/)

## 🎥 Video Tutorial

Watch the video tutorial to see TraceProtocol in action:

<div align="center">

[![Watch the video tutorial on Vimeo](https://img.shields.io/badge/▶%20Watch%20Video%20Tutorial-Vimeo-19B7EA?style=for-the-badge&logo=vimeo&logoColor=white)](https://player.vimeo.com/video/1130674924)

**Click the button above to watch the video tutorial on Vimeo**

</div>

## Table of Contents

- [Video Tutorial](#-video-tutorial)
- [Features](#-features)
- [Installation](#-installation)
- [Usage](#-usage)
- [Technologies Used](#-technologies-used)
- [Project Structure](#-project-structure)
- [Security Features](#️-security-features)
- [Monitoring](#-monitoring)
- [Configuration](#-configuration)
- [Logs](#-logs)
- [Troubleshooting](#-troubleshooting)
- [Contributing](#-contributing)
- [License](#-license)
- [Acknowledgments](#-acknowledgments)
- [Support](#-support)

## 🌟 Features

### Core Privacy & Security Tools
- **Automated VPN Management** - ProtonVPN CLI with automatic server selection and connection management
- **Local DNS Caching** - High-performance DNS caching using dnsmasq for faster domain resolution
- **Encrypted DNS Queries** - Secure DNS resolution via dnscrypt-proxy to prevent DNS leaks and surveillance
- **MAC Address Randomization** - Hardware address anonymization using macchanger to prevent device tracking
- **Tor Integration** - Anonymous browsing and traffic routing through the Tor network
- **Kill Switch Protection** - iptables-based network blocking when VPN disconnects to prevent IP leaks
- **Application Sandboxing** - Firejail integration for running untrusted applications in isolated environments

### System Security & Privacy
- **AppArmor Integration** - Mandatory access control for enhanced system security
- **System Cleaner** - BleachBit integration for privacy-focused system maintenance

### Monitoring & Management
- **Real-time Status Monitor** - Command-line script showing all privacy tools status
- **Desktop Widget** - Conky-based desktop widget for continuous system monitoring
- **VPN Connection Manager** - One-command VPN connect/disconnect with server selection
- **Kill Switch Management** - Enable/disable iptables-based kill switch protection
- **MAC Address Control** - Randomize or restore MAC addresses on demand
- **Detailed Logging** - Complete audit trail of all system changes and operations
- **Configuration Management** - Centralized configuration file for easy customization

## 📋 Requirements

- **Linux system** (Debian/Ubuntu-based distributions recommended)
- **Root/sudo access** for system-level configurations
- **Internet connection** for package installation and VPN connectivity
- **ProtonVPN account** (free or paid)

## 🚀 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/mrxcherif/traceprotocol.git
cd traceprotocol
```

### 2. Make Scripts Executable

```bash
chmod +x trace-protocol.sh
chmod +x scripts/*.sh
```

### 3. Install All Privacy Tools

```bash
sudo ./trace-protocol.sh install
```

**What this Bash script does:**
- Updates your system package manager
- Installs required privacy and security packages (ProtonVPN CLI, Tor, dnscrypt-proxy, dnsmasq, macchanger, AppArmor, Firejail, BleachBit, iptables)
- Configures Tor service
- Installs and configures DNSCrypt-Proxy (listens on 127.0.0.1:5300)
- Configures dnsmasq to forward to DNSCrypt-Proxy and enables caching
- Sets up MAC address randomization (boot and network events)
- Enables AppArmor and creates Conky dashboard helpers
- Creates iptables-based kill switch manager
- Creates configuration files and log directories

## 📖 Usage

### Available Commands

```bash
./trace-protocol.sh [COMMAND]
```

| Command | Description |
|---------|-------------|
| `install` | Install all privacy tools and ProtonVPN |
| `uninstall` | Uninstall all privacy tools |
| `monitor` | Check status of all privacy tools |
| `vpn-connect` | Connect to ProtonVPN (fastest server) |
| `vpn-disconnect` | Disconnect from ProtonVPN |
| `vpn-status` | Show ProtonVPN connection status |
| `vpn-login` | Login to ProtonVPN account |
| `vpn-logout` | Logout from ProtonVPN account |
| `killswitch-on` | Enable VPN kill switch (iptables-based) |
| `killswitch-off` | Disable VPN kill switch |
| `killswitch-status` | Check kill switch status |
| `mac-randomize` | Randomize MAC address immediately |
| `mac-restore` | Restore MAC address to original |
| `clean-logs` | Clean all log files |
| `help` | Show help message |
| `version` | Show version information |

### Examples

#### Basic Workflow

```bash
# Login to ProtonVPN
./trace-protocol.sh vpn-login

# Connect to VPN
./trace-protocol.sh vpn-connect

# Enable kill switch for safety
./trace-protocol.sh killswitch-on

# Check everything is working
./trace-protocol.sh monitor
```

#### Advanced Usage

```bash
# Check VPN status only
./trace-protocol.sh vpn-status

# Disconnect from VPN
./trace-protocol.sh vpn-disconnect

# Check kill switch status
./trace-protocol.sh killswitch-status

# Randomize MAC address manually
./trace-protocol.sh mac-randomize

# Restore original MAC address
./trace-protocol.sh mac-restore

# Clean all logs
./trace-protocol.sh clean-logs
```

## 🛠️ Technologies Used

TraceProtocol combines **Bash** as the core scripting language with powerful privacy and security tools:

<div align="center">
<img src="https://www.security.org/app/uploads/2020/04/Proton-VPN-logo-768x296.png" alt="ProtonVPN" width="250" height="90px"/>
<img src="https://www.lffl.org/wp-content/uploads/2016/04/dnsmasq-logo.png" alt="dnsmasq" width="150" height="90px" />
<img src="https://raw.githubusercontent.com/jedisct1/dnscrypt-proxy/master/logo.png?3" alt="dnscrypt-proxy" width="150" height="85px"/>
<img src="https://www.kali.org/tools/macchanger/images/macchanger-logo.svg" alt="macchanger" width="100" height="90px"/>
</div>

**Core Architecture:**
- **Bash Scripts** - Linux-focused shell scripts for Debian/Ubuntu systems
- **ProtonVPN CLI** - Secure VPN connections with automatic server selection and kill switch
- **dnsmasq** - High-performance DNS caching for faster domain resolution
- **dnscrypt-proxy** - Encrypted DNS queries to prevent DNS leaks and surveillance
- **macchanger** - Hardware address anonymization to prevent device tracking
- **Tor** - Installed and managed as a service; monitored by the desktop widget
- **iptables** - Network filtering for kill switch protection
- **AppArmor** - Enabled to harden the system; status reported by monitor
- **Firejail** - Available for sandboxing applications
- **BleachBit** - Available for privacy cleaning
- **Conky** - Desktop widget for real-time system monitoring

## 📁 Project Structure

```
traceprotocol/
├── trace-protocol.sh           # Main control script
├── scripts/
│   ├── install.sh              # Installation script
│   ├── monitor.sh              # Monitoring script
│   ├── mac-changer.sh          # MAC randomization (manual)
│   ├── mac-randomize-boot.sh   # Boot-time MAC randomization
│   ├── vpn-login.sh            # ProtonVPN login helper
│   ├── killswitch-manager.sh   # iptables-based kill switch manager
│   └── uninstall.sh            # Uninstaller
├── logs/                       # Log files directory
├── docs/                       # Documentation directory
├── privacy-tools.conf          # Configuration file (created after install)
├── README.md                   # This file
├── LICENSE                     # MIT License
├── CONTRIBUTING.md             # Contribution guidelines
└── .gitignore                  # Git ignore rules
```

## 🔍 What Gets Installed

### Core Privacy Tools
- `tor` - The Onion Router
- `dnscrypt-proxy` - DNS encryption 
- `dnsmasq` - DNS caching and forwarding
- `macchanger` - MAC address randomization
- `protonvpn-cli` - ProtonVPN CLI

### Security Tools
- `apparmor` - Mandatory access control
- `apparmor-utils` - AppArmor utilities
- `iptables` - Network filtering (used for kill switch)
- `firejail` - Sandboxing tool

### Privacy Applications
- `bleachbit` - System cleaner
- `torbrowser-launcher` - Tor Browser installer

### Utilities
- `curl` - Data transfer tool
- `wget` - File downloader
- `dnsutils` - DNS utilities
- `coreutils` - Core utilities
- `conky-all` - Desktop widget system

## 🛡️ Security Features

### VPN Kill Switch
Prevents all network traffic if VPN disconnects, protecting against IP leaks. Uses iptables rules to block all traffic except VPN connections.

```bash
./trace-protocol.sh killswitch-on
```

### DNS Leak Protection
Routes DNS queries through encrypted channels (dnsmasq → DNSCrypt-Proxy → Encrypted DNS).

### MAC Address Randomization
Randomizes hardware addresses to prevent tracking. Automatically configured for boot-time and network events.

```bash
./trace-protocol.sh mac-randomize
```

### Application Sandboxing
Firejail available to run untrusted applications in isolated environments.

### System Hardening
AppArmor mandatory access control enabled for enhanced system security.

### IP Leak Protection
Real-time monitoring and protection against IP address exposure when VPN disconnects.

## 📊 Monitoring

The monitor provides real-time status of:

- ✅ **Package Status** - All installed privacy tools
- ✅ **Service Status** - Running services and uptime
- ✅ **VPN Status** - Connection status, server, IP
- ✅ **Kill Switch** - Enabled/disabled status (iptables-based)
- ✅ **DNS Configuration** - Local/remote DNS
- ✅ **DNS Leak Test** - DNS server verification
- ✅ **MAC Randomization** - Configuration status
- ✅ **Public IP** - Current public IP address
- ✅ **IP Protection** - VPN protection status
- ✅ **Tor Status** - Tor service monitoring
- ✅ **AppArmor Status** - Security framework status

### Monitor Output Example

```
━━━ ProtonVPN Status ━━━
✓ ProtonVPN CLI is installed
✓ ProtonVPN is connected
   ℹ Server: US-FREE#1 | IP: 1.2.3.4
✓ Kill switch is enabled

━━━ Network Information ━━━
ℹ Public IP address: 1.2.3.4
✓ IP is protected by VPN
```

## 🔧 Configuration

After installation, a configuration file is created at `privacy-tools.conf`:

```bash
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
```

Edit this file to customize your setup.

## 📝 Logs

All operations are logged to the `logs/` directory:

- `install_YYYYMMDD_HHMMSS.log` - Installation logs
- `monitor_YYYYMMDD.log` - Daily monitoring logs

Clean all logs with:

```bash
./trace-protocol.sh clean-logs
```

## 🤝 Contributing

Contributions are welcome! This project is built entirely with Bash scripts for Linux systems, so we follow strict shell scripting best practices.

### Bash Scripting Guidelines

**Code Standards:**
- Use **Linux-focused** Bash syntax for Debian/Ubuntu compatibility
- Always include proper **shebang** (`#!/bin/bash`) at the top of scripts
- Use **`set -euo pipefail`** for strict error handling
- Follow **consistent indentation** (4 spaces, no tabs)
- Use **meaningful variable names** and add comments for complex logic
- **Quote all variables** to prevent word splitting (`"$variable"`)

**Script Structure:**
```bash
#!/bin/bash
set -euo pipefail

# Script description and usage
# Author: Mr Cherif
# Version: 1.0

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="/var/log/traceprotocol.log"

# Functions
log_info() {
    echo "[INFO] $(date): $*" | tee -a "$LOG_FILE"
}

# Main script logic
main() {
    log_info "Starting TraceProtocol operation"
    # Your code here
}

# Script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

**Testing Requirements:**
- Test scripts on **Linux systems** (Debian/Ubuntu-based distributions)
- Use **shellcheck** for static analysis: `shellcheck script.sh`
- Test **error handling** with invalid inputs and edge cases
- Verify **Linux compatibility** with apt, systemctl, iptables commands

### Contribution Process

1. **Fork the repository**
2. **Create your feature branch** (`git checkout -b feature/AmazingFeature`)
3. **Follow Bash best practices** (see guidelines above)
4. **Test thoroughly** on multiple systems
5. **Run shellcheck** on your scripts
6. **Commit your changes** (`git commit -m 'Add some AmazingFeature'`)
7. **Push to the branch** (`git push origin feature/AmazingFeature`)
8. **Open a Pull Request** with detailed description

### Development Setup

```bash
# Install development tools
sudo apt-get install shellcheck bash-completion

# Run static analysis
shellcheck trace-protocol.sh scripts/*.sh

# Test Linux compatibility
bash -n trace-protocol.sh
```

## 🐛 Troubleshooting

### ProtonVPN won't connect

1. Check login: `./trace-protocol.sh vpn-login`
2. Check status: `./trace-protocol.sh vpn-status`
3. Check logs: `tail -f logs/install_*.log`

### Services not starting

```bash
# Check service status
sudo systemctl status tor
sudo systemctl status dnscrypt-proxy
sudo systemctl status dnsmasq

# Restart services manually
sudo systemctl restart tor
sudo systemctl restart dnscrypt-proxy
sudo systemctl restart dnsmasq
```

### Kill switch blocks internet

If kill switch is blocking your internet when VPN is off:

```bash
./trace-protocol.sh killswitch-off
```

This will restore normal internet access by removing iptables rules.

### DNSCrypt not working

If DNSCrypt-Proxy is not responding or configured:

```bash
# Check monitor - it will automatically fix DNSCrypt issues
./trace-protocol.sh monitor

# The monitor will:
# - Start DNSCrypt-Proxy service if stopped
# - Start dnsmasq service if stopped  
# - Test DNS encryption chain
# - Fix configuration issues automatically
```

### Permission denied errors

Make sure scripts are executable:

```bash
chmod +x trace-protocol.sh
chmod +x scripts/*.sh
```

## ⚠️ Important Notes

1. **ProtonVPN Account Required** - You need a ProtonVPN account (free or paid) to use the VPN features.

2. **System Reboot Recommended** - After installation, reboot your system to apply all changes and ensure MAC randomization works properly.

3. **Kill Switch Warning** - When enabled, kill switch will block all internet if VPN disconnects. Disable it if you need internet access without VPN.

4. **MAC Randomization** - Automatically configured for boot-time and network events. Use `./trace-protocol.sh mac-randomize` to change immediately.

5. **Linux Only** - This tool only works on Linux systems (Debian/Ubuntu-based distributions). Not compatible with macOS or Windows.

6. **Root/Sudo Required** - Installation and kill switch management require root privileges for system-level configurations.

7. **DNS Encryption** - Monitor automatically fixes DNSCrypt issues. Run `./trace-protocol.sh monitor` if DNS problems occur.

## 🚀 Coming Soon

Stay tuned for upcoming updates that will include:

- **Multi-OS Support** - macOS and Windows compatibility with native implementations
- **Advanced VPN Management** - Support for multiple VPN providers beyond ProtonVPN
- **Enhanced Privacy Features** - Additional privacy tools and security enhancements
- **Cross-Platform Monitoring** - Unified monitoring system across all supported operating systems
- **Privacy Analytics Dashboard** - Comprehensive privacy metrics and leak detection reports
- **Automated Privacy Hardening** - One-click system security optimization

Follow the project on [GitHub](https://github.com/mrxcherif/traceprotocol) to get notified of new releases!

## 📜 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

**MIT License Summary:**
- ✅ Commercial use allowed
- ✅ Modification allowed  
- ✅ Distribution allowed
- ✅ Private use allowed
- ❌ No liability or warranty provided

## 🙏 Acknowledgments

**TraceProtocol** is built on top of these excellent privacy and security tools:

- [ProtonVPN](https://protonvpn.com/) - Secure VPN service
- [Tor Project](https://www.torproject.org/) - Anonymity network
- [DNSCrypt](https://dnscrypt.info/) - DNS encryption
- [dnsmasq](https://thekelleys.org.uk/dnsmasq/doc.html) - DNS caching and forwarding
- [macchanger](https://github.com/alobbs/macchanger) - MAC address randomization
- [AppArmor](https://apparmor.net/) - Mandatory access control
- [Firejail](https://firejail.wordpress.com/) - Application sandboxing
- [BleachBit](https://www.bleachbit.org/) - System cleaner
- [Conky](https://github.com/brndnmtthws/conky) - Desktop widget system
- Privacy and open-source community

## 📧 Support

For issues, questions, or suggestions:

- Open an issue on [GitHub](https://github.com/mrxcherif/traceprotocol)
- Check existing issues and documentation
- Contribute to the project
- Connect on [LinkedIn](https://linkedin.com/in/mrxcherif) for professional discussions

## 🔗 Links

### Tool Documentation
- [ProtonVPN Documentation](https://protonvpn.com/support/)
- [Tor Project](https://www.torproject.org/)
- [DNSCrypt Documentation](https://dnscrypt.info/)
- [dnsmasq Documentation](https://thekelleys.org.uk/dnsmasq/doc.html)

### Privacy Resources
- [Privacy Guides](https://www.privacyguides.org/)
- [EFF Surveillance Self-Defense](https://ssd.eff.org/)

---

<div align="center">

**TraceProtocol - Stay Private. Stay Secure. Stay Anonymous.** 🔒

*Protecting your digital footprint, one connection at a time.*

</div>

