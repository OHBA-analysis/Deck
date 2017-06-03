classdef Datastore < handle
    
    properties
        folder;
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
            f = fullfile(self.folder,varargin{:});
        end
        
        function f = matfile(self,varargin)
            f = dk.str.set_ext( self.file(varargin{:}), 'mat' );
        end
        
        function y = exists(self,varargin)
            y = dk.fs.is_file( self.file(varargin{:}) );
        end
        
        function f = find(self,varargin)
            f = dir(fullfile( self.folder, varargin{:} ));
        end
        
        function f = save(self,name,varargin)
            
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
            
            dk.reject( isempty(self.folder), '[dk.Datastore] Folder is not set.' );
            
            % load data
            name = self.matfile(name);
            dk.info('[dk.Datastore] Loading from "%s"...',name);
            data = load(name);

            if nargin > 2
                % extract specific variables
                data = dk.cellfun( @(n) dk.struct.get( data, n, [] ), varargin, false );

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
