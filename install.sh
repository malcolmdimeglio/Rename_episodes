#!/bin/bash

OS="$1"
INSTALL="$2"

echo ""
echo "Package installation checking..."


if [ $OS == "Darwin" ]; then # macOS
    for word in $INSTALL; do
        if [ $(echo $word | grep -c "Xcode") -eq 1 ]; then
            exec bash -c "xcode-select –install" &

        elif [ $(echo $word | grep -c "Homebrew") -eq 1 ]; then
            exec ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" &
            wait
            if [ echo $PATH | grep "/usr/local/bin:/usr/local/sbin" == "" ]; then
                export PATH=/usr/local/bin:/usr/local/sbin:$PATH
            fi

        elif [ $(echo $word | grep -c "coreutils") -eq 1 ]; then
            exec bash -c "brew install coreutils" &
            wait
            if [ $(cat ~/.bash_profile | grep -c "coreutils") -eq 0 ]; then
                echo "# enable Homebrew coreutils" >> ~/.bash_profile
                echo "export PATH=\"/usr/local/opt/coreutils/libexec/gnubin:\$PATH\"" >> ~/.bash_profile
                echo "export MANPATH=\"/usr/local/opt/coreutils/libexec/gnuman:\$MANPATH\"" >> ~/.bash_profile
            fi
            PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH # That we don't need to close then open a new terminal prompt to finish the job

        elif [ $(echo $word | grep -c "gnu-sed") -eq 1 ]; then
            exec bash -c "brew install gnu-sed --with-default-names" &

        elif [ $(echo $word | grep -c "python3") -eq 1 ]; then
            exec bash -c "brew install python3" &

        elif [ $(echo $word | grep -c "pytvmaze") -eq 1 ]; then
            exec bash -c "pip3 install pytvmaze" &
        fi
        wait
    done

fi

if [ $OS == "Linux" ];then

    if [ $(ls "/usr/bin" | grep -c "python3") -eq 0 ]; then
        INSTALL="$INSTALL python3"
    fi

    if [[ $(find /usr/local/lib/python3* -name "pytvmaze") == "" ]]; then
        INSTALL="$INSTALL pytvmaze"
    fi

    for word in $INSTALL; do
        if [ $(echo $word | grep -c "python3") -eq 1 ]; then
            exec bash -c "apt-get install ptyhon3"
            exec bash -c "apt-get update"
            exec bash -c "apt-get -y upgrade"

        elif [ $(echo $word | grep -c "pytvmaze") -eq 1 ]; then
            exec bash -c "pip3 install pytvmaze" &
        fi
        wait
    done
fi

wait
osascript -e 'tell application "System Events" to tell process "Terminal" to keystroke "w" using command down' &


exit
