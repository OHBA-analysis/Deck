function clean( mex_folder, bin_folder )
    
    % remove compiled mex-files in the mex output directory
    f = dk.fs.list_ext( mex_folder, mexext );
    for i = 1:length(f)
        delete(fullfile( mex_folder, f{i} ));
    end

    % if bin folder is specified, remove temporary object files
    if nargin > 1
        f = dk.fs.list_ext( bin_folder, 'o' );
        for i = 1:length(f)
            delete(fullfile( bin_folder, f{i} ));
        end
    end
    
end
