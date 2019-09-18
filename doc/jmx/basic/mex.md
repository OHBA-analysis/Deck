
# Writing Mex files

Here is what you need to write Mex files using JMX.

## Boilerplate

Mex files are C++ programs which define a special function called `mexFunction()`, instead of the traditional `main()` function. Most Mex files using JMX will look like this:

```cpp
// include standard headers here
#include <iostream>
#include "jmx.h"
using namespace jmx_types; // index_t, integ_t, real_t

void usage() {
    jmx::println("Usage: <Output> = function( <Input1>, <Input2> )");
}

void mexFunction( int nargout, mxArray *out[],
                  int nargin, const mxArray *in[] ) 
{
    // redirect stdout and stderr to the Matlab console
    jmx::cout_redirect();
    jmx::cerr_redirect();

    // wrap input and output arguments
    auto args = jmx::Arguments( nargout, out, nargin, in );
    args.verify( 2, 1, usage ); // for example, 2 inputs and 1 output
}
```

## Inputs and outputs

The class `jmx::Arguments` greatly simplifies the interaction with Mex inputs and outputs. For example, to retrieve a matrix as first input, and a vector of `uint8` as a second input, you would simply write:
```cpp
auto x = args.getmat(0); // input count starts at 0
auto y = args.getvec<uint8_t>(1);
```

This will throw an error if the actual inputs do not match the types specified. Note that to be exact, the value-type of y should be `jmx::mex2cpp< mxUINT8_CLASS >::type`, but that is long and complicated, and it is clear that the corresponding standard type is `uint8_t` (from the header `cstdint`).

Similarly, to return a struct with fields `foo="Hello!"` and `bar=true`, you would simply write:
```cpp
auto z = args.mkstruct( 0, {"foo","bar"} );
z.set_value( "foo", jmx::make_string("Hello!") );
z.set_value( "bar", jmx::make_logical(true) );
```

Try to write a Mex file without JMX that simply does this (retrieve two inputs, and create one output), and you will realise quickly how useful this is.

More information about inputs and outputs is provided [here](jmx/basic/io).

## Compilation

Another usually painful step when working with Mex file comes when one tries to compile them into executables, by calling `mex` from the Matlab console.

If anything, there are [a lot of options](https://uk.mathworks.com/help/matlab/ref/mex.html) described in the documentation, and dealing with integer size varying across platforms or using the C++14 standard for example can be difficult to manage in practice.

The JMX library also defines the Matlab function `jmx()` which greatly simplifies the compilation step. Internally, this function calls `jmx_compile()`, which can be used to compile any Mex file, whether using JMX or not. Type `help jmx_compile` for more information. 

More information about compilation in large projects is provided [here](jmx/more/project).
