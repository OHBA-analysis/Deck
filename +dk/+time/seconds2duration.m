function duration = seconds2duration( sec )
%
% Convert an input amount of seconds to an integer vector with days, hours, .. down to miliseconds.
% 
% Contact: jhadida [at] fmrib.ox.ac.uk

    d  = floor(sec/86400);
		sec = sec - d*86400;
	h  = floor(sec/3600);
		sec = sec - h*3600;
	m  = floor(sec/60);
		sec = sec - m*60;
	s  = floor(sec);
		sec = sec - s;
	ms = floor(sec*1000);
    
    duration = [ d, h, m, s, ms ];
    
end
