#!/bin/bash

OS=`uname`

if [ $OS == "Darwin" ]; then # macOS
    yes | pip3 uninstall pytvmaze
    brew uninstall python3
    brew uninstall gnu-sed
    brew uninstall coreutils
    yes | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"  # Homebrew
    
    #sudo rm -rf /Library/Developer/CommandLineTools # Xcode Command Line Tools
fi
