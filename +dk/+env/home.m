function h = home()
%
% On UNIX systems, returns the value of the environment variable $HOME.
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    h = getenv('HOME');
end
