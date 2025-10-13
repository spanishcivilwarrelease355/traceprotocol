# Fix Conky Widget Display

## 🔧 Quick Fix for Conky Issues

Your Conky widget has been updated! Restart it to see the fixes:

```bash
pkill conky
conky -c ~/.conkyrc &
```

## ✅ What Was Fixed

### 1. VPN Status Detection ✅
**Before**: Said "No VPN Connection" even when connected
**After**: Correctly detects by checking for "Server:" field
**Now shows**: ✓ Connected when VPN is active

### 2. Kill Switch Detection ✅
**Before**: Showed "Disabled" even when enabled
**After**: Checks "Kill switch: On" from status output
**Now shows**: ✓ Enabled when kill switch is on

### 3. MAC Address Display ✅
**Before**: Showed 4 MAC addresses or wrong interface
**After**: Gets physical interface (excludes proton0 VPN tunnel)
**Now shows**: Only your actual network card's MAC

### 4. Original MAC Address ✅
**Before**: Empty/N/A
**After**: Will be saved during installation or mac-changer run
**To fix now**: Run this command:

```bash
# Save your original MAC address
IFACE=$(ip route | grep -v proton | grep default | awk '{print $5}' | head -1)
MAC=$(ip link show $IFACE | grep "link/ether" | awk '{print $2}')
sudo mkdir -p /var/lib/traceprotocol
echo "$MAC" | sudo tee /var/lib/traceprotocol/original_mac.txt
echo "$IFACE" | sudo tee /var/lib/traceprotocol/interface.txt
```

## 🎨 Updated Conky Display

After restarting, you should see:

```
╔═══════════════════════════════════╗
║      TraceProtocol Monitor      ║
╚═══════════════════════════════════╝

━━━ VPN STATUS ━━━
Status: ✓ Connected              ← Fixed!
Server: NL-FREE#248
VPN IP: 190.2.151.14
Country: Netherlands
Load: 86%

━━━ IP ADDRESSES ━━━
Public IP: 190.2.151.14          (VPN protected)
VPN Tunnel: 10.2.0.2

━━━ MAC ADDRESSES ━━━
Interface: wlan0                 ← Physical interface
Original MAC: xx:xx:xx:xx:xx:xx ← After you run command above
Current MAC: yy:yy:yy:yy:yy:yy  ← Fixed: shows only one MAC

━━━ SECURITY STATUS ━━━
Kill Switch: ✓ Enabled           ← Fixed!
Tor: ✓ Running
DNSCrypt: ✓ Active
Firewall: ✓ Active

━━━ SYSTEM STATUS ━━━
CPU: 15%  ███░░░░░░░░░░░░
RAM: 35%  ████████░░░░░░░
Disk: 45% ████████████░░░
Uptime: 3h 15m
Time: 12:45:30

TraceProtocol v1.0.0
```

## 🚀 Complete Fix Steps

### Step 1: Save Original MAC (if empty)

```bash
IFACE=$(ip route | grep -v proton | grep default | awk '{print $5}' | head -1)
MAC=$(ip link show $IFACE | grep "link/ether" | awk '{print $2}')
sudo mkdir -p /var/lib/traceprotocol
echo "$MAC" | sudo tee /var/lib/traceprotocol/original_mac.txt
echo "$IFACE" | sudo tee /var/lib/traceprotocol/interface.txt
```

### Step 2: Restart Conky

```bash
pkill conky
conky -c ~/.conkyrc &
```

### Step 3: Verify

Check the top-right corner - you should now see:
- ✓ Connected (green)
- ✓ Enabled kill switch (green)
- Correct MAC addresses
- VPN IP showing

## 🔍 Verification Commands

```bash
# Check VPN status
protonvpn-cli status

# Check kill switch
protonvpn-cli ks --status

# Check if Conky is running
ps aux | grep conky

# Check MAC backup file
cat /var/lib/traceprotocol/original_mac.txt
```

## 📝 What Changed in Conky Config

### VPN Detection:
```lua
-- Before:
grep -qi "Status:.*Connected\|connected"

-- After:
grep -q "Server:"  # Simpler, more reliable
```

### Kill Switch:
```lua
-- Before:
grep -qi "enabled\|on"

-- After:
grep -qi "On"  # Matches "On (Active)" and "On (Inactive)"
```

### MAC Address:
```lua
-- Before:
${gw_iface}  # Shows proton0 when VPN connected

-- After:
${exec ip route | grep -v proton0 | grep default | awk '{print $5}' | head -1}
# Gets physical interface
```

## ⚡ Quick Restart

```bash
pkill conky && conky -c ~/.conkyrc &
```

Look at the top-right corner - everything should be green now! ✅

