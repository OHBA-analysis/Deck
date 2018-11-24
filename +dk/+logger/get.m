function obj = get(name,varargin)
%
% obj = dk.logger.get(name,varargin)
%
% Return existing, or create new, instance of dk.logger.Logger.
% If called without name, print a list of existing loggers to the console.
%
% JH

    persistent loggers;
    if isempty(loggers)
        loggers = {};
    else
        loggers = loggers(cellfun( @isvalid, loggers ));
    end
    
    lnames = dk.mapfun( @(x) x.name, loggers, false );
    if nargin == 0
        disp( 'Currently registered loggers are:' );
        disp( strjoin(lnames,newline) );
    else
        assert( ischar(name) && ~isempty(name), 'Invalid name.' );
        [~,k] = ismember( name, lnames );

        if k > 0
            obj = loggers{k};
        else
            obj = dk.logger.Logger(name,varargin{:});
            loggers{end+1} = obj;
        end
    end

end

function v = isvalid(x)
    try
        x.name;
        v = true;
    catch
        v = false;
    end
end