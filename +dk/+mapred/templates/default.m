classdef $Name < dk.mapred.Abstract

    properties
        name = '$Name';
    end

    methods

        % constructor
        function self = $Name()
        end

        function inputs = get_inputs(self,index)

            inputs = arrayfun( @(x) struct('x',x), linspace(0,2*pi,100), 'UniformOutput', false );
            inputs = [inputs{:}];

            if nargin > 1
                inputs = inputs(index);
            end

        end

        function output = process(self,inputs,folder,varargin)

            % parse options
            opt = dk.obj.kwArgs( varargin{:} );
                opt_mode = lower(opt.get('mode','default'));

            % do stuff
            switch opt_mode

                case {'cos','default'}
                    output = cos(inputs.x);

                case {'sin'}
                    output = sin(inputs.x);

                otherwise
                    warning( 'Unknown mode "%s"', opt_mode );
                    output = [];

            end

            % save data to folder
            savename = fullfile( folder, sprintf('output_%s.mat',opt_mode) ); 
            save( savename, '-v7', 'output' );

        end

        function configure( self, nworkers )

            

        end

    end

end