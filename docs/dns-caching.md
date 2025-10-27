# DNS Caching with dnsmasq

![dnsmasq](https://www.lffl.org/wp-content/uploads/2016/04/dnsmasq-logo.png?width=50)

Provides high-performance DNS caching and forwarding using dnsmasq to improve domain resolution speed and reduce network latency.

## Overview

dnsmasq serves as the local DNS cache in TraceProtocol, forwarding queries to DNSCrypt-Proxy for encryption while providing fast cached responses for frequently accessed domains. This creates a two-layer DNS system: local caching for speed and encrypted upstream resolution for privacy.

## Setup Instructions

### 1. Automatic Installation

dnsmasq is automatically installed and configured during TraceProtocol setup:

```bash
sudo ./trace-protocol.sh install
```

### 2. Configuration Files

The installation creates the following configuration:

**Main Configuration**: `/etc/dnsmasq.d/dnscrypt.conf`
```bash
# Forward all DNS queries to DNSCrypt-Proxy on port 5300
server=127.0.0.1#5300
no-resolv
cache-size=1000
```

### 3. Service Management

dnsmasq runs as a system service:

```bash
# Check service status
sudo systemctl status dnsmasq

# Start service manually
sudo systemctl start dnsmasq

# Restart service
sudo systemctl restart dnsmasq
```

## Usage Examples

### Basic Operations

```bash
# Check if dnsmasq is running
systemctl is-active dnsmasq

# Test DNS resolution through dnsmasq
dig @127.0.0.1 google.com

# Check cache statistics
sudo dnsmasq --test
```

### Advanced Testing

```bash
# Test DNS forwarding to DNSCrypt-Proxy
dig @127.0.0.1 -p 53 google.com

# Verify cache is working
dig @127.0.0.1 google.com
# Second query should be faster due to caching

# Check dnsmasq logs
sudo journalctl -u dnsmasq -f
```

## Configuration Options

### Cache Settings

Modify `/etc/dnsmasq.d/dnscrypt.conf`:

```bash
# Cache size (default: 1000)
cache-size=2000

# Cache time-to-live
cache-ttl=300

# Maximum cache entries
max-cache-ttl=3600
```

### Forwarding Configuration

```bash
# Primary upstream server (DNSCrypt-Proxy)
server=127.0.0.1#5300

# Backup servers (if DNSCrypt fails)
server=8.8.8.8
server=1.1.1.1

# Disable system resolv.conf
no-resolv
```

### Performance Tuning

```bash
# Increase cache size for better performance
cache-size=5000

# Enable query logging for debugging
log-queries

# Set maximum concurrent queries
dns-forward-max=1000
```

## Troubleshooting

### Common Issues

**dnsmasq Not Starting**
```bash
# Check configuration syntax
sudo dnsmasq --test

# Check for port conflicts
sudo netstat -tulpn | grep :53

# Restart service
sudo systemctl restart dnsmasq
```

**DNS Resolution Slow**
```bash
# Check cache hit rate
sudo dnsmasq --test

# Verify upstream server connectivity
dig @127.0.0.1 -p 5300 google.com

# Clear cache and restart
sudo systemctl restart dnsmasq
```

**Cache Not Working**
```bash
# Check cache configuration
grep cache-size /etc/dnsmasq.d/dnscrypt.conf

# Verify cache directory permissions
ls -la /var/cache/dnsmasq/

# Test cache functionality
dig @127.0.0.1 google.com
dig @127.0.0.1 google.com  # Should be faster
```

### Debug Commands

```bash
# Test configuration
sudo dnsmasq --test

# Verbose logging
sudo dnsmasq --log-queries --log-dhcp

# Check DNS forwarding
dig @127.0.0.1 google.com +trace

# Monitor DNS queries
sudo tcpdump -i lo port 53
```

## Related Tools

### DNSCrypt-Proxy Integration

dnsmasq works as the first layer in the DNS chain:
- **Local Cache**: dnsmasq provides cached responses
- **Encrypted Forwarding**: Queries forwarded to DNSCrypt-Proxy
- **Fallback Support**: Backup servers if encryption fails

### System DNS Configuration

dnsmasq integrates with system DNS:
- **Primary DNS**: System points to 127.0.0.1 (dnsmasq)
- **Automatic Forwarding**: All queries go through dnsmasq
- **Transparent Operation**: Applications use dnsmasq automatically

### VPN Integration

DNS caching works with VPN connections:
- **VPN DNS**: Uses VPN provider's DNS servers
- **Local Caching**: Still provides cached responses
- **Leak Protection**: Combined with kill switch protection

## Performance Benefits

### Speed Improvements

- **Cached Responses**: Frequently accessed domains load instantly
- **Reduced Latency**: Local cache eliminates network round-trips
- **Bandwidth Savings**: Cached queries don't use network bandwidth

### Privacy Benefits

- **Query Reduction**: Fewer queries sent to external servers
- **Pattern Masking**: Cached responses hide query patterns
- **Encrypted Upstream**: All external queries are encrypted

## Links

- [dnsmasq Documentation](https://thekelleys.org.uk/dnsmasq/doc.html)
- [dnsmasq Configuration Guide](https://thekelleys.org.uk/dnsmasq/docs/dnsmasq-man.html)
- [Encrypted DNS Documentation](encrypted-dns.md)
- [Troubleshooting Guide](troubleshooting.md)
