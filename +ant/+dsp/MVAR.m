classdef MVAR < handle
%
% Fit and generate from MVAR models.
%

    properties
        p
		w
		A
		C
		m
	end

	methods

        function self = MVAR(varargin)
            self.clear();
            if nargin > 0
                self.fit(varargin{:});
            end
        end

        function clear(self)
            self.p = 0;
            self.A = [];
            self.w = [];
            self.C = [];
            self.m = [];
        end

        function [self,ts] = fit(self,ts,pmin,pmax)
            if nargin < 4, pmax=pmin; end

            [ts,self.m] = ant.priv.mvar_prep(ts);
            [self.w,self.A,self.C] = ant.priv.mvar_fit( ts.vals, pmin, pmax, 'zero' );
            self.p = size(A,2); %?
        end

        function ts = gen(self,tlen,fs)
            t = 0 : (1/fs) : tlen;
            v = ant.priv.mvar_sim( self.w, self.A, self.C, numel(t) );
            v = dk.bsx.add( v, self.m );
            ts = ant.TimeSeries( t, v );
        end

    end
    
end
