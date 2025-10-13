# TraceProtocol - Final Updates

## ✅ Latest Changes

### 1. **Script Renamed** 🎯
**From**: `privacy-manager.sh`  
**To**: `trace-protocol.sh`

**All commands updated:**
```bash
# Old way:
./privacy-manager.sh install

# New way:
./trace-protocol.sh install
```

### 2. **Email & FTP Support Added** ✉️

**New UFW Ports Allowed:**
- **SMTP**: 25, 587, 465 (email sending)
- **IMAP**: 143, 993 (email receiving)
- **POP3**: 110, 995 (email receiving)
- **FTP**: 20, 21 (file transfer)

Now UFW won't block:
- ✅ Email clients (Thunderbird, Evolution, etc.)
- ✅ FTP clients (FileZilla, etc.)
- ✅ Web email interfaces
- ✅ File transfers

### 3. **New Firewall Commands** 🔥

```bash
# Enable UFW (for extra security)
./trace-protocol.sh firewall-on

# Disable UFW (if apps are blocked - like Cursor)
./trace-protocol.sh firewall-off

# Reconfigure UFW rules
./trace-protocol.sh firewall-config
```

### 4. **UFW Now Optional** ⚙️

During `vpn-setup`, you can choose:
- **Yes**: Enable UFW (more secure, may block some apps)
- **No**: Skip UFW (all apps work, still protected by VPN)

**Note**: UFW is extra security. You're still protected by:
- VPN encryption
- Kill switch
- Tor + DNSCrypt

## 🚀 All Available Commands Now

```bash
# Installation
sudo ./trace-protocol.sh install      # Install all packages
./trace-protocol.sh vpn-setup         # Setup VPN (NO sudo!)
sudo ./trace-protocol.sh uninstall    # Remove everything

# Monitoring
./trace-protocol.sh monitor           # Check status
./trace-protocol.sh monitor-live      # Live monitoring

# VPN Control
./trace-protocol.sh vpn-connect       # Connect to VPN
./trace-protocol.sh vpn-disconnect    # Disconnect VPN
./trace-protocol.sh vpn-status        # Show VPN status
./trace-protocol.sh vpn-login         # Login to ProtonVPN

# Security
./trace-protocol.sh killswitch-on     # Enable kill switch
./trace-protocol.sh killswitch-off    # Disable kill switch

# Firewall (NEW!)
./trace-protocol.sh firewall-on       # Enable UFW
./trace-protocol.sh firewall-off      # Disable UFW
./trace-protocol.sh firewall-config   # Reconfigure UFW

# Services
./trace-protocol.sh start-services    # Start Tor, DNSCrypt
./trace-protocol.sh stop-services     # Stop services

# Utilities
./trace-protocol.sh clean-logs        # Clean old logs
./trace-protocol.sh help              # Show help
./trace-protocol.sh version           # Show version
```

## 🔧 Solution for Cursor IDE

**If UFW is blocking Cursor:**

```bash
./trace-protocol.sh firewall-off
```

**Your protection status:**
- ✅ VPN Active: All traffic encrypted
- ✅ Kill Switch: Blocks internet if VPN drops
- ✅ Tor: Anonymous routing
- ✅ DNSCrypt: Encrypted DNS
- ⚠️ UFW: Disabled (so apps work)

**Still very secure!** UFW is optional extra layer.

## 📋 UFW Ports Now Allowed

| Port(s) | Protocol | Service |
|---------|----------|---------|
| 53 | DNS | Domain resolution |
| 80 | HTTP | Web browsing |
| 443 | HTTPS | Secure web |
| 22 | SSH | Secure shell |
| 21, 20 | FTP | File transfer |
| 25, 587, 465 | SMTP | Email sending |
| 143, 993 | IMAP | Email receiving |
| 110, 995 | POP3 | Email receiving |
| 1194 | OpenVPN | VPN connection |
| 5060 | ProtonVPN | VPN alt port |
| 9418 | Git | Git protocol |
| 8080, 8443 | Alt HTTP/S | Alternative ports |

**Plus**: All outgoing connections allowed by default

## 🎯 Recommended Setup

### For Development (Cursor, coding, etc.):
```bash
# Keep UFW disabled
./trace-protocol.sh firewall-off

# You're protected by VPN + Kill Switch
# All apps work normally
```

### For Maximum Security (browsing only):
```bash
# Enable UFW
./trace-protocol.sh firewall-on

# Extra firewall layer
# Some apps may not work
```

### Toggle as Needed:
```bash
# Developing? Disable UFW
./trace-protocol.sh firewall-off

# Done coding? Enable UFW
./trace-protocol.sh firewall-on
```

## 📊 What Changed in Files

| File | Change |
|------|--------|
| `privacy-manager.sh` | → `trace-protocol.sh` |
| All 14 documentation files | Updated references |
| `scripts/install.sh` | Added email/FTP ports |
| `scripts/configure-ufw.sh` | Added email/FTP ports |
| `scripts/vpn-setup.sh` | UFW now optional with warning |

## ✅ Current Status

**Main Script:**
```bash
./trace-protocol.sh  # ← New name!
```

**UFW Rules:**
```bash
# Now allows:
✓ HTTP/HTTPS
✓ Email (SMTP, IMAP, POP3)
✓ FTP
✓ SSH, Git
✓ VPN ports
✓ All outgoing by default
```

**Protection:**
```
VPN ✓ → Kill Switch ✓ → Tor ✓ → DNSCrypt ✓ → UFW (optional)
```

## 🚀 Quick Start

```bash
# 1. Install packages
sudo ./trace-protocol.sh install

# 2. Setup VPN (NO sudo!)
./trace-protocol.sh vpn-setup

# 3. If UFW blocks Cursor:
./trace-protocol.sh firewall-off

# 4. Check status
./trace-protocol.sh monitor
```

## 📝 Files Updated

✅ 15 files updated with new script name
✅ All documentation current
✅ All scripts working
✅ Email and FTP support added
✅ UFW management commands added
✅ Git history preserved

---

**TraceProtocol v1.0.0** - Your complete privacy suite! 🔒

Use `./trace-protocol.sh help` to see all commands.

