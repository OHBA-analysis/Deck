function y = enabled()

    y = strcmpi( getenv(dk.debug.envname), 'on' );

end
