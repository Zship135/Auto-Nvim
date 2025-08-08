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

remove_old_nvim() {
  echo ">>> Removing old Neovim installations..."
  local distro=$(detect_distro)
  
  case "$distro" in
    ubuntu|debian)
      sudo apt remove -y neovim || true
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
  
  # Remove common binary locations
  sudo rm -f /usr/bin/nvim /usr/local/bin/nvim /usr/local/bin/nvim.appimage
}

install_neovim_appimage() {
  echo ">>> Installing Neovim AppImage (>= 0.10.0) ..."
  
  # Create temporary directory
  local temp_dir=$(mktemp -d)
  cd "$temp_dir"
  
  # Download AppImage
  if ! curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage; then
    echo "ERROR: Failed to download Neovim AppImage"
    cd - >/dev/null
    rm -rf "$temp_dir"
    exit 1
  fi
  
  chmod +x nvim.appimage
  
  # Test AppImage execution
  if ./nvim.appimage --version &>/dev/null; then
    echo ">>> AppImage works directly"
    sudo mv nvim.appimage /usr/local/bin/nvim
  else
    echo ">>> AppImage needs FUSE or extraction..."
    
    # Try to install FUSE
    local distro=$(detect_distro)
    case "$distro" in
      ubuntu|debian)
        sudo apt update && sudo apt install -y libfuse2 || true
        ;;
      fedora)
        sudo dnf install -y fuse || true
        ;;
      centos|rhel)
        sudo yum install -y fuse || true
        ;;
      arch|manjaro)
        sudo pacman -S --needed --noconfirm fuse2 || true
        ;;
    esac
    
    # Test again after FUSE installation
    if ./nvim.appimage --version &>/dev/null; then
      echo ">>> AppImage now works with FUSE"
      sudo mv nvim.appimage /usr/local/bin/nvim
    else
      echo ">>> Extracting AppImage (FUSE not available)"
      ./nvim.appimage --appimage-extract >/dev/null
      if [[ -d squashfs-root ]]; then
        sudo mv squashfs-root /opt/nvim
        sudo ln -sf /opt/nvim/AppRun /usr/local/bin/nvim
        rm -f nvim.appimage
      else
        echo "ERROR: Failed to extract AppImage"
        cd - >/dev/null
        rm -rf "$temp_dir"
        exit 1
      fi
    fi
  fi
  
  cd - >/dev/null
  rm -rf "$temp_dir"
  
  # Verify installation
  if nvim --version &>/dev/null; then
    nvim --version | head -n 1
  else
    echo "ERROR: Neovim installation failed"
    exit 1
  fi
}

# Alternative: Install from package manager for newer versions
install_neovim_package() {
  echo ">>> Installing Neovim from package manager..."
  local distro=$(detect_distro)
  
  case "$distro" in
    ubuntu|debian)
      # Add neovim PPA for latest version
      sudo add-apt-repository ppa:neovim-ppa/unstable -y || true
      sudo apt update
      sudo apt install -y neovim
      ;;
    fedora)
      sudo dnf install -y neovim
      ;;
    centos|rhel)
      # Enable EPEL for newer packages
      sudo yum install -y epel-release || true
      sudo yum install -y neovim
      ;;
    arch|manjaro)
      sudo pacman -S --needed --noconfirm neovim
      ;;
    *)
      echo "Package manager installation not supported for this distro, falling back to AppImage"
      return 1
      ;;
  esac
}

ensure_nvim_version() {
  if has_command nvim; then
    local nv_ver
    # More robust version parsing
    nv_ver=$(nvim --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
    
    if [[ -z "$nv_ver" ]]; then
      echo ">>> Cannot determine Neovim version. Reinstalling..."
      remove_old_nvim
      install_neovim_appimage
    elif [[ $(ver "$nv_ver") -lt $(ver "$required_nvim_version") ]]; then
      echo ">>> Neovim version $nv_ver is too old (need >= $required_nvim_version). Upgrading..."
      remove_old_nvim
      # Try package manager first, fallback to AppImage
      if ! install_neovim_package; then
        install_neovim_appimage
      fi
    else
      echo ">>> Neovim $nv_ver already installed and meets requirements."
    fi
  else
    echo ">>> Neovim not found. Installing..."
    # Try package manager first, fallback to AppImage
    if ! install_neovim_package; then
      install_neovim_appimage
    fi
  fi
  
  # Final verification
  if ! has_command nvim; then
    echo "ERROR: Neovim installation failed completely."
    exit 2
  fi
  
  local final_ver
  final_ver=$(nvim --version 2>/dev/null | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
  
  if [[ -z "$final_ver" ]] || [[ $(ver "$final_ver") -lt $(ver "$required_nvim_version") ]]; then
    echo "ERROR: Failed to install Neovim >= $required_nvim_version (got $final_ver)"
    echo "Please install Neovim manually and re-run the script."
    exit 2
  fi
  
  echo ">>> Using Neovim version: $final_ver"
}

install_build_tools() {
  echo ">>> Checking for build tools..."
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
      darwin*)
        if ! xcode-select -p &>/dev/null; then
          echo ">>> Installing Xcode Command Line Tools..."
          xcode-select --install
          echo "Please complete the Xcode installation and re-run the script."
          exit 0
        fi
        ;;
      *)
        echo "WARNING: Please install build tools (gcc, make) manually"
        ;;
    esac
  fi
}

install_pylint() {
  echo ">>> Checking for pylint..."
  if ! has_command pylint; then
    if has_command python3 && has_command pip3; then
      echo ">>> Installing pylint via pip3..."
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
          install_packages python3-pylint || echo "WARNING: pylint not available, install manually if needed"
          ;;
        arch|manjaro)
          install_packages python-pylint
          ;;
        darwin*)
          if has_command brew; then
            brew install pylint
          else
            echo "WARNING: Please install pylint manually"
          fi
          ;;
        *)
          echo "WARNING: Please install pylint manually"
          ;;
      esac
    fi
  fi
}

check_dependencies() {
  echo ">>> Checking dependencies..."
  
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
  
  # Check for basic build tools
  if ! has_command gcc && ! has_command cc && ! has_command clang; then
    echo "ERROR: No C compiler found! Installing build tools..."
    install_build_tools
  fi
  
  if ! has_command make; then
    echo "ERROR: 'make' not found! Installing build tools..."
    install_build_tools
  fi
  
  # Verify again
  if ! has_command make; then
    echo "ERROR: Could not install 'make'. Please install it manually."
    exit 1
  fi
  
  if ! has_command gcc && ! has_command cc && ! has_command clang; then
    echo "ERROR: Could not install a C compiler. Please install gcc, clang, or similar manually."
    exit 1
  fi
}

backup_existing_config() {
  if [ -d "$CONFIG_DIR" ]; then
    local backup_dir="${CONFIG_DIR}.backup.$(date +%Y%m%d_%H%M%S)"
    echo ">>> Backing up existing config to $backup_dir"
    mv "$CONFIG_DIR" "$backup_dir"
  fi
}

rebuild_fzf_native() {
  local fzf_dir="$HOME/.local/share/nvim/lazy/telescope-fzf-native.nvim"
  if [ -d "$fzf_dir" ]; then
    echo ">>> Rebuilding telescope-fzf-native..."
    cd "$fzf_dir"
    make clean 2>/dev/null || true
    if make; then
      echo ">>> telescope-fzf-native built successfully"
    else
      echo "WARNING: Failed to build telescope-fzf-native. Manual intervention may be needed."
    fi
    cd - >/dev/null
  fi
}

install_nvim() {
  echo ">>> Starting Neovim installation and setup..."
  
  # Check dependencies first
  check_dependencies
  
  # Ensure proper Neovim version
  ensure_nvim_version
  
  # Backup existing config if it exists
  backup_existing_config
  
  # Clone the configuration
  echo ">>> Cloning Neovim configuration..."
  if ! git clone "$REPO_URL" "$CONFIG_DIR"; then
    echo "ERROR: Failed to clone configuration repository"
    exit 1
  fi
  
  # Install Lazy.nvim if the config uses it
  if grep -rq "lazy.nvim" "$CONFIG_DIR" 2>/dev/null; then
    echo ">>> Installing Lazy.nvim plugin manager..."
    if [ ! -d "$LAZY_PATH" ]; then
      git clone https://github.com/folke/lazy.nvim.git "$LAZY_PATH"
    fi
  fi
  
  # Install additional tools
  install_pylint
  
  # Show Neovim version
  echo ">>> Installed Neovim version:"
  nvim --version | head -n 1
  
  # Sync plugins
  echo ">>> Syncing Neovim plugins..."
  nvim --headless "+Lazy sync" +qa 2>/dev/null || echo ">>> Plugin sync completed (some warnings are normal)"
  
  # Rebuild native extensions
  rebuild_fzf_native
  
  echo ""
  echo ">>> Neovim setup complete! 🎉"
  echo ">>> Use 'nvim' to launch Neovim with your configuration."
  echo ">>> First startup may take a moment as plugins finish installing."
} 

main_menu() {
  clear
  ascii_art
  script_info
  
  echo "System Information:"
  echo "OS: $(uname -s)"
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Distribution: $(detect_distro)"
  fi
  echo ""
  
  while true; do
    echo "1) Install and set up Neovim automatically"
    echo "q) Quit"
    echo -n ">: "
    read -r choice
    case "$choice" in
      1) install_nvim; break ;;
      q|Q) exit 0 ;;
      *) echo "Invalid choice." ;;
    esac
  done
}

# Handle macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
  # Override some functions for macOS
  install_packages() {
    if has_command brew; then
      brew install "$@"
    else
      echo "ERROR: Homebrew not found. Please install Homebrew first:"
      echo "https://brew.sh"
      exit 1
    fi
  }
  
  install_neovim_package() {
    echo ">>> Installing Neovim via Homebrew..."
    brew install neovim
  }
fi

main_menu
