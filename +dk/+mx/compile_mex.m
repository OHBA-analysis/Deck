function compile_mex( comp, varargin )

    comp.mex_file = true;
    dk.mx.compile( comp, varargin{:} );
    
end
