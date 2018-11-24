
# MAT files

MAT files allow writing data to disk, and sharing it with others.
It is probably simpler and clearer to deal with MAT reading/writing directly from Matlab, but we also provide functions in this library.

## Reading MAT files

Simple wrapper, behaves like a struct.

## Creating MAT files

> Pay attention to storage format

Create using Mex API (especially format), and then wrap using `jmx::MAT`, set variables using either function `set_variable` or method `set_value`.
