classdef DataArray < dk.priv.GrowingContainer
%
% DataArray objects store matrix data with fixed number of columns, optionally accessible by name,
% as well as a struct-array to store data-fields associated with each row.
%
%
% ------------------------------
% ## Construction
%
%   Constructor arguments are forwarded to:
%       reset( ncols, bsize=100 )
%       reset( colnames, bsize=100 )
%
%
% ------------------------------
% ## Storage
%
%   Data is stored in a matrix with the specified number of columns.
%   This matrix usually has more rows than needed, in order to allow for efficient push operations.
%
%   By default, rows are allocated by block as needed.
%   For example, if more memory is needed is order to push rows, a new block of size bsize is allocated.
%   
%   If the number of rows needed is unknown, set a generous block-size (typically in the range 100-1000).
%   The default is 100.
%
%   If you have a reliable upper-bound on the number of rows:
%       set a rather small block-size at construction time, e.g. obj.bsize = max(10, fix(n/100));
%       allocate the desired number of rows in advance with obj.reserve(n)
%
%
% ------------------------------
% ## Usage
%
%   The following methods are provided for easy access:
%       dget    Get data value(s) manually
%       dset    Set data value(s) manually
%       row     Get one or several data rows
%       col     Get one or several data columns for all used rows
%       mget    Get meta-data for a set of rows
%       mfield  Get meta-data field for all used rows
%
%   Note that these methods are provided mainly for consistency (and they can resolve a column name) 
%   but you should access the properties directly for performance.
%
%
% JH

    properties
        data
        meta
        name
    end
    
    properties (Transient,Dependent)
        nrows
        ncols
        numel
    end
    
    methods
        
        function self = DataArray(varargin)
            self.clear();
            if nargin > 0
                self.reset(varargin{:});
            end
        end
        
        function n = get.nrows(self), n = self.nelm; end
        function n = get.ncols(self), n = size(self.data,2); end
        function n = get.numel(self), n = self.nrows * self.ncols; end 
        
        function clear(self)
            self.gcClear();
            self.data = [];
            self.meta = structcol(0);
            self.name = containers.Map();
        end
        
        function reset(self,c,b)
            if nargin < 3, b=100; end
            self.gcInit(b);
            self.meta = structcol(b);
            if iscellstr(c)
                self.data = nan(b,numel(c));
                self.setnames(c);
            elseif isscalar(c)
                self.data = nan(b,c);
            else
                assert( ismatrix(c), 'Bad input.' );
                self.data = nan(b,size(c,2));
                self.add(c);
            end
        end
        
        function setnames(self,varargin)
            if nargin == 2 && iscellstr(varargin{1})
                names = varargin{1};
            else
                names = varargin;
            end
            assert( iscellstr(names) && numel(names) == self.ncols, 'Bad input.' );
            self.name = containers.Map( names, 1:self.ncols );
        end
        
        function c = colnum(self,name)
            c = self.name(name);
        end
        
        % bulk assign of metadata field by copying the value
        function self = assign(self,k,varargin)
            n = nargin-2;
            assert( dk.is.even(n) && iscellstr(varargin(1:2:end)), 'Bad assignment.' );
            for i = 1:2:n
                [self.meta(k).(varargin{i})] = deal(varargin{i+1});
            end
        end
        
        % remove metadata fields
        function rmfield(self,varargin)
            assert( iscellstr(varargin), 'Expected list of fieldnames.' );
            self.meta = rmfield(self.meta,varargin);
        end
        
        % add entries
        function k = add(self,x,varargin)
            assert( ismatrix(x) && size(x,2) == self.ncols, 'Bad number of columns.' );
            n = size(x,1);
            k = self.gcAdd(n);
            self.data(k,:) = x;
            self.assign(k,varargin{:});
        end
        
        % get data (row and meta) associated with a (set of) row(s)
        function [d,m] = both(self,k)
            d = self.row(k);
            m = self.mget(k);
        end
        
    end
    
    methods (Hidden)
        
        function childAlloc(self,n)
            self.data = vertcat(self.data, nan(n,self.ncols));
            self.meta(self.nmax) = dk.struct.make(fieldnames(self.meta));
        end
        
        function childCompress(self,id,remap)
            self.data = self.data(id,:);
            self.meta = self.meta(id);
        end
        
    end
    
    % i/o
    methods
        
        function s = serialise(self,file)
            s = self.gcToStruct();
            s.data = self.data;
            s.meta = self.meta;
            s.name = self.name.keys;
            s.version = '0.1';
            if nargin > 1, save(file,'-v7','-struct','s'); end
        end
        
        function self = unseriaise(self,s)
        if ischar(s), s=load(s); end
        switch s.version
            case '0.1'
                self.data = s.data;
                self.meta = s.meta;
                self.gcFromStruct(s);
                self.setnames(s.name);

            otherwise
                error('Unknown version: %s',s.version);
        end
        end
        
        function c = compare(self,other)
            c = dk.compare( self.serialise(), other.serialise() );
        end
    end
    
    % access
    methods
        
        % NOTE:
        % For all methods below, both scalar and vector indices work.
        % However, name resolution requires single name only.
        
        
        % get element(s) by index (single column by name ok)
        function x = dget(self,r,c)
            if ischar(c), c=self.name(c); end
            assert( all(self.used(r)), 'Invalid row indices' );
            x = self.data(r,c);
        end
        
        % set element(s) by index (single column by name ok)
        function dset(self,r,c,x)
            if ischar(c), c=self.name(c); end
            assert( all(self.used(r)), 'Invalid row indices' );
            assert( all(c < self.ncols), 'Column index out of bounds.' );
            self.data(r,c) = x;
        end
        
        % get row(s) by index
        function x = row(self,k)
            assert( all(self.used(k)), 'Invalid row indices' );
            x = self.data(k,:);
        end
        
        % get column(s) by index or name
        function x = col(self,k)
            if ischar(k), k=self.name(k); end
            x = self.data(self.used,k);
        end
        
        % get meta-data for a given (set of) row(s)
        function x = mget(self,k)
            assert( all(self.used(k)), 'Invalid row indices' );
            x = self.meta(k);
        end
        
        % get field by name
        function x = mfield(self,n)
            x = {self.meta(self.used).(n)};
        end
        
    end
    
end

% Create a nx1 empty struct-array.
function s = structcol(n)
    s = repmat( struct(), n, 1 );
end