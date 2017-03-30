function [hi,ht] = colorbar( range, label, varargin )
%
% [hi,ht] = dk.ui.colorbar( range, label, varargin )
%
% THIS IS NOT A REPLACEMENT FOR MATLAB'S colorbar FUNCTION!
%
% Open a new figure with a colorbar in specified range and label.
% Outputs handles to the axes containing the colorbar and text label.
%
% OPTIONS:
%
%    orient  Orientation of the colorbar: 'horiz' or 'vert' (default: 'vert').
%   reverse  Change the relative position of label and colorbar (default: false).
%      cmap  Colormap, either string or nx3 array of RGB colors (default: 'jet').
%    length  Number of points in the colorbar (default: 128).
%    txtopt  Cell of options for the text label (default: {}). 
%            See 'doc text' for details.
%   
% JH

    % parse options
    opt = dk.obj.kwArgs(varargin{:});
    
        orient = opt.get( 'orient', 'vertical' );
        reverse = opt.get( 'reverse', false );
        cmap = opt.get( 'cmap', 'jet' );
        len = opt.get( 'length', 128 );
        txtopt = opt.get( 'txtopt', {} );
        
    % open new figure
    figure('units','normalized'); colormap(cmap);
    
    % work out the position of things
    switch lower(orient)
        
        case {'vertical','vert','v'}
            
            x = 0;
            y = linspace(range(1),range(2),len);
            if reverse
                hi = axes( 'Position', [ 0.25 0.03 0.50 0.94 ] );
                ht = axes( 'Position', [ 0.03 0.03 0.17 0.94 ], 'Visible', 'off' );
                
                imagesc( hi, x, y, (1:len)' );
                text( ht, 0.5, 0.5, label, 'Rotation', +90, 'HorizontalAlignment', 'center', txtopt{:} );
                hi.YAxisLocation = 'right';
                
            else
                hi = axes( 'Position', [ 0.25 0.03 0.50 0.94 ] );
                ht = axes( 'Position', [ 0.80 0.03 0.17 0.94 ], 'Visible', 'off' );
                
                imagesc( hi, x, y, (1:len)' );
                text( ht, 0.2, 0.5, label, 'Rotation', -90, 'HorizontalAlignment', 'center', txtopt{:} );
                
            end
            hi.XTick = [];
            hi.YDir = 'normal';
            box(hi,'off');
            
        case {'horizontal','horz','h'}
            
            x = linspace(range(1),range(2),len);
            y = 0;
            if reverse
                hi = axes( 'Position', [ 0.07 0.30 0.90 0.50 ] );
                ht = axes( 'Position', [ 0.03 0.03 0.94 0.22 ], 'Visible', 'off' );
                
                imagesc( hi, x, y, (1:len) );
                text( ht, 0.5, 0.5, label, 'HorizontalAlignment', 'center', txtopt{:} );
                hi.XAxisLocation = 'top';
                
            else
                hi = axes( 'Position', [ 0.07 0.20 0.90 0.50 ] );
                ht = axes( 'Position', [ 0.03 0.75 0.94 0.22 ], 'Visible', 'off' );
                
                imagesc( hi, x, y, (1:len) );
                text( ht, 0.5, 0.2, label, 'HorizontalAlignment', 'center', txtopt{:} );
                
            end
            hi.YTick = [];
            box(hi,'off');
            
        otherwise
            error('Unknown orientation: %s',orient);
        
    end

end