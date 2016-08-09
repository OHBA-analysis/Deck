function compile_cpp( comp, varargin )
    
    comp.mex_file = false;
    mex_utils.compile( comp, varargin{:} );

end
