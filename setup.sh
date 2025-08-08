#!/usr/bin/env bash
set -e

REPO_URL="https://github.com/Zship135/Auto-Nvim.git"
CONFIG_DIR="$HOME/.config/nvim"
LAZY_PATH="$HOME/.local/share/nvim/lazy/lazy.nvim"
required_nvim_version="0.10.0"

ascii_art() {
cat << "EOF"
                          ,%@@@@@@@@@@*            .#                           
                      ,@@@@@@@@@@@@@@@@           &@@@@@@@*                     
                       %@@@@@@@@@@@@@@@@@@@@@@@@&@@@@@@@@@@@@@,                 
                       .@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@,              
                    (@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@.               
         *@@@@(  (@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&                 
       .@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@%               
      #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&%(**(%&@@@@@@@@@@@@@@@@@@@@@@%             
     @@@@@@@@@@@@@@@@@@*,############,.,,/   %###########* @@@@@@@@@.*%@@@&     
    @@@@@@@@@@@@@@@@@@@,(((%%%%%&%((/, ,,,, ,(/(&%%%%%%%/* @@@@@@@@@@@@@@@@@    
    /@@@@@@@@@@@@@@@@@@@& *%&%%%&%/, ,,,,,,. &%%&%%%%%/ /@@@@@@@@@@@@@@@@@@@%   
        #@@@@@@@@@@@@@@.  *%%%%%&%/, ,,,, *@%%%%&%%(*   /@@@@@@@@@@@@@@@@@@@@,  
       .@@@@@@@@@@@@@@.   *%%%%%&%/, ,. &%%%%%%%%/.      *@@@@@@@@@@@@@@@@@@@@  
       #@@@@@@@@@@@@@/    *%%%%%&%/, *@%%%%%%%%/ .,,,*.   &@@@@@@@@@@@@@@@@@@@. 
       @@@@@@@@@@@@@@  (, *%&&&&&%/#%%%&&&%%/, ,,,,,,,,,* .@@@@@@@@@@@@@@@#*    
    /&@@@@@@@@@@@@@@@  .. *%%%%%&%%%%%%%%&/ .,,,,,,,,,,.  ,@@@@@@@@@@@@@#       
 *@@@@@@@@@@@@@@@@@@@/    *%%%%%&%%%%%%*%%,,,,,,,,,,,.    @@@@@@@@@@@@@@,       
 .@@@@@@@@@@@@@@@@@@@@.   *%%%%%&%%%%,    ,   .,.        *@@@@@@@@@@@@@@        
  (@@@@@@@@@@@@@@@@@@@@,  *%&%%%&%#* ./%#,,,%#**/%%**(%%*@@@@@@@@@@@@@@*        
   @@@@@@@@@@@@@@@@@@@@@@ *%%%%%/. ,,*%%., %% . %%   %&,@@@@@@@@@@@@@@@@@@@,    
    @@@@@@@@@@@@@@@@@@@@@*,(##/     .%%(  %%/  %%/  %%(,@@@@@@@@@@@@@@@@@@@@    
     @@@@(,/@@@@@@@@@@@@@@@@@@/       .,,.       %@@@@@@@@@@@@@@@@@@@@@@@@%     
             &@@@@@@@@@@@@@@@@@@@@@@&#/**(%@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*      
               @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&        
                 @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*  %@@@@          
               /@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@*                    
              #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&                        
                 /@@@@@@@@@@@@@&@@@@@@@@@@@@@@@@@@@@@@@@*                       
                     *@@@@@@@(          ,@@@@@@@@@@@@@@@@                       
                          ,#.            #@@@@@@@@@&(.                          
EOF
}

script_info() {
  echo "Auto-Nvim Setup Script"
  echo "Author: Zship135"
  echo "Repo: $REPO_URL"
  echo ""
  echo "This script will help you install and set up Neovim with your custom configuration."
  echo "✨ Ensures Neovim 0.10+ for compatibility with modern plugins"
  echo ""
}

has_command() { command -v "$1" >/dev/null 2>&1; }
ver() { printf "%03d%03d%03d" $(echo "$1" | tr '.' ' '); }

# Detect the Linux distribution
detect_distro() {
  if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    echo "$ID"
  elif [[ -f /etc/redhat-release ]]; then
    echo "rhel"
  elif [[ -f /etc/debian_version ]]; then
    echo "debian"
  else
    echo "unknown"
  fi
}

# Install packages based on distribution
install_packages() {
  local packages=("$@")
  local distro=$(detect_distro)
  
  case "$distro" in
    ubuntu|debian)
      sudo apt update && sudo apt install -y "${packages[@]}"
      ;;
    fedora)
      sudo dnf install -y "${packages[@]}"
      ;;
    centos|rhel)
      sudo yum install -y "${packages[@]}"
      ;;
    arch|manjaro)
      sudo pacman -S --needed --noconfirm "${packages[@]}"
      ;;
    *)
      echo "WARNING: Unknown distribution. Please install these packages manually: ${packages[*]}"
      return 1
      ;;
  esac
}

check_current_nvim_version() {
    if has_command nvim; then
        local current_ver
        current_ver=$(nvim --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
        
        if [[ -n "$current_ver" ]] && [[ $(ver "$current_ver") -ge $(ver "$required_nvim_version") ]]; then
            echo "✅ Neovim $current_ver meets requirements (>= $required_nvim_version)"
            return 0
        else
            echo "⚠️ Neovim $current_ver is insufficient (need >= $required_nvim_version)"
            return 1
        fi
    else
        echo "❌ Neovim not found"
        return 1
    fi
}

complete_nvim_removal() {
    echo "🧹 Completely removing all existing Neovim installations..."
    
    # Remove from various package managers
    local distro=$(detect_distro)
    case "$distro" in
        ubuntu|debian)
            sudo apt remove -y neovim neovim-runtime || true
            ;;
        fedora)
            sudo dnf remove -y neovim || true
            ;;
        centos|rhel)
            sudo yum remove -y neovim || true
            ;;
        arch|manjaro)
            sudo pacman -R --noconfirm neovim || true
            ;;
    esac
    
    # Remove snap/flatpak versions
    sudo snap remove nvim || true
    sudo flatpak uninstall -y io.neovim.nvim || true
    
    # Remove binaries from all common locations
    sudo rm -f /usr/bin/nvim
    sudo rm -f /usr/local/bin/nvim
    sudo rm -f /usr/local/bin/nvim.appimage
    sudo rm -f /opt/nvim/bin/nvim
    sudo rm -rf /opt/nvim
    sudo rm -f ~/.local/bin/nvim
    
    # Remove any other nvim binaries found in PATH
    which nvim 2>/dev/null | xargs sudo rm -f || true
    
    echo "✅ Old Neovim installations removed"
}

install_nvim_dependencies() {
    echo "📦 Installing Neovim dependencies..."
    local distro=$(detect_distro)
    
    case "$distro" in
        ubuntu|debian)
            sudo apt update
            sudo apt install -y curl wget unzip fuse libfuse2 || {
                echo "⚠️ Some dependencies might not be available, continuing..."
            }
            ;;
        fedora)
            sudo dnf install -y curl wget unzip fuse || true
            ;;
        centos|rhel)
            sudo yum install -y curl wget unzip fuse || true
            ;;
        arch|manjaro)
            sudo pacman -S --needed --noconfirm curl wget unzip fuse2 || true
            ;;
    esac
}

install_nvim_appimage() {
    echo "🚀 Installing Neovim via AppImage..."
    
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    echo "📥 Downloading latest Neovim AppImage..."
    if ! curl -L -o nvim.appimage https://github.com/neovim/neovim/releases/latest/download/nvim.appimage; then
        echo "❌ Failed to download AppImage"
        cd - >/dev/null
        rm -rf "$temp_dir"
        return 1
    fi
    
    chmod +x nvim.appimage
    
    # Test if AppImage works directly
    if ./nvim.appimage --version &>/dev/null; then
        echo "✅ AppImage works directly"
        sudo mv nvim.appimage /usr/local/bin/nvim
    else
        echo "🔧 AppImage needs extraction (FUSE not available)..."
        ./nvim.appimage --appimage-extract &>/dev/null || {
            echo "❌ Failed to extract AppImage"
            cd - >/dev/null
            rm -rf "$temp_dir"
            return 1
        }
        
        if [[ -d squashfs-root ]]; then
            sudo rm -rf /opt/nvim
            sudo mv squashfs-root /opt/nvim
            sudo ln -sf /opt/nvim/AppRun /usr/local/bin/nvim
            echo "✅ Extracted AppImage installed to /opt/nvim"
        else
            echo "❌ AppImage extraction failed"
            cd - >/dev/null
            rm -rf "$temp_dir"
            return 1
        fi
    fi
    
    cd - >/dev/null
    rm -rf "$temp_dir"
    
    # Test installation
    if nvim --version &>/dev/null; then
        local new_ver
        new_ver=$(nvim --version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
        echo "✅ AppImage installation successful: $new_ver"
        return 0
    else
        echo "❌ AppImage installation failed"
        return 1
    fi
}

install_nvim_prebuilt() {
    echo "🚀 Installing Neovim via prebuilt binary..."
    
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    echo "📥 Downloading prebuilt Neovim binary..."
    if ! curl -L -o nvim-linux64.tar.gz https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz; then
        echo "❌ Failed to download prebuilt binary"
        cd - >/dev/null
        rm -rf "$temp_dir"
        return 1
    fi
    
    echo "📦 Extracting binary..."
    tar xzf nvim-linux64.tar.gz || {
        echo "❌ Failed to extract binary"
        cd - >/dev/null
        rm -rf "$temp_dir"
        return 1
    }
    
    if [[ -d nvim-linux64 ]]; then
        sudo rm -rf /opt/nvim
        sudo mv nvim-linux64 /opt/nvim
        sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim
        echo "✅ Prebuilt binary installed to /opt/nvim"
    else
        echo "❌ Binary extraction failed"
        cd - >/dev/null
        rm -rf "$temp_dir"
        return 1
    fi
    
    cd - >/dev/null
    rm -rf "$temp_dir"
    
    # Test installation
    if nvim --version &>/dev/null; then
        local new_ver
        new_ver=$(nvim --version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
        echo "✅ Prebuilt installation successful: $new_ver"
        return 0
    else
        echo "❌ Prebuilt installation failed"
        return 1
    fi
}

install_nvim_snap() {
    echo "🚀 Installing Neovim via Snap..."
    
    if ! has_command snap; then
        echo "📦 Installing snapd..."
        install_packages snapd
        # Ensure snap service is running
        sudo systemctl enable --now snapd || true
    fi
    
    sudo snap install nvim --classic || {
        echo "❌ Snap installation failed"
        return 1
    }
    
    # Create symlink for consistent access
    sudo ln -sf /snap/bin/nvim /usr/local/bin/nvim || true
    
    # Test installation
    if nvim --version &>/dev/null; then
        local new_ver
        new_ver=$(nvim --version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
        echo "✅ Snap installation successful: $new_ver"
        return 0
    else
        echo "❌ Snap installation failed"
        return 1
    fi
}

ensure_path_priority() {
    echo "🔧 Ensuring /usr/local/bin has PATH priority..."
    
    # Add to PATH with priority if not already there
    if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
        echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
        echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.profile
        if [[ -f ~/.zshrc ]]; then
            echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.zshrc
        fi
        export PATH="/usr/local/bin:$PATH"
        echo "✅ Added /usr/local/bin to PATH with priority"
    fi
}

ensure_nvim_version() {
    echo "🔍 Checking Neovim version requirements..."
    
    if check_current_nvim_version; then
        return 0  # Version is already sufficient
    fi
    
    echo ""
    echo "🛠️ Installing Neovim $required_nvim_version or higher..."
    
    # Complete removal of old installations
    complete_nvim_removal
    
    # Install dependencies
    install_nvim_dependencies
    
    # Ensure PATH priority
    ensure_path_priority
    
    # Try installation methods in order of reliability
    echo ""
    if install_nvim_prebuilt; then
        echo "🎉 Neovim installed successfully via prebuilt binary!"
    elif install_nvim_appimage; then
        echo "🎉 Neovim installed successfully via AppImage!"
    elif install_nvim_snap; then
        echo "🎉 Neovim installed successfully via Snap!"
    else
        echo "❌ All automatic installation methods failed!"
        echo ""
        echo "Please install Neovim 0.10+ manually:"
        echo "1. Visit: https://github.com/neovim/neovim/releases"
        echo "2. Download nvim-linux64.tar.gz"
        echo "3. Extract: tar xzf nvim-linux64.tar.gz"
        echo "4. Move: sudo mv nvim-linux64 /opt/nvim"
        echo "5. Link: sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim"
        exit 1
    fi
    
    # Reload PATH
    export PATH="/usr/local/bin:$PATH"
    
    # Final verification
    echo ""
    echo "🔍 Verifying installation..."
    if check_current_nvim_version; then
        echo "✅ Neovim installation verified successfully!"
    else
        echo "❌ Installation verification failed"
        echo "💡 Try closing and reopening your terminal, then run: nvim --version"
        echo "💡 If that doesn't work, manual installation may be required"
        exit 1
    fi
}

install_build_tools() {
    echo "🔨 Checking for build tools..."
    local distro=$(detect_distro)
    
    if ! has_command gcc && ! has_command make; then
        case "$distro" in
            ubuntu|debian)
                install_packages build-essential
                ;;
            fedora)
                install_packages gcc make
                ;;
            centos|rhel)
                install_packages gcc make
                ;;
            arch|manjaro)
                install_packages base-devel
                ;;
            *)
                echo "WARNING: Please install build tools (gcc, make) manually"
                ;;
        esac
    fi
    
    # Verify build tools are available
    if ! has_command make; then
        echo "ERROR: Could not install 'make'. Please install it manually."
        exit 1
    fi
    
    if ! has_command gcc && ! has_command cc && ! has_command clang; then
        echo "ERROR: Could not install a C compiler. Please install gcc, clang, or similar manually."
        exit 1
    fi
    
    echo "✅ Build tools are available"
}

install_python_tools() {
    echo "🐍 Installing Python development tools..."
    
    # Ensure Python and pip are available
    if ! has_command python3; then
        echo "📦 Installing Python3..."
        install_packages python3 python3-pip
    fi
    
    if ! has_command pip3; then
        echo "📦 Installing pip3..."
        install_packages python3-pip
    fi
    
    # Install pylint
    if ! has_command pylint; then
        echo ">>> Installing pylint..."
        if has_command pip3; then
            pip3 install --user pylint
        else
            local distro=$(detect_distro)
            case "$distro" in
                ubuntu|debian)
                    install_packages python3-pylint
                    ;;
                fedora)
                    install_packages pylint
                    ;;
                centos|rhel)
                    install_packages python3-pylint || true
                    ;;
                arch|manjaro)
                    install_packages python-pylint
                    ;;
                *)
                    echo "WARNING: Please install pylint manually if needed"
                    ;;
            esac
        fi
    fi
    
    # Install pyright language server
    echo "🔧 Installing language servers..."
    if ! has_command pyright-langserver && ! has_command pyright; then
        echo ">>> Installing pyright (Python LSP)..."
        if has_command npm; then
            npm install -g pyright
        elif has_command pip3; then
            pip3 install --user pyright
        else
            echo "⚠️ Cannot install pyright - npm or pip3 required"
            echo "💡 Install Node.js or ensure pip3 is available"
        fi
    fi
    
    echo "✅ Python tools installation completed"
}

check_dependencies() {
    echo "📋 Checking system dependencies..."
    
    # Check for git
    if ! has_command git; then
        echo ">>> Installing git..."
        install_packages git
    fi
    
    # Check for curl
    if ! has_command curl; then
        echo ">>> Installing curl..."
        install_packages curl
    fi
    
    echo "✅ System dependencies satisfied"
}

backup_existing_config() {
    if [ -d "$CONFIG_DIR" ]; then
        local backup_dir="${CONFIG_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
        echo "💾 Backing up existing config to $backup_dir"
        mv "$CONFIG_DIR" "$backup_dir"
        echo "✅ Backup created: $backup_dir"
    fi
}

rebuild_fzf_native() {
    local fzf_dir="$HOME/.local/share/nvim/lazy/telescope-fzf-native.nvim"
    if [ -d "$fzf_dir" ]; then
        echo "🔧 Rebuilding telescope-fzf-native..."
        cd "$fzf_dir"
        make clean 2>/dev/null || true
        if make; then
            echo "✅ telescope-fzf-native built successfully"
        else
            echo "⚠️ Failed to build telescope-fzf-native (this is usually not critical)"
        fi
        cd - >/dev/null
    fi
}

install_nvim() {
    echo "🚀 Starting comprehensive Neovim installation and setup..."
    echo ""
    
    # 1. Check and install system dependencies
    check_dependencies
    
    # 2. Ensure Neovim 0.10+ (this is the critical part!)
    ensure_nvim_version
    
    # 3. Install build tools for native plugin compilation
    install_build_tools
    
    # 4. Backup existing config if present
    backup_existing_config
    
    # 5. Clone the Neovim configuration
    echo "📦 Cloning Neovim configuration..."
    if ! git clone "$REPO_URL" "$CONFIG_DIR"; then
        echo "❌ Failed to clone configuration repository"
        exit 1
    fi
    echo "✅ Configuration cloned successfully"
    
    # 6. Install Lazy.nvim plugin manager if needed
    if grep -rq "lazy.nvim" "$CONFIG_DIR" 2>/dev/null; then
        echo "📦 Installing Lazy.nvim plugin manager..."
        if [ ! -d "$LAZY_PATH" ]; then
            git clone https://github.com/folke/lazy.nvim.git "$LAZY_PATH"
            echo "✅ Lazy.nvim installed"
        else
            echo "✅ Lazy.nvim already present"
        fi
    fi
    
install_language_servers() {
    echo "🌐 Installing common language servers..."
    
    # Check if Node.js/npm is available (needed for many LSPs)
    local need_nodejs=false
    
    if ! has_command node || ! has_command npm; then
        echo "📦 Installing Node.js and npm (required for many language servers)..."
        local distro=$(detect_distro)
        case "$distro" in
            ubuntu|debian)
                # Install NodeSource repository for latest Node.js
                curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - || true
                install_packages nodejs
                ;;
            fedora)
                install_packages nodejs
                ;;
            centos|rhel)
                install_packages nodejs npm
                ;;
            arch|manjaro)
                install_packages nodejs npm
                ;;
            *)
                echo "⚠️ Please install Node.js manually for language server support"
                ;;
        esac
        need_nodejs=true
    fi
    
    # Install common language servers via npm
    if has_command npm; then
        echo ">>> Installing language servers via npm..."
        
        # Python
        if ! has_command pyright-langserver && ! has_command pyright; then
            echo "  • Installing pyright (Python)"
            npm install -g pyright || echo "  ⚠️ Failed to install pyright"
        fi
        
        # TypeScript/JavaScript
        if ! has_command typescript-language-server; then
            echo "  • Installing typescript-language-server"
            npm install -g typescript-language-server typescript || echo "  ⚠️ Failed to install typescript-language-server"
        fi
        
        # HTML/CSS/JSON
        if ! has_command vscode-langservers-extracted; then
            echo "  • Installing vscode language servers (HTML, CSS, JSON)"
            npm install -g vscode-langservers-extracted || echo "  ⚠️ Failed to install vscode-langservers-extracted"
        fi
        
        # Bash
        if ! has_command bash-language-server; then
            echo "  • Installing bash-language-server"
            npm install -g bash-language-server || echo "  ⚠️ Failed to install bash-language-server"
        fi
        
        # Tailwind CSS (if you use it)
        if ! has_command tailwindcss-language-server; then
            echo "  • Installing tailwindcss-language-server"
            npm install -g @tailwindcss/language-server || echo "  ⚠️ Failed to install tailwindcss-language-server"
        fi
    fi
    
    # Add npm global bin to PATH
    if has_command npm; then
        local npm_bin
        npm_bin=$(npm bin -g 2>/dev/null || echo "$HOME/.npm-global/bin")
        if [[ -d "$npm_bin" ]] && [[ ":$PATH:" != *":$npm_bin:"* ]]; then
            echo "export PATH=\"$npm_bin:\$PATH\"" >> ~/.bashrc
            echo "export PATH=\"$npm_bin:\$PATH\"" >> ~/.profile
            if [[ -f ~/.zshrc ]]; then
                echo "export PATH=\"$npm_bin:\$PATH\"" >> ~/.zshrc
            fi
            export PATH="$npm_bin:$PATH"
            echo "✅ Added npm global bin directory to PATH"
        fi
    fi
    
    echo "✅ Language server installation completed"
    
    if [[ "$need_nodejs" == "true" ]]; then
        echo "💡 Note: You may need to restart your terminal for Node.js PATH changes to take effect"
    fi
}
    
    # 8. Show final Neovim version
    echo ""
    echo "📋 Installation Summary:"
    echo "========================"
    nvim --version | head -n 3
    echo ""
    
    # 9. Sync plugins (this may take a while)
    echo "🔄 Syncing Neovim plugins (this may take a few minutes)..."
    nvim --headless "+Lazy sync" +qa 2>/dev/null || {
        echo "⚠️ Plugin sync completed with some warnings (this is normal for first-time setup)"
    }
    echo "✅ Plugin sync completed"
    
    # 10. Rebuild native extensions
    rebuild_fzf_native
    
    echo ""
    echo "🎉 ==============================================="
    echo "🎉 Neovim setup completed successfully!"
    echo "🎉 ==============================================="
    echo ""
    echo "✨ What's been installed:"
    echo "   • Neovim $(nvim --version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"
    echo "   • Your custom configuration from $REPO_URL"
    echo "   • Lazy.nvim plugin manager"
    echo "   • All required plugins and dependencies"
    echo ""
    echo "🚀 To get started:"
    echo "   1. Close and reopen your terminal (to ensure PATH is updated)"
    echo "   2. Run: nvim"
    echo ""
    echo "💡 Note: First startup may take a moment as final plugin setup completes."
    echo ""
} 

main_menu() {
    clear
    ascii_art
    script_info
    
    echo "🖥️  System Information:"
    echo "   OS: $(uname -s)"
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "   Distribution: $(detect_distro)"
    fi
    echo "   Required Neovim: >= $required_nvim_version"
    
    if has_command nvim; then
        local current_ver
        current_ver=$(nvim --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
        if [[ -n "$current_ver" ]]; then
            echo "   Current Neovim: $current_ver"
            if [[ $(ver "$current_ver") -ge $(ver "$required_nvim_version") ]]; then
                echo "   Status: ✅ Version compatible"
            else
                echo "   Status: ⚠️ Upgrade required"
            fi
        fi
    else
        echo "   Current Neovim: Not installed"
        echo "   Status: 📦 Installation required"
    fi
    
    echo ""
    
    while true; do
        echo "🎯 Choose an option:"
        echo "   1) Install and set up Neovim automatically"
        echo "   q) Quit"
        echo -n "   >: "
        read -r choice
        case "$choice" in
            1) install_nvim; break ;;
            q|Q) exit 0 ;;
            *) echo "   ❌ Invalid choice. Please try again." ;;
        esac
    done
}

# Handle macOS specific overrides
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Override functions for macOS
    install_packages() {
        if has_command brew; then
            brew install "$@"
        else
            echo "❌ Homebrew not found. Please install Homebrew first:"
            echo "https://brew.sh"
            exit 1
        fi
    }
    
    complete_nvim_removal() {
        echo "🧹 Removing existing Neovim installations on macOS..."
        brew uninstall neovim || true
        sudo rm -f /usr/local/bin/nvim
        sudo rm -f /opt/homebrew/bin/nvim
        sudo rm -rf /opt/nvim
    }
    
    install_nvim_prebuilt() {
        echo "🚀 Installing Neovim via Homebrew (macOS)..."
        if brew install neovim; then
            local new_ver
            new_ver=$(nvim --version | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
            echo "✅ Homebrew installation successful: $new_ver"
            return 0
        else
            echo "❌ Homebrew installation failed"
            return 1
        fi
    }
    
    install_build_tools() {
        if ! xcode-select -p &>/dev/null; then
            echo ">>> Installing Xcode Command Line Tools..."
            xcode-select --install
            echo "⏳ Please complete the Xcode installation and re-run the script."
            exit 0
        fi
        echo "✅ Xcode Command Line Tools are available"
    }
fi

main_menu
