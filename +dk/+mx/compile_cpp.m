function compile_cpp( comp, varargin )
    
    comp.mex_file = false;
    dk.mx.compile( comp, varargin{:} );

end
