classdef Slider < handle
    
    properties
        callback;
    end
    
    properties (SetAccess = private)
        handles;
        range, step;
    end
    
    methods
        
        function self = Slider(varargin)
            self.clear();
            if nargin > 0
                self.build(varargin{:});
            end
        end
        
        function clear(self)
            self.handles  = struct();
            self.range    = [0 1];
            self.step     = [0.01 0.1];
            self.callback = @dk.pass;
        end
        
        function val = get_value(self)
            
            val = NaN;
            
            if self.check_handle('slider')
                val = self.handles.slider.Value;
            end
        end
        
        function set_value(self,val)
            
            assert( self.check_ui(), 'UI not ready.' );
            
            if nargin > 1
                val = dk.math.clamp( val, [self.handles.slider.Min,self.handles.slider.Max] );
                self.handles.slider.Value = val;
            else
                val = self.get_value();
            end
            
            self.handles.text.String = sprintf('%g',val);
            
        end
        
        function set_range(self,range,step)
            
            % set range
            assert( isnumeric(range) && numel(range)==2, 'Range should be a 1x2 vector.' );
            
            self.range = sort(dk.to_row(range));
            dr = diff(range);
            
            assert( diff(self.range) > eps, 'Range must be a non-singleton interval.' );
            
            % set step
            if nargin > 2
                
                ns = numel(step);
                assert( isnumeric(step) && ns >= 1 && ns <= 2 && all( step > 0 & step <= dr), ...
                    'Step should be a positive scalar or 1x2 vector.' );
                
                if ns == 1, step = [step, min( dr/3, 10*step )]; end
                self.step = sort(dk.to_row(step));
                
            else
                self.step = [0.01 0.1]*dr;
            end
            
            % update UI
            self.update_ui();
            
        end
        
        function set_widths(self,slider,text,sep)
            
            if nargin < 4, sep = 10; end
            if nargin < 3, text = -1; end
            if nargin < 2, slider = -3; end
            
            if self.check_handle('box')
                self.handles.box.Widths = [slider sep text];
            end
            
        end
        
        function set_height(self,h)
            
            if self.check_ui()
                self.handles.slider.Position(4) = h;
                self.handles.text.Position(4) = h;
            end
            
        end
        
        function build(self,parent,callback,varargin)
        %
        % You can specify key-value options for the popup menu.
        %
            
            % create a horizontal box
            self.handles.box = uix.HBox( 'parent', parent, 'spacing', 5, 'padding', 7 );
            
            % set function callback if any
            if nargin < 3 || isempty(callback), callback = @dk.pass; end
            self.callback = callback;
            
            % create the slider
            self.handles.slider = uicontrol( 'parent', self.handles.box, 'style', 'slider', 'callback', @self.callback_slide );
        
            % separator between them
            uix.Empty('parent',self.handles.box);
            
            % create textbox
            self.handles.text = uicontrol( 'parent', self.handles.box, 'style', 'edit', 'callback', @self.callback_text );
        
            % set textbox options
            if nargin > 3
                opt  = struct(varargin{:});
                fopt = fieldnames(opt);
                for i = 1:numel(fopt)
                    f = fopt{i};
                    self.handles.text.(f) = opt.(f);
                end
            end
        
            % set widths
            self.set_widths();
            self.update_ui();
            
        end
        
    end
    
    methods (Hidden)
        
        function ok = check_handle(self,name)
            ok = isfield( self.handles, name ) && ishandle( self.handles.(name) );
        end
        function ok = check_ui(self)
            ok = self.check_handle('slider') && self.check_handle('text');
        end
        
        function callback_slide(self,hobj,edata)
            
            % update text box
            self.set_value();
            
            % trigger callback
            self.callback(hobj.Value);
            
        end
        
        function callback_text(self,hobj,edata)
            
            val = str2num(hobj.String);
            
            % update text box
            self.set_value(val);
            
            % trigger callback
            self.callback(val);
            
        end
        
        function update_ui(self)
            
            if self.check_ui()
                self.handles.slider.Min = self.range(1);
                self.handles.slider.Max = self.range(2);
                self.handles.slider.Value = self.range(1);
                self.handles.slider.SliderStep = self.step / diff(self.range);
                
                self.set_value();
            end
            
        end
        
    end
    
end