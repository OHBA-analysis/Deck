function compile_mex( comp, varargin )

    comp.mex_file = true;
    mex_utils.compile( comp, varargin{:} );
    
end
