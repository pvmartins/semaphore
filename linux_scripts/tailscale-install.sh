#!/bin/bash

# Exit immediately if any command fails
set -e

# Define your reusable auth key here (NEVER expose this in public code)
TAILSCALE_AUTH_KEY="tskey-xxxxxxxxxxxxxxxx"

# Update and install required packages
sudo apt-get update
sudo apt-get install -y curl gnupg2 lsb-release

# Add Tailscale repository and install Tailscale
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/$(lsb_release -cs).noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg > /dev/null
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/$(lsb_release -cs).tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list > /dev/null

sudo apt-get update
sudo apt-get install -y tailscale

# Start Tailscale and log in with the auth key
sudo tailscale up --authkey "$TAILSCALE_AUTH_KEY"

# Show status
tailscale status
