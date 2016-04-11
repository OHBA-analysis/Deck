classdef Datastore < handle
    
    properties
        folder;
    end
    
    methods
        
        function self = Datastore(varargin)
            if nargin > 0
                self.assign(varargin{:});
            end
        end
        
        function assign(self,folder)
            self.folder = dk.fs.realpath(folder);
        end
        
        function f = file(self,varargin)
            f = fullfile(self.folder,varargin{:});
        end
        
        function f = matfile(self,varargin)
            f = dk.string.set_ext( self.file(varargin{:}), 'mat' );
        end
        
        function f = save(self,name,varargin)
            
            f = self.matfile(name);
            
            if nargin == 3 && isstruct(varargin{1})
                data = varargin{1};
            else
                data = struct( varargin{:} );
            end
            
            dk.println('[dk.datastore] Saving to "%s"...',f);
            save( f, '-v7', '-struct', 'data' );
            
        end
        
        function varargout = load(self,name,varargin)
            
            % load data
            name = self.matfile(name);
            dk.println('[dk.datastore] Loading from "%s"...',name);
            data = load(name);

            % extract specific variables
            if nargin > 2
                data = cellfun( @(n) dk.get_field( data, n, [] ), varargin, 'UniformOutput', false );

                if nargout == 1 && nargin > 3
                    varargout{1} = cell2struct( data, varargin, 2 );
                else
                    varargout = data;
                end
            else
                varargout{1} = data;
            end
            
        end
        
    end
    
end
