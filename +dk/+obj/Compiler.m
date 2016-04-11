classdef Compiler < handle
% 
% A very useful class to compile C++ libraries and Mex files using the function mex.
% Most relevant options are available as public attributes, and methods allow to:
%   - define/undefine macros
%   - add/remove libraries or include paths
%
% Once you are done specifying the options of your compilation, run "build" in order to commit the internal state.
% You can print the command to the console (for debuging/verbose) and compile using "print" and "compile".
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    properties (SetAccess = public)
        
        % out_dir, out_name: specify output names
        % opt_file: full path to a custom mexopts.sh
        out_dir, out_name, opt_file;
        
        % use_64b_size : use uint64_t types for matrix indexing (cf -largeArrayDims)
        % use_cpp11    : define compiler option -std=c++0x
        use_64b_size, use_cpp11;
        
        % if true,  compilation produces a Mex-file
        % if false, option -c is used, producing an ordinary object file
        mex_file;
        
        % compilation mode
        dry_run, optimize, debug;
        
        % console output
        verbose, silent;
        
    end
    
    properties (SetAccess = protected)
        
        command, files;
        def, undef, flags;
        lpath, ipath, lib;
        
    end
    
    
    methods
        
        function self = Compiler()
            self.reset();
        end
        
        function default_settings(self)
            
            self.out_dir       = pwd;
            self.out_name      = '';
            self.opt_file      = '';

            self.mex_file      = true;
            self.optimize      = false;
            self.dry_run       = false;
            self.verbose       = false;
            self.use_64b_size  = true;
            self.use_cpp11     = false;
            self.silent        = false;
            self.debug         = false;
            
        end
        
        function reset(self)
            
            self.default_settings();

            self.command       = dk.obj.List();
            self.def           = struct();
            self.undef         = dk.obj.List();
            self.flags         = dk.obj.List();
            self.files         = dk.obj.List();
            self.lpath         = dk.obj.List();
            self.ipath         = dk.obj.List();
            self.lib           = dk.obj.List();
            
        end
        
        function build(self)
            
            self.command.clear();
            
            % Mex version
            if self.use_64b_size
                self.command.append('-largeArrayDims');
            else
                self.command.append('-compatibleArrayDims');
            end
            
            % C++11
            if self.use_cpp11
                self.flag('-std=c++0x');
            end
            
            % Options
            if ~self.mex_file, self.command.append('-c'); end
            if  self.optimize, self.command.append('-O'); end
            if  self.debug,    self.command.append('-g'); end
            if  self.dry_run,  self.command.append('-n'); end
            if  self.verbose,  self.command.append('-v'); end
            if  self.silent,   self.command.append('-silent'); end
            
            % Specify custom option file
            if ~isempty(self.opt_file)
                self.command.append('-f');
                self.command.append(self.opt_file);
            end
            
            % Add out dir/name
            if ~isempty(self.out_dir)
                self.command.append('-outdir');
                self.command.append(self.out_dir);
            end
            if ~isempty(self.out_name)
                self.command.append('-output');
                self.command.append(self.out_name);
            end
            
            % Flags
            if self.flags.len
                self.command.append([ 'CXXFLAGS=''$CXXFLAGS ' strjoin(self.flags.list) '''' ]);
            end
            
            % Defines
            f = fieldnames(self.def);
            for i = 1:length(f)
                v = self.def.(f{i});
                if isempty(v)
                    self.command.append(['-D' f{i}]);
                else
                    self.command.append(['-D' f{i} '=' v ]);
                end
            end
            
            % Undefines
            for i = 1:self.undef.len
                self.command.append(['-U' self.undef.list{i}]);
            end
            
            % Add libraries
            for i = 1:self.lpath.len
                self.command.append(['-L' self.lpath.list{i}]);
            end
            for i = 1:self.lib.len
                self.command.append(['-l' self.lib.list{i}]);
            end
            
            % Add includes
            for i = 1:self.ipath.len
                self.command.append(['-I' self.ipath.list{i}]);
            end
            
            % Add files
            for i = 1:self.files.len
                self.command.append(self.files.list{i});
            end
            
        end
        
        function print(self)
            self.build();
            disp(['mex ' strjoin(self.command.list)]);
        end
        
        function compile(self)
            self.build();
            mex( self.command.list{:} );
        end
        
    end
    
    methods
        
        % Add/remove files to compile
        function add_file(self,f)
            self.files.append(f);
        end
        function rem_file(self,f)
            self.files.remove_all(f);
        end
        function rem_files(self)
            self.files.clear();
        end
        
        % Add compiler flag
        function flag(self,f)
            self.flags.append(f);
        end
        
        % Add/remove defines
        function define(self,name,val)
            if nargin<3, val=''; end
            assert( ischar(name) && ischar(val), ...
                'name and value should be strings.' );
            
            self.def.(name) = val;
        end
        function undefine(self,name)
           self.undef.append( name ); 
        end
        
        % Add/remove library paths
        function add_lib_path(self,lp)
            self.lpath.append(lp);
        end
        function rem_lib_path(self,lp)
            self.lpath.remove_all(lp);
        end
        
        % Add/remove libraries
        function add_lib(self,l)
            self.lib.append(l);
        end
        function rem_lib(self,l)
            self.lib.remove_all(l);
        end
        
        % Add/remove includes
        function add_inc(self,ip)
            self.ipath.append(ip);
        end
        function rem_inc(self,ip)
            self.ipath.remove_all(ip);
        end
        
    end
    
end
