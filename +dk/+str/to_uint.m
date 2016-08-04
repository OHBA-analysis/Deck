function [n,rem] = to_uint( str )
%
% Extract the first unsigned integer found in a string, and return the rest of the string.
% 
% Contact: jhadida [at] fmrib.ox.ac.uk

	n = str >= '0' & str <= '9';
	m = diff(n);
	
	if ~ischar(str) || isempty(str) || ~any(n)
		n   = NaN;
		rem = '';
	elseif any(m)
		nb = find( m ==  1, 1, 'first' );
		ne = find( m == -1, 1, 'first' );
		
		% If no begining was found, or only the beginning of another number
		if isempty(nb) || ( ~isempty(ne) && ne < nb )
			nb = 0;
		end
		
		% If no end was found
		if isempty(ne)
			ne = length(str);
		end
		
		n   = str2double(str( nb+1:ne ));
		rem = str( ne+1:end );
	else
		n   = str2double(str);
		rem = '';
	end
end
