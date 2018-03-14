
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)

## Deck

A general-purpose Matlab (2015+) toolbox that doesn't get in your way.

Documentation is being written on and off, but helptext is already written for most function and should be enough to get you started. 

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


## Usage

### How do I call these functions?

All Deck functions can be called as if they were methods of an object `dk.<submodule>.<function>( <args> )`. For example: `dk.util.array2string( [1,2,3], 'latex' );`

As you can see in the folder `+dk`, there is a lot of stuff in there. The documentation is being written on and off (sorry), but for now you'll either need to guess from the names that 'such' function might be relevant, or ask someone who knows, or maybe try one at random :)

Either way, there is a help-text written for most functions, which should be enough to get you started (if you're a hacker, the code should also be fairly legible). To get help about a function, type `help dk.some.function` from the Matlab console. If that's not helpful, and you really want to know, [open an issue](https://github.com/jhadida/deck/issues) asking for documentation about that particular function.

### Undefined variable "dk" or class "dk.blah".

You installed Deck previously, and it worked, but now it doesn't?
You just need to add the folder to your Matlab path again. From the Matlab console:
```
folder = fullfile( userpath(), 'deck' ); % or wherever you cloned/downloaded Deck
addpath( folder ); dk_startup;
```

If you use Deck regularly, and don't want to do this every time, add the previous commands to your [startup.m](http://uk.mathworks.com/help/matlab/ref/startup.html).

### Updates

If you downloaded Deck using `git`, you will also be able to get all future versions simply by typing from a terminal:
```
cd /wherever/deck/is
git checkout tag/v0.1 # or whatever version you want
```

You can see what versions are available [here](https://github.com/jhadida/deck/releases).

## Contributions

This is free software, all contributions are welcome. 
Bugs can be reported by creating new issues (check the existing open+closed ones before posting please).

For contributing, you'll need a [GitHub account](https://github.com/join). Also, checkout [the docs](https://help.github.com/articles/connecting-to-github-with-ssh/) to link your various computers with your account using SSH keys (avoids having to type passwords).

Then, the recipe is: [fork](https://help.github.com/articles/fork-a-repo/) it, change it ([learn how](https://rogerdudler.github.io/git-guide/)), push it, [pull-request](https://help.github.com/articles/creating-a-pull-request/) it. Send me a message if you're not sure.

## Bugs

Report anything fishy by creating a [new issue](https://github.com/jhadida/deck/issues). 

