# Encrypted DNS with DNSCrypt-Proxy

![dnscrypt-proxy](https://raw.githubusercontent.com/jedisct1/dnscrypt-proxy/master/logo.png?3?width=50)

Provides encrypted DNS queries via DNSCrypt-Proxy to prevent DNS leaks, surveillance, and man-in-the-middle attacks on DNS resolution.

## Overview

DNSCrypt-Proxy serves as the encryption layer in TraceProtocol's DNS system, receiving queries from dnsmasq and forwarding them to encrypted DNS servers. This ensures all DNS queries are protected from eavesdropping and manipulation, providing privacy and security for domain name resolution.

## Setup Instructions

### 1. Automatic Installation

DNSCrypt-Proxy is automatically downloaded and installed from GitHub during setup:

```bash
sudo ./trace-protocol.sh install
```

### 2. Configuration

The installation creates a custom configuration at `/etc/dnscrypt-proxy/dnscrypt-proxy.toml`:

```toml
# DNSCrypt-Proxy Configuration (TraceProtocol)
# Listens on port 5300 to avoid conflict with dnsmasq on port 53

listen_addresses = ['127.0.0.1:5300']
max_clients = 250

ipv4_servers = true
ipv6_servers = false
dnscrypt_servers = true
doh_servers = true

require_dnssec = false
require_nolog = true
require_nofilter = true

force_tcp = false
timeout = 5000

fallback_resolvers = ['9.9.9.9:53', '8.8.8.8:53']
ignore_system_dns = true
```

### 3. Service Management

DNSCrypt-Proxy runs as a systemd service:

```bash
# Check service status
sudo systemctl status dnscrypt-proxy

# Start service manually
sudo systemctl start dnscrypt-proxy

# Enable auto-start
sudo systemctl enable dnscrypt-proxy
```

## Usage Examples

### Basic Operations

```bash
# Test DNSCrypt-Proxy directly
dig @127.0.0.1 -p 5300 google.com

# Check service status
systemctl is-active dnscrypt-proxy

# View service logs
sudo journalctl -u dnscrypt-proxy -f
```

### Advanced Testing

```bash
# Test encrypted DNS resolution
dig @127.0.0.1 -p 5300 google.com +short

# Verify DNSCrypt protocol
dig @127.0.0.1 -p 5300 google.com +trace

# Test different query types
dig @127.0.0.1 -p 5300 google.com MX
dig @127.0.0.1 -p 5300 google.com AAAA
```

### Monitor Integration

The TraceProtocol monitor automatically tests DNSCrypt-Proxy:

```bash
# Monitor will test and fix DNSCrypt issues
./trace-protocol.sh monitor

# Automatic retry mechanism for slow networks
# Tests connectivity with 10 retry attempts
# Progressive wait times between attempts
```

## Configuration Options

### Server Selection

Modify `/etc/dnscrypt-proxy/dnscrypt-proxy.toml`:

```toml
# Enable specific server types
dnscrypt_servers = true    # DNSCrypt protocol
doh_servers = true         # DNS over HTTPS
dot_servers = false        # DNS over TLS

# Server requirements
require_dnssec = true      # Require DNSSEC validation
require_nolog = true       # Require no-logging servers
require_nofilter = true    # Require no-filtering servers
```

### Performance Settings

```toml
# Connection settings
max_clients = 500          # Maximum concurrent clients
timeout = 5000            # Query timeout (milliseconds)
force_tcp = false         # Force TCP for all queries

# Fallback configuration
fallback_resolvers = ['9.9.9.9:53', '1.1.1.1:53']
ignore_system_dns = true
```

### Security Options

```toml
# Privacy settings
require_nolog = true      # Only use no-logging servers
require_nofilter = true   # Only use no-filtering servers

# Protocol preferences
dnscrypt_servers = true   # Prefer DNSCrypt
doh_servers = true        # Allow DNS over HTTPS
```

## Troubleshooting

### Common Issues

**DNSCrypt-Proxy Not Starting**
```bash
# Check configuration syntax
sudo dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml -check

# Check for port conflicts
sudo netstat -tulpn | grep :5300

# View startup logs
sudo journalctl -u dnscrypt-proxy --since "5 minutes ago"
```

**Slow DNS Resolution**
```bash
# Test direct connectivity
dig @127.0.0.1 -p 5300 google.com

# Check server response times
sudo dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml -resolve google.com

# Try different servers
# Edit configuration to use faster servers
```

**Connection Timeouts**
```bash
# Increase timeout settings
# Edit dnscrypt-proxy.toml:
timeout = 10000

# Check network connectivity
ping 8.8.8.8

# Test with fallback resolvers
dig @9.9.9.9 google.com
```

### Debug Commands

```bash
# Test configuration
sudo dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml -check

# Verbose logging
sudo dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml -logfile /var/log/dnscrypt-proxy.log

# Test specific server
sudo dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml -resolve google.com

# Monitor network traffic
sudo tcpdump -i lo port 5300
```

## Related Tools

### dnsmasq Integration

DNSCrypt-Proxy works as the second layer in the DNS chain:
- **Receives Queries**: From dnsmasq on port 5300
- **Encrypts Traffic**: All queries sent to encrypted servers
- **Returns Results**: Encrypted responses back to dnsmasq

### System DNS Chain

Complete DNS resolution flow:
1. **Application** → queries system DNS (127.0.0.1:53)
2. **dnsmasq** → checks cache, forwards to DNSCrypt-Proxy (127.0.0.1:5300)
3. **DNSCrypt-Proxy** → encrypts and forwards to external servers
4. **External Servers** → return encrypted responses
5. **DNSCrypt-Proxy** → decrypts and returns to dnsmasq
6. **dnsmasq** → caches response and returns to application

### VPN Integration

Encrypted DNS works with VPN connections:
- **VPN DNS**: Uses VPN provider's DNS servers
- **Encrypted Queries**: All DNS traffic remains encrypted
- **Leak Protection**: Combined with kill switch for complete protection

## Security Benefits

### Privacy Protection

- **Query Encryption**: DNS queries encrypted with DNSCrypt protocol
- **No Logging**: Uses servers that don't log queries
- **No Filtering**: Uses servers that don't filter results
- **Pattern Hiding**: Encrypted traffic hides query patterns

### Security Features

- **Man-in-the-Middle Protection**: Encrypted queries prevent interception
- **DNS Spoofing Prevention**: DNSSEC validation available
- **Fallback Security**: Secure fallback to trusted resolvers
- **Protocol Flexibility**: Supports DNSCrypt and DNS over HTTPS

## Links

- [DNSCrypt Documentation](https://dnscrypt.info/)
- [DNSCrypt-Proxy GitHub](https://github.com/DNSCrypt/dnscrypt-proxy)
- [DNS Caching Documentation](dns-caching.md)
- [Troubleshooting Guide](troubleshooting.md)
