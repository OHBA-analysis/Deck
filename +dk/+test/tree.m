
T = dk.test.tree_rand(4);

% plot tree and shape
T.plot('Name','First plot');
[d,w] = T.shape();
fprintf('Width[%d]: %s\n',d,sprintf('%d ',w));

% remove node and redraw
n = T.n_nodes;
r = randi(fix(n/2));
T.rem_node(r);
T.plot('Name','After removing');
dk.println('After removing node %d / %d',r,n);
T.print();

% cleanup and redraw
T.cleanup();
T.plot('Name','After cleanup');
disp('After cleanup:');
T.print();

% traversal
disp('Depth-first search:');
T.dfs( @(k,n) fprintf('%d ',k) ); fprintf('\n');

disp('Breadth-first search:');
T.bfs( @(k,n) fprintf('%d ',k) ); fprintf('\n');