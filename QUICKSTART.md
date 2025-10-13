# TraceProtocol - Quick Start Guide

⚡ Get up and running with TraceProtocol in 5 minutes!

## 🚀 Two-Step Installation

### Step 1: Install Privacy Tools (with sudo)

```bash
sudo ./trace-protocol.sh install
```

Wait 10-30 minutes for installation to complete. When prompted to configure ProtonVPN, answer **y**.

### Step 2: ProtonVPN Setup (runs automatically OR manually)

**Option A: During installation** (automatic)
- The installer will call vpn-setup.sh automatically as your normal user
- Just answer the prompts

**Option B: After installation** (manual)
```bash
# Run WITHOUT sudo!
./trace-protocol.sh vpn-setup
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
./trace-protocol.sh monitor
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
| `./trace-protocol.sh install` | Install all privacy tools |
| `./trace-protocol.sh vpn-connect` | Connect to fastest VPN server |
| `./trace-protocol.sh vpn-disconnect` | Disconnect from VPN |
| `./trace-protocol.sh vpn-status` | Show VPN connection details |
| `./trace-protocol.sh monitor` | Full status check |
| `./trace-protocol.sh monitor-live` | Live monitoring (updates every 30s) |
| `./trace-protocol.sh killswitch-on` | Enable kill switch |
| `./trace-protocol.sh killswitch-off` | Disable kill switch |
| `./trace-protocol.sh help` | Show all commands |

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
./trace-protocol.sh vpn-disconnect

# Try to access internet (should fail)
ping 8.8.8.8

# Reconnect
./trace-protocol.sh vpn-connect
```

### Manage Services

```bash
# Start all privacy services
./trace-protocol.sh start-services

# Stop privacy services
./trace-protocol.sh stop-services
```

## 📁 Important Files

- **Main Script**: `./trace-protocol.sh`
- **Conky Config**: `~/.conkyrc`
- **Logs**: `./logs/`
- **Configuration**: `./privacy-tools.conf`

## 🔍 Troubleshooting

### VPN Won't Connect

```bash
# Check login status
./trace-protocol.sh vpn-login

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
./trace-protocol.sh stop-services
./trace-protocol.sh start-services
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
- **Full Monitor**: Run `./trace-protocol.sh monitor`
- **Help**: Run `./trace-protocol.sh help`

## 🎯 Daily Usage

```bash
# Morning: Connect to VPN
./trace-protocol.sh vpn-connect

# Check status anytime
./trace-protocol.sh monitor

# Evening: Disconnect (optional)
./trace-protocol.sh vpn-disconnect
```

## 🚨 Emergency Commands

```bash
# Kill switch blocking internet?
./trace-protocol.sh killswitch-off

# Conky using too much CPU?
pkill conky

# Need to reset everything?
./trace-protocol.sh vpn-disconnect
./trace-protocol.sh stop-services
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

