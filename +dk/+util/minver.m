function c = minver(v)
%
% c = dk.util.minver(v)
%
% Check that current Matlab version is more recent than the input.
% Input should be a string of the form '2014b', or an integer denoting the year.
%
% JH

    mver = version('-release');
    assert( length(mver) == 5, 'Expected release string to be 5 chars long.' );
    myear = str2double(mver(1:4));
    
    if isnumeric(v)
        c = v <= myear;
    else
        assert( ischar(v) && length(v)==5, 'Version query should be 5 chars long.' );
        qyear = str2double(v(1:4));
        if qyear == myear
            c = v(end) <= mver(end);
        else
            c = qyear < myear;
        end
    end

end