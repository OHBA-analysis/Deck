function h = mesh(m,varargin)
%
% h = dk.ui.mesh( mesh, args... )
%
% Draw input mesh as a patch with specified options.
%
% The input mesh should be a struct { faces, vertices }.
%
% The option FaceVertexCData automatically converts face-color specification to
% vertex-color specification if needed.
%
% 
% See also: dk.ui.face2vertex, patch
%
% JH

    % find faces and vertices fields
    fields = fieldnames(m);
    lf = dk.mapfun( @lower, fields );
    f = m.(fields{strcmp( 'faces', lf )});
    v = m.(fields{strcmp( 'vertices', lf )});
    
    % check size of facevertexcdata
    nf = size( f, 1 );
    nv = size( v, 1 );
    
    for i = 1:2:nargin-1
        switch lower(varargin{i})
            case 'vertexcolor'
                varargin{i} = 'FaceVertexCData';
            case 'facecolor'
                if dk.is.rgb(varargin{i+1},nf)
                    varargin{i} = 'FaceVertexCData';
                    varargin{i+1} = dk.ui.face2vertex( varargin{i+1}, f, nv );
                end
            case 'facevertexcdata'
                if size(varargin{i+1},1) ~= nv
                    varargin{i+1} = dk.ui.face2vertex( varargin{i+1}, f, nv );
                end
        end
    end
    
    % draw patch
    h = patch( 'Faces', f, 'Vertices', v, varargin{:} );

end