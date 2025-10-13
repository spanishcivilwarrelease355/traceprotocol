# TraceProtocol - Quick Start Guide

⚡ Get up and running with TraceProtocol in 5 minutes!

## 🚀 Two-Step Installation

### Step 1: Install Privacy Tools (with sudo)

```bash
sudo ./privacy-manager.sh install
```

Wait 10-30 minutes for installation to complete. When prompted to configure ProtonVPN, answer **y**.

### Step 2: ProtonVPN Setup (runs automatically OR manually)

**Option A: During installation** (automatic)
- The installer will call vpn-setup.sh automatically as your normal user
- Just answer the prompts

**Option B: After installation** (manual)
```bash
# Run WITHOUT sudo!
./privacy-manager.sh vpn-setup
```

## 🔐 VPN Setup Process

When you run vpn-setup (automatically or manually):

```bash
# 1. Enter your ProtonVPN username
Username: your_username@proton.me

# 2. Enter your password (when prompted)
Password: ********

# 3. Connect to VPN (when asked)
Answer: y

# 4. Enable Kill Switch (when asked)
Answer: y

# 5. Done!
```

## ✅ Verify Installation

```bash
./privacy-manager.sh monitor
```

## 📊 Conky Widget

**Your desktop widget is already running!**

Look at the top-right corner of your screen to see:
- VPN connection status
- Security services status
- Real-time IP address
- System information

### Widget Controls

```bash
# Stop widget
pkill conky

# Start widget
conky -c ~/.conkyrc &

# Restart widget
pkill conky && sleep 2 && conky -c ~/.conkyrc &
```

## 🎯 Essential Commands

| Command | What it does |
|---------|-------------|
| `./privacy-manager.sh install` | Install all privacy tools |
| `./privacy-manager.sh vpn-connect` | Connect to fastest VPN server |
| `./privacy-manager.sh vpn-disconnect` | Disconnect from VPN |
| `./privacy-manager.sh vpn-status` | Show VPN connection details |
| `./privacy-manager.sh monitor` | Full status check |
| `./privacy-manager.sh monitor-live` | Live monitoring (updates every 30s) |
| `./privacy-manager.sh killswitch-on` | Enable kill switch |
| `./privacy-manager.sh killswitch-off` | Disable kill switch |
| `./privacy-manager.sh help` | Show all commands |

## 🛠️ Common Tasks

### Connect to Specific Country

```bash
protonvpn-cli connect --cc US    # USA
protonvpn-cli connect --cc UK    # United Kingdom
protonvpn-cli connect --cc JP    # Japan
```

### Check Your IP

```bash
curl https://api.ipify.org
```

### Test Kill Switch

```bash
# Disconnect VPN (with kill switch enabled)
./privacy-manager.sh vpn-disconnect

# Try to access internet (should fail)
ping 8.8.8.8

# Reconnect
./privacy-manager.sh vpn-connect
```

### Manage Services

```bash
# Start all privacy services
./privacy-manager.sh start-services

# Stop privacy services
./privacy-manager.sh stop-services
```

## 📁 Important Files

- **Main Script**: `./privacy-manager.sh`
- **Conky Config**: `~/.conkyrc`
- **Logs**: `./logs/`
- **Configuration**: `./privacy-tools.conf`

## 🔍 Troubleshooting

### VPN Won't Connect

```bash
# Check login status
./privacy-manager.sh vpn-login

# Try different server
protonvpn-cli connect --random
```

### Conky Widget Not Showing

```bash
# Restart Conky
pkill conky
conky -c ~/.conkyrc &
```

### Services Not Running

```bash
# Restart all services
./privacy-manager.sh stop-services
./privacy-manager.sh start-services
```

## 📚 Documentation

- **Full README**: [README.md](README.md)
- **Setup Guide**: [docs/SETUP.md](docs/SETUP.md)
- **Conky Widget**: [docs/CONKY_WIDGET.md](docs/CONKY_WIDGET.md)
- **GitHub Setup**: [docs/GITHUB_SETUP.md](docs/GITHUB_SETUP.md)
- **Contributing**: [CONTRIBUTING.md](CONTRIBUTING.md)

## ⚠️ Important Notes

1. **ProtonVPN Account Required** - Get one at [protonvpn.com](https://protonvpn.com)
2. **Kill Switch Warning** - When enabled, blocks all internet if VPN disconnects
3. **Reboot Recommended** - After initial installation
4. **Widget Updates** - Conky updates every 5 seconds

## 🎨 Widget Customization

Edit `~/.conkyrc` to customize:
- Position: Change `gap_x`, `gap_y`, `alignment`
- Colors: Change `color1` through `color5`
- Transparency: Change `own_window_argb_value` (0-255)
- Update speed: Change `update_interval`

## 🔗 Quick Links

- **Check VPN Status**: Look at Conky widget (top-right)
- **Full Monitor**: Run `./privacy-manager.sh monitor`
- **Help**: Run `./privacy-manager.sh help`

## 🎯 Daily Usage

```bash
# Morning: Connect to VPN
./privacy-manager.sh vpn-connect

# Check status anytime
./privacy-manager.sh monitor

# Evening: Disconnect (optional)
./privacy-manager.sh vpn-disconnect
```

## 🚨 Emergency Commands

```bash
# Kill switch blocking internet?
./privacy-manager.sh killswitch-off

# Conky using too much CPU?
pkill conky

# Need to reset everything?
./privacy-manager.sh vpn-disconnect
./privacy-manager.sh stop-services
```

## ✅ Verification Checklist

After installation, verify:

- [ ] VPN connects successfully
- [ ] Kill switch is enabled
- [ ] Conky widget appears on desktop
- [ ] Monitor shows all services running
- [ ] Public IP changes when VPN connects
- [ ] No IP/DNS leaks (check at ipleak.net)

## 🎉 You're Ready!

TraceProtocol is now protecting your privacy!

- ✅ VPN installed and configured
- ✅ Privacy tools running
- ✅ Desktop monitor active
- ✅ Kill switch protecting you

**Stay safe and private!** 🔒

---

For more details, see [README.md](README.md)

