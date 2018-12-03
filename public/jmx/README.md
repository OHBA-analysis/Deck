
# Jonathan's Mex library

This is a simple and tiny C++11 library to make it easier to work with both Matlab and C++.

The [official Mex API](?) provides a lot of functions to work with Matlab containers in C or C++, but I found the guidance rather poor, and the tools quite verbose and clunky in practice. Writing a Mex function which takes and returns cells, structures and matrices, dealing with default values, reading from / saving to MAT files, and capable of detecting keyboard interruptions, typically requires several hours or even days to get right for non-experienced users. 

If you already know both languages, it shouldn't be that difficult to connect existing C++ code with Matlab, and that is why I wrote my library. I tried to keep it as lean as possible (suggestions welcome): just the necessary and sufficient functionality to take the pain away, no fluff or fancy, you can build more complicated things over it if needed. I hope it will be helpful to you as much as it is for me. Please [open an issue](?) if you find a bug, or if you think there is something missing; and if you like it, please star the repo!

## Contributors

- Jonathan HADIDA ([jhadida87@gmail.com](mailto:jhadida87@gmail.com))
  - Initial design, implementation and documentation (July 2018)
