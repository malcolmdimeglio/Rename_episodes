#!/usr/bin/env python3
# -*- coding:utf-8 -*-



# Overall description:
# 
# The .txt input file architerture is as follows:
# +-----------------+
# |Season_Name      |
# |X         		|
# |Y 				|
# +-----------------+
# X represent the Season number, Y represent the total of .mkv file in the folder.
# Y will help to secure the script. If Y and the number found on internet differ we want to be able to know it.
# 
# The .txt output file architecture is as follows:
# +-----------------+
# |Episode Name 1   |
# |Episode Name 2   |
# |... 				|
# |... 				|
# +-----------------+
# 
# If the renaming process is aborted then the .txt output file architecture is as follows:
# +-----------------+
# |***ERR***      	|
# |         		|
# | 				|
# +-----------------+
# 
# If there is a typo in the Season Name then the .txt output file architecture is as follows:
# +-----------------+
# |Episode Name 1   |
# |Episode Name 2   |
# |... 				|
# |... 				|
# |***New_Name = XX	|
# +-----------------+
# With XX as the Season Name without the typo. This info will be used to rename properly all the .mkv and .srt but also the main folder.




import os
import time
import pytvmaze

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

def printDarkRed(word): 	print("\033[31m {}\033[00m" .format(word))
def printOrange(word): 		print("\033[33m {}\033[00m" .format(word))
def printLightGrey(word): 	print("\033[37m {}\033[00m" .format(word))
def printLightRed(word): 	print("\033[91m {}\033[00m" .format(word))
def printLightGreen(word): 	print("\033[92m {}\033[00m" .format(word))
def printYellow(word): 		print("\033[93m {}\033[00m" .format(word))
def printLightPurple(word): print("\033[94m {}\033[00m" .format(word))
def printPink(word): 		print("\033[95m {}\033[00m" .format(word))
def printCyan(word): 		print("\033[96m {}\033[00m" .format(word))

web_nbr_of_episodes = 0


with open ("list_of_episode_names.txt","r") as my_file:
	season_name = my_file.readline().rstrip()
	season_number = my_file.readline().rstrip()
	txt_total_ep = my_file.readline().rstrip()


try:
	my_show = pytvmaze.get_show(show_name=season_name,embed='episodes')
except pytvmaze.exceptions.ShowNotFound:
	# The above listed color print functions can't take more than 1 expression, the line below prints as printLightRed  but with several variables
	print("\033[91mCouldn't find \"{}\" online, look for typos or rename the episodes yourself\nSorry\033[00m".format(season_name))
	input("Press Enter to exit")
	raise SystemExit("") #identical to sys.exit(), but in that case I don't need to import another library (here 'sys')
except pytvmaze.exceptions.ConnectionError:
	printLightRed("No internet internet connection, check your connection and try again.")
	input("Press Enter to exit")
	raise SystemExit("") #identical to sys.exit(), but in that case I don't need to import another library (here 'sys')

with open ("list_of_episode_names.txt","w") as my_file:
	try:
		for episode in my_show[int(season_number)]:
			web_nbr_of_episodes += 1
	except pytvmaze.exceptions.SeasonNotFound:
		# The above listed color print functions can't take more than 1 expression, the line below prints as printLightRed but with several variables
		print ("\033[91mCouldn't find the Season {} look for typos or rename the episodes yourself\nSorry\033[00m ".format(season_number))
		input("Press Enter to exit")
		raise SystemExit("") #identical to  sys.exit(), but in that case I don't need to import another library (here 'sys')


	# if the total episode number in the folder is different from the number of episode found on internet 
	if int (txt_total_ep) != web_nbr_of_episodes:
		printLightRed("/!\\ Be careful! The number of episodes you have doesn't match the actual number of episode in this TV show")
		print("Total .mkv files counted: {}".format(txt_total_ep))
		printLightRed("Tip: Two of your episodes might have been merged into one")
		printLightGrey("Here is the list of all the episode name:")

		for episode in my_show[int(season_number)]:
			printLightGreen(episode)
		answer = input("Do you want to continue anyways? (y/n) ")

		if answer == "n":
			printPink("Renaming process aborted")
			my_file.write("***ERR***"+'\n')
		elif answer == 'y':
			for episode in my_show[int(season_number)]:
				my_file.write(episode.title+'\n')
		else:
			printPink("You smart ass... Renaming process aborted")
			my_file.write("***ERR***"+'\n')
			
	else:
		for episode in my_show[int(season_number)]:
			my_file.write(episode.title+'\n')

	# in case there is a typo in the season name given by the bash script. We want to rename all the episodes with the right name.
	if my_show.name != season_name:
		my_file.write("***New_Name = "+my_show.name+'\n')
		print("\033[96mBe careful there was a typo in your folder name, it was \"{}\" instead of \"{}\"\nI corrected it for you\033[00m".format(season_name,my_show.name))











