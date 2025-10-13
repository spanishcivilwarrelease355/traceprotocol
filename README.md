# TraceProtocol 🔒

**Privacy & VPN Management Suite for Linux**

A comprehensive privacy and VPN management tool for Linux systems (Debian/Ubuntu/Parrot OS). TraceProtocol automatically installs and configures ProtonVPN CLI along with essential privacy and security tools, and provides real-time monitoring of your privacy protection status.

## 🌟 Features

### Security & Privacy Tools
- **ProtonVPN CLI** - Secure VPN connection with kill switch
- **Tor** - Anonymous browsing and traffic routing
- **DNSCrypt-Proxy** - Encrypted DNS queries
- **MAC Address Randomization** - Hardware address anonymization
- **UFW Firewall** - Uncomplicated firewall configuration
- **AppArmor** - Mandatory access control
- **Firejail** - Application sandboxing
- **BleachBit** - Privacy-focused system cleaner

### Secure Messaging
- **Signal Desktop** - End-to-end encrypted messaging
- **Telegram Desktop** - Secure messaging platform

### Monitoring & Management
- **Real-time Status Monitor** - Check all privacy tools at a glance
- **VPN Connection Manager** - Easy VPN connect/disconnect
- **Kill Switch Control** - Prevent IP leaks
- **Service Management** - Start/stop privacy services
- **Detailed Logging** - Track all system changes

## 📋 Requirements

- Linux system (Debian/Ubuntu/Parrot OS or derivative)
- Root/sudo access
- Internet connection
- ProtonVPN account (free or paid)

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/traceprotocol.git
cd traceprotocol
```

### 2. Install All Privacy Tools

```bash
sudo ./trace-protocol.sh install
```

This will:
- Update your system
- Install all privacy and security packages
- Configure ProtonVPN CLI
- Set up firewall, Tor, DNSCrypt
- Enable security services

### 3. Login to ProtonVPN

```bash
./trace-protocol.sh vpn-login
```

Enter your ProtonVPN credentials when prompted.

### 4. Connect to VPN

```bash
./trace-protocol.sh vpn-connect
```

### 5. Enable Kill Switch

```bash
./trace-protocol.sh killswitch-on
```

### 6. Monitor Your Privacy Status

```bash
./trace-protocol.sh monitor
```

## 📖 Usage

### Available Commands

```bash
./trace-protocol.sh [COMMAND]
```

| Command | Description |
|---------|-------------|
| `install` | Install all privacy tools and ProtonVPN |
| `monitor` | Check status of all privacy tools |
| `monitor-live` | Continuously monitor status (refreshes every 30s) |
| `vpn-connect` | Connect to ProtonVPN (fastest server) |
| `vpn-disconnect` | Disconnect from ProtonVPN |
| `vpn-status` | Show ProtonVPN connection status |
| `vpn-login` | Login to ProtonVPN account |
| `killswitch-on` | Enable VPN kill switch |
| `killswitch-off` | Disable VPN kill switch |
| `start-services` | Start all privacy services |
| `stop-services` | Stop all privacy services |
| `clean-logs` | Clean old log files (older than 30 days) |
| `help` | Show help message |
| `version` | Show version information |

### Examples

#### Basic Workflow

```bash
# Install everything
sudo ./trace-protocol.sh install

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

# Live monitoring (updates every 30 seconds)
./trace-protocol.sh monitor-live

# Restart privacy services
./trace-protocol.sh stop-services
./trace-protocol.sh start-services

# Clean old logs
./trace-protocol.sh clean-logs
```

## 📁 Project Structure

```
traceprotocol/
├── trace-protocol.sh           # Main control script
├── scripts/
│   ├── install.sh              # Installation script
│   ├── vpn-setup.sh            # VPN configuration
│   ├── monitor.sh              # Monitoring script
│   ├── mac-changer.sh          # MAC randomization
│   ├── configure-ufw.sh        # Firewall configuration
│   └── uninstall.sh            # Uninstaller
├── logs/                       # Log files directory
├── docs/                       # Documentation
├── privacy-tools.conf          # Configuration file (created after install)
├── README.md                   # This file
├── LICENSE                     # MIT License
└── .gitignore                 # Git ignore rules
```

## 🔍 What Gets Installed

### Core Privacy Tools
- `tor` - The Onion Router
- `dnscrypt-proxy` - DNS encryption
- `macchanger` - MAC address randomization
- `proton-vpn-gnome-desktop` - ProtonVPN CLI and GUI

### Security Tools
- `apparmor` - Mandatory access control
- `apparmor-utils` - AppArmor utilities
- `ufw` - Uncomplicated Firewall
- `iptables` - Network filtering
- `firejail` - Sandboxing tool

### Privacy Applications
- `bleachbit` - System cleaner
- `torbrowser-launcher` - Tor Browser installer
- `signal-desktop` - Secure messaging
- `telegram-desktop` - Encrypted messaging

### Utilities
- `curl` - Data transfer tool
- `wget` - File downloader
- `dnsmasq` - DNS caching

## 🛡️ Security Features

### VPN Kill Switch
Prevents all network traffic if VPN disconnects, protecting against IP leaks.

```bash
./trace-protocol.sh killswitch-on
```

### DNS Leak Protection
Routes DNS queries through encrypted channels (DNSCrypt + ProtonVPN).

### MAC Address Randomization
Randomizes hardware addresses to prevent tracking (configured but commented out by default).

Edit `/etc/network/interfaces` to enable for your interface.

### Firewall Protection
UFW configured to deny all incoming connections and allow outgoing only.

### Application Sandboxing
Firejail available to run untrusted applications in isolated environments.

## 📊 Monitoring

The monitor provides real-time status of:

- ✅ **Package Status** - All installed privacy tools
- ✅ **Service Status** - Running services and uptime
- ✅ **VPN Status** - Connection status, server, IP
- ✅ **Kill Switch** - Enabled/disabled status
- ✅ **Firewall Status** - Active rules count
- ✅ **DNS Configuration** - Local/remote DNS
- ✅ **MAC Randomization** - Configuration status
- ✅ **Public IP** - Current public IP address
- ✅ **IP Protection** - VPN protection status

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
MAC_RANDOMIZATION=false

# Monitoring Settings
MONITOR_INTERVAL=60
LOG_RETENTION_DAYS=30
```

Edit this file to customize your setup.

## 📝 Logs

All operations are logged to the `logs/` directory:

- `install_YYYYMMDD_HHMMSS.log` - Installation logs
- `monitor_YYYYMMDD.log` - Daily monitoring logs

Clean old logs with:

```bash
./trace-protocol.sh clean-logs
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

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

# Restart services
./trace-protocol.sh start-services
```

### Kill switch blocks internet

If kill switch is blocking your internet when VPN is off:

```bash
./trace-protocol.sh killswitch-off
```

### Permission denied errors

Make sure scripts are executable:

```bash
chmod +x trace-protocol.sh
chmod +x scripts/*.sh
```

## ⚠️ Important Notes

1. **ProtonVPN Account Required** - You need a ProtonVPN account (free or paid) to use the VPN features.

2. **System Reboot Recommended** - After installation, reboot your system to apply all changes.

3. **Kill Switch Warning** - When enabled, kill switch will block all internet if VPN disconnects. Disable it if you need internet access without VPN.

4. **MAC Randomization** - Configured but commented out by default. Enable manually if needed.

5. **Firewall Rules** - UFW denies all incoming connections. Adjust rules if you run servers.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

**TraceProtocol** is built on top of these excellent privacy tools:

- [ProtonVPN](https://protonvpn.com/) - Secure VPN service
- [Tor Project](https://www.torproject.org/) - Anonymity network
- [DNSCrypt](https://dnscrypt.info/) - DNS encryption
- Privacy and open-source community

## 📧 Support

For issues, questions, or suggestions:

- Open an issue on GitHub
- Check existing issues and documentation
- Contribute to the project

## 🔗 Links

- [ProtonVPN Documentation](https://protonvpn.com/support/)
- [Tor Project](https://www.torproject.org/)
- [Privacy Guides](https://www.privacyguides.org/)
- [EFF Surveillance Self-Defense](https://ssd.eff.org/)

---

<div align="center">

**TraceProtocol - Stay Private. Stay Secure. Stay Anonymous.** 🔒

*Protecting your digital footprint, one connection at a time.*

</div>

