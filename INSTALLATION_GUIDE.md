# TraceProtocol - Complete Installation Guide

## 🎯 Overview

TraceProtocol uses a **two-step installation** process to avoid ProtonVPN running as root:

1. **Step 1**: Install packages (requires sudo)
2. **Step 2**: Configure VPN (NO sudo - as normal user)

## 🚀 Installation Process

### Step 1: Install Packages (5-30 minutes)

```bash
cd /home/isdevis/Desktop/privacy
sudo ./privacy-manager.sh install
```

**What happens:**
- ✅ Updates system packages
- ✅ Installs ProtonVPN CLI
- ✅ Installs Tor, DNSCrypt, privacy tools
- ✅ Installs Conky widget
- ✅ Configures UFW rules (but keeps it **disabled**)
- ✅ Starts Tor, DNSCrypt, AppArmor services
- ✅ Creates Conky configuration
- ✅ Starts Conky widget

**At the end, you'll see:**
```
════════════════════════════════════════
   DON'T REBOOT YET!
════════════════════════════════════════

Please run the VPN setup first:
  ./privacy-manager.sh vpn-setup

After VPN setup is complete, you can reboot if needed.
```

**⚠️ IMPORTANT**: Do NOT reboot yet! Continue to Step 2.

### Step 2: Configure ProtonVPN (2-5 minutes)

```bash
./privacy-manager.sh vpn-setup
```

**⚠️ Run WITHOUT sudo - as your normal user!**

**What happens:**

#### Prompt 1: Username
```
Enter your ProtonVPN username:
Username: opxnel@proton.me
```

#### Prompt 2: Password
```
Enter your Proton VPN password: ********
```

#### Automatic: VPN Connects
```
Successfully connected to Proton VPN.
[Shows VPN status]
```

#### Prompt 3: Kill Switch
```
Enable kill switch? (y/n)
Answer: y
✓ Kill switch enabled!
```

#### Prompt 4: Firewall
```
Enable UFW firewall? (y/n)
Answer: y
✓ UFW firewall enabled!
```

#### Automatic: Conky Restarts
```
✓ Conky widget is running!
Check the top-right corner of your screen.
```

### Step 3: Verification

```bash
./privacy-manager.sh monitor
```

You should see:
- ✅ ProtonVPN CLI installed
- ✅ VPN connected
- ✅ Kill switch enabled
- ✅ UFW firewall active
- ✅ All services running
- ✅ Conky widget on desktop

## 🔍 What Gets Configured

### During Step 1 (sudo install):
- ✅ ProtonVPN CLI package
- ✅ Tor service (running)
- ✅ DNSCrypt-Proxy2 (running)
- ✅ AppArmor (enabled)
- ✅ UFW firewall rules (configured, **not enabled**)
- ✅ Conky widget (created and started)
- ✅ MAC changer (installed, not enabled)
- ✅ Firejail, BleachBit tools

### During Step 2 (vpn-setup):
- ✅ ProtonVPN login with credentials
- ✅ VPN connection to fastest server
- ✅ Kill switch activation
- ✅ UFW firewall activation
- ✅ Conky widget refresh

## ⚠️ Common Issues & Solutions

### Issue 1: "Running Proton VPN as root" Error

**Cause**: You ran vpn-setup with sudo

**Solution**: Run vpn-setup WITHOUT sudo:
```bash
./privacy-manager.sh vpn-setup  # ← NO sudo!
```

### Issue 2: ProtonVPN Login Fails

**Cause**: UFW firewall was blocking it (fixed in current version)

**Solution**: UFW is now kept disabled during initial setup

### Issue 3: Conky Widget Not Showing

**Solutions**:
```bash
# Restart Conky manually
pkill conky
conky -c ~/.conkyrc &

# Check if running
ps aux | grep conky

# Check configuration
cat ~/.conkyrc
```

### Issue 4: VPN Says "Connected" But Verification Shows Failed

**Cause**: Status check pattern mismatch (fixed in current version)

**Current behavior**: Script always continues to kill switch/UFW prompts after connection attempt

### Issue 5: Installation Hangs on apt Prompts

**Cause**: Interactive prompts (fixed in current version)

**Solution**: Now uses `DEBIAN_FRONTEND=noninteractive` and `yes |` commands

## 📋 Installation Checklist

- [ ] Step 1 completed: `sudo ./privacy-manager.sh install`
- [ ] Step 2 completed: `./privacy-manager.sh vpn-setup` (NO sudo!)
- [ ] VPN connected and verified
- [ ] Kill switch enabled
- [ ] UFW firewall enabled
- [ ] Conky widget visible on desktop
- [ ] Monitor shows all services running

## 🎯 Correct Command Usage

| Task | Command | Needs sudo? |
|------|---------|------------|
| Install packages | `./privacy-manager.sh install` | ✅ YES |
| Setup VPN | `./privacy-manager.sh vpn-setup` | ❌ NO |
| Connect VPN | `protonvpn-cli c -f` | ❌ NO |
| Disconnect VPN | `protonvpn-cli d` | ❌ NO |
| Check status | `./privacy-manager.sh monitor` | ❌ NO |
| Enable firewall | `ufw enable` | ✅ YES |
| Restart Conky | `pkill conky && conky -c ~/.conkyrc &` | ❌ NO |

## 🔄 Reinstallation Steps

To test from scratch:

```bash
# 1. Uninstall everything (with sudo)
sudo ./privacy-manager.sh uninstall

# 2. Install packages (with sudo)
sudo ./privacy-manager.sh install
# Wait for completion, read the message

# 3. Setup VPN (WITHOUT sudo!)
./privacy-manager.sh vpn-setup
# Answer all prompts with 'y'

# 4. Verify
./privacy-manager.sh monitor
protonvpn-cli status
ps aux | grep conky
```

## 📊 What the Conky Widget Shows

Located in top-right corner:
```
╔═══════════════════════════════════╗
║      TraceProtocol Monitor      ║
╚═══════════════════════════════════╝

━━━ VPN STATUS ━━━
✓ Connected
Server: US-FREE#105
IP: x.x.x.x
Country: United States

━━━ SECURITY STATUS ━━━
Kill Switch: ✓ Enabled
Tor Service: ✓ Running
DNSCrypt: ✓ Active
AppArmor: ✓ Enabled
Firewall: ✓ Active

━━━ NETWORK INFO ━━━
Public IP: x.x.x.x
Interface: wlan0
Local IP: 192.168.1.x

━━━ SYSTEM STATUS ━━━
CPU: 15%  ███░░░░░░░░░░░░
RAM: 35%  ████████░░░░░░░
Disk: 45% ████████████░░░

Uptime: 2h 15m
Time: 11:52:30

TraceProtocol v1.0.0
```

## 🛡️ Security Setup Order

**Why this order?**

1. **Install packages** (with sudo) - Required for package installation
2. **Keep UFW disabled** - Allows ProtonVPN to login
3. **Login to ProtonVPN** (as user) - No root/firewall blocking
4. **Connect to VPN** (as user) - Establishes secure tunnel
5. **Enable kill switch** - Prevents leaks if VPN drops
6. **Enable UFW** - Now safe to enable firewall
7. **Restart Conky** - Shows updated VPN status

## 🎮 Daily Usage

```bash
# Check everything
./privacy-manager.sh monitor

# Connect VPN (if not connected)
protonvpn-cli c -f

# Disconnect VPN
protonvpn-cli d

# Check VPN status
protonvpn-cli status

# Restart Conky widget
pkill conky && conky -c ~/.conkyrc &
```

## 📝 Files Created

- `~/.conkyrc` - Conky widget configuration
- `~/.config/autostart/traceprotocol-conky.desktop` - Auto-start on login
- `~/.config/protonvpn/` - ProtonVPN settings (after login)
- `./privacy-tools.conf` - TraceProtocol configuration
- `./logs/` - Installation and monitoring logs

## 🔧 Troubleshooting

### Conky Not Visible

```bash
# Method 1: Restart Conky
pkill conky
conky -c ~/.conkyrc &

# Method 2: Check if file exists
ls -la ~/.conkyrc

# Method 3: Test Conky
conky -C -c ~/.conkyrc  # Check for errors
```

### VPN Not Connecting

```bash
# Check status
protonvpn-cli status

# Try reconnecting
protonvpn-cli d
protonvpn-cli c -f

# Check if ProtonVPN is installed
which protonvpn-cli
protonvpn-cli --version
```

### Firewall Blocking Everything

```bash
# Check UFW status
sudo ufw status verbose

# Disable temporarily
sudo ufw disable

# Re-enable
sudo ufw enable
```

## ✅ Success Indicators

After complete setup, you should have:

1. ✅ **VPN Connected**
   ```bash
   protonvpn-cli status
   # Should show: Status: Connected
   ```

2. ✅ **Kill Switch Enabled**
   ```bash
   protonvpn-cli ks --status
   # Should show: Kill Switch is enabled
   ```

3. ✅ **Firewall Active**
   ```bash
   sudo ufw status
   # Should show: Status: active
   ```

4. ✅ **Conky Widget Visible**
   - Check top-right corner of desktop
   - Should show green checkmarks for VPN and services

5. ✅ **Public IP Changed**
   ```bash
   curl https://api.ipify.org
   # Should show ProtonVPN server IP, not your real IP
   ```

## 🎉 You're Done!

After both steps complete:
- 🔒 Your traffic is encrypted through VPN
- 🛡️ Kill switch protects against leaks
- 🔥 Firewall blocks unwanted connections
- 👁️ Conky monitors everything in real-time
- 🕵️ Tor, DNSCrypt provide additional privacy layers

**Stay private and secure!** 🔒

