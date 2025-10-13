#!/bin/bash

# Quick script to save original MAC address for Conky display

echo "Saving original MAC address..."
echo ""

# Create directory
sudo mkdir -p /var/lib/traceprotocol
sudo chmod 755 /var/lib/traceprotocol

# Your interface based on your ip a output
INTERFACE="wlp3s0"

# Get permanent MAC from permaddr field
PERM_MAC=$(ip link show $INTERFACE | grep "link/ether" | grep -o "permaddr [0-9a-f:]*" | awk '{print $2}')

# Get current MAC
CURRENT_MAC=$(ip link show $INTERFACE | grep "link/ether" | awk '{print $2}')

echo "Interface: $INTERFACE"
echo "Current MAC:  $CURRENT_MAC"
echo "Original MAC (permaddr): $PERM_MAC"
echo ""

# Save permanent MAC as original
if [ -n "$PERM_MAC" ]; then
    echo "$PERM_MAC" | sudo tee /var/lib/traceprotocol/original_mac.txt
    echo "$INTERFACE" | sudo tee /var/lib/traceprotocol/interface.txt
    echo ""
    echo "✓ Original MAC saved: $PERM_MAC"
else
    echo "$CURRENT_MAC" | sudo tee /var/lib/traceprotocol/original_mac.txt
    echo "$INTERFACE" | sudo tee /var/lib/traceprotocol/interface.txt
    echo ""
    echo "✓ Current MAC saved: $CURRENT_MAC"
fi

echo ""
echo "Restarting Conky widget..."
pkill conky
sleep 1
conky -c ~/.conkyrc &

echo ""
echo "✓ Done! Check top-right corner of your desktop."
echo "  Original MAC should now appear in Conky widget."

