
## Proposal

The idea is to merge gradually Deck, Nest and JMX.

Nest will keep all the model building + simulation stuff, but will lose all maths + dsp + ui stuff.

The maths + ts parts of Deck will be moved to another module called `ant` (for Analysis Toolbox), which will also host the previous stuff taken from Nest.

JMX will also be added as a subfolder of Deck, added to the path on startup.
This will allow `ant` to have optimised C++ routines independent of the big libs (Drayn, OSD, NSL).


Overall, this will make Deck quite a big library. Thoughts need to be given about documentation.
In favour of one shallow Docsify pointing to smaller independent ones for Deck, AnT and JMX.
