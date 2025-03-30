#!/bin/bash
# Debian Server Setup Script
# Designed for minimal Debian servers without common utilities
# Run in sudo

echo "Starting Debian server setup..."

# Basic server upgrades and essentials
echo "Installing core system packages..."
apt-get update
apt-get install -y \
  sudo \
  zsh \
  git \
  curl \
  wget \
  vim \
  tmux \
  software-properties-common \
  build-essential \
  fuse

# Install basic development tools
echo "Installing development packages..."
apt-get install -y \
  nvm \
  ripgrep \
  fd-find \
  fzf \
  bat \
  nodejs \
  tealdeer

# Install neovim AppImage
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-arm64.appimage
chmod u+x nvim-linux-arm64.appimage
mkdir -p /opt/nvim
mv nvim-linux-arm64.appimage /opt/nvim/nvim
echo 'export PATH="$PATH:/opt/nvim"' >>~/.zshrc

# Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.2/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# Create local bin directory for symlinks
mkdir -p $HOME/.local/bin
echo 'export PATH="$HOME/.local/bin:$PATH"' >>$HOME/.profile
source $HOME/.profile

# Create symlinks for different binary names
if command -v fdfind >/dev/null; then
  ln -sf $(which fdfind) $HOME/.local/bin/fd
fi

# Setup shell environment
echo "Setting up shell environment..."

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "Oh My Zsh is already installed."
fi

# Install zsh plugins
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"

# Install zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  echo "Installing zsh-autosuggestions..."
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
  echo "zsh-autosuggestions is already installed."
fi

# Install zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  echo "Installing zsh-syntax-highlighting..."
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
  echo "zsh-syntax-highlighting is already installed."
fi

# Install powerlevel10k theme
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
  echo "Installing powerlevel10k..."
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
else
  echo "powerlevel10k is already installed."
fi

# Create/update .zshrc
cat >$HOME/.zshrc <<'EOF'
# Path to the oh-my-zsh installation.

export ZSH="$HOME/.oh-my-zsh"

# Set powerlevel10k theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set plugins
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# User configuration
export PATH="$HOME/.local/bin:$PATH"

# Preferred editor
export EDITOR='nvim'

# History settings
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# Aliases
alias vi='nvim'
alias vim='nvim'
EOF

# Create basic tmux configuration
cat >$HOME/.tmux.conf <<'EOF'
# Use C-a as prefix
unbind C-b
set -g prefix C-s
bind C-s send-prefix

# Improve colors
set -g default-terminal "screen-256color"

# Increase history limit
set -g history-limit 50000

# Start window numbering at 1
set -g base-index 1
setw -g pane-base-index 1

# Basic mouse support
set -g mouse on
EOF

# Set zsh as default shell
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s $(which zsh)
  echo "Set zsh as default shell. You'll need to log out and back in for this to take effect."
fi

# Setup inputrc for better tab completion in bash (fallback)
cat >$HOME/.inputrc <<'EOF'
# Make Tab autocomplete regardless of filename case
set completion-ignore-case on

# List all matches in case multiple possible completions are possible
set show-all-if-ambiguous on

# Use the text that has already been typed as the prefix for searching commands
"\e[A": history-search-backward
"\e[B": history-search-forward

# Show extra file information when completing
set visible-stats on

# Allow UTF-8 input and output
set input-meta on
set output-meta on
set convert-meta off
EOF

echo "====================================="
echo "Minimal server setup complete! Please log out and log back in to use zsh."
echo "If you want to keep using bash for now, run: source ~/.inputrc"
echo "====================================="
