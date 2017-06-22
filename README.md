
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](https://tldrlegal.com/license/gnu-affero-general-public-license-v3-(agpl-3.0))

## Deck

A general-purpose Matlab (2015+) toolbox that doesn't get in your way.

Detailed documentation to come. 
Helptext should be sufficient to get started if you know what you want to use.

## Installation

Make sure you have `git` installed on your machine (type `git --version` in a terminal). 
If not, follow [these instructions](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) (if you are on OSX you can also use [Homebrew](http://brew.sh/)).

Then go to the folder in which you'd like to install Deck and type:
```
git clone https://github.com/Sheljohn/Deck.git <folder_name|default:"deck">
```

To use Deck in Matlab, simply add the source folder to your path (do **NOT** use `genpath`), and run `dk_startup`. 
All of Deck's functions can then be called as if they were methods of an object, e.g. `dk.<submodule>.<function>( <args> )`.

You will also be able to install future versions simply by typing `git checkout tag/<tag_name>` from the terminal.

## Contributions

All contributions are welcome. Bugs can be reported by creating new issues (but please search the existing list before posting).

For contributing, you will need either a GitHub account, or an account on [FMRIB's GitLab](https://git.fmrib.ox.ac.uk). 
Either way, make sure you register your SSH key in your settings ([GitHub](https://help.github.com/articles/connecting-to-github-with-ssh/) | [FMRIB](https://git.fmrib.ox.ac.uk/help/ssh/README)).

Create a new branch and make your changes, then submit a pull request to the main repo. 
You can also create a fork on GitHub and then submit a pull requests with the proposed contribution.
Not all contributions will be added to the master branch, but centralising them into the same repository should facilitate sharing while keeping up-to-date with the master branch.

## Bugs

Please report any bug by creating a new issue, or directly to jhadida [at] fmrib.


