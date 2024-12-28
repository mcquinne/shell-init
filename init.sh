#!/bin/bash

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install zsh on various OS types
install_zsh() {
    # Use sudo if not root
    SUDO=""
    if [[ "root" != "$(whoami)" ]]; then
        SUDO="sudo"
    fi

    # Detect the operating system
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if ! command_exists brew; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew install zsh
    elif command_exists yum; then
        # Amazon Linux or other yum-based systems
        $SUDO yum update -y
        $SUDO yum install -y zsh util-linux-user findutils git
    elif command_exists apt-get; then
        # Debian-based systems
        $SUDO apt-get update
        $SUDO apt-get install -y zsh
    else
        echo "Unsupported operating system"
        exit 1
    fi

    # Set Zsh as the default shell
    if [[ "$SHELL" != *"zsh"* ]]; then
        chsh -s "$(command -v zsh)"
    fi
}

if ! command_exists zsh; then
    install_zsh
fi

# Set up XDG vars and dirs
export XDG_BIN_HOME="$HOME/.local/bin"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
mkdir -p $XDG_BIN_HOME $XDG_CACHE_HOME $XDG_CONFIG_HOME $XDG_DATA_HOME $XDG_STATE_HOME
export PATH="$XDG_BIN_HOME:$PATH"

# Install Antigen if not already installed
if [ ! -f "$XDG_CACHE_HOME/antigen.zsh" ]; then
    curl -L git.io/antigen > "$XDG_CACHE_HOME/antigen.zsh"
fi

# Create .zshrc configuration file
cat << EOF > ~/.zshrc
export XDG_BIN_HOME="$HOME/.local/bin"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export PATH="$XDG_BIN_HOME:$PATH"

# Load Antigen
source "$XDG_CACHE_HOME/antigen.zsh"

# Load Oh My Zsh library
antigen use oh-my-zsh

# Load bundles
antigen bundle git
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-syntax-highlighting

# Set theme
antigen theme robbyrussell

# Apply Antigen configurations
antigen apply
EOF

echo "Shell initialized. Restart your terminal or run 'zsh' to start using the new shell."
