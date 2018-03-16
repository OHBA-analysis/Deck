classdef Mapping < handle
%
% Storage for associating multidimensional coordinates with multivariate data and metadata.
% The storage is allocated and grown automatically to avoid reallocating the arrays too often.
%
% ## WARNING
%
%   DO NOT MODIFY THE SHAPE/SIZE/TYPE OF ANY PROPERTY!
%   DO NOT MODIFY THE VALUE OF: last
%
%   THE METHOD compress() INVALIDATES ANY PREVIOUS INDEXING!
%
%
% ------------------------------
% ## Construction
% 
%   Constructor arguments are forwarded to:
%       reset( ndim, nvar, bsize=500 )
%
%   This method allocates:
%       arrays of NaNs for x and y, 
%       struct array with no fields for meta
%       all-false vector for used
%
%   The block size can be modified manually after construction.
%
%
% ------------------------------
% ## Storage and usage
%
%   The properties can be accessed anytime for reading.
%   The indices are preserved when removing points, BUT NOT when using compress().
%
%   New entries should be added one by one using the method: 
%       add( x, y, 'Field1',Value1, 'Field2',...)
%   Fieldnames for the metadata are case-sensitive, and are common to all entries.
%   
%   Multiple entries can be added at once using the method addn() instead, but in
%   that case, the metadata should either be input as a struct-array directly, or
%   the values should be iterable (ie either a vector or a cell).
%
%   One or several points can be removed at once using: rem([i1,i2,i3,...]).
%   Removal simply marks the point as unused, and does not cause reallocation.
%   The indices of all points in-use are returned by find().
%
%   The coordinate data is stored in the rows of x.
%   The associated data is stored in the rows of y.
%   The associated metadata is stored in meta as a struct.
%   
%   The data at index k can also be accessed with positional outputs [x,y,meta] 
%   using data(k). If k is a vector, then the outputs are matrices and struct-arrays.
%   This can be useful if you always use x, y and the metadata together for any index.
%
%   Finally, all points in-use can be iterated using the method: iter( @callback )
%   The callback should be a function-handle accepting the following inputs:
%       callback( k:index, x:row, y:row, meta:struct )
%   It does not need to return an output, BUT IF IT DOES NOT, you should not request
%   an output to the function iter (this will cause an error otherwise). If it does 
%   return something, the output is a cell of same length as the number of points 
%   IN USE (that is, the indices in the output cell do not necessarily correspond 
%   to the indices of the points within the instance!).
%   
%
% ------------------------------
% ## Memory management
%
%   The memory allocation is managed dynamically, and evolves with the instance.
%   Manual allocations for N entries can be forced using the method alloc(N).
%
%   In most cases, you will want to use reserve(N) instead, which checks whether
%   the capacity allows the addition of N new points without dynamic reallocation.
%   
%   If you remove a lot of points, you should run compress() to optimise the storage.
%   A remap of previous indices is returned in output, and can be used simply as:
%       new_index = remap(old_index)
%   
%   You can also monitor the sparsity to assess whether compression is needed.
%   A warning will be issued everytime a point is removed if the sparsity is above 90%.
%
% JH

    properties
        x           % nmax x npts matrix
        y           % nmax x nvar matrix
        meta        % struct-array of metadata
        used        % nmax x 1 logical
        last        % index of last used point
        bsize       % default reallocation size
    end
    
    properties (Transient,Dependent)
        nmax        % number of points allocated
        npts        % number of points in use
        ndim        % number of columns in x
        nvar        % number of columns in y
        ready       % check if the object has been initialised
        capacity    % number of points that can be added without reallocation
        sparsity    % sparsity ratio (>0.2 means compression needed)
    end
    
    % dependent properties
    methods
        
        function n = get.npts(self)
            n = sum(self.used);
        end
        function n = get.ndim(self)
            n = size(self.x,2);
        end
        function n = get.nvar(self)
            n = size(self.y,2);
        end
        function n = get.nmax(self)
            n = numel(self.used);
        end
        function y = get.ready(self)
            y = ~isempty(self.x);
        end
        function n = get.capacity(self)
            n = self.nmax - self.last;
        end
        function s = get.sparsity(self)
            s = 1 - self.npts / self.last;
        end
        
    end
    
    % i/o
    methods
        
        function s=serialise(self,file)
            f = {'x','y','meta','used','last','bsize'};
            n = numel(f);
            s.version = '0.1';
            for i = 1:n
                s.(f{i}) = self.(f{i});
            end
            if nargin > 1, save(file,'-v7','-struct','s'); end
        end
        
        function self=unserialise(self,s)
        if ischar(s), s=load(s); end
        switch s.version
            case '0.1'
                f = {'x','y','meta','used','last','bsize'};
                n = numel(f);
                for i = 1:n
                    self.(f{i}) = s.(f{i});
                end
            otherwise
                error('Unknown version: %s',s.version);
        end
        end
        
        function same=compare(self,other)
            same = dk.compare( self.serialise(), other.serialise() );
        end
        
    end
    
    % setup
    methods
        
        function self = Mapping(varargin)
            self.clear();
            if nargin == 1 && isstruct(varargin{1})
                self.unserialise(varargin{1});
            elseif nargin > 1
                self.reset(varargin{:});
            end
        end
        
        function clear(self)
            self.x = [];
            self.y = [];
            self.meta = structcol(0);
            self.used = false(0);
            self.bsize = 0;
            self.last = 0;
        end
        
        function reset(self,nd,nv,b)
            if nargin < 4, b=500; end
            
            self.x = nan( b, nd );
            self.y = nan( b, nv );
            self.meta = structcol(b);
            self.used = false(b,1);
            self.bsize = b;
            self.last = 0;
        end
        
        function rem(self,k)
            self.used(k) = false;
            dk.wreject( self.sparsity > 0.9, 'Storage is very sparse, you should run compress().' );
        end
        function k = add(self,x,y,varargin)
            k = self.last+1;
            if k > self.nmax
                self.alloc(self.bsize);
            end
            
            self.last = k;
            self.used(k) = true;
            self.x(k,:) = x;
            self.y(k,:) = y;
            
            n = nargin - 3;
            for i = 1:2:n
                field = varargin{i};
                value = varargin{i+1};
                self.meta(k).(field) = value;
            end
        end
        function k = addn(self,x,y)
            n = size(x,1);
            self.reserve(n);
            
            b = self.last+1;
            e = self.last+n;
            k = b:e;
            
            self.last = e;
            self.used(k) = true;
            
            self.x(k,:) = x;
            self.y(k,:) = y;
        end
        function [x,y,m] = data(self,k)
            x = self.x(k,:);
            y = self.y(k,:);
            m = self.meta(k);
        end
        
        function alloc(self,n)
            nd = self.ndim;
            nv = self.nvar;
            nm = self.nmax;
            
            self.x = vertcat(self.x, nan(n,nd));
            self.y = vertcat(self.y, nan(n,nv));
            self.used = vertcat(self.used, false(n,1));
            self.meta(nm+n) = self.meta(1);
        end
        function n = reserve(self,n)
            n = max(0, n - self.capacity);
            if n > 0
                self.alloc(n);
            end
        end
        
        function id = find(self)
            id = find(self.used);
        end
        function remap = compress(self)
            np = self.npts;
            nc = self.last;
            id = self.find();
            cp = self.capacity;
            
            remap = zeros(nc,1);
            remap(id) = 1:np;
            
            self.x = self.x(id,:);
            self.y = self.y(id,:);
            self.meta = self.meta(id);
            self.used = self.used(id);
            
            self.last = np;
            self.alloc(cp);
        end
        
        function out = iter(self,callback,idx)
            if nargin < 3, idx = self.find(); end
            ni = numel(idx);
            
            if nargout > 0
                out = cell(1,ni);
                for i = 1:ni
                    k = idx(i);
                    out{i} = callback( k, self.x(k,:), self.y(k,:), self.meta(k) );
                end
            else
                for i = 1:ni
                    k = idx(i);
                    callback( k, self.x(k,:), self.y(k,:), self.meta(k) );
                end
            end
        end
        
        % bulk assign of metadata field by copying the value
        function self = assign(self,index,field,value)
            n = numel(index);
            for i = 1:n
                self.meta(index(i)).(field) = value;
            end
        end
        
        
    end
    
end

% Create a nx1 empty struct-array.
function s = structcol(n)
    s = repmat( struct(), n, 1 );
end
