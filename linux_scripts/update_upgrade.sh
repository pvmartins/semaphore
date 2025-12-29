#!/bin/bash

# Check if the script is running as root
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root (use sudo)"
  exit 1
fi

echo "--- Starting System Update ---"

# 1. Update the package list
echo "Updating package lists..."
apt update

# 2. Upgrade packages
echo "Upgrading packages..."
apt upgrade -y

# 3. Full distribution upgrade (optional but recommended for Ubuntu)
# apt dist-upgrade -y

# 4. Remove unnecessary packages
echo "Cleaning up..."
apt autoremove -y
apt autoclean

echo "--- Update Complete ---"
