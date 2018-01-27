#!/bin/bash


# Usually, the folder used to put all the .mkv/.mp4/.aviand .srt file in, is named as followed : Season_name - Season X
# With X a number (2, 5, 10 etc.)
# In order to make the work easier for the python script, we want to save in a text file the name of the Serie, its season number and how many episode (.mkv & .mp4 & .avi file) there is.
# This function will create a .txt file with these 3 information thanks to the main folder name and the files it contains.
# The python scrpit will then extract these information and work from there.


IFS=$'\n'   #Input Field Separator

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;36m'
NC='\033[0m' # No Color

CODE_OK=0
CODE_REFUSE_INSTALLATION=1
CODE_ERR_PKG_INSTALL=2
CODE_NO_XCODE=3

PATH_SCRIPT_FOLDER=$PWD
PATH_FILE_WITH_EPISODE_NAME=$(readlink -e $(mktemp))
SEASON_NAME=""
SEASON_NUMBER=""
PARENT_FOLDER_NAME=""
OPTION="DEFAULT"

chmod u+x $PATH_FILE_WITH_EPISODE_NAME

# If previous package installation failed some .log files might still be around 
rm *.log 2> /dev/null

./check_pkg_config.sh 2> /dev/null
ret=$?

if [ $ret == $CODE_REFUSE_INSTALLATION ]; then
    echo -e "${RED}Sorry you can't run this scrpit. Please get a proper setup and run the script again"
    echo "this script can't rename the files without all packages installed"
    echo "The episodes didn't get renamed"
    echo -e "Bye${NC}"
    echo ""
    exit
elif [ $ret == $CODE_ERR_PKG_INSTALL ]; then
    echo -e "${RED}Something went wrong during a package installation"
    echo "You can read the log files if there was an error during the installation"
    echo "If there is no log file then, the installation went fine and the problem came from somthing else"
    echo "The episodes didn't get renamed"
    echo -e "Bye-e ${NC}"
    echo ""
    exit
elif [ $ret == $CODE_NO_XCODE ]; then
    echo -e "${BLUE}Please install 'Xcode Command Line Tools' first, and then, run this script again"
    echo -e "To install Xcode CLT run : xcode-select --install${NC}"
    exit
elif [ $ret == 127 ]; then
    echo "Be carefull with the path you're giving. Something is wrong here. Try again with a different one"
    exit
fi

PATH_SERIE_FOLDER=$(readlink -e $1 2> /dev/null) #if no path given readlink fails and prints out an Error

if [ "$PATH_SERIE_FOLDER" == "" ]; then
    echo "Couldn't find the folder \"$1\". Don't fogret to give a path or look for tipos"
    exit
fi

# Get the name of the main folder we want to extract the informations of. (here : Season_Name - Season X)
# This folder contains all the .mkv/.mp4/.avi and .srt
PARENT_FOLDER_NAME=$(basename $(readlink -e $PATH_SERIE_FOLDER))

# Now truncate both sides of the folder's name and store the result
infos=$(echo $PARENT_FOLDER_NAME | sed 's/\ \-\ /\n/g')
# We want the number of .mkv + .mp4 + .avifile stored. This will help in case two episodes have been merged into one.
# Whereas on internet they may appear as two different ones. 
# We will store that value in the .txt file later, then the python script will check the accuracy and prevent shifting in naming.
total_mkv_file=$(find $PATH_SERIE_FOLDER -name "*.mkv" -o -name "*.mp4" -o -name "*.avi" 2> /dev/null | wc -l)

# Let's store the useful information
for info in $infos
do
    echo $info >> $PATH_FILE_WITH_EPISODE_NAME
done

echo $total_mkv_file >> $PATH_FILE_WITH_EPISODE_NAME
# At the end :
# 1st line = Season Name
# 2nd line = Season N
# 3rd line = number of episodes (.mkv + mp4 + avi files)

# We save the season Name and Season Number in global variables we'll use later
SEASON_NAME="$(sed -n 1p $PATH_FILE_WITH_EPISODE_NAME)"

# We don't actually need "Season" of "Season N", only the number matters
sed -i '2 s/[^0-9]//g' $PATH_FILE_WITH_EPISODE_NAME
# We want the season number a 2 digit number 02, 05, 10 etc.
SEASON_NUMBER=$(printf %02d $(sed -n 2p $PATH_FILE_WITH_EPISODE_NAME))


./find_episodes_online.py $PATH_FILE_WITH_EPISODE_NAME
ret=$?

if [ $ret == 1 ]; then
    echo "Something is wrong with the script. Contact developper"
    echo "Your files haven't been renamed"
    exit


if [ $(grep -c "\*\*\*New_Name" $PATH_FILE_WITH_EPISODE_NAME) -gt 0 ] # if new name to be defined then change it (because of a possible typo in the folder name)
then
    SEASON_NAME="$( grep "\*\*\*New_Name" $PATH_FILE_WITH_EPISODE_NAME | sed 's/\*\*\*New_Name \= //')"

    sed -i '/\*\*\*New_Name/d' $PATH_FILE_WITH_EPISODE_NAME

    new_folder_name="$SEASON_NAME - Season $(echo $SEASON_NUMBER | sed 's/0\([1-9]\)/\1/')"
    new_folder_path=$(dirname $PATH_SERIE_FOLDER)/$new_folder_name
    mv $PATH_SERIE_FOLDER $new_folder_path 2> /dev/null
    # Since MacOS is NOT case sensitive we might get an error if the online case's name differs from the local one ... so we use : 2> /dev/null
    PARENT_FOLDER_NAME=$new_folder_name
    PATH_SERIE_FOLDER=$new_folder_path
    
fi

if [ $(grep -c "\*\*\*Merge" $PATH_FILE_WITH_EPISODE_NAME) -gt 0 ]; then # Means we need to merge 2 episode names into 1
    OPTION="MERGE"
    
    ep1=$(grep "\*\*\*Merge" $PATH_FILE_WITH_EPISODE_NAME | sed 's/\*\*\*Merge \= //' | cut -d ' ' -f1)
    ep2=$(grep "\*\*\*Merge" $PATH_FILE_WITH_EPISODE_NAME | sed 's/\*\*\*Merge \= //' | cut -d ' ' -f2)

    sed -i '/\*\*\*Merge/d' $PATH_FILE_WITH_EPISODE_NAME # don't want that line in the file anymore

fi

if [ $(grep -c "\*\*\*ERR\*\*\*" $PATH_FILE_WITH_EPISODE_NAME) -eq 0 ]; then # if no Error in file

    # 1st lower case all the caracter in order to work on a simple base
    # 2nd upper case the first letter of the line
    # 3rd upper case all the letter following a "space" caracter
    sed -i -e 's/[A-Z]/\L&/g' -e 's/^./\U&/g' -e 's/ ./\U&/g' $PATH_FILE_WITH_EPISODE_NAME

    # We now want to rename all the episodes with the same format
    # e.g. Saison Name - 02x13 - Episode Name.mkv(.mp4)(.avi)(.en.srt)
    # or Saison Name - 02x13&14 - Episode Name + Episode Name.mkv(.mp4)(.avi)(.en.srt)
    num_episode=1
    for file in $(find $PATH_SERIE_FOLDER  -name "*.mkv" -o -name "*.mp4" -o -name "*.avi" 2> /dev/null | sort -V)
    do
        if [ $(echo $file | grep -c ".mkv") -gt 0 ]; then
            ext="mkv"
        elif [ $(echo $file | grep -c ".mp4") -gt 0 ]; then
            ext="mp4"
        elif [ $(echo $file | grep -c ".avi") -gt 0 ]; then
            ext="avi"
        fi

        if [ $OPTION == "DEFAULT" ]; then
            EPISODE_NAME="$(sed -n ${num_episode}p $PATH_FILE_WITH_EPISODE_NAME)"
            EPISODE_NUMBER="$( printf %02d $num_episode )"
            
            mv "$file" "$PATH_SERIE_FOLDER/$SEASON_NAME - ${SEASON_NUMBER}x$EPISODE_NUMBER - $EPISODE_NAME.$ext" 2> /dev/null
            ((num_episode++))

        elif [ $OPTION == "MERGE" ]; then
            if [ $num_episode == $ep1 ]; then

                EPISODE_NAME="$(sed -n ${ep1}p $PATH_FILE_WITH_EPISODE_NAME)"
                EPISODE_NAME="${EPISODE_NAME} + $(sed -n ${ep2}p $PATH_FILE_WITH_EPISODE_NAME)"
                EPISODE_NUMBER="$( printf %02d"&"%02d $ep1 $ep2)"
                
                mv "$file" "$PATH_SERIE_FOLDER/$SEASON_NAME - ${SEASON_NUMBER}x$EPISODE_NUMBER - $EPISODE_NAME.$ext" 2> /dev/null
                num_episode=$(($num_episode+2))
            else
                EPISODE_NAME="$(sed -n ${num_episode}p $PATH_FILE_WITH_EPISODE_NAME)"
                EPISODE_NUMBER="$( printf %02d $num_episode )"
                
                mv "$file" "$PATH_SERIE_FOLDER/$SEASON_NAME - ${SEASON_NUMBER}x$EPISODE_NUMBER - $EPISODE_NAME.$ext" 2> /dev/null
                ((num_episode++))
            fi

        fi

    done

    if [ $(find $PATH_SERIE_FOLDER  -name "*.srt" | wc -l) -gt 0 ]; then
        num_episode=1
        ext="en.srt"
        
        for file in $(find $PATH_SERIE_FOLDER  -name "*.srt" | sort -V)
        do
            EPISODE_NAME="$(sed -n ${num_episode}p $PATH_FILE_WITH_EPISODE_NAME)"
            EPISODE_NUMBER="$( printf %02d $num_episode )"
        
            mv "$file" "$PATH_SERIE_FOLDER/$SEASON_NAME - ${SEASON_NUMBER}x$EPISODE_NUMBER - $EPISODE_NAME.$ext" 2> /dev/null
            ((num_episode++))
        done

        # Hightly improbable to find 2 merged episodes (.mkv/.mp4/.avi) with 2 merged .srt files. If there are subtitles with this show,
        # there are most likely hardcoded or available through the menu.

    fi
echo "Episode renaming done"
fi



rm $PATH_FILE_WITH_EPISODE_NAME








