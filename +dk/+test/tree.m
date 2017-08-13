
T = dk.obj.Tree();

% add nodes
k = T.add_nodes( 1, 3 );
T.add_nodes( k(2), 2 );
T.add_node(T.add_node( k(3) ));
T.plot('Name','First plot');

% remove node and redraw
T.rem_node(k(3));
T.plot('Name','After removal');
T.print();

T.cleanup();
T.add_node(2);
T.plot('Name','After cleanup');
T.print();

% traversal
T.dfs( @(k,n) disp(k) );
T.bfs( @(k,n) disp(k) );