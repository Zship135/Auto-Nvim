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

remove_old_nvim() {
  echo ">>> Removing old Neovim (apt and legacy binaries)..."
  sudo apt remove -y neovim || true
  sudo rm -f /usr/bin/nvim /usr/local/bin/nvim /usr/local/bin/nvim.appimage
}

install_neovim_appimage() {
  echo ">>> Installing Neovim AppImage (>= 0.10.0) ..."
  curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
  chmod u+x nvim.appimage
  sudo mv nvim.appimage /usr/local/bin/nvim
  # WSL fix for FUSE2
  if ! nvim --version &>/dev/null; then
    echo ">>> AppImage may require libfuse2. Installing..."
    sudo apt update && sudo apt install -y libfuse2
  fi
  nvim --version | head -n 1
}

ensure_nvim_version() {
  if has_command nvim; then
    local nv_ver
    nv_ver=$(nvim --version | head -n1 | grep -oP 'v?\K[0-9]+\.[0-9]+\.[0-9]+')
    if [[ -z "$nv_ver" ]] || [[ $(ver "$nv_ver") -lt $(ver "$required_nvim_version") ]]; then
      echo ">>> Neovim version is too old or not found ($nv_ver). Reinstalling..."
      remove_old_nvim
      install_neovim_appimage
    else
      echo ">>> Neovim $nv_ver already installed."
    fi
  else
    echo ">>> Neovim not found. Installing..."
    install_neovim_appimage
  fi
  # FINAL CHECK -- halt if still not correct
  local final_ver
  final_ver=$(nvim --version | head -n1 | grep -oP 'v?\K[0-9]+\.[0-9]+\.[0-9]+')
  if [[ -z "$final_ver" ]] || [[ $(ver "$final_ver") -lt $(ver "$required_nvim_version") ]]; then
    echo "ERROR: Failed to install Neovim >= $required_nvim_version. Please install manually and re-run the script."
    exit 2
  fi
  echo ">>> Using Neovim version: $final_ver"
}

install_build_tools() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo ">>> Checking for build-essential (gcc, make)..."
    if ! has_command gcc || ! has_command make; then
      sudo apt update && sudo apt install -y build-essential
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    if ! has_command gcc || ! has_command make; then
      xcode-select --install || true
    fi
  fi
}

install_pylint() {
  echo ">>> Checking for pylint..."
  if ! has_command pylint; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      sudo apt update && sudo apt install -y pylint
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      brew install pylint
    fi
  fi
}

check_c_compiler_and_make() {
  if ! has_command gcc && ! has_command cc && ! has_command clang && ! has_command zig; then
    echo "ERROR: No C compiler found! Please install gcc, clang, or zig."
    exit 1
  fi
  if ! has_command make; then
    echo "ERROR: 'make' not found! Please install make."
    exit 1
  fi
}

rebuild_fzf_native() {
  if [ -d "$HOME/.local/share/nvim/lazy/telescope-fzf-native.nvim" ]; then
    cd "$HOME/.local/share/nvim/lazy/telescope-fzf-native.nvim"
    make clean || true
    make || echo "Manual intervention may be needed for telescope-fzf-native.nvim"
    cd - >/dev/null
  fi
}

install_nvim() {
  ensure_nvim_version
  if [ ! -d "$CONFIG_DIR" ]; then
    git clone "$REPO_URL" "$CONFIG_DIR"
  else
    git -C "$CONFIG_DIR" pull
  fi
  if grep -rq "lazy.nvim" "$CONFIG_DIR"; then
    if [ ! -d "$LAZY_PATH" ]; then
      git clone https://github.com/folke/lazy.nvim.git "$LAZY_PATH"
    fi
  fi
  install_build_tools
  install_pylint
  check_c_compiler_and_make
  nvim --version
  nvim --headless "+Lazy sync" +qa || true
  rebuild_fzf_native
  echo ">>> Neovim setup complete! Use 'nvim' to launch."
} 

main_menu() {
  clear
  ascii_art
  script_info
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

main_menu
