# TraceProtocol - Automated Installation Guide

## 🎯 What's New

TraceProtocol now features **fully automated installation**! Everything happens in one command:

- ✅ Installs all privacy tools
- ✅ Prompts for ProtonVPN login
- ✅ Automatically connects to VPN
- ✅ Enables kill switch
- ✅ Creates and starts Conky widget
- ✅ Configures all services

**No more separate commands!** Just run the installer and answer a few questions.

## 🚀 Quick Start (From Scratch)

### Step 1: Uninstall Old Installation (If Any)

```bash
cd /home/isdevis/Desktop/privacy
sudo ./trace-protocol.sh uninstall
```

This will:
- Disconnect VPN
- Stop all services
- Remove all packages
- Clean up configurations

### Step 2: Run Automated Installation

```bash
sudo ./trace-protocol.sh install
```

### Step 3: Follow the Prompts

During installation, you'll be asked:

1. **"Would you like to configure ProtonVPN now? (y/n)"**
   - Answer: `y`
   - This starts the automatic setup

2. **ProtonVPN Login**
   - Enter your **ProtonVPN username**
   - Enter your **ProtonVPN password**
   - Enter **2FA code** (if you have 2FA enabled)

3. **"Enable kill switch? (y/n)"**
   - Answer: `y` (recommended)
   - This prevents IP leaks if VPN disconnects

4. **"Connect to VPN now? (y/n)"**
   - Answer: `y`
   - Connects to the fastest VPN server automatically

### Step 4: Done!

After installation completes:
- ✅ All packages are installed
- ✅ VPN is connected
- ✅ Kill switch is enabled
- ✅ Conky widget is running (top-right corner)
- ✅ All services are active

## 📋 What Gets Installed

### Privacy & Security Packages
- `proton-vpn-gnome-desktop` - ProtonVPN CLI
- `tor` - The Onion Router
- `dnscrypt-proxy` - DNS encryption
- `macchanger` - MAC address randomization
- `apparmor` - Mandatory access control
- `ufw` - Firewall
- `firejail` - Application sandboxing
- `bleachbit` - System cleaner
- `signal-desktop` - Secure messaging
- `telegram-desktop` - Encrypted messaging
- `torbrowser-launcher` - Tor Browser
- `conky-all` - Desktop widget
- `dnsutils` - DNS tools (dig, nslookup)

### What Gets Configured
- VPN connection with kill switch
- Firewall (UFW) with default deny incoming
- Tor service (running)
- DNSCrypt-Proxy (running)
- AppArmor (enabled)
- Conky desktop monitor
- Auto-start on login

## 🔄 Complete Test Installation

```bash
# 1. Uninstall everything
sudo ./trace-protocol.sh uninstall

# 2. Fresh install with automation
sudo ./trace-protocol.sh install

# When prompted:
# - Configure ProtonVPN? y
# - Enter your ProtonVPN credentials
# - Enable kill switch? y
# - Connect to VPN? y

# 3. Verify installation
./trace-protocol.sh monitor

# 4. Check Conky widget
# Look at top-right corner of your screen
```

## 📊 Installation Timeline

**Expected Duration: 10-30 minutes**

| Step | Duration | What's Happening |
|------|----------|------------------|
| System Update | 2-5 min | Updating system packages |
| Package Installation | 5-15 min | Installing all privacy tools |
| ProtonVPN Setup | 2-5 min | Installing ProtonVPN CLI |
| Service Configuration | 1-2 min | Configuring Tor, DNSCrypt, etc. |
| VPN Login & Connect | 1-2 min | Your ProtonVPN setup |
| Conky Widget | <1 min | Creating desktop monitor |
| **Total** | **10-30 min** | *Depends on internet speed* |

## 🎨 What You'll See

### During Installation

```
========================================
      TraceProtocol Installer
========================================

Starting installation process...
Updating system packages...
Installing base privacy and security packages...
Installing tor...
Installing dnscrypt-proxy...
...
Installing ProtonVPN CLI...
...

========================================
  Automatic ProtonVPN Configuration
========================================

Would you like to configure ProtonVPN now? (y/n)
Answer: y

Starting ProtonVPN login process...
Enter your ProtonVPN credentials...

[ProtonVPN login screen]

Enable kill switch? (y/n)
Answer: y

Kill switch enabled!

Connect to VPN now? (y/n)
Answer: y

Connecting to fastest VPN server...
Connected to US-FREE#1
VPN IP: 1.2.3.4

Starting Conky desktop widget...
Conky widget started!

========================================
  Installation completed successfully!
========================================

TraceProtocol is now installed and configured!
```

### After Installation

Check your desktop - you should see the Conky widget in the top-right corner:

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
...
```

## 🛠️ Manual Steps (If You Skip Automation)

If you answer `n` to ProtonVPN configuration during installation:

```bash
# Login to ProtonVPN
./trace-protocol.sh vpn-login

# Connect to VPN
./trace-protocol.sh vpn-connect

# Enable kill switch
./trace-protocol.sh killswitch-on

# Start Conky widget
conky -c ~/.conkyrc &
```

## ⚠️ Important Notes

### 1. ProtonVPN Account Required
- Get a free account at [protonvpn.com](https://protonvpn.com)
- Have your credentials ready before installation

### 2. Kill Switch Warning
- When enabled, kill switch **blocks all internet** if VPN disconnects
- To disable: `./trace-protocol.sh killswitch-off`

### 3. Conky Widget
- Appears in top-right corner
- Updates every 5 seconds
- Auto-starts on login
- To restart: `pkill conky && conky -c ~/.conkyrc &`

### 4. First Time Setup
- Installation requires **sudo/root** access
- **Internet connection** is required
- Allow **10-30 minutes** for complete setup

## 🔍 Verification Steps

After installation, verify everything works:

```bash
# 1. Check all services
./trace-protocol.sh monitor

# 2. Verify VPN connection
./trace-protocol.sh vpn-status

# 3. Check public IP (should be VPN IP)
curl https://api.ipify.org

# 4. Test DNS leaks
# Visit: https://dnsleaktest.com

# 5. Verify Conky widget is running
ps aux | grep conky
```

## 🐛 Troubleshooting

### Installation Failed

```bash
# Check logs
tail -f logs/install_*.log

# Try manual update
sudo apt update
sudo apt upgrade

# Retry installation
sudo ./trace-protocol.sh install
```

### VPN Not Connecting

```bash
# Check if ProtonVPN is installed
protonvpn-cli --version

# Try manual login
./trace-protocol.sh vpn-login

# Connect manually
./trace-protocol.sh vpn-connect
```

### Conky Widget Not Showing

```bash
# Check if Conky is installed
conky --version

# Start Conky manually
conky -c ~/.conkyrc &

# Check for errors
conky -C -c ~/.conkyrc
```

### Kill Switch Blocking Internet

```bash
# Disable kill switch
./trace-protocol.sh killswitch-off

# Or manually
protonvpn-cli ks --off
```

## 📁 Log Files

Installation logs are saved in:

```
logs/install_YYYYMMDD_HHMMSS.log
```

To view the latest log:

```bash
ls -lt logs/install_*.log | head -1 | awk '{print $NF}' | xargs cat
```

## 🎯 Post-Installation

After successful installation:

1. **Check Status**
   ```bash
   ./trace-protocol.sh monitor
   ```

2. **Test VPN Connection**
   - Check Conky widget
   - Visit [ipleak.net](https://ipleak.net)
   - Verify IP is from VPN server

3. **Customize Conky** (Optional)
   ```bash
   nano ~/.conkyrc
   pkill conky && conky -c ~/.conkyrc &
   ```

4. **Review Services**
   ```bash
   systemctl status tor
   systemctl status dnscrypt-proxy
   sudo ufw status
   ```

## 🚀 Daily Usage

```bash
# Morning: Check status
./trace-protocol.sh monitor

# If VPN disconnected
./trace-protocol.sh vpn-connect

# Evening: Optional disconnect
./trace-protocol.sh vpn-disconnect
```

## 📚 Additional Resources

- **Full Documentation**: [README.md](README.md)
- **Quick Start**: [QUICKSTART.md](QUICKSTART.md)
- **Conky Widget**: [docs/CONKY_WIDGET.md](docs/CONKY_WIDGET.md)
- **Setup Guide**: [docs/SETUP.md](docs/SETUP.md)

## ✅ Complete Test Checklist

- [ ] Uninstalled old installation
- [ ] Ran automated installer
- [ ] Entered ProtonVPN credentials
- [ ] Enabled kill switch
- [ ] Connected to VPN
- [ ] Conky widget appeared
- [ ] All services running (checked with monitor)
- [ ] Public IP changed to VPN IP
- [ ] No DNS leaks detected
- [ ] Conky auto-starts on login

---

**Your TraceProtocol installation is now fully automated!** 🚀🔒

Everything happens in one command - just run the installer and follow the prompts!

