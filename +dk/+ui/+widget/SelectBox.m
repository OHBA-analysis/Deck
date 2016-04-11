classdef SelectBox < handle
%
% A horizontal box with a selector (popup menu) at the left of a confirm button.
% The relative widths can be changed via the field relative_widths. 
% The separation between the popup menu and the button is 10pts wide.
%

    properties
        handles;
        choices;
    end
    
    properties (Dependent)
        n_choices;
    end
    
    methods
        
        function self = SelectBox(varargin)
            self.clear();
            if nargin > 0
                self.build(varargin{:});
            end
        end
        
        function clear(self)
            self.handles  = struct();
            self.choices  = {'--'};
        end
        
        function n = get.n_choices(self)
            n = numel(self.choices);
        end
        
        function [val,name] = current_selection(self)
            
            val = NaN; name = '';
            
            if self.check_handle('popup')
                val  = self.handles.popup.Value;
                name = self.handles.popup.String{val};
            end
        end
        
        function set_choices(self,choices)
            
            assert( iscell(choices), 'Choices should be a cell.' );
            self.choices = choices;
            
            if self.check_handle('popup')
                self.handles.popup.String = choices;
                self.handles.popup.Value  = 1;
            end
            
        end
        
        function set_widths(self,selector,button,sep)
            
            if nargin < 4, sep = 10; end
            if nargin < 3, button = -1; end
            if nargin < 2, selector = -3; end
            
            if self.check_handle('popup')
                self.handles.box.Widths = [selector sep button];
            end
            
        end
        
        function build(self,parent,button_callback,varargin)
        %
        % You can specify key-value options for the popup menu.
        %
            
            % create a horizontal box
            self.handles.box = uix.HBox( 'parent', parent, 'spacing', 5, 'padding', 7 );
            
            % create the selector
            self.handles.popup = uicontrol( ...
                'parent', self.handles.box, ...
                'style', 'popup', ...
                'string', self.choices ...
            );
            
            % set popup options
            if nargin > 3
                opt  = struct(varargin{:});
                fopt = fieldnames(opt);
                for i = 1:numel(fopt)
                    f = fopt{i};
                    self.handles.popup.(f) = opt.(f);
                end
            end
        
            % separator between them
            uix.Empty('parent',self.handles.box);
            
            % create selection button
            self.handles.button = uicontrol( ...
                'parent', self.handles.box, ...
                'string', 'Select', ...
                'callback', button_callback ...
            );
        
            % set widths
            self.set_widths();
            
        end
        
    end
    
    methods (Hidden)
        
        function ok = check_handle(self,name)
            ok = isfield( self.handles, name ) && ishandle( self.handles.(name) );
        end
        
    end
    
end
