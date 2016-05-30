function c = rwb(n,twosided)
	% twosided is equivalant to signed i.e. caxis is symmetric & centered at 0

	if nargin < 2 || isempty(twosided)
		twosided = true; % two sided by default
	end

	if nargin < 1 || isempty(n)
		n = 101;
	end
	
	if twosided
		% n should be odd so that zero is in the middle, if twosided
		if mod(n,2) == 0, n=n+1; end
		saturation = linspace(1,0,floor(n/2)+1);
		saturation = saturation(1:end-1); % Remove the zero-saturation and have the correct length
	else
		saturation = linspace(1,0,n);
	end

	red = rgb2hsv([1 0 0]);
	red = repmat(red,length(saturation),1);
	red(:,2) = saturation;

    if ~twosided
        c = hsv2rgb(red);
        return
    end

    blue = rgb2hsv([0 0 1]);
	blue = repmat(blue,length(saturation),1);
	blue(end:-1:1,2) = saturation;

	c = [hsv2rgb(red); 1 1 1; hsv2rgb(blue)];
	c = c(end:-1:1,:);
    
end

