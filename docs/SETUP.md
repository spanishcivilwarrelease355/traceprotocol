# Setup Guide

Complete setup guide for Privacy & VPN Manager.

## Prerequisites

### System Requirements

- **Operating System**: Debian, Ubuntu, Parrot OS, or derivative
- **RAM**: 2GB minimum (4GB recommended)
- **Disk Space**: 500MB for all tools
- **Network**: Active internet connection
- **Permissions**: Root/sudo access

### ProtonVPN Account

You need a ProtonVPN account to use the VPN features:

1. **Free Account**: Visit [protonvpn.com](https://protonvpn.com) and sign up
2. **Paid Account**: Better speeds and more servers
3. **Note your credentials**: Username and password

## Installation Steps

### Step 1: Clone Repository

```bash
# Clone to your preferred location
cd ~/Desktop
git clone https://github.com/yourusername/traceprotocol.git
cd traceprotocol
```

### Step 2: Run Installation

```bash
# Make scripts executable (if needed)
chmod +x trace-protocol.sh
chmod +x scripts/*.sh

# Run installation (requires sudo)
sudo ./trace-protocol.sh install
```

The installation will:
- Update your system
- Install all privacy packages
- Configure services
- Set up ProtonVPN CLI
- Enable firewall
- Create configuration files

**Note**: Installation may take 10-30 minutes depending on your internet speed.

### Step 3: Login to ProtonVPN

```bash
# Login with your ProtonVPN credentials
./trace-protocol.sh vpn-login
```

You'll be prompted for:
- ProtonVPN username
- ProtonVPN password
- 2FA code (if enabled)

### Step 4: Connect to VPN

```bash
# Connect to fastest server
./trace-protocol.sh vpn-connect

# Or manually choose server
protonvpn-cli connect --cc US  # Connect to US
protonvpn-cli connect --sc     # Show server list
```

### Step 5: Enable Kill Switch

```bash
# Enable kill switch (recommended)
./trace-protocol.sh killswitch-on
```

### Step 6: Verify Installation

```bash
# Check all services
./trace-protocol.sh monitor
```

You should see:
- ✅ All packages installed
- ✅ Services running
- ✅ VPN connected
- ✅ Kill switch enabled

## Post-Installation Configuration

### Enable MAC Address Randomization (Optional)

```bash
# Edit network interfaces file
sudo nano /etc/network/interfaces

# Uncomment the line for your network interface:
# For Ethernet: pre-up /usr/bin/macchanger -r eth0
# For WiFi: pre-up /usr/bin/macchanger -r wlan0

# Find your interface name
ip link show
```

### Configure Firewall Rules (Optional)

```bash
# Allow specific ports if needed
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS

# Check firewall status
sudo ufw status verbose
```

### Auto-Connect VPN on Boot (Optional)

Create a systemd service:

```bash
sudo nano /etc/systemd/system/protonvpn-autoconnect.service
```

Add:

```ini
[Unit]
Description=ProtonVPN Auto Connect
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/bin/protonvpn-cli connect --fastest
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

Enable:

```bash
sudo systemctl enable protonvpn-autoconnect.service
sudo systemctl start protonvpn-autoconnect.service
```

## Verification

### Check VPN Connection

```bash
# Method 1: Using traceprotocol
./trace-protocol.sh vpn-status

# Method 2: Using protonvpn-cli
protonvpn-cli status

# Method 3: Check public IP
curl https://api.ipify.org
```

### Check for IP Leaks

Visit these sites in your browser:
- [ipleak.net](https://ipleak.net)
- [dnsleaktest.com](https://dnsleaktest.com)
- [browserleaks.com](https://browserleaks.com)

You should see:
- ✅ ProtonVPN server IP
- ✅ No DNS leaks
- ✅ No WebRTC leaks

### Test Kill Switch

```bash
# Disconnect VPN while kill switch is enabled
./trace-protocol.sh vpn-disconnect

# Try to access internet (should fail)
ping 8.8.8.8

# Reconnect VPN
./trace-protocol.sh vpn-connect
```

## Troubleshooting

### Installation Failed

```bash
# Check logs
tail -f logs/install_*.log

# Try manual update
sudo apt update
sudo apt upgrade

# Retry installation
sudo ./trace-protocol.sh install
```

### VPN Won't Connect

```bash
# Check ProtonVPN login
./trace-protocol.sh vpn-login

# Check network connectivity
ping protonvpn.com

# Try different server
protonvpn-cli connect --random
```

### Services Not Starting

```bash
# Check service status
sudo systemctl status tor
sudo systemctl status dnscrypt-proxy

# Restart services
./trace-protocol.sh stop-services
./trace-protocol.sh start-services

# Check for errors
journalctl -xe
```

### Kill Switch Blocks Everything

```bash
# Disable kill switch
./trace-protocol.sh killswitch-off

# Or manually
protonvpn-cli ks --off
```

### Permission Errors

```bash
# Make scripts executable
chmod +x trace-protocol.sh
chmod +x scripts/*.sh

# Run with sudo when needed
sudo ./trace-protocol.sh install
```

## Maintenance

### Update System

```bash
# Update packages
sudo apt update && sudo apt upgrade

# Update ProtonVPN
sudo apt update && sudo apt install --only-upgrade proton-vpn-gnome-desktop
```

### Clean Logs

```bash
# Clean logs older than 30 days
./trace-protocol.sh clean-logs

# Manual cleanup
find logs/ -name "*.log" -mtime +30 -delete
```

### Backup Configuration

```bash
# Backup privacy-tools.conf
cp privacy-tools.conf privacy-tools.conf.backup

# Backup firewall rules
sudo ufw status numbered > firewall-backup.txt
```

## Uninstallation

To remove all installed packages:

```bash
# Disconnect VPN
./trace-protocol.sh vpn-disconnect

# Disable kill switch
./trace-protocol.sh killswitch-off

# Remove packages
sudo apt remove --purge proton-vpn-gnome-desktop tor dnscrypt-proxy \
    macchanger apparmor-utils bleachbit firejail ufw \
    signal-desktop telegram-desktop torbrowser-launcher

# Remove configuration
sudo rm -rf /etc/protonvpn
sudo rm -f /etc/network/interfaces.backup

# Reset firewall
sudo ufw disable
sudo ufw reset
```

## Next Steps

After successful installation:

1. ✅ **Test VPN connection** regularly
2. ✅ **Monitor system** with live monitor
3. ✅ **Check for updates** weekly
4. ✅ **Review logs** for issues
5. ✅ **Backup configuration** monthly

## Additional Resources

- [ProtonVPN Support](https://protonvpn.com/support/)
- [Privacy Guides](https://www.privacyguides.org/)
- [EFF's Surveillance Self-Defense](https://ssd.eff.org/)
- [Tor Project Documentation](https://support.torproject.org/)

---

**Need Help?** Open an issue on GitHub or check existing documentation.

