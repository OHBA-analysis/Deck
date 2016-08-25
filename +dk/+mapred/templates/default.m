classdef ${Class} < dk.mapred.Abstract

    properties (Constant)
        name = '${Name}';
        id = '${ID}';
    end

    methods

        function inputs = get_inputs(self,index)

            inputs = linspace(0,2*pi,100);
            %inputs = dk.arrayfun( @(x) struct('x',x), inputs, false );
            %inputs = [inputs{:}];

            if nargin > 1
                inputs = inputs(index);
            end

        end

        function output = process(self,inputs,folder,varargin)

            if nargin < 3, folder=[]; end

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
            if ~isempty(folder)
                savename = fullfile( folder, sprintf('output_%s.mat',opt_mode) ); 
                save( savename, '-v7', 'output' );
            end

        end

    end

end