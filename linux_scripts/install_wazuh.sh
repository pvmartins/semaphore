#!/bin/bash

# Configuration Variables
WAZUH_MANAGER="192.168.2.236"
WAZUH_AGENT_GROUP="default"
WAZUH_AGENT_NAME="wazuh-agent-$(hostname)"
WAZUH_PACKAGE_URL="https://packages.wazuh.com/4.x/apt/pool/main/w/wazuh-agent/wazuh-agent_4.14.1-1_amd64.deb"
PACKAGE_FILE=$(basename "$WAZUH_PACKAGE_URL")

echo "--- Starting Wazuh Agent Installation ---"

# --- 1. Clean up Previous Installation ---
echo "Checking for and cleaning up any previous Wazuh Agent installation..."

# Check if the wazuh-agent package is installed (for Debian/Ubuntu)
if dpkg -l | grep -q wazuh-agent; then
    echo "Previous agent found. Stopping service and purging package..."
    
    # 1. Stop the service
    sudo systemctl stop wazuh-agent 2>/dev/null || true

    # 2. Purge the package (removes config files)
    if ! sudo dpkg --purge wazuh-agent; then
        echo "Warning: dpkg purge failed, proceeding with file cleanup."
    fi

    # 3. Clean up the main data directory to remove the old agent ID/key
    if [ -d "/var/ossec" ]; then
        echo "Removing old /var/ossec directory..."
        sudo rm -rf /var/ossec/
    fi
    
    # Reload daemon after removal
    sudo systemctl daemon-reload
    echo "Previous installation fully removed."

else
    echo "No previous Wazuh Agent installation found."
fi

# --- 2. Check for Local Package and Download if missing ---
if [ -f "$PACKAGE_FILE" ]; then
    echo "Found local package: $PACKAGE_FILE. Skipping download."
else
    echo "Local package not found. Downloading from $WAZUH_PACKAGE_URL..."
    if ! wget "$WAZUH_PACKAGE_URL"; then
        echo "Error: Failed to download the package." >&2
        exit 1
    fi
fi

# --- 3. Install the Package with Configuration ---
echo "Installing Wazuh Agent..."
# Use environment variables for configuration during dpkg install
if ! sudo WAZUH_MANAGER="$WAZUH_MANAGER" \
         WAZUH_AGENT_GROUP="$WAZUH_AGENT_GROUP" \
         WAZUH_AGENT_NAME="$WAZUH_AGENT_NAME" \
         dpkg -i "./$PACKAGE_FILE"; then
    echo "Error: dpkg installation failed." >&2
    exit 1
fi

# --- 4. Reload Daemon and Start Service ---
echo "Enabling and starting the Wazuh Agent service..."
sudo systemctl daemon-reload
sudo systemctl enable wazuh-agent
sudo systemctl start wazuh-agent

echo "--- Wazuh Agent Installation Complete ---"