function signal = hilbinv( envelope, phase )
%
% Compute the inverse Hilbert transform from an input envelope and phase.
% Note that this does not restore the DC component of the original signal, 
% which is lost when we do the forward transform.
    
    signal = imag(-1j * hilbert( envelope .* sin(phase) ));

end
