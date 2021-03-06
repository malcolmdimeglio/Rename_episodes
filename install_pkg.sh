#!/bin/bash


# All missing packages are given as a parameter from the parent script "check_config.sh"
# This script installs all of them and gives indication on the success or the failur of the installation
# .log files will be available in case of failure for review.

OS="$1"
INSTALL="$2"
ERR_FLAG=0

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

sudo echo ""
echo "Installation ..."
touch .current_config.info

if [ $OS == "Darwin" ]; then # macOS
    for word in $INSTALL; do

        # Homebrew
        if [ $(echo $word | grep -c "Homebrew") -eq 1 ]; then
            printf "\n" | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" > install_homebrew.log
            
            echo -e "Homebrew ... \c"

            # Check if installation success or failure
            if [ $(tail -12 install_homebrew.log | grep -c "Installation successful") -eq 1 ]; then
                echo -e "${GREEN}SUCCESS${NC}"
                rm install_homebrew.log
                echo "Homebrew: Installed" >> .current_config.info
            else
               echo -e "${RED}FAIL${NC}"
               ERR_FLAG=1
            fi
            if [[ $(echo "$PATH" | grep "/usr/local/bin:/usr/local/sbin") == "" ]]; then
                export PATH=/usr/local/bin:/usr/local/sbin:$PATH
            fi

        # Coreutils
        elif [ $(echo $word | grep -c "coreutils") -eq 1 ]; then
            echo -e "Coreutils ... \c"
            brew install coreutils > install_coreutils.log

            # Modify bash_profile once and for all
            if [ $(cat ~/.bash_profile | grep -c "coreutils") -eq 0 ]; then
                echo "# enable Homebrew coreutils" >> ~/.bash_profile
                echo "export PATH=\"/usr/local/opt/coreutils/libexec/gnubin:\$PATH\"" >> ~/.bash_profile
                echo "export MANPATH=\"/usr/local/opt/coreutils/libexec/gnuman:\$MANPATH\"" >> ~/.bash_profile
            fi

            if [ -f ~/.zshrc ] && [ $(cat ~/.bash_profile | grep -c "coreutils") -eq 0 ]; then
                echo "# enable Homebrew coreutils" >> ~/.zshrc
                echo "export PATH=\"/usr/local/opt/coreutils/libexec/gnubin:\$PATH\"" >> ~/.zshrc
                echo "export MANPATH=\"/usr/local/opt/coreutils/libexec/gnuman:\$MANPATH\"" >> ~/.zshrc
            fi

            # Check if installation success or failure
            if [ $(tail -15 install_coreutils.log | grep -c "All commands have been installed") -eq 1 ]; then
                echo -e "${GREEN}SUCCESS${NC}"
                rm install_coreutils.log
                echo "Coreutils: Installed" >> .current_config.info
            else
               echo -e "${RED}FAIL${NC}"
               ERR_FLAG=1
            fi

            PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH # That we don't need to close then open a new terminal prompt to finish the job

        # GNU sed
        elif [ $(echo $word | grep -c "gnu-sed") -eq 1 ]; then
            echo -e "GNU sed ... \c"
            brew install gnu-sed --with-default-names > install_gnu_sed.log

            # Check if installation success or failure
            if [ $(tail -1 install_gnu_sed.log | grep -c "built in") -eq 1 ]; then
                echo -e "${GREEN}SUCCESS${NC}"
                rm install_gnu_sed.log
                echo "GNU sed: Installed" >> .current_config.info
            else
               echo -e "${RED}FAIL${NC}"
               ERR_FLAG=1
            fi

        # Python3
        elif [ $(echo $word | grep -c "python3") -eq 1 ]; then
            echo -e "Python3 ... \c"
            brew install python3 > install_python3.log

            # Check if installation success or failure
            if [ $(tail -13 install_python3.log | grep -c "have been installed") -eq 1 ]; then
                echo -e "${GREEN}SUCCESS${NC}"
                rm install_python3.log
                echo "Python3: Installed" >> .current_config.info
            else
               echo -e "${RED}FAIL${NC}"
               ERR_FLAG=1
            fi

        # Pytvmaze API
        elif [ $(echo $word | grep -c "pytvmaze") -eq 1 ]; then
            echo -e "pytvmaze ... \c"
            pip3 install pytvmaze > install_pytvmaze.log

            # Check if installation success or failure
            if [ $(tail -1 install_pytvmaze.log | grep -c "Successfully installed") -eq 1 ]; then
                echo -e "${GREEN}SUCCESS${NC}"
                rm install_pytvmaze.log
                echo "Pytvmaze API: Installed" >> .current_config.info
            else
                echo -e "${RED}FAIL${NC}"
                ERR_FLAG=1
            fi
        fi
    done

fi

if [ $OS == "Linux" ];then

    for word in $INSTALL; do
        if [ $(echo $word | grep -c "python3") -eq 1 ]; then
            yes | apt-get install python3
            echo "Python3: Installed" >> .current_config.info
            
        elif [ $(echo $word | grep -c "py3-pip") -eq 1 ]; then
            yes | apt-get install python3-pip
            echo "Python3 pip pkg: Installed" >> .current_config.info

        elif [ $(echo $word | grep -c "pytvmaze") -eq 1 ]; then
            pip3 install pytvmaze
            echo "Pytvmaze API: Installed" >> .current_config.info
        fi
    done
fi

exit $ERR_FLAG






