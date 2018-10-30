function yes = is_dir( name )
%
% y = dk.fs.isdir( name )
%
% Check that path is a folder.
% Note: this is not equivalent to isdir or isfolder.
%
% See also: dk.fs.exist
%
% JH

    yes = dk.fs.exist( name, 'dir' );
end
