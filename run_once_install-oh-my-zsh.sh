#!/bin/bash

set -e

OMZ_DIR="$HOME/.oh-my-zsh"
CUSTOM_DIR="$OMZ_DIR/custom"

echo "🚀 Installing Oh My Zsh and plugins..."

# Function to download and extract archive
download_and_extract() {
    local url="$1"
    local dest="$2"
    local temp_dir="/tmp/chezmoi-install-$(basename "$dest" | sed 's/^\.//g' | tr '/' '-')"
    
    echo "📦 Installing $(basename "$dest")..."
    
    # Create temporary directory
    mkdir -p "$temp_dir"
    
    # Create destination directory
    mkdir -p "$dest"
    
    # Download and extract
    curl -fsSL "$url" | tar -xz -C "$temp_dir" --strip-components=1
    
    # Copy files to destination (excluding cache directories)
    rsync -av --exclude='cache/' "$temp_dir/" "$dest/"
    
    # Cleanup
    rm -rf "$temp_dir"
}

# Install Oh My Zsh
if [ ! -d "$OMZ_DIR" ]; then
    temp_dir="/tmp/chezmoi-install-oh-my-zsh"
    mkdir -p "$temp_dir"
    echo "📦 Installing Oh My Zsh..."
    
    # Download and extract oh-my-zsh
    curl -fsSL "https://github.com/ohmyzsh/ohmyzsh/archive/master.tar.gz" | \
        tar -xz -C "$temp_dir" --strip-components=1
    
    # Create destination and copy files (excluding cache)
    mkdir -p "$OMZ_DIR"
    rsync -av --exclude='cache/' "$temp_dir/" "$OMZ_DIR/"
    
    # Cleanup
    rm -rf "$temp_dir"
else
    echo "✅ Oh My Zsh already installed"
fi

# Create custom directories
mkdir -p "$CUSTOM_DIR/plugins"
mkdir -p "$CUSTOM_DIR/themes"

# Install zsh-syntax-highlighting
if [ ! -d "$CUSTOM_DIR/plugins/zsh-syntax-highlighting" ]; then
    temp_dir="/tmp/chezmoi-install-syntax-highlighting"
    mkdir -p "$temp_dir"
    echo "📦 Installing zsh-syntax-highlighting..."
    
    curl -fsSL "https://github.com/zsh-users/zsh-syntax-highlighting/archive/master.tar.gz" | \
        tar -xz -C "$temp_dir" --strip-components=1
    
    # Copy only specific files (matching your include pattern)
    mkdir -p "$CUSTOM_DIR/plugins/zsh-syntax-highlighting"
    cp "$temp_dir"/*.zsh "$CUSTOM_DIR/plugins/zsh-syntax-highlighting/" 2>/dev/null || true
    cp "$temp_dir"/.version "$CUSTOM_DIR/plugins/zsh-syntax-highlighting/" 2>/dev/null || true
    cp "$temp_dir"/.revision-hash "$CUSTOM_DIR/plugins/zsh-syntax-highlighting/" 2>/dev/null || true
    cp -r "$temp_dir"/highlighters "$CUSTOM_DIR/plugins/zsh-syntax-highlighting/" 2>/dev/null || true
    
    rm -rf "$temp_dir"
else
    echo "✅ zsh-syntax-highlighting already installed"
fi

# Install zsh-autosuggestions
if [ ! -d "$CUSTOM_DIR/plugins/zsh-autosuggestions" ]; then
    download_and_extract "https://github.com/zsh-users/zsh-autosuggestions/archive/master.tar.gz" "$CUSTOM_DIR/plugins/zsh-autosuggestions"
else
    echo "✅ zsh-autosuggestions already installed"
fi

# Install powerlevel10k theme
if [ ! -d "$CUSTOM_DIR/themes/powerlevel10k" ]; then
    temp_dir="/tmp/chezmoi-install-powerlevel10k"
    mkdir -p "$temp_dir"
    echo "📦 Installing powerlevel10k theme..."
    
    curl -fsSL "https://github.com/romkatv/powerlevel10k/archive/master.tar.gz" | \
        tar -xz -C "$temp_dir" --strip-components=1
    
    # Copy files excluding .zwc files
    mkdir -p "$CUSTOM_DIR/themes/powerlevel10k"
    rsync -av --exclude='*.zwc' "$temp_dir/" "$CUSTOM_DIR/themes/powerlevel10k/"
    
    rm -rf "$temp_dir"
else
    echo "✅ powerlevel10k already installed"
fi

echo "✨ Oh My Zsh installation complete!"
echo ""
echo "📝 Next steps:"
echo "   1. Update your .zshrc to use these plugins:"
echo "      plugins=(git zsh-syntax-highlighting zsh-autosuggestions)"
echo "   2. Set your theme:"
echo "      ZSH_THEME=\"powerlevel10k/powerlevel10k\""
echo "   3. Restart your shell or run: source ~/.zshrc"
echo ""
echo "🔄 To update later, run:"
echo "   rm -rf ~/.oh-my-zsh && chezmoi apply"