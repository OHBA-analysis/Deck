
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://www.gnu.org/licenses/agpl-3.0)

> **NOTE (Jan 2019):**
> This toolbox is undergoing a massive restructuration; the documentation might not be up-to-date, please rely on helptext only.
> A new, consolidated documentation is being written. The instructions below have been updated.

## Deck

A general-purpose Matlab (2015+) toolbox that doesn't get in your way. Deck is now an aggregate of 3 sub-projects:

 - The original `dk` toolbox, containing general tools to extend Matlab's capabilities;
 - The new `ant` toolbox, containing analysis tools mainly for time-series data;
 - The new `jmx` library, with a lightweight C++ library making it super-easy to write Mex files.

## Installation 

> Requirements:
> `git` is required to clone this repo (recommended install).
> You will need a C++ compiler setup with your Matlab installation in order to use `ant` and `jmx`.

From the Matlab console:
```
folder = fullfile( userpath(), 'deck' ); % where Deck will be downloaded
setenv( 'DECK_FOLDER', folder ); % can be used within system calls
!git clone https://github.com/jhadida/deck.git "$DECK_FOLDER"
addpath(folder);
dk_startup;
ant.compile(); % optional, if you want to use ant+jmx
```

From a terminal:
```
DECK_FOLDER=${HOME}/Documents/MATLAB/deck
git clone https://github.com/jhadida/deck.git "$DECK_FOLDER"
echo
echo "All done. To use it, type in the Matlab console:"
echo ">> addpath('$DECK_FOLDER');"
echo ">> dk_startup;"
echo ">> ant.compile(); % optional, if you want to use ant+jmx"
```

Alternatively without git, download a zip archive (green button near the top), extract it, add the folder to the Matlab path (do **NOT** use `genpath`), and type:
```
dk_startup;
ant.compile(); % optional, if you want to use ant+jmx
```

## Usage

### How do I call these functions?

All Deck functions can be called as if they were methods of an object `dk.<submodule>.<function>( <args> )`. For example: `dk.util.array2string( [1,2,3], 'latex' );`. Similarly for the `ant` library: `I = imread('cameraman.tif'); ant.img.show(im2double(I));`.

The functions in the `jmx` are prefixed with `jmx_`; they are mainly used to compile Mex files (see `help jmx`).

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
git pull
```

Then from the Matlab console:
```
ant.compile(); % optional, if you want to use ant+jmx
```

## Documentation

As you can see in the folder `+dk`, there is a lot of stuff in there. 
The documentation is being written on and off (sorry), and can be read by browsing the source folders on GitHub. 
Go ahead, click on [`+dk/+str`](https://github.com/jhadida/deck/tree/master/%2Bdk/%2Bstr) for example.

If you are looking for something specific, you'll either need to guess from the names that 'such' function might be relevant, or ask someone who knows, or maybe try something at random :)
Either way, there is a help-text written for most functions, which should be enough to get you started (if you're a hacker, the code should also be fairly legible). 
To get help about a function, type `help dk.some.function` from the Matlab console. 
If that's not helpful, and you really want to know, [open an issue](https://github.com/jhadida/deck/issues) asking for documentation about that particular function.

## Contributions

This is free software, all contributions are welcome. 
Bugs can be reported by creating new issues (check the existing open+closed ones before posting please).

For contributing, you'll need a [GitHub account](https://github.com/join). Also, checkout [the docs](https://help.github.com/articles/connecting-to-github-with-ssh/) to link your various computers with your account using SSH keys (avoids having to type passwords).

Then, the recipe is: [fork](https://help.github.com/articles/fork-a-repo/) it, change it ([learn how](https://rogerdudler.github.io/git-guide/)), push it, [pull-request](https://help.github.com/articles/creating-a-pull-request/) it. Send me a message if you're not sure.

## Bugs

Report anything fishy by creating a [new issue](https://github.com/jhadida/deck/issues). 

