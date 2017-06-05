function h = colorbar( range, label, varargin )
%
% h = dk.ui.colorbar( range, label, varargin )
%
% THIS IS NOT A REPLACEMENT FOR MATLAB'S colorbar FUNCTION!
%
% Open a new figure with a colorbar in specified range and label.
% Outputs handles to colorbar image and text label (structure).
%
% Example:
%   dk.ui.colorbar( [-3 7], 'This is a label', ...
%       'orient', 'h', 'reverse', true, 'txtopt', {'FontSize',25}, 'cmap', dk.ui.cmap.wjet );
%
% INPUTS:
%     range  1x2 vector specifying the extents of the colorbar.
%     label  The text label to be placed near the colorbar.
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
        
    % these guys control how close/far the text label is from the colorbar
    tlo = 0.2;
    thi = 0.5;
        
    % open new figure
    fig=figure('units','normalized'); colormap(cmap);
    
    % work out the position of things
    switch lower(orient)
        
        case {'vertical','vert','v'}
            
            x = 0;
            y = linspace(range(1),range(2),len);
            if reverse
                hi = axes( 'Position', [ 0.25 0.03 0.50 0.94 ] );
                ht = axes( 'Position', [ 0.03 0.03 0.17 0.94 ], 'Visible', 'off' );
                
                oi=imagesc( hi, x, y, (1:len)' );
                ot=text( ht, thi, 0.5, label, 'Rotation', +90, 'HorizontalAlignment', 'center', txtopt{:} );
                hi.YAxisLocation = 'right';
                
            else
                hi = axes( 'Position', [ 0.25 0.03 0.50 0.94 ] );
                ht = axes( 'Position', [ 0.80 0.03 0.17 0.94 ], 'Visible', 'off' );
                
                oi=imagesc( hi, x, y, (1:len)' );
                ot=text( ht, tlo, 0.5, label, 'Rotation', -90, 'HorizontalAlignment', 'center', txtopt{:} );
                
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
                
                oi=imagesc( hi, x, y, (1:len) );
                ot=text( ht, 0.5, thi, label, 'HorizontalAlignment', 'center', txtopt{:} );
                hi.XAxisLocation = 'top';
                
            else
                hi = axes( 'Position', [ 0.07 0.20 0.90 0.50 ] );
                ht = axes( 'Position', [ 0.03 0.75 0.94 0.22 ], 'Visible', 'off' );
                
                oi=imagesc( hi, x, y, (1:len) );
                ot=text( ht, 0.5, tlo, label, 'HorizontalAlignment', 'center', txtopt{:} );
                
            end
            hi.YTick = [];
            box(hi,'off');
            
        otherwise
            error('Unknown orientation: %s',orient);
        
    end
    
    % save handles in figure UserData
    h.text.axis = ht;
    h.text.handle = ot;
    h.image.axis = hi;
    h.image.handle = oi;
    fig.UserData = h;

end