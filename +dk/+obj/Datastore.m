classdef Datastore < handle
%
% dk.obj.Datastore()
%
% Bind to a folder on the file-system, and load/save from it, find patterns, etc.
% You can get more information about particular functions by typing:
%   help dk.obj.Datastore.NAME_OF_FUNCTION
% 
% Construction:
%   assign, clear
%
% Load/save:
%   load, save
%
% Other:
%   exists, find
%
% JH

    properties
        folder; % the folder bound to the datastore
    end
    
    methods
        
        function self = Datastore(varargin)
            self.clear();
            if nargin > 0
                self.assign(varargin{:});
            end
        end
        
        function clear(self)
            self.folder = [];
        end
                
        function assign(self,folder,create)
        %
        % assign(self,folder,create=false)
        %
        % Binds input folder to datastore instance.
        % Input folder is resolved (follow symlinks) beforehand.
        % If create=false, and folder does not already exist, an error is thrown.
        % No issue if create=true and folder already exists.
        % 
        
            if nargin < 3, create=false; end
            
            folder = dk.fs.realpath(folder);
            if create && ~dk.fs.is_dir(folder)
                dk.assert( mkdir(folder), '[dk.Datastore] Could not create folder "%s".', folder );
                dk.info('[dk.Datastore] Created folder "%s".',folder);
            end
            
            dk.assert( dk.fs.is_dir(folder), '[dk.Datastore] Folder "%s" not found.', folder );
            self.folder = folder;
        end
        
        function f = file(self,varargin)
        % Full path to file (extension MUST be set manually)
            f = fullfile(varargin{:});
            if f(1) ~= filesep
                f = fullfile(self.folder,f);
            end
        end
        
        function f = matfile(self,varargin)
        % Full path to MAT file with extension
            f = dk.str.set_ext( self.file(varargin{:}), 'mat' );
        end
        
        function y = exists(self,varargin)
        % Check whether relative path exists
            y = dk.fs.is_file( self.file(varargin{:}) );
        end
        
        function f = find(self,varargin)
        % Find pattern in folder
            f = dir(fullfile( self.folder, varargin{:} ));
        end
        
        function move(self,src,dst)
        %
        % Move file
        %
            
            src = self.file(src);
            dst = self.file(dst);
            
            dk.reject( dk.fs.is_file(dst), 'Destination already exists.' );
            movefile( src, dst );
        end
        
        function remove(self,name)
        %
        % Remove file
        
            name = self.file(name);
            if dk.fs.is_file(name)
                delete(name);
            else
                warning( 'File not found: %s', name );
            end
        end
        
        function f = save(self,name,varargin)
        %
        % save(self,name,varargin)
        %
        % Save input to f = self.matfile(name).
        % Input can either be a struct, or a key/value list.
        % MAT file is saved with -v7 option.
        %
            
            dk.reject( isempty(self.folder), '[dk.Datastore] Folder is not set.' );
            
            % set MAT filename
            f = self.matfile(name);
            dk.wreject( dk.fs.is_file(f), '[dk.Datastore] File "%s" will be overwritten.', f );
            
            % parse input to be saved
            if nargin == 3 && isstruct(varargin{1})
                % either a structure
                data = varargin{1};
            else
                % or key/value pairs
                data = struct( varargin{:} );
            end
            
            % save data
            dk.info('[dk.Datastore] Saving to "%s"...',f);
            save( f, '-v7', '-struct', 'data' );
            
        end
        
        function varargout = load(self,name,varargin)
        %
        % load(self,name,varargin)
        %
        % Load self.matfile(name) from the storage folder.
        % Specific variables can be retrieved by specifying them in input.
        % If the fieldname does not exist, the default value is [].
        %
        % Several outputs possible:
        %
        %   x = load('myfile.mat','foo'); % x=foo
        %   x = load('myfile.mat','foo','bar'); % x=struct({foo,bar})
        %   [x,y] = load('myfile.mat','foo','bar'); % x=foo and y=bar
        %   [x,y] = load('myfile.mat','foo','bar','baz'); % x=foo and y=bar
        %
            
            dk.reject( isempty(self.folder), '[dk.Datastore] Folder is not set.' );
            
            % load data
            name = self.matfile(name);
            dk.info('[dk.Datastore] Loading from "%s"...',name);
            data = load(name);

            if nargin > 2
                % extract specific variables
                data = dk.mapfun( @(n) dk.struct.get( data, n, [] ), varargin, false );

                if nargout == 1 && nargin > 3
                    % more than one field required, but only one output: return a structure
                    varargout = {cell2struct( data, varargin, 2 )};
                else
                    % only one field required: return its value
                    varargout = data;
                end
            else
                % return the whole structure
                varargout = {data};
            end
            
        end
        
    end
    
end
