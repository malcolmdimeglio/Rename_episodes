#!/bin/bash

OS="$1"
INSTALL="$2"

echo ""
echo "Package installation checking..."


if [ $OS == "Darwin" ]; then # macOS
    for word in $INSTALL; do
        if [ $(echo $word | grep -c "Xcode") -eq 1 ]; then
            exec bash -c "xcode-select –install" &

        if [ $(echo $word | grep -c "Homebrew") -eq 1 ]; then
            printf "\n" | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" > install_homebrew.log
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
            PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH # That we don't need to close then open a new terminal prompt to finish the job

        elif [ $(echo $word | grep -c "gnu-sed") -eq 1 ]; then
            echo -e "GNU sed ... \c"
            brew install gnu-sed --with-default-names > install_gnu_sed.log

        elif [ $(echo $word | grep -c "python3") -eq 1 ]; then
            echo -e "Python3 ... \c"
            brew install python3 > install_python3.log

        elif [ $(echo $word | grep -c "pytvmaze") -eq 1 ]; then
            echo -e "pytvmaze ... \c"
            pip3 install pytvmaze > install_pytvmaze.log
        fi
        wait
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



exit
