# MAC Randomization with macchanger

![macchanger](https://www.kali.org/tools/macchanger/images/macchanger-logo.svg?width=50)

Provides hardware address anonymization using macchanger to prevent device tracking and enhance privacy by randomizing network interface MAC addresses.

## Overview

MAC address randomization is a critical privacy feature that prevents device tracking by changing the hardware address of network interfaces. TraceProtocol integrates macchanger to provide automatic MAC randomization during boot, network events, and VPN connections, making it difficult for network operators to track your device.

## Setup Instructions

### 1. Automatic Installation

macchanger is automatically installed during TraceProtocol setup:

```bash
sudo ./trace-protocol.sh install
```

### 2. Boot-Time Randomization

A systemd service is created for automatic MAC randomization at boot:

**Service File**: `/etc/systemd/system/traceprotocol-mac-randomize.service`
```ini
[Unit]
Description=TraceProtocol MAC Address Randomization
Documentation=TraceProtocol Privacy Suite
After=network-pre.target
Before=network.target
Wants=network-pre.target

[Service]
Type=oneshot
ExecStart=/home/USER/Desktop/privacy/scripts/mac-randomize-boot.sh
RemainAfterExit=yes
TimeoutStartSec=30
User=root
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```

### 3. Network Event Randomization

NetworkManager dispatcher script handles automatic randomization:

**Dispatcher Script**: `/etc/NetworkManager/dispatcher.d/99-traceprotocol-mac-randomize`
```bash
#!/bin/bash
# Automatic MAC randomization on network events
# Runs when interfaces come up or down
```

## Usage Examples

### Manual MAC Operations

```bash
# Randomize MAC address immediately
./trace-protocol.sh mac-randomize

# Restore original MAC address
./trace-protocol.sh mac-restore

# Check current MAC address
ip link show | grep "link/ether"
```

### Advanced Operations

```bash
# Randomize specific interface
sudo macchanger -r eth0

# Set specific MAC address
sudo macchanger -m 02:11:22:33:44:55 eth0

# Show original MAC address
sudo macchanger -s eth0

# Randomize with specific vendor
sudo macchanger -a eth0
```

### Automatic Randomization

MAC addresses are automatically randomized during:
- **System Boot**: Via systemd service
- **Network Events**: Via NetworkManager dispatcher
- **VPN Connections**: Before connecting to VPN
- **VPN Disconnections**: After disconnecting from VPN

## Configuration Options

### Privacy Settings

Edit `privacy-tools.conf`:

```bash
# Privacy Settings
MAC_RANDOMIZATION=true
```

### Boot Script Configuration

The boot script (`mac-randomize-boot.sh`) includes:

```bash
# Interface detection
INTERFACE=$(ip link show | grep -E "^[0-9]+: (eth|wlan|wlp|enp|ens)" | head -1)

# MAC generation
NEW_MAC=$(printf "02:%02x:%02x:%02x:%02x:%02x" $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))

# Interface management
ip link set dev "$INTERFACE" down
ip link set dev "$INTERFACE" address "$NEW_MAC"
ip link set dev "$INTERFACE" up
```

### NetworkManager Dispatcher

The dispatcher script handles:
- **Interface Up Events**: Randomizes MAC when interface comes up
- **Interface Down Events**: Prepares for next randomization
- **Connectivity Changes**: Responds to network state changes

## Troubleshooting

### Common Issues

**MAC Randomization Not Working**
```bash
# Check if macchanger is installed
which macchanger

# Verify interface permissions
ip link show

# Test manual randomization
sudo macchanger -r eth0
```

**Interface Not Found**
```bash
# List all network interfaces
ip link show

# Check interface status
ip link show eth0

# Verify interface is not virtual
ip link show | grep -v "lo:\|proton\|tun"
```

**Permission Denied**
```bash
# Check if running as root
whoami

# Use sudo for manual operations
sudo macchanger -r eth0

# Verify script permissions
ls -la scripts/mac-changer.sh
```

### Debug Commands

```bash
# Check MAC randomization logs
sudo journalctl -u traceprotocol-mac-randomize.service

# View NetworkManager dispatcher logs
sudo journalctl -f | grep mac-randomize

# Test interface detection
ip link show | grep -E "(eth|wlan|wlp|enp|ens)"

# Verify MAC change
ip link show eth0 | grep "link/ether"
```

## Related Tools

### VPN Integration

MAC randomization works with VPN connections:
- **Pre-Connection**: MAC randomized before VPN connects
- **Post-Disconnection**: MAC randomized after VPN disconnects
- **Enhanced Privacy**: Prevents correlation between VPN and device

### Kill Switch Integration

MAC randomization complements kill switch protection:
- **Device Anonymization**: MAC randomization hides device identity
- **Traffic Protection**: Kill switch protects traffic when VPN fails
- **Complete Privacy**: Both device and traffic are protected

### System Integration

MAC randomization integrates with system services:
- **Boot Service**: Automatic randomization at startup
- **Network Events**: Randomization on network changes
- **Service Management**: Controlled via systemd

## Privacy Benefits

### Device Tracking Prevention

- **Hardware Address Changes**: Regular MAC address randomization
- **Network Operator Privacy**: ISPs cannot track device consistently
- **WiFi Privacy**: Different MAC for each network connection
- **Location Privacy**: Prevents location tracking via MAC addresses

### Enhanced Anonymity

- **Device Fingerprinting**: Makes device harder to identify
- **Network Correlation**: Prevents linking device across networks
- **Temporal Privacy**: Different MAC addresses over time
- **Spatial Privacy**: Different MAC addresses per location

## Security Considerations

### Network Compatibility

- **Router Compatibility**: Some routers may reject random MACs
- **Corporate Networks**: May require specific MAC addresses
- **Network Policies**: Some networks track MAC addresses

### Best Practices

- **Regular Changes**: MAC addresses change automatically
- **Original Backup**: Original MAC address is saved
- **Restoration**: Can restore original MAC if needed
- **Monitoring**: Monitor for network connectivity issues

## Links

- [macchanger Documentation](https://github.com/alobbs/macchanger)
- [MAC Address Randomization Guide](https://en.wikipedia.org/wiki/MAC_address#Randomization)
- [VPN Management Documentation](vpn-management.md)
- [Troubleshooting Guide](troubleshooting.md)
