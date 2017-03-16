function rescale( f, factor )
%
% dk.ui.fig.rescale( f, factor )
%
% Multiply the current size of the figure by a real factor.
%
% JH

    [~,hw] = dk.ui.fig.position(f);
    dk.ui.fig.resize( f, factor*hw );

end