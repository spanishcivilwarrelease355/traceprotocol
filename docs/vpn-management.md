# VPN Management with ProtonVPN

![ProtonVPN](https://www.security.org/app/uploads/2020/04/Proton-VPN-logo-768x296.png?width=50)

Automates secure VPN connections using ProtonVPN CLI to protect network traffic and maintain privacy while browsing the internet.

## Overview

TraceProtocol integrates ProtonVPN CLI to provide automated VPN management with features like automatic server selection, connection monitoring, and seamless integration with the kill switch system. This ensures your internet traffic is encrypted and routed through secure servers.

## Setup Instructions

### 1. Account Requirements

- **ProtonVPN Account**: Free or paid account required
- **Credentials**: Username and password for authentication

### 2. Installation

ProtonVPN CLI is automatically installed during TraceProtocol setup:

```bash
sudo ./trace-protocol.sh install
```

### 3. Initial Login

Authenticate with your ProtonVPN account:

```bash
./trace-protocol.sh vpn-login
```

Enter your ProtonVPN credentials when prompted. The credentials are securely stored for future connections.

## Usage Examples

### Basic VPN Operations

```bash
# Connect to fastest available server
./trace-protocol.sh vpn-connect

# Check connection status
./trace-protocol.sh vpn-status

# Disconnect from VPN
./trace-protocol.sh vpn-disconnect

# Logout from account
./trace-protocol.sh vpn-logout
```

### Advanced Usage

```bash
# Connect with automatic MAC randomization
./trace-protocol.sh vpn-connect
# MAC address is automatically randomized before connection

# Check detailed connection information
./trace-protocol.sh vpn-status
# Shows server, country, IP address, and connection time
```

## Configuration Options

### ProtonVPN Settings

Edit `privacy-tools.conf` to customize VPN behavior:

```bash
# VPN Settings
VPN_ENABLED=true
VPN_AUTOCONNECT=false
```

### ProtonVPN CLI Configuration

ProtonVPN CLI stores configuration in:
- **Config Directory**: `~/.config/protonvpn-cli/`
- **Logs**: `/var/log/protonvpn-cli.log`

### Server Selection

ProtonVPN automatically selects the fastest server, but you can manually specify:
- **Free servers**: Limited bandwidth
- **Paid servers**: Full speed and features
- **Country selection**: Available through ProtonVPN CLI directly

## Troubleshooting

### Common Issues

**VPN Connection Fails**
```bash
# Check login status
./trace-protocol.sh vpn-login

# Verify account credentials
protonvpn-cli status

# Check network connectivity
ping 8.8.8.8
```

**Slow Connection Speed**
- Try different ProtonVPN servers
- Check your internet connection speed
- Verify you're using a paid account for full speed

**Connection Drops Frequently**
- Enable kill switch: `./trace-protocol.sh killswitch-on`
- Check network stability
- Verify ProtonVPN server status

### Debug Commands

```bash
# Verbose ProtonVPN output
protonvpn-cli --verbose c -f

# Check ProtonVPN logs
tail -f /var/log/protonvpn-cli.log

# Test VPN connectivity
curl -s https://api.ipify.org
```

## Related Tools

### Kill Switch Integration

VPN management integrates with the kill switch system:
- **Automatic Protection**: Kill switch activates when VPN disconnects
- **Traffic Blocking**: All non-VPN traffic is blocked
- **Seamless Recovery**: Traffic resumes when VPN reconnects

### MAC Randomization

VPN connections trigger automatic MAC address changes:
- **Pre-Connection**: MAC randomized before VPN connects
- **Post-Disconnection**: MAC randomized after VPN disconnects
- **Enhanced Privacy**: Prevents device tracking

### DNS Integration

VPN works with encrypted DNS:
- **DNS Leak Protection**: DNS queries routed through VPN
- **Encrypted Resolution**: Combined with DNSCrypt-Proxy
- **Cached Queries**: Integrated with dnsmasq caching

## Links

- [ProtonVPN Documentation](https://protonvpn.com/support/)
- [ProtonVPN CLI Guide](https://protonvpn.com/support/linux-vpn-setup/)
- [Troubleshooting Guide](troubleshooting.md)
- [Kill Switch Documentation](kill-switch.md)
