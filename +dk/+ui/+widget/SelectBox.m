classdef SelectBox < handle
%
% A horizontal box with a selector (popup menu) on the left, and a confirm button on the right.
% The relative widths can be changed via the method set_widths. 
% The separation between the popup menu and the button is 10pts wide.
%

    properties (SetAccess = private)
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
            
            if self.check_ui()
                val  = self.handles.popup.Value;
                name = self.handles.popup.String{val};
            end
        end
        
        function set_choices(self,choices)
            
            assert( iscell(choices), 'Choices should be a cell.' );
            self.choices = choices;
            
            if self.check_ui()
                self.handles.popup.String = choices;
                self.handles.popup.Value  = 1;
            end
            
        end
        
        function set_widths(self,selector,button,sep)
            
            if nargin < 4, sep = 10; end
            if nargin < 3, button = -1; end
            if nargin < 2, selector = -3; end
            
            if self.check_ui()
                self.handles.box.Widths = [selector sep button];
            end
            
        end
        
        function set_height(self,h)
            
            if self.check_ui()
                self.handles.popup.Position(4) = h;
                self.handles.button.Position(4) = h;
            end
            
        end
        
        function build(self,parent,callback,varargin)
        %
        % You can specify key-value options for the popup menu.
        %
        
            if nargin < 3 || isempty(callback), callback = @dk.pass; end
            
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
                'callback', callback ...
            );
        
            % set widths
            self.set_widths();
            
        end
        
    end
    
    methods (Hidden)
        
        function ok = check_handle(self,name)
            ok = isfield( self.handles, name ) && ishandle( self.handles.(name) );
        end
        
        function ok = check_ui(self)
            ok = self.check_handle('popup') && self.check_handle('button');
        end
        
    end
    
end
