function L = lights( varargin )
%
% L = dk.ui.lights( varargin )
%
% Remove all lights in current axes, and set specified lights one by one instead.
% Each input should be:
%   [az,el] 1x2 vector
%   string right, left, headlight
%   {...} cell of inputs to be forwarded to camlight
%
% Returns the handles to the lights created.
%
% Example:
%   dk.ui.lights( 'left', {[0,90],'infinite'} );
%
% JH

    % delete current lights
    delete(findobj( gca, 'type', 'light' ));

    % create new lights
    L = cell(1,nargin);
    for i = 1:nargin
        
        arg = varargin{i};
        if ~iscell(arg), arg = {arg}; end
        if isnumeric(arg{1})
            arg1 = num2cell(arg{1});
            arg  = [ arg1{:}, arg(2:end) ];
        end
        L{i} = camlight(arg{:});
        
    end

end