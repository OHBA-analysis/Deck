
## Installation

### Requirements

Make sure you have `git` installed on your machine (type `git --version` in a terminal). 
If not, follow [these instructions](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) (if you are on OSX you can also use [Homebrew](http://brew.sh/)).

### Simplest case

From the Matlab console:
```
folder = fullfile( userpath(), 'deck' ); % where Deck will be downloaded
setenv( 'DECK_FOLDER', folder ); % can be used within system calls
!git clone https://github.com/jhadida/deck.git "$DECK_FOLDER"
addpath(folder);
dk_startup;
```

From a terminal:
```
DECK_FOLDER=${HOME}/Documents/MATLAB/deck
git clone https://github.com/jhadida/deck.git "$DECK_FOLDER"
echo
echo "All done. To use it, type in the Matlab console:"
echo ">> addpath('$DECK_FOLDER');"
echo ">> dk_startup;"
```

### Otherwise

 - Clone this repository wherever you like (`git clone https://github.com/jhadida/deck.git "/wherever/I/Like"`), or download a zip by clicking the green button at the top of this page.
 - From the Matlab console, add the folder to your path using `addpath('/wherever/I/Like');`. (Do **NOT** use `genpath`!)
 - Then, type `dk_startup`.

### Updates

`git checkout tag/v0.1 # or whatever version you want`
You can see what versions are available [here](https://github.com/jhadida/deck/releases).