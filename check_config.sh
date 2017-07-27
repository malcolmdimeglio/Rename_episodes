#!/bin/bash

OS=`uname`
INSTALL=""

echo ""
echo "Package installation checking..."

if [ $OS == "Darwin" ]; then # macOS

    if [[ $(find -d /Library/Developer -name "CommandLineTools" 2> /dev/null) == "" ]]; then
        INSTALL="$INSTALL Xcode"
    fi
    if [ $(ls "/usr/local/" 2> /dev/null | grep -c "Homebrew") -eq 0 ]; then
        INSTALL="$INSTALL Homebrew"
    fi
    if [ $(ls "/usr/local/Cellar" 2> /dev/null | grep -c "coreutils") -eq 0 ]; then
        INSTALL="$INSTALL coreutils"
    fi
    if [ $(ls "/usr/local/Cellar" 2> /dev/null | grep -c "gnu-sed") -eq 0 ]; then
        INSTALL="$INSTALL gnu-sed"
    fi
    if [ $(ls "/usr/local/bin" 2> /dev/null | grep -c "python3") -eq 0 ]; then
        INSTALL="$INSTALL python3"
    fi
    if [[ $(find /Library/Frameworks/Python.framework/Versions/python3* -name "pytvmaze" 2> /dev/null) == "" && \
          $(find /usr/local/lib/python3* -name "pytvmaze" 2> /dev/null) == "" ]]; then
        INSTALL="$INSTALL pytvmaze"
    fi

    if [[ $INSTALL == "" ]]; then
        echo "System up to date"
        exit 1
    else
        echo "$INSTALL need(s) to be installed first"
        until [[ $answer == "y" || $answer == "Y" || $answer == "n" || $answer == "N" ]]; do
            echo "Do you want to do the installation now? (y/n)"
            read answer
        done
        if [[ $answer == "n" || $answer == "N" ]];then
            echo "Sorry you can't run this scrpit. Please get a proper setup and run the script again"
            exit 2
        fi
    fi

    osascript  -e 'do shell script "open -a Terminal ."' -e 'tell application "Terminal" to do script "./install.sh '" ${OS} '$INSTALL' "' " in selected tab of the front window' > /dev/null
    echo "Installation success"
fi