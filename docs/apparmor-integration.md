# AppArmor Integration for System Hardening

![AppArmor](https://www.unixtutorial.org/images/posts/apparmor-logo.png?width=50)

Provides mandatory access control using AppArmor to enhance system security by restricting application access to system resources and files.

## Overview

AppArmor integration in TraceProtocol provides mandatory access control (MAC) to enhance system security. AppArmor uses security profiles to restrict what applications can access, preventing malicious or compromised applications from accessing sensitive system resources.

## Setup Instructions

### 1. Automatic Installation

AppArmor is automatically installed and configured during TraceProtocol setup:

```bash
sudo ./trace-protocol.sh install
```

### 2. Service Configuration

AppArmor runs as a systemd service with automatic startup:

```bash
# Check service status
sudo systemctl status apparmor

# Start service manually
sudo systemctl start apparmor

# Enable auto-start
sudo systemctl enable apparmor
```

### 3. Profile Management

AppArmor profiles are located in `/etc/apparmor.d/` and can be customized for different applications.

## Usage Examples

### Basic AppArmor Operations

```bash
# Check AppArmor status
sudo systemctl status apparmor

# List loaded profiles
sudo apparmor_status

# Check specific profile
sudo apparmor_status | grep firefox
```

### Advanced Profile Management

```bash
# Load profile
sudo apparmor_parser -r /etc/apparmor.d/usr.bin.firefox

# Unload profile
sudo apparmor_parser -R /etc/apparmor.d/usr.bin.firefox

# Reload profile
sudo apparmor_parser -r /etc/apparmor.d/usr.bin.firefox

# Check profile syntax
sudo apparmor_parser -T /etc/apparmor.d/usr.bin.firefox
```

### TraceProtocol Integration

```bash
# Monitor AppArmor status
./trace-protocol.sh monitor

# Check AppArmor logs
sudo journalctl -u apparmor -f

# View AppArmor audit logs
sudo tail -f /var/log/audit/audit.log | grep apparmor
```

## Configuration Options

### AppArmor Profiles

AppArmor profiles define what applications can access:

**Basic Profile Example**:
```bash
# Basic application profile
#include <tunables/global>

/usr/bin/firefox {
  #include <abstractions/base>
  #include <abstractions/nameservice>
  #include <abstractions/user-tmp>
  #include <abstractions/web-browsers>

  /usr/bin/firefox mr,
  /usr/lib/firefox/** mr,
  /home/*/.mozilla/** rw,
  /tmp/** rw,
  /dev/shm/** rw,

  deny /etc/passwd r,
  deny /etc/shadow r,
  deny /root/** r,
}
```

### Security Modes

AppArmor operates in different modes:

```bash
# Enforce mode (blocks violations)
sudo aa-enforce /usr/bin/firefox

# Complain mode (logs violations)
sudo aa-complain /usr/bin/firefox

# Disable mode (no restrictions)
sudo aa-disable /usr/bin/firefox
```

### Custom Profiles

Create custom profiles for specific applications:

```bash
# Create custom profile
sudo nano /etc/apparmor.d/usr.bin.custom-app

# Load custom profile
sudo apparmor_parser -r /etc/apparmor.d/usr.bin.custom-app

# Enable profile
sudo aa-enforce /usr/bin/custom-app
```

## Troubleshooting

### Common Issues

**AppArmor Service Not Starting**
```bash
# Check service status
sudo systemctl status apparmor

# View error logs
sudo journalctl -u apparmor --since "10 minutes ago"

# Check kernel support
cat /sys/kernel/security/apparmor/profiles
```

**Profile Loading Errors**
```bash
# Check profile syntax
sudo apparmor_parser -T /etc/apparmor.d/usr.bin.application

# Check profile permissions
ls -la /etc/apparmor.d/usr.bin.application

# Reload profile
sudo apparmor_parser -r /etc/apparmor.d/usr.bin.application
```

**Application Access Denied**
```bash
# Check AppArmor logs
sudo tail -f /var/log/audit/audit.log | grep apparmor

# Check profile status
sudo apparmor_status | grep application

# Switch to complain mode
sudo aa-complain /usr/bin/application
```

### Debug Commands

```bash
# Check AppArmor status
sudo apparmor_status

# View loaded profiles
cat /sys/kernel/security/apparmor/profiles

# Check profile syntax
sudo apparmor_parser -T /etc/apparmor.d/usr.bin.application

# View audit logs
sudo tail -f /var/log/audit/audit.log | grep apparmor
```

## Related Tools

### Firejail Integration

AppArmor complements Firejail:
- **AppArmor**: System-level access control
- **Firejail**: Application-level sandboxing
- **Layered Security**: Multiple security layers

### System Integration

AppArmor integrates with system services:
- **Service Management**: Controlled via systemd
- **Logging**: Integrated with audit system
- **Monitoring**: Monitored by TraceProtocol

### VPN Integration

AppArmor works with VPN connections:
- **Network Protection**: Controls network access
- **VPN Traffic**: Allows VPN traffic
- **Privacy Protection**: Combined with VPN security

## Security Benefits

### Mandatory Access Control

- **System Protection**: Prevents access to system files
- **Application Isolation**: Restricts application capabilities
- **Resource Control**: Limits CPU and memory access
- **Network Control**: Controls network access

### Enhanced Security

- **Profile-Based**: Customizable security profiles
- **Enforcement**: Blocks unauthorized access
- **Logging**: Comprehensive audit logging
- **Compliance**: Meets security compliance requirements

## Advanced Features

### Profile Development

Create custom profiles for specific needs:

```bash
# Generate profile template
sudo aa-genprof /usr/bin/application

# Edit profile
sudo nano /etc/apparmor.d/usr.bin.application

# Test profile
sudo apparmor_parser -T /etc/apparmor.d/usr.bin.application
```

### Audit Logging

Monitor AppArmor enforcement:

```bash
# View audit logs
sudo tail -f /var/log/audit/audit.log | grep apparmor

# Search for specific violations
sudo grep "apparmor" /var/log/audit/audit.log

# Monitor real-time violations
sudo auditctl -w /etc/apparmor.d/ -p w -k apparmor
```

### Profile Management

Manage multiple profiles:

```bash
# List all profiles
sudo apparmor_status

# Enable all profiles
sudo aa-enforce /etc/apparmor.d/*

# Disable all profiles
sudo aa-disable /etc/apparmor.d/*
```

## Best Practices

### Security Guidelines

- **Use Profiles**: Enable profiles for all applications
- **Regular Updates**: Keep AppArmor updated
- **Monitor Logs**: Check audit logs regularly
- **Test Profiles**: Test profiles before enforcement

### Profile Management

- **Start with Complain**: Use complain mode first
- **Monitor Violations**: Check for access violations
- **Refine Profiles**: Update profiles based on violations
- **Enable Enforcement**: Switch to enforce mode

## Links

- [AppArmor Documentation](https://apparmor.net/)
- [AppArmor Wiki](https://wiki.ubuntu.com/AppArmor)
- [Application Sandboxing Documentation](application-sandboxing.md)
- [Troubleshooting Guide](troubleshooting.md)
