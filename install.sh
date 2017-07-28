#!/bin/bash


OS="$1"
INSTALL="$2"
ERR_FLAG=0

echo ""
echo "Package installation checking..."


if [ $OS == "Darwin" ]; then # macOS
    for word in $INSTALL; do

        if [ $(echo $word | grep -c "Homebrew") -eq 1 ]; then
            printf "\n" | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" > install_homebrew.log
            
            echo -e "Homebrew ... \c"
            if [ $(tail -12 install_homebrew.log | grep -c "Installation successful") -eq 1 ]; then
                echo -e "${GREEN}SUCCESS${NC}"
                rm install_homebrew.log
            else
               echo -e "${RED}FAIL${NC}"
               ERR_FLAG=1
            fi
            if [[ $(echo "$PATH" | grep "/usr/local/bin:/usr/local/sbin") == "" ]]; then
                export PATH=/usr/local/bin:/usr/local/sbin:$PATH
            fi

        elif [ $(echo $word | grep -c "coreutils") -eq 1 ]; then
            echo -e "Coreutils ... \c"
            brew install coreutils > install_coreutils.log

            if [ $(cat ~/.bash_profile | grep -c "coreutils") -eq 0 ]; then
                echo "# enable Homebrew coreutils" >> ~/.bash_profile
                echo "export PATH=\"/usr/local/opt/coreutils/libexec/gnubin:\$PATH\"" >> ~/.bash_profile
                echo "export MANPATH=\"/usr/local/opt/coreutils/libexec/gnuman:\$MANPATH\"" >> ~/.bash_profile
            fi

            if [ $(tail -15 install_coreutils.log | grep -c "All commands have been installed") -eq 1 ]; then
                echo -e "${GREEN}SUCCESS${NC}"
                rm install_coreutils.log
            else
               echo -e "${RED}FAIL${NC}"
               ERR_FLAG=1
            fi

            PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH # That we don't need to close then open a new terminal prompt to finish the job

        elif [ $(echo $word | grep -c "gnu-sed") -eq 1 ]; then
            echo -e "GNU sed ... \c"
            brew install gnu-sed --with-default-names > install_gnu_sed.log

            if [ $(tail -1 install_gnu_sed.log | grep -c "built in") -eq 1 ]; then
                echo -e "${GREEN}SUCCESS${NC}"
                rm install_gnu_sed.log
            else
               echo -e "${RED}FAIL${NC}"
               ERR_FLAG=1
            fi

        elif [ $(echo $word | grep -c "python3") -eq 1 ]; then
            echo -e "Python3 ... \c"
            brew install python3 > install_python3.log

            if [ $(tail -13 install_python3.log | grep -c "have been installed") -eq 1 ]; then
                echo -e "${GREEN}SUCCESS${NC}"
                rm install_python3.log
            else
               echo -e "${RED}FAIL${NC}"
               ERR_FLAG=1
            fi

        elif [ $(echo $word | grep -c "pytvmaze") -eq 1 ]; then
            echo -e "pytvmaze ... \c"
            pip3 install pytvmaze > install_pytvmaze.log

            if [ $(tail -1 install_pytvmaze.log | grep -c "Successfully installed") -eq 1 ]; then
                echo -e "${GREEN}SUCCESS${NC}"
                rm install_pytvmaze.log
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
            apt-get install ptyhon3
            apt-get update
            apt-get -y upgrade

        elif [ $(echo $word | grep -c "pytvmaze") -eq 1 ]; then
            pip3 install pytvmaze
        fi
    done
fi

exit $ERR_FLAG






