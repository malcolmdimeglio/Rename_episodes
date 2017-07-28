#!/bin/bash


CODE_OK=0
CODE_NO_INSTALLATION=1
CODE_ERR_PCKG_INSTALL=2
CODE_NO_XCODE=3

OS=`uname`
INSTALL=""

echo ""
echo "Package installation checking..."

if [ $OS == "Darwin" ]; then # macOS

    if [[ $(find -d /Library/Developer -name "CommandLineTools" 2> /dev/null) == "" ]]; then
        exit $CODE_NO_XCODE
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
        exit $CODE_OK
    else
        echo "The system needs the installation of : $INSTALL"
        until [[ $answer == "y" || $answer == "Y" || $answer == "n" || $answer == "N" ]]; do
            echo -e "Do you want to do the installation now? (y/n) \c"
            read answer
        done
        if [[ $answer == "n" || $answer == "N" ]];then
            exit $CODE_NO_INSTALLATION
        fi
    fi
fi

if [ $OS == "Linux" ];then

    if [ $(ls "/usr/bin" | grep -c "python3") -eq 0 ]; then
        INSTALL="$INSTALL python3"
    fi

    if [[ $(find /usr/local/lib/python3* -name "pytvmaze") == "" ]]; then
        INSTALL="$INSTALL pytvmaze"
    fi
fi

./install.sh $OS "$INSTALL"
ret=$?

if [ $ret == 0 ]; then
    echo -e "Installation success\n"
    exit $CODE_OK
else
    echo -e "Installation fail\n"
    exit $CODE_ERR_PCKG_INSTALL
fi




