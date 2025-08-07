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

install_nvim() {
  echo "Starting Neovim installation and setup..."

  echo ">>> Checking for Neovim..."
  if ! command -v nvim &>/dev/null; then
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

  echo ">>> Installing/updating your custom Neovim config..."
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

  echo ">>> Running Lazy.nvim plugin sync (if applicable)..."
  nvim --headless "+Lazy sync" +qa || true

  echo ">>> Installing Mason tools (if applicable)..."
  nvim --headless "+MasonInstallAll" +qa || true

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
