#!/usr/bin/env bash
set -e

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
  echo "Repo: https://github.com/Zship135/Auto-Nvim"
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
  echo -e "${GREEN}>>> Checking for Neovim..."
  if ! command -v nvim &>/dev/null; then
    echo -e "${GREEN}>>> Neovim not found. Attempting to install..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
      sudo apt update && sudo apt install -y neovim
    elif [[ "$OSTYPE" == "darwin" ]]; then
      brew install neovim
    else
      echo -e "${RED}>>> Unsupported OS."
      exit 1
    fi
  else
    echo -e "${GREEN}>>> Neovim is already installed. Carrying on..."
  fi

  echo -e "${GREEN}>>> Installing Nvim config..."
  LAZY_PATH="$HOME/.local/share/nvim/lazy/lazy.nvim"
  if [ ! -d "$LAZY_PATH" ]; then
    git clone https://github.com/folke/lazy.nvim.git "$LAZY_PATH"
  else
    echo -e "${GREEN}>>>Lazy.nvim already installed. Carrying on..."
  fi

  echo -e "${GREEN}>>> Syncing plugins..."
  nvim --headless "+Lazy sync" +qa

  echo -e "${GREEN}>>> Installing mason tools (if needed)..."
  nvim --headless "+MasonInstallAll" +qa || true
  echo ""
  
  echo -e "${GREEN}>>> Neovim setup complete! Use 'nvim' to launch."

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
