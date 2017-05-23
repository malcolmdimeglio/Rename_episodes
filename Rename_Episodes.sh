#!/bin/bash

IFS=$'\n'   #Input Field Separator

SCRIPT_FOLDER_PATH=$PWD
FILE_WITH_EPISODE_NAME="list_of_episode_names.txt"
SEASON_NAME=""
SEASON_NUMBER=""
PARENT_FOLDER_NAME=""
SERIE_FOLDER_PATH=$(readlink -e $1)

# Overall description:

# This code will rename : - the main folder "SEASON_NAME - Season X" if there is a typo in the Season Name
#                         - all the .mkv & .mp4 file as follows "Saison Name - 02x13 - Episode Name.mkv(.mp4)"
#                         - all the .srt file as follows "Saison Name - 02x13 - Episode Name.en.srt"
# 
# In order to work properly an API needs to be installed (to get the season's informations)
# but also the GNU sed wich is not a built in feature on MacOS, as well as the gnu version of readlink:
# The following commands will get you the right setup
# 
#  brew install coreutils
#  brew install -with-default-names gnu-sed
#  pip install pytvmaze (could need a 'pip install --upgrade pytvmaze')
#  
# coreutils gets you the linux like command greadlink which work as readlink.
#  
#  modify .bash_profile and add the following lines
#  # enable Homebrew coreutils
#    export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
#    export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
#    
# These lines will allow you to use all coreutils command lines without the need to add 'g' before. 
# Adding it to the path alows you to not take care of it anymore and use GNU command.
# 



# (Unfortunatly) Since the command 'ls -v' doesn't seem to be working here (but does on linux) we need to pre-process the episodes' name.
# The function below lists all the files that have a single number enclosed between two caracters in their name (i.e. Hello1you)
# if there is more than one occurence in the name, we want to change them all
# We want to add a 0 before the number (for single digit number) in the file name (i.e. Hello01you)
# this will help later to list and sort all the files.
# If it's not done, episode10 would be listed before episode2 which will fuck everything up
# now with episode2 named as episode02, the problem is solved
# This fucntion also reformat the episode names written in the text file. (Gets all first letter with capital case)
function rename_files_and_format_episode_name()
{
    for my_file in $(ls *.mkv *.mp4 | grep '[^0-9][0-9][^0-9]'); do
        mv $my_file $(echo $my_file | sed 's/\([^0-9]\)\(\([0-9]\)[^0-9]\)/\10\2/g')
    done

    # this test is not really important, though it prevents an error log to be printed if there is no .srt files in the folder
    if [ $1 == "SRT_PRESENT" ]; then
        for my_file in $(ls *.srt | grep '[^0-9][0-9][^0-9]'); do
            mv $my_file $(echo $my_file | sed 's/\([^0-9]\)\(\([0-9]\)[^0-9]\)/\10\2/g')
        done
    fi


    # 1st lower case all the caracter in order to work on a simple base
    # 2nd upper case the first letter of the line
    # 3rd upper case all the letter following a "space" caracter
    sed -i -e 's/[A-Z]/\L&/g' -e 's/^./\U&/g' -e 's/ ./\U&/g' $FILE_WITH_EPISODE_NAME   
}

# This function will rename all the episode with the same format
# e.g. Saison Name - 02x13 - Episode Name.mkv
function rename_mkv()
{
    num_episode=1
    for file in $(ls *.mkv *.mp4)
    do
        if [ $(echo $file | grep -c ".mkv") -gt 0 ]; then
            ext="mkv"
        elif [ $(echo $file | grep -c ".mp4") -gt 0 ]; then
            ext="mp4"
        fi

        EPISODE_NAME="$(sed -n ${num_episode}p $FILE_WITH_EPISODE_NAME).$ext"
        EPISODE_NUMBER="$( printf %02d $num_episode )"
        
        mv "$file" "$SEASON_NAME - ${SEASON_NUMBER}x$EPISODE_NUMBER - $EPISODE_NAME"
        ((num_episode++))
    done
}
 
 # same as above but for .srt (subtitles files) ** the syntax is slightly different
 function rename_srt()
{
    num_episode=1

    for file in $(ls *.srt)
    do
        EPISODE_NAME="$(sed -n ${num_episode}p $FILE_WITH_EPISODE_NAME).en.srt"
        EPISODE_NUMBER="$( printf %02d $num_episode )"

        mv "$file" "$SEASON_NAME - ${SEASON_NUMBER}x$EPISODE_NUMBER - $EPISODE_NAME"
        ((num_episode++))
    done
}

# Usually the folder used to put all the .mkv and .srt file is name as followed : Season_name - Season X
# With X a number (2, 5, 10 etc.)
# In order to make the work easier for the python script, we want to save in a text file the name of the Serie, its season number and how many episode (file) there is.
# This function will create a .txt file with these 3 information thanks to the main folder name and the files it contains.
# The python scrpit will then extract these information and work from there.
function write_my_txt_file()
{

    # INPUT PATH : /xxx/yyy/zzz/Season_Name - Season X
    


    # Get the name of the main folder we want to extract the informations of. (here : Season_Name - Season X)
    # This folder contains all the .mkv and .srt + the script's folder
    PARENT_FOLDER_NAME=$(basename $(readlink -e .))

    # Now truncate both sides of the folder's name and store the result
    infos=$(echo $PARENT_FOLDER_NAME | sed 's/\ \-\ /\n/g')
    # We want the number of .mkv file stored. This will help in case two episodes have been merged into one.
    # whereas on internet they may appear as two different ones. 
    # We will store that value in the .txt file later, then the python script will check the accuracy and prevent shifting in naming.
    total_mkv_file=$(ls *.mkv *.mp4 | wc -l | sed 's/\t//')
    
    cd $SCRIPT_FOLDER_PATH
    # now at /aaa/bbb/ccc/Script_Episode

    # This create the .txt file and give permission to modify it, then write the info in it
    touch $FILE_WITH_EPISODE_NAME
    chmod u+x $FILE_WITH_EPISODE_NAME

    # Let's store the useful information
    for info in $infos
    do
        echo $info >> $FILE_WITH_EPISODE_NAME
    done

    echo $total_mkv_file >> $FILE_WITH_EPISODE_NAME
    # At the end :
    # 1st line = Season Name
    # 2nd line = Season N
    # 3rd line = number of episodes (.mkv files)

    # We save the season Name and Season Number in global variables we'll use later
    SEASON_NAME="$(sed -n 1p $FILE_WITH_EPISODE_NAME)"

    # We don't actually need "Season" of "Season N", only the number matters
    sed -i '2 s/[^0-9]//g' $FILE_WITH_EPISODE_NAME
    # We want the season number a 2 digit number 02, 05, 10 etc.
    SEASON_NUMBER="$( sed -n 2p $FILE_WITH_EPISODE_NAME | sed 's/^[1-9]/0&/')"

    cd $SERIE_FOLDER_PATH
    # same current directory as it entered the funtion



    # OUTPUT PATH : /xxx/yyy/zzz/Season_Name - Season X
}
 

cd $SERIE_FOLDER_PATH
# Now at /xxx/yyy/zzz/Season_Name - Season X
write_my_txt_file

cd $SCRIPT_FOLDER_PATH
# Now at /aaa/bbb/ccc/Script_Episode
./find_name_on_internet.py

# Move the python generated .txt file in the working directory (which contains all the .mkv & .srt files)
cp $SCRIPT_FOLDER_PATH/$FILE_WITH_EPISODE_NAME $SERIE_FOLDER_PATH

cd $SERIE_FOLDER_PATH
# Now at /xxx/yyy/zzz/Season_Name - Season X
# 
if [ $(grep -c "\*\*\*New_Name" $FILE_WITH_EPISODE_NAME) -gt 0 ] # if new name to be defined then change it (because of a possible typo in the folder name)
then
    rename_line_number=$( sed -n "/\*\*\*New_Name/=" $FILE_WITH_EPISODE_NAME)
    SEASON_NAME="$( sed -n ${rename_line_number}p $FILE_WITH_EPISODE_NAME | sed 's/\*\*\*New_Name \= //')"
    # delete the line with "***New_Name = xx" that it won't get somehow in the way of renaming process. Shouldn't happen anyway though
    # sed -i '$d' $FILE_WITH_EPISODE_NAME (That cmd deletes the last line, which is not necesserly ***New_Name, we might have added other info after, later on)
    sed -i '/\*\*\*New_Name/d' $FILE_WITH_EPISODE_NAME
    
    cd ..
    # now at /xxx/yyy/zzz/
    new_folder_name="$SEASON_NAME - Season $(echo $SEASON_NUMBER | sed 's/0\([1-9]\)/\1/')"

    mv $PARENT_FOLDER_NAME $new_folder_name
    PARENT_FOLDER_NAME=$new_folder_name
    SERIE_FOLDER_PATH=$(readlink -e $new_folder_name)
    PARENT_FOLDER_NAME=$new_folder_name
    
    cd $SERIE_FOLDER_PATH
    # now at /xxx/yyy/zzz/Season_Name - Season X (with updated Season_Name)
fi
    
if [ $(grep -c "\*\*\*ERR\*\*\*" $FILE_WITH_EPISODE_NAME) -eq 0 ]; then # if no Error in file
    
    if [ $(ls | grep -c ".srt") -gt 0 ]; then
        rename_files_and_format_episode_name "SRT_PRESENT"
        rename_srt
    else 
        rename_files_and_format_episode_name "SRT_NOT_PRESENT"
    fi      
    rename_mkv
fi


rm $FILE_WITH_EPISODE_NAME

# For some unknown reasons, if : 
#   - There is a typo in the folder name AND the wrong amount of file compared to the amount of episodes found on internet
#   - The folowing 'rm' command is used without the -f option 
# Then .txt file will be removed but will still appear in the folder... (trying to open it will raise an Error saying : file can't be found)
# force option solves that problem.
# 
# Somehow adding a "sleep 1" command before prevent that error and allows the rm command without -f option
# It is probably because of a parallel threading of "finder" execution. Makes sens but I have no idea how to prove it though
rm $SCRIPT_FOLDER_PATH/$FILE_WITH_EPISODE_NAME







