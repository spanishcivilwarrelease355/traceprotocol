# Troubleshooting Guide

Comprehensive troubleshooting guide for common issues across all TraceProtocol features and components.

## General Troubleshooting

### Debug Commands

```bash
# Enable verbose output for TraceProtocol
bash -x ./trace-protocol.sh command

# Check system logs
sudo journalctl -f

# Check TraceProtocol logs
tail -f logs/install_*.log

# Check system status
systemctl status
```

### Common System Issues

**Permission Denied Errors**
```bash
# Check if running as root
whoami

# Use sudo for system operations
sudo ./trace-protocol.sh install

# Check file permissions
ls -la trace-protocol.sh
```

**Service Not Starting**
```bash
# Check service status
sudo systemctl status service-name

# Restart service
sudo systemctl restart service-name

# Check service logs
sudo journalctl -u service-name -f
```

## VPN Management Troubleshooting

### Connection Issues

**ProtonVPN Connection Fails**
```bash
# Check login status
./trace-protocol.sh vpn-login

# Verify credentials
protonvpn-cli status

# Check network connectivity
ping 8.8.8.8

# Test ProtonVPN servers
protonvpn-cli c -f
```

**Slow Connection Speed**
```bash
# Try different servers
protonvpn-cli c -f

# Check internet speed
speedtest-cli

# Verify account type
protonvpn-cli account
```

**Connection Drops Frequently**
```bash
# Enable kill switch
./trace-protocol.sh killswitch-on

# Check network stability
ping -c 10 8.8.8.8

# Verify ProtonVPN status
protonvpn-cli status
```

### Debug Commands

```bash
# Verbose ProtonVPN output
protonvpn-cli --verbose c -f

# Check ProtonVPN logs
tail -f /var/log/protonvpn-cli.log

# Test VPN connectivity
curl -s https://api.ipify.org
```

## DNS Troubleshooting

### DNS Resolution Issues

**dnsmasq Not Starting**
```bash
# Check configuration syntax
sudo dnsmasq --test

# Check for port conflicts
sudo netstat -tulpn | grep :53

# Restart service
sudo systemctl restart dnsmasq
```

**DNSCrypt-Proxy Not Working**
```bash
# Check service status
sudo systemctl status dnscrypt-proxy

# Test configuration
sudo dnscrypt-proxy -config /etc/dnscrypt-proxy/dnscrypt-proxy.toml -check

# Check port conflicts
sudo netstat -tulpn | grep :5300
```

**DNS Leak Test Failures**
```bash
# Test DNS resolution
dig @127.0.0.1 google.com

# Check DNS chain
dig @127.0.0.1 -p 5300 google.com

# Test external DNS
dig @8.8.8.8 google.com
```

### Debug Commands

```bash
# Test DNS configuration
sudo dnsmasq --test

# Check DNS forwarding
dig @127.0.0.1 google.com +trace

# Monitor DNS queries
sudo tcpdump -i lo port 53
```

## MAC Randomization Troubleshooting

### Randomization Issues

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
```

## Kill Switch Troubleshooting

### Protection Issues

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
```

## Tor Integration Troubleshooting

### Connection Issues

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

## Application Sandboxing Troubleshooting

### Sandboxing Issues

**Application Won't Start in Sandbox**
```bash
# Check Firejail logs
sudo journalctl -u firejail --since "5 minutes ago"

# Test with verbose output
firejail --debug application

# Check profile syntax
firejail --validate-profile /etc/firejail/application.profile
```

**Network Access Denied**
```bash
# Check network restrictions
firejail --net=eth0 application

# Allow specific network access
firejail --net=eth0 --dns=8.8.8.8 application

# Test network connectivity
firejail --net=eth0 ping 8.8.8.8
```

**Filesystem Access Issues**
```bash
# Check filesystem restrictions
firejail --private application

# Allow specific directory access
firejail --private=/home/user/Documents application

# Test filesystem access
firejail --private ls /home/user/Documents
```

### Debug Commands

```bash
# Test Firejail configuration
firejail --validate-profile /etc/firejail/application.profile

# Verbose Firejail output
firejail --debug application

# Check Firejail status
firejail --list

# View Firejail logs
sudo tail -f /var/log/firejail.log
```

## AppArmor Integration Troubleshooting

### Profile Issues

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

## System Cleaning Troubleshooting

### Cleaning Issues

**BleachBit Not Starting**
```bash
# Check installation
which bleachbit

# Check dependencies
ldd /usr/bin/bleachbit

# Run with debug output
bleachbit --debug
```

**Permission Denied Errors**
```bash
# Run with sudo for system files
sudo bleachbit --clean system.cache

# Check file permissions
ls -la ~/.local/share/bleachbit/

# Fix permissions
chmod 755 ~/.local/share/bleachbit/
```

**Cleaning Failures**
```bash
# Check for running applications
ps aux | grep firefox
ps aux | grep chrome

# Close applications before cleaning
killall firefox
killall chrome

# Retry cleaning
bleachbit --clean firefox.cache
```

### Debug Commands

```bash
# Debug mode
bleachbit --debug

# Verbose output
bleachbit --clean --verbose

# Check configuration
bleachbit --config

# View logs
tail -f ~/.local/share/bleachbit/logs/bleachbit.log
```

## Monitoring Troubleshooting

### Widget Issues

**Conky Not Starting**
```bash
# Check installation
which conky

# Check dependencies
ldd /usr/bin/conky

# Run with debug output
conky -d
```

**Widget Not Displaying**
```bash
# Check if Conky is running
ps aux | grep conky

# Check configuration syntax
conky -t

# Check desktop environment
echo $XDG_CURRENT_DESKTOP
```

**Configuration Errors**
```bash
# Test configuration
conky -t

# Check configuration file
cat ~/.conkyrc

# Restore default configuration
cp /usr/share/conky/conky.conf ~/.conkyrc
```

### Debug Commands

```bash
# Debug mode
conky -d

# Test configuration
conky -t

# Verbose output
conky -v

# Check logs
tail -f ~/.conky.log
```

## Getting Help

### Log Files

Check these log files for detailed error information:

```bash
# TraceProtocol logs
tail -f logs/install_*.log

# System logs
sudo journalctl -f

# Service-specific logs
sudo journalctl -u service-name -f
```

### Support Resources

- **GitHub Issues**: [Open an issue](https://github.com/mrxcherif/traceprotocol)
- **Documentation**: Check individual feature documentation
- **Community**: Connect on [LinkedIn](https://linkedin.com/in/mrxcherif)

### Reporting Issues

When reporting issues, include:

1. **System Information**: OS version, kernel version
2. **Error Messages**: Complete error messages
3. **Log Files**: Relevant log file excerpts
4. **Steps to Reproduce**: How to reproduce the issue
5. **Expected Behavior**: What should happen
6. **Actual Behavior**: What actually happens
