
# Arrays

Only vectors, matrices and volumes for now.
Basic usage: reading inputs, creating outputs, working with temporary arrays.
Advanced usage: understanding memory management.

 - Properties
 - Accessing elements
 - Reading variables
 - Creating variables
 - Temporary arrays
 - Memory management

## Properties

Number of elements.
Size: vector `n`, matrix `nr,nc`, volume `nr,nc,ns`.

## Accessing elements

Either 1d sequential with `[]`, or multi-dimensional with `()`.

## Reading variables

Wrapping from [[ function arguments | getting-started ]], or from [[ MAT-files | mat ]].

## Creating variables

Use a maker, save `mxArray` to `rhs`, and wrap using array container.

## Temporary arrays

Setting memory storage template parameter.

By default `ReadOnlyMemory`, but can also `CppMemory` and `MatlabMemory`.

This is not the same as creating an output!

## Memory management

Data and size, allocate and free.

Make persistent manually.