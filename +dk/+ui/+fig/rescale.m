function rescale( f, factor )

    [~,hw] = dk.ui.fig.position(f);
    dk.ui.fig.resize( f, factor*hw );

end