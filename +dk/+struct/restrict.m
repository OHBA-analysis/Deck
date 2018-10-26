function restrict( s, allowed )
%
% dk.struct.restrict( s, allowed )
%
% Check fieldnames of s, and throw an error if any is unknown.
%
% JH

    assert( isstruct(s) && iscellstr(allowed), 'Bad inputs.' );

    unknown = setdiff( fieldnames(s), allowed );
    assert( isempty(unknown), 'Unknown fieldnames:\n%s', strjoin(unknown,newline) );

end