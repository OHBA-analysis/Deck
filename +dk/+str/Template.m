classdef Template < handle
%
% Python-style string template.
%
% JH

    properties
        text
    end
    
    methods
        
        function self = Template(varargin)
            self.clear();
            if nargin > 0
                self.assign(varargin{:});
            end
        end
        
        function clear(self)
            self.text = '';
        end
        
        function self = assign(self,text,isfilename)
            
            if nargin < 3, isfilename=false; end
            if isfilename
                self.text = dk.fs.gets(text);
            else
                self.text = text;
            end
            
        end
        
        function v = variables(self)
            
            v = regexp( self.text, '[^$]\$\{[\w\d_-]+\}', 'match' );
            v = unique(cellfun( @(x) x(4:end-1), v, 'UniformOutput', false ));
            if nargout == 0, cellfun(@disp,v); end
            
        end
        
        function s = substitute(self,varargin)
            
            sub = dk.obj.kwArgs();
            sub.CaseSensitive = true;
            sub.parse(varargin{:});
            sub = sub.parsed;
            
            f = fieldnames(sub);
            n = numel(f);
            s = self.text;
            
            for i = 1:n
                s = strrep( s, ['${' f{i} '}'], sub.(f{i}) );
            end
            
        end
        
    end
    
end