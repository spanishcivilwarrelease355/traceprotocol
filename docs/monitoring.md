# Real-time Monitoring with Conky

![Conky](https://deepinenespañol.org/wp-content/uploads/2018/05/Logo-de-Conky-300x180.png?width=50)

Provides real-time system monitoring using Conky to display privacy tools status, network information, and system metrics on the desktop.

## Overview

Conky integration in TraceProtocol provides a desktop widget that displays real-time information about all privacy tools, network status, and system metrics. This allows you to monitor your privacy setup at a glance without opening terminal windows or running commands.

## Setup Instructions

### 1. Automatic Installation

Conky is automatically installed during TraceProtocol setup:

```bash
sudo ./trace-protocol.sh install
```

### 2. Configuration

Conky configuration is automatically created and customized for TraceProtocol:

```bash
# Check Conky installation
which conky

# Check configuration file
ls -la ~/.conkyrc

# Start Conky
conky
```

### 3. Desktop Integration

Conky runs as a desktop widget and integrates with your desktop environment:

```bash
# Start Conky automatically
conky -d

# Start with custom config
conky -c ~/.conkyrc

# Stop Conky
killall conky
```

## Usage Examples

### Basic Monitoring

```bash
# Start Conky widget
conky

# Check Conky status
ps aux | grep conky

# Restart Conky
killall conky && conky
```

### Advanced Configuration

```bash
# Edit Conky configuration
nano ~/.conkyrc

# Test configuration
conky -t

# Start with specific config
conky -c ~/.conkyrc-traceprotocol
```

### TraceProtocol Integration

```bash
# Monitor all privacy tools
./trace-protocol.sh monitor

# Check Conky widget status
ps aux | grep conky

# View Conky logs
tail -f ~/.conky.log
```

## Configuration Options

### Conky Configuration

The TraceProtocol Conky configuration displays:

```bash
# TraceProtocol Conky Configuration
background yes
use_xft yes
xftfont DejaVu Sans:size=9
xftalpha 0.8
update_interval 1.0
total_run_times 0
own_window yes
own_window_type normal
own_window_transparent yes
own_window_hints undecorated,below,sticky,skip_taskbar,skip_pager
double_buffer yes
minimum_size 300 400
maximum_width 300
draw_shades no
draw_outline no
draw_borders no
draw_graph_borders yes
default_color white
default_shade_color black
default_outline_color grey
alignment top_right
gap_x 10
gap_y 10
no_buffers yes
uppercase no
cpu_avg_samples 2
net_avg_samples 2
override_utf8_locale no
uppercase no
use_spacer right
```

### Display Elements

The Conky widget displays:

```bash
# Privacy Tools Status
${color white}TraceProtocol Status${color}
${color green}VPN: ${exec ./trace-protocol.sh vpn-status | grep -o "Connected\|Disconnected"}
${color green}Kill Switch: ${exec ./trace-protocol.sh killswitch-status | grep -o "Active\|Inactive"}
${color green}MAC Randomization: ${exec ./trace-protocol.sh monitor | grep "MAC Randomization" | awk '{print $3}'}
${color green}DNS Encryption: ${exec ./trace-protocol.sh monitor | grep "DNS Encryption" | awk '{print $3}'}
${color green}Tor: ${exec systemctl is-active tor}

# Network Information
${color white}Network Status${color}
${color green}IP Address: ${exec curl -s https://api.ipify.org}
${color green}DNS Server: ${exec cat /etc/resolv.conf | grep nameserver | head -1 | awk '{print $2}'}
${color green}Interface: ${exec ip link show | grep -E "^[0-9]+: (eth|wlan)" | head -1 | awk '{print $2}' | sed 's/://'}

# System Metrics
${color white}System Metrics${color}
${color green}CPU: ${cpu}% ${cpubar}
${color green}RAM: ${mem} / ${memmax} ${membar}
${color green}Disk: ${fs_used /} / ${fs_size /} ${fs_bar /}
```

## Troubleshooting

### Common Issues

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

## Related Tools

### System Integration

Conky integrates with system services:
- **Service Monitoring**: Monitors systemd services
- **Network Monitoring**: Displays network status
- **System Metrics**: Shows CPU, RAM, disk usage

### Privacy Integration

Conky works with privacy tools:
- **VPN Status**: Displays VPN connection status
- **Kill Switch**: Shows kill switch status
- **DNS Status**: Displays DNS encryption status
- **Tor Status**: Shows Tor service status

### Desktop Integration

Conky integrates with desktop environments:
- **GNOME**: Works with GNOME desktop
- **KDE**: Compatible with KDE desktop
- **XFCE**: Integrates with XFCE desktop
- **Custom**: Works with custom desktop setups

## Security Benefits

### Real-time Monitoring

- **Status Visibility**: See privacy tools status at a glance
- **Network Monitoring**: Monitor network connections
- **System Monitoring**: Track system performance
- **Alert System**: Visual alerts for status changes

### Privacy Awareness

- **Privacy Status**: Always know your privacy status
- **Network Awareness**: See current network configuration
- **Service Status**: Monitor all privacy services
- **Performance Tracking**: Track system performance

## Advanced Features

### Custom Widgets

Create custom widgets for specific needs:

```bash
# Create custom widget
nano ~/.conkyrc-custom

# Start custom widget
conky -c ~/.conkyrc-custom
```

### Multiple Widgets

Run multiple Conky instances:

```bash
# Start multiple widgets
conky -c ~/.conkyrc-privacy &
conky -c ~/.conkyrc-system &
conky -c ~/.conkyrc-network &
```

### Integration Scripts

Create integration scripts:

```bash
# Create monitoring script
sudo nano /usr/local/bin/traceprotocol-monitor

# Make executable
sudo chmod +x /usr/local/bin/traceprotocol-monitor

# Run monitoring
traceprotocol-monitor
```

## Best Practices

### Configuration Guidelines

- **Regular Updates**: Update configuration regularly
- **Test Changes**: Test configuration changes
- **Backup Config**: Backup configuration files
- **Monitor Performance**: Monitor widget performance

### Privacy Guidelines

- **Status Visibility**: Keep privacy status visible
- **Network Awareness**: Monitor network status
- **Service Monitoring**: Monitor all privacy services
- **Alert System**: Use visual alerts for status changes

## Links

- [Conky Documentation](https://conky.sourceforge.net/)
- [Conky Configuration Guide](https://conky.sourceforge.net/configs.html)
- [Desktop Widget Guide](https://conky.sourceforge.net/widgets.html)
- [Troubleshooting Guide](troubleshooting.md)
