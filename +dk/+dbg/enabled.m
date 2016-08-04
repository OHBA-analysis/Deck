function y = enabled()

    y = strcmpi( getenv(dk.dbg.envname), 'on' );

end
