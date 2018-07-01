classdef GrowingContainer < handle
%
% Container class with storage grown automatically to avoid reallocating too often.
%
% ## WARNING
%
%   PROPERTIES ACCESS IS PUBLIC
%   DO NOT MODIFY THE SHAPE/SIZE/TYPE OF ANY PROPERTY
%   DO NOT MODIFY THE VALUE OF: last
%
%   THE METHOD compress() INVALIDATES ANY PREVIOUS INDEXING!
%
% ------------------------------
% ## Memory management
%
%   The memory allocation is managed dynamically, and evolves with the instance.
%   Allocations are done in bulk whenever they become necessary, not for every addition.
%   This makes the addition of new elements much more efficient time-wise.
%
%   Manual allocations for N entries can be forced using the method alloc(N).
%   In most cases, you will want to use reserve(N) instead, which checks whether
%   the capacity allows the addition of N new elements without dynamic reallocation.
%   The size of the memory block allocated is controled by bsize.
%
%   One or several elements can be removed at once using: rem([i1,i2,i3,...]).
%   Removal simply marks the point as unused, and does not cause reallocation, hence preserving
%   indexing. The indices of all points still in-use are returned by find().
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
        used        % logical column vector marking used elements
        last        % index of last assigned element
        bsize       % block-size for allocation
    end
    
    properties (Transient,Dependent)
        nmax        % number of elements allocated
        nelm        % number of elements in use
        ready       % check that object is initialised
        capacity    % number of elements that can be added without reallocation
        sparsity    % sparsity ratio (compress when between 0.2-0.5)
    end
    
    events
        OnAlloc     % triggered after allocation
        OnCompress  % triggered after compression
    end
    
    methods (Abstract) % TO BE IMPLEMENTED
        
        % extend data containers by n elements
        %
        % this is called after allocation of this object (cf alloc), and before
        % triggering the OnAlloc event
        childAlloc(self,n);
        
        % compress data containers to contain only used elements
        %
        % this is called after compression of this object (cf compress), and before
        % triggering the OnCompress event
        childCompress(self,id,remap);
        
    end
    
    methods % main public methods
        
        % dependent properties
        function n = get.nmax(self), n=numel(self.used); end
        function n = get.nelm(self), n=nnz(self.used); end
        function n = get.capacity(self), n = self.nmax - self.last; end
        function y = get.ready(self), y = ~isempty(self.used); end
        function s = get.sparsity(self), s = 1 - (self.bsize + self.nelm)/(self.bsize + self.last); end
        
        function set.bsize(self,b)
            b = floor(b);
            assert( b > 0, 'Block-size should be positive.' );
            self.bsize = b;
        end
        
        % return indices of used elements
        function k = find(self)
            k = find(self.used);
        end
        
        % remove elements by marking them as unused to preserve indexing
        function rem(self,k)
            assert( k <= self.last, 'Index out of bounds.' );
            self.used(k) = false;
            dk.wreject( self.sparsity > 0.9, 'Storage is very sparse, you should run compress().' );
        end
        
        % allocate memory for more elements
        function n = alloc(self,n)
            self.used = vertcat( self.used, false(n,1) );
            self.childAlloc(n);
            self.notify('OnAlloc');
        end
        % ensure the capacity is large enough for adding n elements
        function n = reserve(self,n)
            n = max(0, n-self.capacity);
            if n > 0, self.alloc(n); end
        end
        % ensure the capacity is large enough to fit all indices in k
        function n = accom(self,k)
            n = max(0, max(k(:))-self.nmax);
            if n > 0, self.alloc(n); end
        end
        
        % reduce the storage only to used element
        %
        % this causes capacity to become 0
        function remap = compress(self)
            ne = self.nelm;
            nl = self.last;
            id = self.find();
            
            remap = zeros(nl,1);
            remap(id) = 1:ne;
            
            self.used = self.used(id);
            self.childCompress(id,remap);
            self.notify('OnCompress');
        end
        
    end
    
    methods (Hidden, Access=protected) % internal methods to be called by children classes
        
        % initialisation 
        %
        function gcClear(self)
            self.used = false(0);
            self.bsize = 100;
            self.last = 0;
        end
        
        function gcInit(self,b)
            self.bsize = b;
            self.used = false(b,1);
            self.last = 0;
        end
        
        % addition of new element(s)
        % triggers alloc if necessary
        %
        function k = gcAdd(self,n)
            b = self.last+1;
            e = self.last+n;
            k = b:e;
            if e > self.nmax
                self.alloc(ceil( (e - self.nmax)/self.bsize ) * self.bsize);
            end
            self.last = e;
            self.used(k) = true;
        end
        
        
        % serialisation
        %
        function s=gcToStruct(self)
            s.used  = self.used;
            s.last  = self.last;
            s.bsize = self.bsize;
        end
        
        function self=gcFromStruct(self,s)
            self.used = s.used;
            self.last = s.last;
            self.bsize = s.bsize;
        end
        
    end
    
end