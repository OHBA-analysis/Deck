## Deck

A general-purpose Matlab (2015+) toolbox that doesn't get in your way.

Detailed documentation to come, though helptext should be sufficient to get started if you know what you want to use.

## Installation

Log into your account on [FMRIB's GitLab](https://git.fmrib.ox.ac.uk), and make sure you register [your SSH key](https://git.fmrib.ox.ac.uk/help/ssh/README) in your user settings.
Once this is done, go to your Matlab folder and type in a terminal:
```
git clone git@git.fmrib.ox.ac.uk:jhadida/deck.git <folder_name|default:"deck">
```
You now have all the sources installed, and will be able to update to future versions simply typing `git checkout tag/<tag_name>`.

To use Deck in Matlab, simply add the source folder to your path, and run `dk_startup`. 
Make sure you **DO NOT** use `genpath` when adding to the path; the folder _containing_ `+dk` should be on your path, not the folder `+dk` itself.
All of Deck's functions can then be called as if they were methods of an object, e.g. `dk.<submodule>.<function>( <args> )`.

## Bugs

Please report any bug to jhadida [at] fmrib.

