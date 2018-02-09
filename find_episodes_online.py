#!/usr/bin/env python3
# -*- coding:utf-8 -*-

# Overall description:
# 
# The .txt input file architecture is as follows:
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
# With XX as the Season Name without the typo.
# This info will be used to rename properly all the .mkv and .srt but also the main folder.
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

import pytvmaze
import sys
import re

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


def print_dark_red(word): print("\033[31m {}\033[00m" .format(word))


def print_light_grey(word): print("\033[37m {}\033[00m" .format(word))


def print_light_red(word): print("\033[91m {}\033[00m" .format(word))


def print_light_green(word): print("\033[92m {}\033[00m" .format(word))


def print_pink(word): print("\033[95m {}\033[00m" .format(word))


def options(mkv_nbr, web_nbr):
    input_list = ['']
    if web_nbr - mkv_nbr == 1:  # 2 episodes to merge
        input_list = input("List the episodes' number you want to merge, separated by a comma: e.g: 3,4"+'\n')
    elif web_nbr - mkv_nbr > 1:  # more than 2 episodes to merge
        input_list = input("List the episodes' number you want to merge, separated by a comma: e.g: 1,2 7,8 11,12"+'\n')
    else:
        return []
    
    if input_list == ['']:
        return []
  
    input_list = re.split(' |,',input_list)
    
    if web_nbr - mkv_nbr != len(input_list)/2:  #input_list list a pair of episode for 1 merge. '/2' allows to get the number of merge needed.
            print("Be carefull you need to list {} pair(s) of episode to merge not {}" .format(str(web_nbr - mkv_nbr), str(int(len(input_list)/2))))
            return options(mkv_nbr, web_nbr)

    for i in range(0,len(input_list)-1,2):  # keep an order. if 4,3 is given, turn it into 3,4
        if input_list[i] > input_list[i+1]:
            input_list[i], input_list[i+1] = input_list[i+1], input_list[i]

    for i in range(0,int(len(input_list)/2),1):  # turn the current list from ['2', '3', '5', '6', '8', '9'] into ['2,3', '5,6', '8,9']
        input_list[i:i+2] = [','.join(input_list[i:i+2])]
    
    return input_list


def ask_yes_no_question(question):
    ans = input(question+" (y/n)")
    if (ans == "n") or (ans == "N") or (ans == "no") or (ans == "NO"):
        return 0
    elif (ans == 'y') or (ans == 'Y') or (ans == 'yes') or (ans == 'YES'):
        return 1
    else:
        print_pink("You smart ass... this is a yes/no question")
        return ask_yes_no_question(question)


episode_file_path = sys.argv[1]

with open(episode_file_path, "r") as my_file:
    season_name = my_file.readline().rstrip()
    season_number = my_file.readline().rstrip()
    txt_total_ep = my_file.readline().rstrip()

with open(episode_file_path, "w") as my_file:
    try:
        tvm = pytvmaze.TVMaze()
        my_show = tvm.get_show(show_name=season_name, embed='episodes')
    except pytvmaze.exceptions.ShowNotFound:
        # The above listed color print functions can't take more than 1 expression,
        # the line below prints as print_light_red  but with several variables
        print("\033[91mCouldn't find \"{}\" online, look for typos or rename the episodes yourself\nSorry\033[00m". format(season_name))
        my_file.write("***ERR***"+'\n')
        input("Press Enter to exit")
        raise SystemExit("")  # identical to sys.exit()
    except pytvmaze.exceptions.ConnectionError:
        print_light_red("No internet internet connection, check your connection and try again.")
        my_file.write("***ERR***"+'\n')
        input("Press Enter to exit")
        raise SystemExit("")
    except:
        print_light_red("Unexpected Error. Check if multiple series have the same name, that could explain why.")
        my_file.write("***ERR***"+'\n')
        input("Press Enter to exit")
        raise SystemExit("")

    try:
        for episode in my_show[int(season_number)]:
            web_nbr_of_episodes += 1
    except pytvmaze.exceptions.SeasonNotFound:
        print("\033[91mCouldn't find the Season {} look for typos or rename the episodes yourself\nSorry\033[00m ". format(season_number))
        my_file.write("***ERR***"+'\n')
        input("Press Enter to exit")
        raise SystemExit("")

    # if the total episode number in the folder is different from the number of episode found on internet 
    if int(txt_total_ep) != web_nbr_of_episodes:
        print_light_red("\n\r/!\\ Be careful! The number of episodes you have doesn't match the actual number of episode in this TV show")
        print("Total .mkv/.mp4 files counted: {}\nTotal episodes found online: {}".format(txt_total_ep, web_nbr_of_episodes))
        if int(txt_total_ep) < web_nbr_of_episodes:
            print_light_grey("Tip: Two of your episodes might have been merged into one")
        else:
            print_light_grey("Tip: Check if there isn't any 'special Christmas' kind of episode that sliped in your folder")
            print_light_grey("Here is the list of all the episode name:")

        for episode in my_show[int(season_number)]:
            print_light_green(episode)
        if int(txt_total_ep) < web_nbr_of_episodes:
            answer = ask_yes_no_question("Do you want to merge the naming of 2 episodes into 1?")
        else:
            answer = ask_yes_no_question("Do you want to continue the naming process? (the last "+str(int(txt_total_ep) - web_nbr_of_episodes)+" episode(s) won't be properly renamed)")

        if answer:
            merge_ep = options(int(txt_total_ep), int(web_nbr_of_episodes))
            if merge_ep:
                for episode in my_show[int(season_number)]:
                    my_file.write(episode.title+'\n')
                if merge_ep:  # means merge needed
                    my_file.write("***Merge = ")
                    for ep in merge_ep:
                        my_file.write("{} " .format(str(ep)))
                    my_file.write('\n')
            else:
                print_pink("Renaming process aborted")
                my_file.write("***ERR***"+'\n')
        else:
            print_pink("Renaming process aborted")
            my_file.write("***ERR***"+'\n')
            
    else:
        for episode in my_show[int(season_number)]:
            my_file.write(episode.title+'\n')

    # in case there is a typo in the season name given by the bash script.
    # We want to rename all the episodes with the right name.
    if my_show.name != season_name:
        my_file.write("***New_Name = "+my_show.name+'\n')
        print("\033[96mBe careful there was a typo in your folder name, it was \"{}\" instead of \"{}\"\nI corrected it for you\033[00m". format(season_name, my_show.name))





