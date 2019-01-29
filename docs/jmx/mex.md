
# Getting Started

Getting started with Matlab-Mex.

 - Sharing memory and variables
 - Mex or not Mex?
 - Using this library
 - Projects with multiple files


## Sharing memory and variables

Variables require memory, memory is managed internally by Matlab.

As far as I understand, Mex allows you to access Matlab's memory directly.

You should never, EVER modify an input variable; create a new one to store any processing instead.


## Mex or not Mex?

Mex functions are callable from Matlab and MUST define a `mexFunction`

For example, a typical Mex-file using this library would look like this:

```cpp
#include "jmx.h"
#include "example-lib.h" // other headers from this project ...

// it's considered bad practice to use entire namespace like this, 
// but that's ok for short functions...
using namespace jmx;

// ------------------------------------------------------------------------

void mexFunction( int nargout, mxArray *out[],
                  int nargin, const mxArray *in[] ) 
{
    // collect inputs
    JMX_ASSERT( nargin >= 1, "This function requires a vector in input" );
    auto x = get_vector<double>(in[0]);

    // print something to the console
    cout_redirect(true);
    println("Hello there :)");

    // call functions from included headers
    // simple_function(x);

    // create an output matrix
    if (nargout >= 1) {
        out[0] = make_matrix( 1, 2 );
        auto out0 = get_matrix_rw<double>(out[0]); // note the suffix '_rw'
        out0[0] = 1;
        out0(0,1) = -1;
    }
}
```

Non-Mex code (e.g. libraries) can also be compiled, but cannot be called directly from the Matlab console.


## Projects with multiple files

Most projects will have multiple files.

Compile each file independently (most likely not Mex), specify linked objects with the compiler.

Then compile the main Mex file at the end, specifying all linked objects.
