# TraceProtocol Conky Widget

A beautiful desktop widget that displays real-time VPN and privacy status on your desktop.

## Features

The Conky widget displays:

### 🔒 VPN Status
- **Connection Status** - Connected/Disconnected indicator
- **Server Information** - Current VPN server location
- **IP Address** - Your current VPN IP address
- **Country** - Geographic location via VPN

### 🛡️ Security Services
- **Kill Switch** - ProtonVPN kill switch status
- **Tor Service** - Tor daemon running status
- **DNSCrypt** - DNS encryption service status
- **AppArmor** - Security module status
- **Firewall (UFW)** - Firewall active/inactive

### 🌐 Network Information
- **Public IP** - Current public IP address
- **DNS Server** - DNS resolver being used
- **Network Interface** - Active interface name
- **Local IP** - Private network IP

### 💻 System Information
- **CPU Usage** - Real-time CPU percentage with bar graph
- **RAM Usage** - Memory usage percentage with bar graph
- **Disk Usage** - Root partition usage with bar graph
- **System Uptime** - How long system has been running
- **Current Time & Date** - Live clock

### ⚡ Quick Actions
- Commands to connect/disconnect VPN
- Link to full monitoring dashboard

## Installation

The Conky widget is automatically configured if you installed TraceProtocol. If you need to set it up manually:

### 1. Install Conky

```bash
sudo apt install conky-all
```

### 2. Configuration Files

The widget uses these files:

- **Config**: `~/.conkyrc` - Main Conky configuration
- **Autostart**: `~/.config/autostart/traceprotocol-conky.desktop` - Auto-launch on login

### 3. Start Conky

```bash
# Start manually
conky -c ~/.conkyrc

# Or start in background
conky -c ~/.conkyrc &
```

### 4. Autostart

The widget is configured to start automatically 15 seconds after login.

## Customization

### Change Position

Edit `~/.conkyrc`:

```lua
conky.config = {
    alignment = 'top_right',  -- Options: top_left, top_right, bottom_left, bottom_right
    gap_x = 20,               -- Horizontal offset from edge
    gap_y = 50,               -- Vertical offset from edge
```

### Change Colors

```lua
    color1 = '00FF00',  -- Green for success
    color2 = 'FF0000',  -- Red for errors
    color3 = 'FFFF00',  -- Yellow for warnings
    color4 = '00FFFF',  -- Cyan for info
    color5 = 'FF8800',  -- Orange for highlights
```

### Change Transparency

```lua
    own_window_argb_value = 180,  -- 0 (transparent) to 255 (opaque)
```

### Change Update Interval

```lua
    update_interval = 5.0,  -- Update every 5 seconds
```

### Change Font

```lua
    font = 'DejaVu Sans Mono:size=9',
```

### Change Size

```lua
    minimum_width = 350,
    maximum_width = 350,
```

## Advanced Customization

### Add Custom Monitoring

You can add custom checks by editing the `conky.text` section:

```lua
conky.text = [[
...
${color}Custom Check: ${exec your-command-here}
...
]];
```

### Monitor Specific Interface

Replace `${gw_iface}` with your interface name (e.g., `eth0`, `wlan0`):

```lua
${color}Local IP: ${color4}${addr eth0}
```

## Troubleshooting

### Widget Not Showing

```bash
# Check if Conky is running
ps aux | grep conky

# Restart Conky
pkill conky
conky -c ~/.conkyrc &
```

### Wrong Information Displayed

```bash
# Kill and restart Conky
pkill conky
sleep 2
conky -c ~/.conkyrc &
```

### Sudo Password Prompts

The widget uses `sudo ufw status` which may prompt for password. To fix:

```bash
# Edit sudoers file
sudo visudo

# Add this line (replace 'username' with your username):
username ALL=(ALL) NOPASSWD: /usr/sbin/ufw status
```

### Widget Behind Other Windows

Edit `~/.conkyrc`:

```lua
    own_window_type = 'dock',      -- Options: desktop, dock, normal, override
    own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
```

Change `below` to `above` to keep widget on top.

## Disable Widget

### Temporarily

```bash
pkill conky
```

### Permanently

```bash
# Remove autostart file
rm ~/.config/autostart/traceprotocol-conky.desktop

# Or disable it
echo "Hidden=true" >> ~/.config/autostart/traceprotocol-conky.desktop
```

### Remove Completely

```bash
pkill conky
rm ~/.conkyrc
rm ~/.config/autostart/traceprotocol-conky.desktop
```

## Re-enable Widget

```bash
# Start Conky
conky -c ~/.conkyrc &

# Make sure autostart is enabled
chmod +x ~/.config/autostart/traceprotocol-conky.desktop
```

## Widget Appearance

The widget has a modern, semi-transparent dark theme with:
- **Color-coded status** - Green (OK), Red (Error), Yellow (Warning), Cyan (Info)
- **Progress bars** - Visual representation of CPU, RAM, Disk usage
- **Unicode symbols** - ✓ (success), ✗ (error), ○ (disabled), ⚠ (warning)
- **Sections** - Organized into clear categories
- **Semi-transparent** - Blends with desktop background
- **Always visible** - Stays on desktop, below windows

## Performance Impact

The Conky widget is lightweight:
- **CPU Usage**: < 1%
- **RAM Usage**: ~10-20 MB
- **Update Interval**: 5 seconds (configurable)
- **Network Calls**: Minimal (60-300 second intervals for external IPs)

## Integration with TraceProtocol

The widget integrates seamlessly with TraceProtocol:

- Uses same monitoring commands
- Shows real-time VPN connection status
- Displays security service states
- Provides quick command references
- Updates automatically when VPN connects/disconnects

## Screenshots

The widget displays in the top-right corner showing:

```
╔═══════════════════════════════════╗
║      TraceProtocol Monitor      ║
╚═══════════════════════════════════╝

━━━ VPN STATUS ━━━
✓ Connected
Server: US-FREE#1
IP: 1.2.3.4
Country: United States

━━━ SECURITY STATUS ━━━
Kill Switch: ✓ Enabled
Tor Service: ✓ Running
DNSCrypt: ✓ Active
AppArmor: ✓ Enabled
Firewall: ✓ Active

━━━ NETWORK INFO ━━━
Public IP: 1.2.3.4
DNS Server: 1.2.3.4
Interface: wlan0
Local IP: 192.168.1.100

━━━ SYSTEM STATUS ━━━
CPU: 25%  ████████░░░░░░░░
RAM: 45%  ████████████░░░░
Disk: 60% ████████████████

Uptime: 5h 32m
Time: 14:23:45  Date: 2025-10-13

━━━ QUICK ACTIONS ━━━
• Connect VPN: ./trace-protocol.sh vpn-connect
• Full Status: ./trace-protocol.sh monitor
• Disconnect: ./trace-protocol.sh vpn-disconnect

TraceProtocol v1.0.0
```

## Support

For issues with the Conky widget:

1. Check Conky is installed: `conky --version`
2. Verify config syntax: `conky -C -c ~/.conkyrc`
3. Check logs: Look for errors when starting Conky
4. Test commands manually that appear in the widget
5. Open an issue on GitHub

---

**Enjoy your TraceProtocol Conky widget!** 🔒

