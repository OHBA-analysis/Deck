classdef Logger < handle
%
% Simple logging implementation, heavily inspired by:
%   https://github.com/optimizers/logging4matlab
%
% Logging levels are:
%   all
%   trace
%   debug
%   info
%   warning
%   error
%   critical
%   off
%
% JH

    properties (Constant)
        
        LEVEL = struct( ...
            'all',      1, ...
            'trace',    2, ...
            'debug',    3, ...
            'info',     4, ...
            'warning',  5, ...
            'error',    6, ...
            'critical', 7, ...
            'off',      8 ...
        );
        
    end
    
    properties 
        fileLevel
        consoleLevel
        
        nodate
        lvlchar
    end
    
    properties (SetAccess = private)
        name
        file
        datefmt
        
        backup % backup state to be used with saveState/resetState
    end
    
    methods (Hidden, Static)
        function str = callerInfo()
            [ST,~] = dbstack();
            if length(ST) > 2
                name = ST(3).name;
                line = ST(3).line;
                str = sprintf( '%s:%d', name, line );
            else
                str = 'Console';
            end
        end
    end
    
    % -----------------------------------------------------------------------------------------
    % management method
    % -----------------------------------------------------------------------------------------
    methods
        
        function self = Logger(varargin)
            self.reset(varargin{:});
        end
        
        function reset(self,name,varargin)
            assert( ischar(name) && ~isempty(name), 'Name should be a string.' );
            arg = dk.obj.kwArgs(varargin{:});
            
            self.name = name;
            self.file = struct('path', arg.get('file',[]), 'id', -1);
            self.datefmt = arg.get('datefmt','yyyy-mm-dd HH:MM:SS.FFF');
            self.nodate = arg.get('nodate',false);
            self.lvlchar = arg.get('lvlchar',false);
            
            % set log levels
            self.fileLevel = arg.get('flevel','info');
            self.consoleLevel = arg.get('clevel','info');
            
            % clear previous backups
            self.backup = [];
            
            % open file if any
            self.open();
        end
        
        function set.fileLevel(self,val)
            val = lower(val);
            assert( isfield(self.LEVEL,val), 'Invalid level.' );
            self.fileLevel = val;
        end
        
        function set.consoleLevel(self,val)
            val = lower(val);
            assert( isfield(self.LEVEL,val), 'Invalid level.' );
            self.consoleLevel = val;
        end
        
        function saveState(self)
            f = {'fileLevel', 'consoleLevel', 'nodate', 'lvlchar'};
            n = numel(f);
            
            b = struct();
            for i = 1:n
                b.(f{i}) = self.(f{i});
            end
            self.backup = b;
        end
        
        function resetState(self)
            f = {'fileLevel', 'consoleLevel', 'nodate', 'lvlchar'};
            n = numel(f);
            
            b = self.backup;
            for i = 1:n
                self.(f{i}) = b.(f{i});
            end
        end
        
        function y = hasFile(self)
            y = ~isempty(self.file.path);
        end
        
        function y = isFileOpen(self)
            y = self.hasFile() && (self.file.id > -1);
        end
        
        function y = ignoreLogging(self)
            y = strcmp(self.fileLevel,'off') && strcmp(self.consoleLevel,'off');
        end
        
        function self = setFile(self,fpath)
            self.open(fpath);
        end
        
    end
    
    % -----------------------------------------------------------------------------------------
    % logging methods
    % -----------------------------------------------------------------------------------------
    methods
        
        function trace(self, varargin)
            if ~self.ignoreLogging()
                caller = self.callerInfo();
                self.write('t', caller, varargin{:});
            end
        end

        function debug(self, varargin)
            if ~self.ignoreLogging()
                caller = self.callerInfo();
                self.write('d', caller, varargin{:});
            end
        end

        function info(self, varargin)
            if ~self.ignoreLogging()
                caller = self.callerInfo();
                self.write('i', caller, varargin{:});
            end
        end

        function warn(self, varargin)
            if ~self.ignoreLogging()
                caller = self.callerInfo();
                self.write('w', caller, varargin{:});
            end
        end

        function error(self, varargin)
            if ~self.ignoreLogging()
                caller = self.callerInfo();
                self.write('e', caller, varargin{:});
                error( 'Logger "%s" triggered an error.', self.name );
            end
        end

        function critical(self, varargin)
            if ~self.ignoreLogging()
                caller = self.callerInfo();
                self.write('c', caller, varargin{:});
                error( 'Logger "%s" triggered an error.', self.name );
            end
        end
        
        % conditional variants
        function debugif(self,cdt,varargin)
            if all(logical(cdt))
                self.debug(varargin{:});
            end
        end
        
        function warnif(self,cdt,varargin)
            if all(logical(cdt))
                self.warn(varargin{:});
            end
        end
        
        function errorif(self,cdt,varargin)
            if all(logical(cdt))
                self.error(varargin{:});
            end
        end

    end

    methods (Hidden)
        
        % open/close log file
        function self = open(self,fpath)
            if nargin < 2
                fpath=self.file.path; 
            end
            self.close();
            if isempty(fpath)
                self.file.path = [];
                self.file.id = -1;
            else
                self.file.path = fpath;
                self.file.id = fopen(fpath,'a');
            end
        end
        
        function self = close(self)
            if self.isFileOpen()
                fclose(self.file.id);
                self.file.id = -1;
            end
        end
        
        % generic logging function
        function write(self,level,caller,message,varargin)
            
            % determine level
            switch lower(level)
                case {'a','all'}
                    level = 'all';
                case {'t','trace'}
                    level = 'trace';
                case {'d','dbg','debug'}
                    level = 'debug';
                case {'i','info'}
                    level = 'info';
                case {'w','warn','warning'}
                    level = 'warning';
                case {'e','err','error'}
                    level = 'error';
                case {'c','critical'}
                    level = 'critical';
                otherwise
                    error( 'Unknown level: %s', level );
            end
            levelnum = self.LEVEL.(level);
            
            % build log line
            mstr = sprintf( message, varargin{:} );
            dstr = datestr( now(), self.datefmt );
            dstr = sprintf( '%-23s', dstr );
            
            lstr = upper(level); 
            if self.lvlchar
                lstr = lstr(1);
            else
                lstr = sprintf( '%-8s', lstr );
            end
            
            % write to console
            if self.LEVEL.(self.consoleLevel) <= levelnum
                if self.nodate
                    logline = sprintf( '%s [%s] %s', lstr, caller, mstr );
                else
                    logline = sprintf( '%s %s [%s] %s', dstr, lstr, caller, mstr );
                end
                if levelnum >= self.LEVEL.error
                    fprintf( 2, '%s\n', logline );
                else
                    fprintf( '%s\n', logline );
                end
            end
            
            % write to file
            if self.isFileOpen() && self.LEVEL.(self.fileLevel) <= levelnum
                logline = sprintf( '%s %s [%s] %s', dstr, lstr, caller, mstr );
                fprintf( self.file.id, '%s\n', logline );
            end
            
        end
        
    end
    
end