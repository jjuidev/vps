#!/bin/bash
set -e

echo "💡 Setup zsh, Oh My Zsh and plugins..."

# Install zsh if not installed
if ! command -v zsh >/dev/null 2>&1; then
  echo "📦 Installing zsh..."
  sudo apt install -y zsh
else
  echo "✅ Zsh is already installed ($(zsh --version))"
fi

# Install Oh My Zsh if not installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "📦 Installing Oh My Zsh..."
  export RUNZSH=no
  export CHSH=no
  export KEEP_ZSHRC=yes
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "✅ Oh My Zsh is already installed, skipping installation."
fi

# Install plugins if not installed
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

[ ! -d "${ZSH_CUSTOM}/plugins/zsh-autosuggestions" ] && \
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM}/plugins/zsh-autosuggestions

[ ! -d "${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting" ] && \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM}/plugins/zsh-syntax-highlighting

# Add plugins to ~/.zshrc if not installed
if ! grep -q "zsh-autosuggestions" ~/.zshrc; then
  echo "🔧 Update ~/.zshrc with new plugins..."
  sed -i 's/^plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc || true
fi

# Set zsh as default shell
CURRENT_SHELL=$(basename "$SHELL")
if [ "$CURRENT_SHELL" != "zsh" ]; then
  echo "🔁 Setting zsh as default shell..."
  sudo chsh -s "$(which zsh)" "$USER" || true
else
  echo "✅ Default shell is already zsh"
fi

# Load zshrc to apply immediately
if [ -f ~/.zshrc ]; then
  echo "🔄 Loading ~/.zshrc..."
  # Use zsh -c to load config without exiting session
  zsh -ic "source ~/.zshrc; echo '✨ Zsh config reloaded!'" || true
fi

# Execute zsh to apply immediately
exec zsh

echo "✅ Setup zsh, Oh My Zsh and plugins completed!"
zsh --version