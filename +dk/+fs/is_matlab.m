function yes = is_matlab( name )
%
% Returns true for: .m scripts, Mex files, P-files and built-ins
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    yes = ismember( exist( name, 'file' ), [3 5 6] ) || ...
        ( dk.fs.is_file(name) && strcmpi(name(end-1:end),'.m') );
end
