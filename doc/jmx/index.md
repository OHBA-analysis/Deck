
# Mex library

This library lives in the folder `jmx`, which is added to the path when calling `dk_startup()`.

Building the library can be done using `jmx_build()`, but you will only need to do this if you want to compile your own Mex files.
Calling `ant.compile()` (to compile the Mex files inside `ant`) automatically rebuilds JMX at every call.
