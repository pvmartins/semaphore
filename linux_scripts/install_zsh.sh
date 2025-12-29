#!/bin/bash

# Script to install and configure Zsh with Oh My Zsh, plugins, and theme

# Exit on error
set -e

echo "[+] Installing Zsh..."
sudo apt update
sudo apt install -y zsh wget git

echo "[+] Zsh version:"
zsh --version

# Set Zsh as default shell
echo "[+] Setting Zsh as default shell for current user..."
chsh -s $(which zsh)

# Install Oh My Zsh (non-interactive)
echo "[+] Installing Oh My Zsh..."
export RUNZSH=no
sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

# Set theme in ~/.zshrc
echo "[+] Setting Zsh theme to 'jonathan'..."
sed -i 's/^ZSH_THEME=.*/ZSH_THEME="jonathan"/' ~/.zshrc

# Install zsh-autosuggestions plugin
echo "[+] Installing zsh-autosuggestions..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# Install zsh-syntax-highlighting plugin
echo "[+] Installing zsh-syntax-highlighting..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Add plugins to ~/.zshrc
echo "[+] Adding plugins to .zshrc..."
sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

# Restart shell
echo "[+] Restarting shell to apply changes..."
exec zsh
