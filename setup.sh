#!/usr/bin/env bash
set -e

REPO_URL="https://github.com/Zship135/Auto-Nvim.git"
CONFIG_DIR="$HOME/.config/nvim"
LAZY_PATH="$HOME/.local/share/nvim/lazy/lazy.nvim"

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

show_menu() {
  echo "1) Install and set up Neovim automatically"
  echo "q) Quit"
  echo -n ">: "
}

has_command() {
  command -v "$1" >/dev/null 2>&1
}

install_build_tools() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo ">>> Checking for build-essential (gcc, make)..."
    if ! has_command gcc || ! has_command make; then
      echo ">>> Installing build-essential (requires sudo)..."
      sudo apt update && sudo apt install -y build-essential
    else
      echo ">>> C compiler and make found."
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    echo ">>> Checking for Xcode Command Line Tools..."
    if ! has_command gcc || ! has_command make; then
      echo ">>> Installing Xcode Command Line Tools (may prompt)..."
      xcode-select --install || true
    else
      echo ">>> C compiler and make found."
    fi
  else
    echo ">>> WARNING: Unable to auto-install build tools for this OS."
    echo ">>> Please ensure you have a C compiler and make installed."
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
    echo ">>> Attempting to rebuild telescope-fzf-native.nvim..."
    cd "$HOME/.local/share/nvim/lazy/telescope-fzf-native.nvim"
    make clean || true
    make || echo "Manual intervention may be needed for telescope-fzf-native.nvim"
    cd - >/dev/null
  fi
}

install_nvim() {
  echo "Starting Neovim installation and setup..."

  echo ">>> Checking for Neovim..."
  if ! has_command nvim; then
    echo ">>> Neovim not found. Attempting to install..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      sudo apt update && sudo apt install -y neovim
    elif [[ "$OSTYPE" == "darwin"* ]]; then
      brew install neovim
    else
      echo ">>> Unsupported OS."
      exit 1
    fi
  else
    echo ">>> Neovim is already installed. Carrying on..."
  fi

  echo ">>> Installing or updating your custom Neovim config..."
  if [ ! -d "$CONFIG_DIR" ]; then
    git clone "$REPO_URL" "$CONFIG_DIR"
  else
    echo ">>> Config directory already exists. Pulling latest changes..."
    git -C "$CONFIG_DIR" pull
  fi

  # Optional: Ensure lazy.nvim exists if your config expects it in this path.
  if grep -rq "lazy.nvim" "$CONFIG_DIR"; then
    echo ">>> Ensuring lazy.nvim is installed..."
    if [ ! -d "$LAZY_PATH" ]; then
      git clone https://github.com/folke/lazy.nvim.git "$LAZY_PATH"
    else
      echo ">>> lazy.nvim already present."
    fi
  fi

  install_build_tools
  check_c_compiler_and_make

  echo ">>> Running Lazy.nvim plugin sync (if applicable)..."
  nvim --headless "+Lazy sync" +qa || true

  rebuild_fzf_native

  echo ""
  echo ">>> MasonInstallAll is not a valid Neovim command."
  echo ">>> To install language servers/tools, open Neovim and run ':Mason' interactively."
  echo ""
  echo ">>> Neovim setup complete! Use 'nvim' to launch."
} 

main_menu() {
  clear
  ascii_art
  script_info

  while true; do
    show_menu
    read -r choice
    case "$choice" in
      1)
        install_nvim
        break
        ;;
      q|Q)
        echo "Goodbye!"
        clear
        exit 0
        ;;
      *)
        echo "Invalid choice. Please try again."
        ;;
    esac
  done
}

main_menu
