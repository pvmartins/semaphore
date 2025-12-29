#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status

# Update system packages
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Install required dependencies
echo "Installing required dependencies..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker’s official GPG key
echo "Adding Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "Adding Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
echo "Installing Docker..."
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# Enable and start Docker
echo "Enabling and starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# Verify Docker installation
echo "Verifying Docker installation..."
docker --version
sudo docker run hello-world

# Add user to Docker group (Optional)
echo "Adding user to Docker group..."
sudo usermod -aG docker $USER
newgrp docker

echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Set executable permissions
echo "Setting executable permissions for Docker Compose..."
sudo chmod +x /usr/local/bin/docker-compose

# Verify Docker Compose installation
echo "Verifying Docker Compose installation..."
docker-compose --version

# Restart Docker service
echo "Restarting Docker service..."
sudo systemctl restart docker

echo "Docker and Docker Compose installation completed successfully!"
