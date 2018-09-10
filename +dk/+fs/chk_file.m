function chk_file(x)
    dk.assert( dk.fs.is_file(x), 'File not found: %s', x );
end