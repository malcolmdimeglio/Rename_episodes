#!/bin/bash


# Usually, the folder used to put all the .mkv/.mp4/.aviand .srt file in, is named as followed : Season_name - Season X
# With X a number (2, 5, 10 etc.)
# In order to make the work easier for the python script, we want to save in a text file the name of the Serie, its season number and how many episode (.mkv & .mp4 & .avi file) there is.
# This function will create a .txt file with these 3 information thanks to the main folder name and the files it contains.
# The python scrpit will then extract these information and work from there.


IFS=$'\n'   #Input Field Separator

SCRIPT_FOLDER_PATH=$PWD
FILE_WITH_EPISODE_NAME="list_of_episode_names.txt"
FILE_WITH_EPISODE_NAME_PATH=""
SEASON_NAME=""
SEASON_NUMBER=""
PARENT_FOLDER_NAME=""
OPTION="DEFAULT"
OS=`uname`

if [ $OS == "Darwin" ]; then # macOS

    # Check if packages installation are already done
    if [ $(ls "/usr/local/" | grep -c "Homebrew") -eq 0 ]; then
        echo "'Homebrew' package is not installed on your computer. You will need it to run this scrpit, install the API and so on."
        until [[ $answer == "y" || $answer == "Y" || $answer == "n" || $answer == "N" ]]; do
            echo "Do you want to install it now? (y/n)"
            read answer
        done

        case $answer in
            "y"|"Y")
                exec ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
                wait
                export PATH=/usr/local/bin:/usr/local/sbin:$PATH
                ;;
            "n"|"N")
                echo "Sorry you can't run this scrpit. Please get a proper setup"
                exit
                ;;
        esac
    fi

    if [ $(ls "/usr/local/Cellar" | grep -c "coreutils") -eq 0 ]; then
        echo "'coreutils' package is not installed on your computer. You will need it to run this script."
        until [[ $answer == "y" || $answer == "Y" || $answer == "n" || $answer == "N" ]]; do
            echo "Do you want to install it now? (y/n)"
            read answer
        done

        case $answer in
            "y"|"Y")
                exec bash -c "brew install coreutils" &
                wait
                if [ $(cat ~/.bash_profile | grep -c "coreutils") -eq 0 ]; then
                    echo "# enable Homebrew coreutils" >> ~/.bash_profile
                    echo "export PATH=\"/usr/local/opt/coreutils/libexec/gnubin:\$PATH\"" >> ~/.bash_profile
                    echo "export MANPATH=\"/usr/local/opt/coreutils/libexec/gnuman:\$MANPATH\"" >> ~/.bash_profile
                fi
                PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH # That we don't need to close then open a new terminal prompt to finish the job
                ;;
            "n"|"N")
                echo "Sorry you can't run this scrpit. Please get a proper setup"
                exit
                ;;
        esac
    fi

    if [ $(ls "/usr/local/Cellar" | grep -c "gnu-sed") -eq 0 ]; then
        echo "'gnu-sed' package is not installed on your computer. You will need it to run this script."
        until [[ $answer == "y" || $answer == "Y" || $answer == "n" || $answer == "N" ]]; do
            echo "Do you want to install it now? (y/n)"
            read answer
        done

        case $answer in
            "y"|"Y")
                exec bash -c "brew install gnu-sed --with-default-names" &
                wait
                ;;
            "n"|"N")
                echo "Sorry you can't run this scrpit. Please get a proper setup"
                exit
                ;;
        esac
    fi

    if [ $(ls "/usr/local/bin" | grep -c "python3") -eq 0 ]; then
        echo "'Python 3' is not installed on your computer. You will need it to run this scrpit."
        until [[ $answer == "y" || $answer == "Y" || $answer == "n" || $answer == "N" ]]; do
            echo "Do you want to install it now? (y/n)"
            read answer
        done

        case $answer in
            "y"|"Y")
                exec bash -c "brew install python3"
                wait
                ;;
            "n"|"N")
                echo "Sorry you can't run this scrpit. Please get a proper setup"
                exit
                ;;
        esac
    fi

        path_to_api=$(find /Library/Frameworks/Python.framework/Versions/ -name "pytvmaze")

    if [[ $path_to_api == "" ]]; then
        echo "'pytvmaze' is not installed on your computer. You will need this API to run this scrpit."
        until [[ $answer == "y" || $answer == "Y" || $answer == "n" || $answer == "N" ]]; do
            echo "Do you want to install it now? (y/n)"
            read answer
        done

        case $answer in
            "y"|"Y")
                exec bash -c "pip3 install pytvmaze"
                wait
                ;;
            "n"|"N")
                echo "Sorry you can't run this scrpit. Please get a proper setup"
                exit
                ;;
        esac
    fi
            
fi

SERIE_FOLDER_PATH=$(readlink -e $1)

if [ "$SERIE_FOLDER_PATH" == "" ]; then
    echo "Couldn't find the folder \"$1\". Look for tipos"
    exit
fi

cd $SERIE_FOLDER_PATH
# Now at /xxx/yyy/zzz/Season_Name - Season X

# Get the name of the main folder we want to extract the informations of. (here : Season_Name - Season X)
# This folder contains all the .mkv/.mp4/.avi and .srt
PARENT_FOLDER_NAME=$(basename $(readlink -e .))

# Now truncate both sides of the folder's name and store the result
infos=$(echo $PARENT_FOLDER_NAME | sed 's/\ \-\ /\n/g')
# We want the number of .mkv + .mp4 + .avifile stored. This will help in case two episodes have been merged into one.
# whereas on internet they may appear as two different ones. 
# We will store that value in the .txt file later, then the python script will check the accuracy and prevent shifting in naming.
total_mkv_file=$(ls *.mkv *.mp4 *.avi 2> /dev/null | wc -l | sed 's/\t//')

cd $SCRIPT_FOLDER_PATH
# now at /aaa/bbb/ccc/Script_Episode

# This create the .txt file and give permission to modify it, then write the info in it
touch $FILE_WITH_EPISODE_NAME
chmod u+x $FILE_WITH_EPISODE_NAME

FILE_WITH_EPISODE_NAME_PATH=$(readlink -e $FILE_WITH_EPISODE_NAME)

# Let's store the useful information
for info in $infos
do
    echo $info >> $FILE_WITH_EPISODE_NAME_PATH
done

echo $total_mkv_file >> $FILE_WITH_EPISODE_NAME_PATH
# At the end :
# 1st line = Season Name
# 2nd line = Season N
# 3rd line = number of episodes (.mkv + mp4 + avi files)

# We save the season Name and Season Number in global variables we'll use later
SEASON_NAME="$(sed -n 1p $FILE_WITH_EPISODE_NAME_PATH)"

# We don't actually need "Season" of "Season N", only the number matters
sed -i '2 s/[^0-9]//g' $FILE_WITH_EPISODE_NAME_PATH
# We want the season number a 2 digit number 02, 05, 10 etc.
SEASON_NUMBER=$(printf %02d $(sed -n 2p $FILE_WITH_EPISODE_NAME_PATH))

cd $SCRIPT_FOLDER_PATH
# Now at /aaa/bbb/ccc/Script_Episode

./find_name_on_internet.py

cd $SERIE_FOLDER_PATH
# Now at /xxx/yyy/zzz/Season_Name - Season X
# 
if [ $(grep -c "\*\*\*New_Name" $FILE_WITH_EPISODE_NAME_PATH) -gt 0 ] # if new name to be defined then change it (because of a possible typo in the folder name)
then
    SEASON_NAME="$( grep "\*\*\*New_Name" $FILE_WITH_EPISODE_NAME_PATH | sed 's/\*\*\*New_Name \= //')"

    sed -i '/\*\*\*New_Name/d' $FILE_WITH_EPISODE_NAME_PATH
    
    cd ..
    # now at /xxx/yyy/zzz/
    new_folder_name="$SEASON_NAME - Season $(echo $SEASON_NUMBER | sed 's/0\([1-9]\)/\1/')"

    mv $PARENT_FOLDER_NAME $new_folder_name 2> /dev/null
    # Since MacOS is NOT case sensitive we might get an error if the online case's name differs from the local one ... so we use : 2> /dev/null
    PARENT_FOLDER_NAME=$new_folder_name
    SERIE_FOLDER_PATH=$(readlink -e $new_folder_name)
    
    cd $SERIE_FOLDER_PATH
    # now at /xxx/yyy/zzz/Season_Name - Season X (with updated Season_Name)
fi

if [ $(grep -c "\*\*\*Merge" $FILE_WITH_EPISODE_NAME_PATH) -gt 0 ]; then # Means we need to merge 2 episode names into 1
    OPTION="MERGE"
    
    ep1=$(grep "\*\*\*Merge" $FILE_WITH_EPISODE_NAME_PATH | sed 's/\*\*\*Merge \= //' | cut -d ' ' -f1)
    ep2=$(grep "\*\*\*Merge" $FILE_WITH_EPISODE_NAME_PATH | sed 's/\*\*\*Merge \= //' | cut -d ' ' -f2)

    sed -i '/\*\*\*Merge/d' $FILE_WITH_EPISODE_NAME_PATH # don't want that line in the file anymore

fi

if [ $(grep -c "\*\*\*ERR\*\*\*" $FILE_WITH_EPISODE_NAME_PATH) -eq 0 ]; then # if no Error in file

    # 1st lower case all the caracter in order to work on a simple base
    # 2nd upper case the first letter of the line
    # 3rd upper case all the letter following a "space" caracter
    sed -i -e 's/[A-Z]/\L&/g' -e 's/^./\U&/g' -e 's/ ./\U&/g' $FILE_WITH_EPISODE_NAME_PATH

    # We now want to rename all the episodes with the same format
    # e.g. Saison Name - 02x13 - Episode Name.mkv(.mp4)(.avi)(.en.srt)
    # or Saison Name - 02x13&14 - Episode Name + Episode Name.mkv(.mp4)(.avi)(.en.srt)
    num_episode=1
    for file in $(ls -v *.mkv *.mp4 *.avi 2> /dev/null)
    do
        if [ $(echo $file | grep -c ".mkv") -gt 0 ]; then
            ext="mkv"
        elif [ $(echo $file | grep -c ".mp4") -gt 0 ]; then
            ext="mp4"
        elif [ $(echo $file | grep -c ".avi") -gt 0 ]; then
            ext="avi"
        fi

        if [ $OPTION == "DEFAULT" ]; then
            EPISODE_NAME="$(sed -n ${num_episode}p $FILE_WITH_EPISODE_NAME_PATH).$ext"
            EPISODE_NUMBER="$( printf %02d $num_episode )"
            
            mv "$file" "$SEASON_NAME - ${SEASON_NUMBER}x$EPISODE_NUMBER - $EPISODE_NAME" 2> /dev/null
            ((num_episode++))

        elif [ $OPTION == "MERGE" ]; then
            if [ $num_episode == $ep1 ]; then

                EPISODE_NAME="$(sed -n ${ep1}p $FILE_WITH_EPISODE_NAME_PATH)"
                EPISODE_NAME="${EPISODE_NAME} + $(sed -n ${ep2}p $FILE_WITH_EPISODE_NAME_PATH).$ext"
                EPISODE_NUMBER="$( printf %02d"&"%02d $ep1 $ep2)"
                
                mv "$file" "$SEASON_NAME - ${SEASON_NUMBER}x$EPISODE_NUMBER - $EPISODE_NAME" 2> /dev/null
                num_episode=$(($num_episode+2))
            else
                EPISODE_NAME="$(sed -n ${num_episode}p $FILE_WITH_EPISODE_NAME_PATH).$ext"
                EPISODE_NUMBER="$( printf %02d $num_episode )"
                
                mv "$file" "$SEASON_NAME - ${SEASON_NUMBER}x$EPISODE_NUMBER - $EPISODE_NAME" 2> /dev/null
                ((num_episode++))
            fi

        fi

    done

    if [ $(ls | grep -c ".srt") -gt 0 ]; then
        num_episode=1
        ext="en.srt"
        
        for file in $(ls -v *.srt)
        do
            EPISODE_NAME="$(sed -n ${num_episode}p $FILE_WITH_EPISODE_NAME_PATH).$ext"
            EPISODE_NUMBER="$( printf %02d $num_episode )"
        
            mv "$file" "$SEASON_NAME - ${SEASON_NUMBER}x$EPISODE_NUMBER - $EPISODE_NAME" 2> /dev/null
            ((num_episode++))
        done

        # Hightly improbable to find 2 merged episodes (.mkv/.mp4/.avi) with 2 merged .srt files. If there are subtitles with this show,
        # there are most likely hardcoded or available through the menu.

    fi

fi


rm $FILE_WITH_EPISODE_NAME_PATH







