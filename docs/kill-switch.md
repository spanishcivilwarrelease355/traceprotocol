# Kill Switch with iptables

![iptable](https://webistore.ru/wp-content/uploads/2021/12/iptables_linux.png)

Provides advanced network protection using iptables rules to block all traffic when VPN disconnects, preventing IP leaks and maintaining privacy.

## Overview

The kill switch is a critical security feature that uses iptables to create a comprehensive firewall that blocks all internet traffic when VPN connections fail. This prevents accidental IP leaks and ensures your real IP address remains hidden even if the VPN disconnects unexpectedly.

## Setup Instructions

### 1. Automatic Installation

The kill switch manager is automatically installed during TraceProtocol setup:

```bash
sudo ./trace-protocol.sh install
```

### 2. Kill Switch Manager

The kill switch uses a dedicated manager script: `scripts/killswitch-manager.sh`

```bash
# Enable kill switch
./trace-protocol.sh killswitch-on

# Disable kill switch
./trace-protocol.sh killswitch-off

# Check kill switch status
./trace-protocol.sh killswitch-status
```

### 3. Automatic Interface Detection

The kill switch automatically detects:
- **Physical Interface**: Primary network interface (eth0, wlan0, etc.)
- **VPN Interface**: VPN tunnel interface (tun0, proton0, etc.)
- **Network Configuration**: Current network setup

## Usage Examples

### Basic Kill Switch Operations

```bash
# Enable kill switch protection
./trace-protocol.sh killswitch-on

# Check if kill switch is active
./trace-protocol.sh killswitch-status

# Disable kill switch (restore internet)
./trace-protocol.sh killswitch-off
```

### Advanced Operations

```bash
# Manual kill switch management
sudo scripts/killswitch-manager.sh enable
sudo scripts/killswitch-manager.sh disable
sudo scripts/killswitch-manager.sh status

# Check iptables rules
sudo iptables -L -n -v
sudo ip6tables -L -n -v
```

### Integration with VPN

```bash
# Connect VPN with kill switch
./trace-protocol.sh vpn-connect
./trace-protocol.sh killswitch-on

# Kill switch automatically protects when VPN disconnects
# All traffic blocked until VPN reconnects or kill switch disabled
```

## Configuration Options

### iptables Rules

The kill switch creates comprehensive iptables rules:

**IPv4 Rules**:
```bash
# Default policies
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow VPN interface
iptables -A INPUT -i tun0 -j ACCEPT
iptables -A OUTPUT -o tun0 -j ACCEPT

# Allow VPN server connections
iptables -A OUTPUT -o eth0 -p udp --dport 1194 -j ACCEPT
iptables -A OUTPUT -o eth0 -p udp --dport 443 -j ACCEPT

# Block all other traffic
iptables -A OUTPUT -o eth0 -j DROP
```

**IPv6 Rules**:
```bash
# Similar rules for IPv6
ip6tables -P INPUT DROP
ip6tables -P OUTPUT DROP
ip6tables -P FORWARD DROP
# ... (similar IPv6 configuration)
```

### VPN Provider Support

The kill switch works with any VPN provider:
- **ProtonVPN**: Automatically detects proton interfaces
- **OpenVPN**: Works with tun/tap interfaces
- **WireGuard**: Supports wg interfaces
- **Custom VPNs**: Detects any VPN interface

## Troubleshooting

### Common Issues

**Kill Switch Blocks Internet When VPN is Off**
```bash
# Disable kill switch to restore internet
./trace-protocol.sh killswitch-off

# Check VPN status
./trace-protocol.sh vpn-status

# Reconnect VPN
./trace-protocol.sh vpn-connect
```

**Kill Switch Not Working**
```bash
# Check kill switch status
./trace-protocol.sh killswitch-status

# Verify iptables rules
sudo iptables -L -n -v

# Check VPN interface detection
ip link show | grep -E "(tun|tap|proton|wg)"
```

**Interface Detection Issues**
```bash
# Check physical interface
ip link show | grep -E "(eth|wlan|wlp|enp|ens)"

# Check VPN interface
ip link show | grep -E "(tun|tap|proton|wg)"

# Manual interface specification
# Edit killswitch-manager.sh if needed
```

### Debug Commands

```bash
# Check iptables rules
sudo iptables -L -n -v
sudo ip6tables -L -n -v

# View kill switch logs
sudo tail -f /var/log/traceprotocol-killswitch.log

# Test network connectivity
ping 8.8.8.8
curl -s https://api.ipify.org

# Check interface status
ip link show
ip route show
```

## Related Tools

### VPN Integration

Kill switch works seamlessly with VPN connections:
- **Automatic Protection**: Activates when VPN disconnects
- **Traffic Blocking**: Blocks all non-VPN traffic
- **Seamless Recovery**: Allows traffic when VPN reconnects

### DNS Integration

Kill switch protects DNS queries:
- **DNS Leak Prevention**: Blocks DNS queries on physical interface
- **Encrypted DNS**: Allows DNS through VPN interface
- **Fallback Protection**: Prevents DNS leaks when VPN fails

### MAC Randomization Integration

Kill switch works with MAC randomization:
- **Device Privacy**: MAC randomization hides device identity
- **Traffic Privacy**: Kill switch protects traffic
- **Complete Protection**: Both device and traffic are protected

## Security Benefits

### IP Leak Prevention

- **Complete Blocking**: All traffic blocked when VPN fails
- **No Accidental Leaks**: Prevents accidental IP exposure
- **Automatic Protection**: No manual intervention required
- **Comprehensive Coverage**: IPv4 and IPv6 protection

### Advanced Protection

- **VPN-Agnostic**: Works with any VPN provider
- **Interface Detection**: Automatically finds VPN interfaces
- **Rule Management**: Comprehensive iptables rules
- **State Tracking**: Maintains connection state

## Technical Details

### Rule Structure

The kill switch creates a layered protection system:
1. **Default Deny**: All traffic blocked by default
2. **Loopback Allow**: Local traffic allowed
3. **Established Allow**: Existing connections allowed
4. **VPN Allow**: VPN interface traffic allowed
5. **Server Allow**: VPN server connections allowed
6. **Physical Block**: All other physical interface traffic blocked

### Interface Detection

```bash
# Physical interface detection
PRIMARY_INTERFACE=$(ip link show | grep -E "^[0-9]+: (eth|wlan|wlp|enp|ens)" | head -1)

# VPN interface detection
VPN_INTERFACE=$(ip link show | grep -E "^[0-9]+: (tun|tap|proton|wg|vpn)" | head -1)
```

## Links

- [iptables Documentation](https://netfilter.org/documentation/)
- [iptables Tutorial](https://www.netfilter.org/documentation/HOWTO/packet-filtering-HOWTO.html)
- [VPN Management Documentation](vpn-management.md)
- [Troubleshooting Guide](troubleshooting.md)
