function A = data_array()

    names = {'a', '_', '123', 'with spaces'};
    nc = numel(names);
    nb = 5;
    
    A = dk.obj.DataArray( names, {}, nb );
    D = rand(nb+1,nc);
    
    assert( A.ncols == nc );
    assert( A.nrows == 0 );
    assert( A.nmax == nb );

    A.add( D(1:nb,:), 'hello', 1, 'world', 2 );
    assert( A.nrows == nb );
    assert( A.nmax == nb );
    assert( A.capacity == 0 );
    
    A.add( D(end,:) );
    assert( A.nrows == nb+1 );
    assert( A.nmax == 2*nb );
    assert( A.capacity == nb-1 );
    
    assert( all(A.col('123') == D(:,3)) );
    assert( A.dget(nb,'with spaces') == D(nb,end) );
    
    A.compress();
    assert( A.nmax == nb+1 );
    assert( isempty(A.mget(nb+1).hello) );
    assert( A.mget(3).world == 2 );
    
%     Try also
%     x = rand(1e5,10);
%     D = dk.obj.DataArray(x,732);
%     D.setnames(num2cell(char('a' + (0:9))))
%     y = D.col('d');
    
end