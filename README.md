# Rename Episodes


## Goal

 - Rename all the .mkv .mp4 & .srt files from a given folder with a common pattern
 - Rename the main folder if there is a typo in the Season Name

## Installation instruction
You will need python 3 installed. This script won't run with Python 2.
Both Bash & Python languages are used here.

```bash
$ apt-get install python3
```
### API Installation

You will need an API to get the season's information
```bash
$ pip3 install pytvmaze
```
See README here: https://github.com/srob650/pytvmaze

### For Linux users
You don't need specific actions to run the script. Although, if you get the following error `ImportError: cannot import pytvmaze` it probably means you've installed the module under Python2.
To solve this problem:

```bash
mv /usr/local/lib/python2.X/dist-packages/pytvmaze /usr/local/lib/python3.Y/dist-packages/pytvmaze
```
Replace 'X' and 'Y' with your versions of python.

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
The folder name **MUST HAVE** the following name structure: '[SeasonName] - [Season SeasonNumber]'

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

*Before*
```
.
└── Blck Mirror - Season 2
    ├── Black.Mirror.S01E01.1080p.WEB-DL-Special.mkv
    ├── Black.Mirror.S01E02.1080p.WEB-DL-Special.mkv
    └── Black.Mirror.S01E03.1080p.WEB-DL-Special.mkv
```
*After*
```
.
└── Black Mirror - Season 2
    ├── Black Mirror - 01x01 - Be Right Back.mkv
    ├── Black Mirror - 01x02 - Fifteen Million Merits.mkv
    └── Black Mirror - 01x03 - The Waldo Moment.mkv
```

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

You will be shown all the episodes found online, and ask what kind of action you want to do. It will depend on whether you have more or less files than the real number of episodes.
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

## Testing
To have a preview of how this script works, you can use the Tests folder. You will find 2 other folders you will need to rename. (Make a copy first if you want to make several attempt and play with the limitation of the script)

Inside those folders are fake .mkv and .srt files. In the Homeland folder, you can open the files with a text editor. For instance, you will be able to read *episode1* for the 1st episode of the season and *Sous titre de l’épisode 1* for the subtitle of the 1st episode. All 12 .mkv and .srt files have these info. (I'll translate that last one to english - one day)

This will allow you to double check after runing the script that none of the names have been mixed up during the process.

Rename the 2 folders:

* Homeland - Season 5
* Incorporated - Season 1

- The Homeland folder contains no mistakes. (You can add a typo if you feel the need to test it : 'Homelnd - Season 5' or whichever you want)
- The Incorporated folder contains 9 episodes instead of 10. The 9th episode is the season finale, so it actually is both 9th and 10th episode merged.

Run these lines to start testing.
```bash
./Rename_episodes.sh Tests/Homeland\ -\ Season\ 5
./Rename_episodes.sh Tests/Incorporated\ -\ Season\ 1
```

## Word of the programmer
* If you use this code properly and what it is made for, it will work like a charm.
* If you find some flaws, please share them. I'll modify my code if I feel the need.
* It is of course possible to improve the script, make it bigger, add more information, but as for my own use, that's all I need.




