# Tor Integration for Anonymous Browsing

![Tor](https://upload.wikimedia.org/wikipedia/commons/d/df/Tor_Browser_icon_(New).png?width=50)

Provides anonymous browsing and traffic routing through the Tor network to enhance privacy and enable access to onion services.

## Overview

Tor integration in TraceProtocol provides anonymous browsing capabilities by routing traffic through the Tor network. This creates multiple layers of encryption and routing, making it extremely difficult to trace your internet activity back to your real IP address.

## Setup Instructions

### 1. Automatic Installation

Tor is automatically installed and configured during TraceProtocol setup:

```bash
sudo ./trace-protocol.sh install
```

### 2. Service Configuration

Tor runs as a systemd service with automatic startup:

```bash
# Check service status
sudo systemctl status tor

# Start service manually
sudo systemctl start tor

# Enable auto-start
sudo systemctl enable tor
```

### 3. Configuration Files

Tor configuration is located at `/etc/tor/torrc` with default settings optimized for privacy.

## Usage Examples

### Basic Tor Operations

```bash
# Check if Tor is running
systemctl is-active tor

# View Tor service logs
sudo journalctl -u tor -f

# Test Tor connectivity
curl --socks5 127.0.0.1:9050 https://check.torproject.org/api/ip
```

### Tor Browser Integration

```bash
# Install Tor Browser Launcher
sudo apt install torbrowser-launcher

# Launch Tor Browser
torbrowser-launcher

# Update Tor Browser
torbrowser-launcher --update
```

### Advanced Tor Usage

```bash
# Test Tor circuit
torify curl https://httpbin.org/ip

# Check Tor exit node
torify curl https://check.torproject.org/api/ip

# Test onion service access
torify curl http://3g2upl4pq6kufc4m.onion
```

## Configuration Options

### Tor Configuration

Edit `/etc/tor/torrc` for custom settings:

```bash
# Basic Tor configuration
SOCKSPort 9050
ControlPort 9051
CookieAuthentication 1

# Privacy settings
SafeLogging 1
AvoidDiskWrites 1

# Performance settings
MaxCircuitDirtiness 600
NewCircuitPeriod 30
```

### Tor Browser Settings

Tor Browser can be configured for enhanced privacy:

```bash
# Security level settings
# Standard: Default security
# Safer: Disables JavaScript on non-HTTPS sites
# Safest: Disables JavaScript, some fonts, and images
```

### Network Integration

Tor integrates with TraceProtocol's network stack:
- **DNS Resolution**: Uses Tor's DNS resolution
- **Traffic Routing**: All Tor traffic goes through Tor network
- **Kill Switch**: Tor traffic is protected by kill switch

## Troubleshooting

### Common Issues

**Tor Service Not Starting**
```bash
# Check service status
sudo systemctl status tor

# View error logs
sudo journalctl -u tor --since "10 minutes ago"

# Test configuration
sudo tor --verify-config
```

**Slow Tor Performance**
```bash
# Check Tor circuit
torify curl -w "@curl-format.txt" -o /dev/null -s https://httpbin.org/ip

# Test different exit nodes
# Tor automatically selects fastest available nodes

# Check network connectivity
ping 8.8.8.8
```

**Connection Failures**
```bash
# Test Tor connectivity
curl --socks5 127.0.0.1:9050 https://check.torproject.org/api/ip

# Check firewall settings
sudo ufw status
sudo iptables -L

# Verify Tor port
sudo netstat -tulpn | grep 9050
```

### Debug Commands

```bash
# Test Tor configuration
sudo tor --verify-config

# Verbose Tor output
sudo tor --verify-config --hush

# Check Tor logs
sudo tail -f /var/log/tor/log

# Test SOCKS proxy
curl --socks5 127.0.0.1:9050 https://httpbin.org/ip
```

## Related Tools

### VPN Integration

Tor can work alongside VPN for enhanced privacy:
- **VPN + Tor**: Double encryption and routing
- **Tor over VPN**: VPN first, then Tor
- **VPN over Tor**: Tor first, then VPN
- **Kill Switch**: Protects both VPN and Tor traffic

### DNS Integration

Tor uses its own DNS resolution:
- **Tor DNS**: Resolves domains through Tor network
- **Onion Services**: Access to .onion domains
- **DNS Leak Protection**: All DNS through Tor

### Monitoring Integration

Tor status is monitored by TraceProtocol:
- **Service Status**: Checks if Tor service is running
- **Connectivity Tests**: Verifies Tor network access
- **Performance Monitoring**: Tracks Tor performance

## Privacy Benefits

### Anonymity Features

- **Multi-Layer Encryption**: Traffic encrypted multiple times
- **Random Routing**: Traffic routed through random nodes
- **IP Address Hiding**: Real IP address is hidden
- **Traffic Analysis Resistance**: Difficult to correlate traffic

### Access Capabilities

- **Onion Services**: Access to .onion websites
- **Censorship Circumvention**: Bypass geographic restrictions
- **Anonymous Communication**: Secure messaging and email
- **Research Privacy**: Protect research activities

## Security Considerations

### Performance Impact

- **Slower Speeds**: Tor is slower than direct connections
- **Latency**: Additional routing increases latency
- **Bandwidth**: Multiple encryption layers use more bandwidth
- **Reliability**: Tor network can be unreliable

### Security Best Practices

- **HTTPS Only**: Always use HTTPS with Tor
- **No Personal Information**: Don't log into personal accounts
- **Regular Updates**: Keep Tor Browser updated
- **Security Settings**: Use appropriate security levels

## Advanced Features

### Onion Services

```bash
# Access onion services
torify curl http://3g2upl4pq6kufc4m.onion

# Create hidden service (advanced)
# Requires additional Tor configuration
```

### Tor Control

```bash
# Use Tor control port
echo -e "authenticate\nGETINFO status/circuit-established\nquit" | nc 127.0.0.1 9051

# Change Tor circuit
echo -e "authenticate\nSIGNAL NEWNYM\nquit" | nc 127.0.0.1 9051
```

## Links

- [Tor Project](https://www.torproject.org/)
- [Tor Browser Documentation](https://tb-manual.torproject.org/)
- [Tor Network Status](https://torstatus.blutmagie.de/)
- [Troubleshooting Guide](troubleshooting.md)
