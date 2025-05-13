#!/usr/bin/env bash

set -e

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
FONTS_DIR="$HOME/.local/share/fonts"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Read package list
if command -v jq >/dev/null 2>&1; then
    echo -e "${BLUE}jq is already installed${NC}"
else
    echo -e "${YELLOW}Installing jq...${NC}"
    sudo apt-get update
    sudo apt-get install -y jq
fi

# Parse packages.json
APT_PACKAGES=$(jq -r '.apt[]' "$SCRIPT_DIR/packages.json")
EXTERNAL_PACKAGES=$(jq -r '.external[]' "$SCRIPT_DIR/packages.json")
FONTS=$(jq -r '.fonts[]' "$SCRIPT_DIR/packages.json")

# Update package lists
echo -e "${BLUE}Updating package lists...${NC}"
sudo apt-get update

# Install Git if not already installed
if command -v git >/dev/null 2>&1; then
    echo -e "${BLUE}Git is already installed${NC}"
else
    echo -e "${YELLOW}Installing Git...${NC}"
    sudo apt-get install -y git
fi

# Install Docker repository dependencies
echo -e "${YELLOW}Installing Docker prerequisites...${NC}"
sudo apt-get install -y ca-certificates curl gnupg

# Add Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Set up the repository
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update apt package index
sudo apt-get update

# Install packages from APT
for package in $APT_PACKAGES; do
    if [ "$package" != "docker-ce" ] && [ "$package" != "docker-ce-cli" ] && [ "$package" != "containerd.io" ] && [ "$package" != "docker-buildx-plugin" ] && [ "$package" != "docker-compose-plugin" ]; then
        if dpkg -l | grep -q "^ii  $package "; then
            echo -e "${BLUE}$package is already installed${NC}"
        else
            echo -e "${YELLOW}Installing $package...${NC}"
            sudo apt-get install -y "$package"
        fi
    fi
done

# Install Docker
echo -e "${YELLOW}Installing Docker...${NC}"
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker "$USER"
echo -e "${GREEN}Added $USER to the docker group${NC}"
echo -e "${YELLOW}NOTE: You'll need to log out and back in for this to take effect${NC}"

# Add eza alias to zsh config if it doesn't exist
if ! grep -q "alias ls='eza'" "$HOME/.zshrc" 2>/dev/null; then
    echo -e "${YELLOW}Adding eza alias to zsh config...${NC}"
    echo 'alias ls="eza"' >> "$HOME/.zshrc"
    echo 'alias ll="eza -l"' >> "$HOME/.zshrc"
    echo 'alias la="eza -la"' >> "$HOME/.zshrc"
    echo -e "${GREEN}Added eza aliases to zsh config${NC}"
fi

# Install oh-my-zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "${YELLOW}Installing oh-my-zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo -e "${GREEN}oh-my-zsh installed${NC}"
else
    echo -e "${BLUE}oh-my-zsh is already installed${NC}"
fi

# Install powerlevel10k if not already installed
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    echo -e "${YELLOW}Installing powerlevel10k theme...${NC}"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
    # Set ZSH_THEME="powerlevel10k/powerlevel10k" in ~/.zshrc
    sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/' "$HOME/.zshrc"
    echo -e "${GREEN}powerlevel10k theme installed${NC}"
else
    echo -e "${BLUE}powerlevel10k theme is already installed${NC}"
fi

# Create fonts directory if it doesn't exist
mkdir -p "$FONTS_DIR"

# Install MesloLGS NF fonts
echo -e "${YELLOW}Installing MesloLGS NF fonts...${NC}"
for type in Regular Bold Italic 'Bold Italic'; do
    file="MesloLGS NF ${type}.ttf"
    url="https://github.com/romkatv/powerlevel10k-media/raw/master/${file// /%20}"
    target="$FONTS_DIR/${file}"
    
    if [ ! -f "$target" ]; then
        echo -e "${YELLOW}Downloading $file...${NC}"
        curl -fsSL -o "$target" "$url"
    else
        echo -e "${BLUE}Font $file already exists${NC}"
    fi
done

# Update font cache
echo -e "${YELLOW}Updating font cache...${NC}"
fc-cache -f

# Set Zsh as default shell if it's not already
if [ "$SHELL" != "$(which zsh)" ]; then
    echo -e "${YELLOW}Setting Zsh as default shell...${NC}"
    chsh -s "$(which zsh)"
    echo -e "${GREEN}Zsh set as default shell${NC}"
else
    echo -e "${BLUE}Zsh is already the default shell${NC}"
fi

echo -e "${GREEN}Installation complete!${NC}"
echo -e "${YELLOW}Please log out and log back in to apply all changes.${NC}"
echo -e "${YELLOW}After logging back in, run 'p10k configure' to set up your powerlevel10k theme.${NC}"