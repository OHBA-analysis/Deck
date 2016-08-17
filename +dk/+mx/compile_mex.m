function compile_mex( comp, varargin )

    if nargin == 1 && ischar(comp)
        dk.mx.compile( dk.mx.compiler(), comp );
    else
        comp.mex_file = true;
        dk.mx.compile( comp, varargin{:} );
    end
    
end
