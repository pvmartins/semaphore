#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo." 
   exit 1
fi

# Update package list
echo "Updating package list..."
sudo apt update

# Install required packages
echo "Installing net-tools..."
sudo apt install -y net-tools

echo "Bringing up the enp0s8 interface..."
ifconfig enp0s8 up

# Install DHCP client
echo "Installing isc-dhcp-client..."
sudo apt install -y isc-dhcp-client

# Request an IP address
echo "Requesting an IP address for enp0s8..."
sudo dhclient enp0s8

# Check and ensure enp0s8 has an IP address
echo "Checking IP configuration for enp0s8..."
ip a | grep -A3 enp0s8 | grep 'inet '

if ip a show enp0s8 | grep -q 'inet '; then
    echo "enp0s8 has an IP address. Network setup completed."
else
    echo "Warning: enp0s8 does not have an IP address. Check your DHCP settings."
fi