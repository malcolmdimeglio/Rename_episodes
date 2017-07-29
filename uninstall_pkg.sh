#!/bin/bash

OS=`uname`

if [ $OS == "Darwin" ]; then # macOS

    if [[ $(find /Library/Frameworks/Python.framework/Versions/python3* -name "pytvmaze" 2> /dev/null) != "" || \
          $(find /usr/local/lib/python3* -name "pytvmaze" 2> /dev/null) != "" ]]; then
          yes | pip3 uninstall pytvmaze
    fi

    if [[ $(find -d /usr/local/bin -name "python3" 2> /dev/null) != ""  ]]; then
        brew uninstall python3
    fi

    if [[ $(find -d /usr/local/Cellar -name "gnu-sed" 2> /dev/null) != ""  ]]; then
        brew uninstall gnu-sed
    fi

    if [[ $(find -d /usr/local/Cellar -name "coreutils" 2> /dev/null) != ""  ]]; then
        brew uninstall coreutils

        if [[ $(grep "coreutils" ~/.bash_profile) != "" ]]; then
            sed -i '/coreutils/d' ~/.bash_profile
        fi
    fi

    if [[ $(find -d /usr/local -name "Homebrew" 2> /dev/null) != ""  ]]; then
        yes | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"  # Homebrew
    fi

    if [[ $(find -d /Library/Developer -name "CommandLineTools" 2> /dev/null) != "" ]]; then
        #sudo rm -rf /Library/Developer/CommandLineTools # Xcode Command Line Tools
    fi

fi
