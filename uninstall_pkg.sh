#!/bin/bash

# ***** WARNING *****
# 
# This script is to use with extrem carefullness. 
# Not that it will do unreversible actions but more that some packages will be uninstalled reguardless of their usefullness.
# You might still need some of them in the future for other use like Python3 or Homebrew etc.
# Xcode Command Line Tools uninstallation is commented. Since it's pretty usefull whatever you're doing on your terminal.
# 
# This script uninstall all packages needed for the main script to work. Even though you've installed some by yourself for previous use.
# Feel free to comment the uninstall lines for the packages you want to keep.


OS=`uname`

if [ $OS == "Darwin" ]; then # macOS

    # Pytvmaze API
    if [[ $(find /Library/Frameworks/Python.framework/Versions/python3* -name "pytvmaze" 2> /dev/null) != "" || \
          $(find /usr/local/lib/python3* -name "pytvmaze" 2> /dev/null) != "" ]]; then
        yes | pip3 uninstall pytvmaze
    fi

    # Python3
    if [[ $(find -d /usr/local/bin -name "python3" 2> /dev/null) != ""  ]]; then
        brew uninstall python3
    fi

    # GNU sed
    if [[ $(find -d /usr/local/Cellar -name "gnu-sed" 2> /dev/null) != ""  ]]; then
        brew uninstall gnu-sed
    fi

    # Coreutils
    if [[ $(find -d /usr/local/Cellar -name "coreutils" 2> /dev/null) != ""  ]]; then
        brew uninstall coreutils

        if [[ $(grep "coreutils" ~/.bash_profile) != "" ]]; then
            sed -i '/coreutils/d' ~/.bash_profile
        fi
    fi

    # Homebrew
    if [[ $(find -d /usr/local -name "Homebrew" 2> /dev/null) != ""  ]]; then
        yes | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"  # Homebrew
    fi

    # Xcode Command Line Tools
    if [[ $(find -d /Library/Developer -name "CommandLineTools" 2> /dev/null) != "" ]]; then
        #sudo rm -rf /Library/Developer/CommandLineTools
        echo ""
    fi
fi


