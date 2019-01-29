
# Printing and display

Either print to the console, or show information about containers.

## Redirecting `std::cout`

By default, using `printf` or `std::cout` will not reliably print to the Matlab console.
You need to use `mexPrintf` if you want to be sure to see it.

We provide seamless redirection of output stream `std::cout` to the Matlab console.

Call `cout_redirect` at the beginning of your Mex function, or instantiate `coutRedirection` in desired scope for temporary redirection.

## Displaying containers

> Under construction, experimental and basic
