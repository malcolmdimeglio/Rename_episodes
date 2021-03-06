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

# Handle some potential errors and avoid renaming process in this case
if [ $ret != 0 ]; then
    echo "Something went wrong with the script. Contact developper"
    echo "Your files haven't been renamed"
    exit
fi


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
    nb_couple_episodes=$(grep "\*\*\*Merge" $PATH_FILE_WITH_EPISODE_NAME | grep -o , | wc -l)
    # input line looks like: ***Merge = 1,2 14,15 18,19
    # we want to seperate everythin into 2 lists:
    # with the previous given example we want: episode1 = 1 14 18    and     episode2 = 2 15 19
    for i in `seq 1 $nb_couple_episodes`
    do
        episode1=$episode1$(grep "\*\*\*Merge" $PATH_FILE_WITH_EPISODE_NAME | sed 's/\*\*\*Merge \= //' | cut -d ' ' -f$i | cut -d ',' -f1)" "
        episode2=$episode2$(grep "\*\*\*Merge" $PATH_FILE_WITH_EPISODE_NAME | sed 's/\*\*\*Merge \= //' | cut -d ' ' -f$i | cut -d ',' -f2)" "
    done
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
    count=1
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
            # Keeping the same example as above written
            # 'count' will increment for each merge. it allows to extract 1st episode number to merge, then 2nd on the next loop and so on, from the list: episode1 = 1 14 18
            # 'num_episode' increments from 1st episode to last (let's say 25) (for 25 files)
            # first episode will be merged properly, then 'num_episode' jumps to 3, and 'counts' to 2
            # then 'num_episode' increments to 4 after a normal episode renaming.
            # If we only grep 'num_episode' in 'episode1'
            # Problem: grep sees "1 14 18" as a list of unrelated caracters. So 'num_episode' (which is equal to 4) will grep on '14' when it shouldn't
            # (or if 'num_episode' = 8, 'num_episode' will grep on 18 even if 'counts' = 2)
            # So we need to isolate each number independantly (with `cut`) that 'num_episode' only greps with 1 number and not the whole list
            # and -x option for absolute perfect match, that 'num_episode' greps on '14' as a whole and not '1' & '4'
            if [ $(echo $episode1 | cut -d' ' -f$count| grep -cx $num_episode) -gt 0 ]; then
                
                ep1=$(echo $episode1 | cut -d' ' -f$count)
                ep2=$(echo $episode2 | cut -d' ' -f$count)

                EPISODE_NAME="$(sed -n ${ep1}p $PATH_FILE_WITH_EPISODE_NAME)"
                EPISODE_NAME="${EPISODE_NAME} + $(sed -n ${ep2}p $PATH_FILE_WITH_EPISODE_NAME)"
                EPISODE_NUMBER="$( printf %02d"&"%02d $ep1 $ep2)"
                
                mv "$file" "$PATH_SERIE_FOLDER/$SEASON_NAME - ${SEASON_NUMBER}x$EPISODE_NUMBER - $EPISODE_NAME.$ext" 2> /dev/null
                num_episode=$((num_episode+2))
                ((count++))
            else
                EPISODE_NAME="$(sed -n ${num_episode}p $PATH_FILE_WITH_EPISODE_NAME)"
                EPISODE_NUMBER="$( printf %02d $num_episode )"

                mv "$file" "$PATH_SERIE_FOLDER/$SEASON_NAME - ${SEASON_NUMBER}x$EPISODE_NUMBER - $EPISODE_NAME.$ext" 2> /dev/null
                ((num_episode++))
            fi
        fi

    done

    # Double check that there is the same amount of .srt files as mkv/mp4/avi files.
    # It could be possible to have a few HC subtitles or embedded, and some written in a .srt files.
    # If the number of .srt files differs from the number of movie files, the script will wrongly rename the subtitles. And good luck with that.
    if [ $(find $PATH_SERIE_FOLDER  -name "*.srt" | wc -l) ==  $(find $PATH_SERIE_FOLDER  -name "*.mkv" -o -name "*.mp4" -o -name "*.avi" 2> /dev/null | wc -l) ]; then
        num_episode=1
        count=1
        ext="en.srt"
        
        for file in $(find $PATH_SERIE_FOLDER  -name "*.srt" | sort -V)
        do
            if [ $OPTION == "DEFAULT" ]; then
                EPISODE_NAME="$(sed -n ${num_episode}p $PATH_FILE_WITH_EPISODE_NAME)"
                EPISODE_NUMBER="$( printf %02d $num_episode )"
            
                mv "$file" "$PATH_SERIE_FOLDER/$SEASON_NAME - ${SEASON_NUMBER}x$EPISODE_NUMBER - $EPISODE_NAME.$ext" 2> /dev/null
                ((num_episode++))

            elif [ $OPTION == "MERGE" ]; then
                if [ $(echo $episode1 | grep -c $num_episode) -gt 0 ]; then
                    ep1=$(echo $episode1 | cut -d' ' -f$count)
                    ep2=$(echo $episode2 | cut -d' ' -f$count)
                    
                    EPISODE_NAME="$(sed -n ${ep1}p $PATH_FILE_WITH_EPISODE_NAME)"
                    EPISODE_NAME="${EPISODE_NAME} + $(sed -n ${ep2}p $PATH_FILE_WITH_EPISODE_NAME)"
                    EPISODE_NUMBER="$( printf %02d"&"%02d $ep1 $ep2)"
                    
                    mv "$file" "$PATH_SERIE_FOLDER/$SEASON_NAME - ${SEASON_NUMBER}x$EPISODE_NUMBER - $EPISODE_NAME.$ext" 2> /dev/null
                    num_episode=$(($num_episode+2))
                    ((count++))
                else
                    EPISODE_NAME="$(sed -n ${num_episode}p $PATH_FILE_WITH_EPISODE_NAME)"
                    EPISODE_NUMBER="$( printf %02d $num_episode )"
                    
                    mv "$file" "$PATH_SERIE_FOLDER/$SEASON_NAME - ${SEASON_NUMBER}x$EPISODE_NUMBER - $EPISODE_NAME.$ext" 2> /dev/null
                    ((num_episode++))
                fi
            fi
        done

    fi
echo "Episode renaming done"
fi

rm $PATH_FILE_WITH_EPISODE_NAME





