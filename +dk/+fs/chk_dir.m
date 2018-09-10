function chk_dir(x)
    dk.assert( dk.fs.is_dir(x), 'Not a directory: %s', x );
end