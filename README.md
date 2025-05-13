# Dotfiles

Dotfiles and installation scripts for my Windows and Linux development environments.

## What's Included

These scripts install and configure the following tools:

- **Git** - Version control system
- **Docker** - Containerization platform
- **Zsh** - Modern shell alternative to Bash
- **Oh-My-Zsh** - Framework for managing Zsh configuration
- **Powerlevel10k** - A theme for Zsh
- **Oh-My-Posh** - Framework for managing powershell configuration (windows only)
- **Powerlevel10k theme** - A theme for oh-my-posh (windows only)
- **Exa** - Modern replacement for `ls` (with aliases set up - linux only)
- **Required fonts** - MesloLGS NF for Powerlevel10k

## Setting Up Windows

The Windows script uses [Scoop](https://scoop.sh/) to manage package installation.

```powershell
# Run from the repository root
.\windows\install.ps1
```

After installation:
1. Restart your terminal for changes to take effect
2. For Zsh with Powerlevel10k, run `zsh` and follow the configuration wizard

## Setting Up Linux

The Linux script uses apt for package management and works best on Ubuntu/Debian-based systems.

```bash
# Make the script executable
chmod +x ./linux/install.sh

# Run from the repository root
./linux/install.sh
```

After installation:
1. Log out and log back in for group changes to take effect (for Docker)
2. Run `p10k configure` to customize your Powerlevel10k theme

## Manual Configuration

If you need to configure anything manually:

- **Powerlevel10k**: Run `p10k configure` in Zsh
- **Exa aliases**: The aliases `ls`, `ll`, and `la` are set up automatically
- **Docker**: On Linux, you may need to log out and back in for group permissions to take effect
