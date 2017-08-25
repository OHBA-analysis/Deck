classdef Tree < handle
    
    properties
        node
    end

    properties (Transient,Dependent)
        n_nodes, n_leaves, n_splits;
    end
    
    methods
        function n=get.n_nodes(self)
            n=numel(self.node);
        end
        function n=get.n_leaves(self)
            n=sum([self.node.is_leaf]);
        end
        function n=get.n_splits(self)
            n=self.n_nodes - self.n_leaves;
        end
    end
    
    methods
        
        function self = Tree(varargin)
            self.reset(varargin{:});
        end
        
        function self=reset(self,varargin)
            % set root node
            self.node = dk.obj.Node(1,1,varargin{:});
        end
        
        % shape of the tree
        function [depth,width] = shape(self)
            depth = [self.node.depth];
            valid = [self.node.is_valid];
            depth = depth(valid);
            width = accumarray( depth(:), 1 );
            depth = max(depth);
        end
        
        % add/remove single node
        function k=add_node(self,p,varargin)
            k = length(self.node)+1;
            d = self.node(p).depth+1;
            self.node(k) = dk.obj.Node(d,p,varargin{:});
            self.node(p).add_child(k);
        end
        function self=rem_node(self,k)
            % cannot remove node from array without screwing up indices, use cleanup
            self.parent(k).rem_child(k);
            c = self.node(k).children;
            for i = 1:length(c)
                self.rem_node(c(i));
            end
            self.node(k).clear();
        end
        
        % add/remove multiple nodes
        function k=add_nodes(self,p,n)
            k = zeros(1,n);
            for i = 1:n
                k(i) = self.add_node(p);
            end
        end
        function rem_nodes(self,k)
            for i = 1:numel(k)
                self.rem_node(k(i));
            end
        end
        
        % semantic access to nodes
        function N=root(self)
            N=self.node(1);
        end
        function p=parent(self,k)
            p=self.node( self.node(k).parent );
        end
        function N=children(self,k)
            N=self.node( self.node(k).children );
        end
        
        % remove deleted nodes and re-index the tree
        function self=cleanup(self)
            
            depth = [self.node.depth];
            valid = [self.node.is_valid];
            
            % remap depth (this should not happen)
            count = accumarray( 1+depth(:), 1 );
            assert( all(count(2:end) > 0), 'Bug during removal.' );
            
            % remap valid indices, and sort by depth
            [~,order] = sort(depth(valid));
            old2new = zeros(size(self.node));
            old2new(valid) = order;
            
            self.node = self.node(valid);
            n = numel(self.node);
            for i = 1:n
                self.node(i).remap( old2new );
            end
            
        end
        
        % traversal methods (note: the order is not guaranteed)
        function bfs(self,callback,cur)
            if nargin < 3, cur = 1; end
            next = cell(size(cur));
            for i = 1:length(cur)
                curnode = self.node(cur(i));
                callback(cur(i), curnode);
                next{i} = curnode.children;
            end
            next = unique(horzcat( next{:} ));
            if ~isempty(next)
                self.bfs( callback, next );
            end
        end
        function dfs(self,callback,cur)
            if nargin < 3, cur=1; end
            assert( isscalar(cur), 'Expected a single node.' );
            curnode = self.node(cur);
            callback(cur, curnode);
            next = curnode.children;
            for i = 1:length(next)
                self.dfs( callback, next(i) );
            end
        end
        
        function print(self)
            N = self.n_nodes;
            for i = 1:N 
                Ni = self.node(i);
                if Ni.is_valid
                    dk.println( '%d [%d] : %d children, %d data-fields', i, Ni.depth, numel(Ni.children), numel(Ni.fields) );
                else
                    dk.println( '%d [%d] : DELETED', i, Ni.depth );
                end
            end
        end
        
        function gobj = plot(self,varargin)
        %
        % Draw the tree in a figure.
        %
        % Options:
        %
        %        Name  Figure name
        %        Link  Link options (see line options)
        %      Sepfun  Function of the depth adding width to separate branches
        %     Balance  Balancing flag (children reordering)
        %    NodeSize  Alias for MarkerSize
        %    NodeEdge  Alias for MarkerEdgeColor
        %   NodeColor  Nx3 array of colours for each node
        %     ToolTip  Function handle to be called by datacursormode
        %
            
            opt = dk.obj.kwArgs(varargin{:});
            balance = opt.get('Balance',true);
            
            % properties
            depth = [self.node.depth];
            D = max(depth);
            N = self.n_nodes;
            
            % width and height
            sepfun = opt.get( 'Sepfun', @(x)x );
            width = self.compute_widths(sepfun);
            height = width(1) ./ log10(9+(1:D));
            
            % parse options
            linkopt = opt.get('Link', {} );
            nodeopt = {'MarkerSize',opt.get('NodeSize',8),'MarkerEdgeColor',opt.get('NodeEdge','k')};
            nodecol = opt.get('NodeColor',dk.cmap.interp( hsv(max(D,5)), depth ));
            
            % axis coordinate and offset for each node
            coord = zeros(1,N);
            offset = zeros(1,N);
            
            % open new figure for display
            gobj.fig  = figure('Color','w','Name',opt.get('Name','[dk] Tree plot'));
            gobj.node = gobjects(1,N);
            gobj.link = gobjects(1,N); % first link is null
            
            % draw the root
            coord(1) = width(1)/2;
            gobj.node(1) = draw_node( width(1)/2, height(1), nodecol(1,:), nodeopt );
            hold on;
            
            % draw tree level by level, starting from the root
            for h = 1:D-1

                % find nodes at that level, and their children
                p = find( depth == h );

                % draw the children of each parent
                y = height(h+1);
                np = numel(p);
                for i = 1:np

                    % skip if there are no children
                    pi = p(i);
                    if self.node(pi).is_leaf, continue; end
                    
                    % reorder children to balance the tree
                    ci = self.node(pi).children;
                    di = 1+self.node(pi).depth;
                    nc = numel(ci);
                    if balance
                        ci = reorder_children( ci, width(ci) );
                    end

                    % draw the children in order
                    x0 = offset(pi); % offset of the parent
                    x0 = x0 + (width(pi) - sum(width(ci)))/2; % add separation increment
                    for j = 1:nc
                        cij = ci(j); 

                        % save position of current node
                        offset(cij) = x0;
                        coord(cij) = x0 + width(cij)/2;

                        % update offset for siblings
                        x0 = x0 + width(cij);

                        % draw node and link to parent
                        glink = draw_link( coord(cij), y, coord(pi), height(h), linkopt );
                        gnode = draw_node( coord(cij), y, nodecol(di,:), nodeopt );

                        % save handles
                        gobj.node(cij) = gnode;
                        gobj.link(cij) = glink;

                        % set datatip
                        gnode.UserData.id = cij;
                        glink.UserData.id = pi;
                    end
                end

                fprintf('Level %d\n',h);
            end
            hold off; axis off;
            
            % set data tip
            tooltip = opt.get( 'ToolTip', @datatip );
            set( datacursormode(gcf), 'updatefcn', tooltip );
            
        end
        
    end
    
    methods (Hidden)
        
        function w = compute_widths(self,sepfun)
        %
        % Compute the width required for displaying each node and its children.
        % The leaf nodes have a width of 1, which is equivalent to right and left margins of 1/2.
        %
        % The width of leaf nodes is propagated to their parents (summing for all children), and then to 
        % the grandparents, etc. Until we reach the root. Note that this _needs_ to be done level by level.
        %

            depth = [self.node.depth];
            maxdepth = max(depth);
            inc = sepfun(fliplr(0:maxdepth-1));

            % initialise width
            w = zeros(size(self.node));
            w( [self.node.is_leaf] ) = 1; % set all leaves to 1

            % propagate width level by level, starting from the bottom
            for h = maxdepth:-1:2
                k = find( depth == h );
                p = [self.node(k).parent];
                n = numel(k);

                for i = 1:n
                    w(k(i)) = w(k(i)) + inc(h);
                    w(p(i)) = w(p(i)) + w(k(i));
                end
            end

        end
        
    end
    
end

% Isolate functions which actually draw stuff.
function h = draw_node(x,y,c,opt)
    opt = [ opt, {'MarkerFaceColor',c} ];
    h = plot(x,y,'o',opt{:});
end

function h = draw_link(x,y,xx,yy,opt)
    h = plot([x,xx],[y,yy],'k-',opt{:});
end

function txt = datatip(~,evt)
    try
        dat = evt.Target.UserData;
        txt = { ['id: ' num2str(dat.id)] };
    catch
        txt = 'Undefined';
    end
end

function c = reorder_children( c, w )
%
% Simple balancing technique which distributes weights in decreasing order, 
% starting at the centre and alternating right and left.
%

    n = numel(c);
    if n == 1, return; end
    
    [~,o] = sort(w,'descend');
    r = zeros(1,n);
    p = ceil(n/2);

    for i = 1:n
        if mod(i,2) == 1 % odd
            r( p - (i-1)/2 ) = c(o(i));
        else
            r( p + i/2 ) = c(o(i));
        end
    end
    c = r;
    
end
