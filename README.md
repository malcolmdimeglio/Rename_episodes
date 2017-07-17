# Rename Episodes


## Goal

 - Rename all the .mkv .mp4 & .srt files with a common pattern
 - Rename the main folder if there is a typo in the Season Name

## Installation instruction
You will need python 3 installed. This script won't run with Python 2.
Both Bash & Python languages are used here.

### API Installation

You will need an API to get the season's information
```bash
$ pip install pytvmaze
```
See README here: https://github.com/srob650/pytvmaze

### For OSX users
Coreutils package is not a built-in feature on OSX.
This script uses GNU bash command. If you want this code to run smoothly you need to execute the following lines.
#### Installing Coreutils command lines
```bash
brew install coreutils
```
#### Export to the PATH
modify your .bash_profile and add the following lines
```bash
# enable Homebrew coreutils
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
```

## Example
```bash
./Rename_Episodes.sh [PATH_TO_FOLDER]
./Rename_Episodes.sh ../../Black\ Mirror\ -\ Season\ 2
./Rename_Episodes.sh /Users/Toto/Desktop/Black\ Mirror\ -\ Season\ 2
```
The script can allow either absolute or relative path as a parameter.
The folder name MUST HAVE the following name structure: '[SeasonName] - [Season SeasonNumber]'

The 2 white spaces around the dash are important.
White spaces in the SeasonName are allowed


**Original name:** Black.Mirror.S01E02.1080p.WEB-DL-Special.mkv

**Final name:** Black Mirror - 01x02 - Fifteen Million Merits.mkv

## Special behaviour
This script handles different special behaviour like:
- **Reasonable amount of typos:**

If your folder's name is *Blck Mirror* instead of *Black Mirror* the script will correct it for you. You will see the following line on the prompt 

```
Be careful there was a typo in your folder name, it was "Blck Mirror" instead of "Black Mirror"
I corrected it for you
```
Then, your folder's name will be changed automatically

If the typo is too big then you'll get the following result
```
Couldn't find "Blk Mrrr" online, look for typos or rename the episodes yourself
Sorry
```
The program will exit. You must take care of the problem then run the script again 
- **A season number that doesn't exist (yet?)**
```
Couldn't find the Season 99 look for typos or rename the episodes yourself
Sorry
```
The program will exit. You must take care of the problem then run the script again 

- **The total amount of episode in the folder differs from the number of episode found online**

You will be shown all the episodes found online, and ask what kind of action you want to do depending if you have more or less files than the actual number episodes.
```
/!\ Be careful! The number of episodes you have doesn't match the actual number of episode in this TV show
Total .mkv/.mp4 files counted: 2
Total episodes found online: 3
 Tip: Two of your episodes might have been merged into one
 Here is the list of all the episode name:
 S02E01 Be Right Back
 S02E02 White Bear
 S02E03 The Waldo Moment
Do you want to merge the naming of 2 episodes into 1? (y/n)
```
If your answer is 'n' then the renaming process will be aborted, you will keep the original name and the program will exit.

If your answer is 'y' you will be asked which episodes' name you want to merge. This situation sometimes happens for season finale or pilot episodes.

`List the episodes' number you want to merge, separated by spaces: 2 3`

Your episode will be renamed as such: Black Mirror - 02x02&03 - White Bear + The Waldo Moment.mkv
