#!/usr/bin/env python3
# -*- coding:utf-8 -*-



# Overall description:
# 
# The .txt input file architerture is as follows:
# +-----------------+
# |Season_Name      |
# |X                |
# |Y                |
# +-----------------+
# X represent the Season number, Y represent the total of .mkv/.mp4 file in the folder.
# Y will help to secure the script. If Y and the number found on internet differ we want to be able to know it.
# 
# The .txt output file architecture is as follows:
# +-----------------+
# |Episode Name 1   |
# |Episode Name 2   |
# |...              |
# |...              |
# +-----------------+
# 
# If the renaming process is aborted then the .txt output file architecture is as follows:
# +-----------------+
# |***ERR***        |
# |                 |
# |                 |
# +-----------------+
# 
# If there is a typo in the Season Name then the .txt output file architecture is as follows:
# +-----------------+
# |Episode Name 1   |
# |Episode Name 2   |
# |...              |
# |...              |
# |***New_Name = XX |
# +-----------------+
# With XX as the Season Name without the typo. This info will be used to rename properly all the .mkv and .srt but also the main folder.
# 
# If there is a merge needed in the naming of 2 episodes then the .txt output file architecture is as follows:
# +-----------------+
# |Episode Name 1   |
# |Episode Name 2   |
# |...              |
# |...              |
# |***Merge = X Y   |
# +-----------------+
# With X & Y the 2 episode numbers to merge





import os
import time
import pytvmaze
import sys

# https://github.com/srob650/pytvmaze

# black='\033[30m'
# Darkred='\033[31m'
# green='\033[32m'
# orange='\033[33m'
# blue='\033[34m'
# purple='\033[35m'
# cyan='\033[36m'
# lightgrey='\033[37m'
# darkgrey='\033[90m'
# lightred='\033[91m'
# lightgreen='\033[92m'
# yellow='\033[93m'
# lightblue='\033[94m'
# pink='\033[95m'
# lightcyan='\033[96m'

web_nbr_of_episodes = 0

def printDarkRed(word):     print("\033[31m {}\033[00m" .format(word))
def printOrange(word):      print("\033[33m {}\033[00m" .format(word))
def printLightGrey(word):   print("\033[37m {}\033[00m" .format(word))
def printLightRed(word):    print("\033[91m {}\033[00m" .format(word))
def printLightGreen(word):  print("\033[92m {}\033[00m" .format(word))
def printYellow(word):      print("\033[93m {}\033[00m" .format(word))
def printLightPurple(word): print("\033[94m {}\033[00m" .format(word))
def printPink(word):        print("\033[95m {}\033[00m" .format(word))
def printCyan(word):        print("\033[96m {}\033[00m" .format(word))


def options (mkv_nbr, web_nbr):
    if (mkv_nbr < web_nbr): # ask if merge 2 or more episodes names
        input_list = input("List the episodes' number you want to merge, separated by spaces: ")
        input_list = input_list.split(' ')

        if len(input_list) != 2:
            print("Please only put 2 episodes you want to merge together")
            options(mkv_nbr, web_nbr)
        else:
            if (int(input_list[0]) > int(input_list[1])):
                input_list[1], input_list[0] = input_list[0], input_list[1]
            return (input_list[0], input_list[1])
    else: # remind that the exciding files wont be renamed
        return (0,0)

def ask_yes_no_question (question):
    answer = input(question+" (y/n)")
    if (answer == "n") or (answer == "N") or (answer == "no") or (answer == "NO"):
        return 0
    elif (answer == 'y') or (answer == 'Y') or (answer == 'yes') or (answer == 'YES'):
        return 1
    else:
        printPink("You smart ass... this is a yes/no question")
        return ask_yes_no_question (question)


episode_file_path = sys.argv[1]

with open (episode_file_path,"r") as my_file:
    season_name = my_file.readline().rstrip()
    season_number = my_file.readline().rstrip()
    txt_total_ep = my_file.readline().rstrip()

with open (episode_file_path,"w") as my_file:

    try:
        tvm = pytvmaze.TVMaze()
        my_show = tvm.get_show(show_name=season_name,embed='episodes')
    except pytvmaze.exceptions.ShowNotFound:
        # The above listed color print functions can't take more than 1 expression, the line below prints as printLightRed  but with several variables
        print("\033[91mCouldn't find \"{}\" online, look for typos or rename the episodes yourself\nSorry\033[00m".format(season_name))
        my_file.write("***ERR***"+'\n')
        input("Press Enter to exit")
        raise SystemExit("") #identical to sys.exit(), but in that case I don't need to import another library (here 'sys')
    except pytvmaze.exceptions.ConnectionError:
        printLightRed("No internet internet connection, check your connection and try again.")
        my_file.write("***ERR***"+'\n')
        input("Press Enter to exit")
        raise SystemExit("") #identical to sys.exit(), but in that case I don't need to import another library (here 'sys')
    except:
        printLightRed("Unexpected Error. Check if multiple series have the same name, that could explain why.")
        my_file.write("***ERR***"+'\n')
        input("Press Enter to exit")
        raise SystemExit("")

    try:
        for episode in my_show[int(season_number)]:
            web_nbr_of_episodes += 1
    except pytvmaze.exceptions.SeasonNotFound:
        # The above listed color print functions can't take more than 1 expression, the line below prints as printLightRed but with several variables
        print ("\033[91mCouldn't find the Season {} look for typos or rename the episodes yourself\nSorry\033[00m ".format(season_number))
        my_file.write("***ERR***"+'\n')
        input("Press Enter to exit")
        raise SystemExit("") #identical to  sys.exit(), but in that case I don't need to import another library (here 'sys')

    # if the total episode number in the folder is different from the number of episode found on internet 
    if int (txt_total_ep) != web_nbr_of_episodes:
        printLightRed("\n\r/!\\ Be careful! The number of episodes you have doesn't match the actual number of episode in this TV show")
        print("Total .mkv/.mp4 files counted: {}\nTotal episodes found online: {}".format(txt_total_ep,web_nbr_of_episodes))
        if int (txt_total_ep) < web_nbr_of_episodes:
            printLightGrey("Tip: Two of your episodes might have been merged into one")
        else:
            printLightGrey("Tip: Check if there isn't any 'special Christmas' kind of episode that sliped in your folder")
        printLightGrey("Here is the list of all the episode name:")

        for episode in my_show[int(season_number)]:
            printLightGreen(episode)
        if int (txt_total_ep) < web_nbr_of_episodes:
            answer = ask_yes_no_question("Do you want to merge the naming of 2 episodes into 1?")
            #answer = input("Do you want to merge the naming of 2 episodes into 1? (y/n) ")
        else:
            answer = ask_yes_no_question("Do you want to continue the naming process? (the last "+str(int(txt_total_ep) - web_nbr_of_episodes)+" episode(s) won't be properly renamed)")
            #answer = input("Do you want to continue the naming process? (the last "+str(int(txt_total_ep) - web_nbr_of_episodes)+" episode(s) won't be properly renamed) (y/n) ")

        if answer:
            (merge1,merge2) = options(int(txt_total_ep), int(web_nbr_of_episodes))
            for episode in my_show[int(season_number)]:
                my_file.write(episode.title+'\n')
            if (int(merge1) != 0): # means merge needed
                my_file.write("***Merge = "+merge1+' '+merge2+'\n')
        elif not answer:
            printPink("Renaming process aborted")
            my_file.write("***ERR***"+'\n')

            
    else:
        for episode in my_show[int(season_number)]:
            my_file.write(episode.title+'\n')

    # in case there is a typo in the season name given by the bash script. We want to rename all the episodes with the right name.
    if my_show.name != season_name:
        my_file.write("***New_Name = "+my_show.name+'\n')
        print("\033[96mBe careful there was a typo in your folder name, it was \"{}\" instead of \"{}\"\nI corrected it for you\033[00m".format(season_name,my_show.name))







