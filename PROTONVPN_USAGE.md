# ProtonVPN Usage Guide for TraceProtocol

## Quick Commands

### Login
```bash
protonvpn-cli login YOUR_USERNAME
```

### Connect to VPN
```bash
protonvpn-cli c -f              # Connect to fastest server
protonvpn-cli c --cc US         # Connect to US server
protonvpn-cli c --cc UK         # Connect to UK server
protonvpn-cli c --random        # Connect to random server
```

### Disconnect
```bash
protonvpn-cli d
```

### Status
```bash
protonvpn-cli status
```

### Kill Switch
```bash
protonvpn-cli ks --on           # Enable kill switch
protonvpn-cli ks --off          # Disable kill switch
protonvpn-cli ks --status       # Check kill switch status
```

### Reconnect
```bash
protonvpn-cli r
```

## Important Notes

### "Running as root" Warning

If you see this warning:
```
Running Proton VPN as root is not supported and is highly discouraged...
Are you sure that you want to proceed (y/N):
```

You can:
1. Type `y` and press Enter to continue
2. Or run the command as your regular user (without sudo)

**Note**: The TraceProtocol installer automatically handles this prompt, but when running commands manually, you may see it.

### Running Commands as Regular User

For normal usage, run ProtonVPN commands **without sudo**:

```bash
# ✅ Correct (as regular user)
protonvpn-cli c -f
protonvpn-cli status
protonvpn-cli d

# ❌ Avoid (as root)
sudo protonvpn-cli c -f
```

### If You Get D-Bus Errors

If you see errors like:
```
KeyringError: Environment variable DBUS_SESSION_BUS_ADDRESS is unset
```

This happens when running as root. Solution:

**Option 1**: Run without sudo (recommended)
```bash
protonvpn-cli c -f
```

**Option 2**: Set environment variables manually (if you must use sudo)
```bash
sudo DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus" \
     HOME="$HOME" \
     protonvpn-cli c -f
```

## Common Workflows

### Daily Usage
```bash
# Morning: Connect
protonvpn-cli c -f

# Check status anytime
protonvpn-cli status

# Evening: Disconnect (optional)
protonvpn-cli d
```

### Switching Servers
```bash
# Disconnect current
protonvpn-cli d

# Connect to new server
protonvpn-cli c --cc JP    # Japan
```

### Quick Reconnect
```bash
protonvpn-cli r
```

## Troubleshooting

### Cannot Connect

1. Check login status:
   ```bash
   protonvpn-cli status
   ```

2. Try logging in again:
   ```bash
   protonvpn-cli login YOUR_USERNAME
   ```

3. Check internet connection:
   ```bash
   ping google.com
   ```

### Kill Switch Blocking Internet

If kill switch is blocking your internet when VPN is off:

```bash
# Disable kill switch
protonvpn-cli ks --off

# Disconnect VPN
protonvpn-cli d
```

### Stuck Connection

```bash
# Force disconnect
protonvpn-cli d

# Or kill OpenVPN process
sudo pkill openvpn

# Then reconnect
protonvpn-cli c -f
```

## Advanced Options

### List All Servers
```bash
protonvpn-cli c --sc
```

### Connect to Specific Server
```bash
protonvpn-cli c "US-FREE#1"
```

### Use Different Protocols
```bash
# TCP (more stable, slower)
protonvpn-cli c -f -p tcp

# UDP (faster, default)
protonvpn-cli c -f -p udp
```

## Integration with TraceProtocol

### Using privacy-manager.sh
```bash
# Connect through manager
./privacy-manager.sh vpn-connect

# Disconnect
./privacy-manager.sh vpn-disconnect

# Status
./privacy-manager.sh vpn-status

# Login
./privacy-manager.sh vpn-login
```

### Monitor with Conky

The Conky widget (top-right corner) shows:
- Connection status
- Current server
- VPN IP address
- Kill switch status

To restart Conky:
```bash
pkill conky && conky -c ~/.conkyrc &
```

## Tips

1. **Enable Kill Switch**: Always use kill switch to prevent IP leaks
   ```bash
   protonvpn-cli ks --on --permanent
   ```

2. **Auto-Connect on Boot**: Add to startup applications
   ```bash
   echo "protonvpn-cli c -f" >> ~/.bashrc
   ```

3. **Check for IP Leaks**: Visit https://ipleak.net while connected

4. **Fastest Connection**: Use `-f` flag for auto-server selection

5. **Persistent Connection**: Kill switch ensures no traffic without VPN

## Help

For more options:
```bash
protonvpn-cli --help
protonvpn-cli c --help
protonvpn-cli ks --help
```

---

**ProtonVPN CLI installed by TraceProtocol** 🔒

