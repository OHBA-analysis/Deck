classdef FrameStack < handle
%
% A vertical box with a selector (popup menu) on top of an image axes.
% The selector choices are the titles of the images. Selection can be set externally.
%

    properties
        framerate;
        options;
    end

    properties (SetAccess = private)
        handles;
        frames;
        playing;
    end
    
    properties (Dependent)
        n_frames;
    end
    
    methods
        
        function self = FrameStack(varargin)
            self.clear();
            if nargin > 0
                self.build(varargin{:});
            end
        end
        
        function clear(self)
            self.handles   = struct();
            self.frames    = [];
            self.framerate = 1;
            self.options   = struct();
            self.playing   = false;
        end
                
        function n = get.n_frames(self)
            if isempty(self.frames)
                n = 0; 
            else
                n = size(self.frames,3);
            end
        end
        
        function num = current_frame(self)
            
            num = NaN;
            if self.check_ui()
                num = self.handles.slider.Value;
            end
            
        end
        
        function set_frames(self,frames,framerate,options)
        
            if nargin < 4, options = struct(); end
            if nargin < 3, framerate = 1; end
            
            assert( isnumeric(frames) && ndims(frames)==3, 'Input frames should be a volume.' );
            assert( isnumeric(framerate) && isscalar(framerate) && framerate > eps, 'Framerate should be a positive scalar.' );
            assert( isstruct(options), 'Options should be a structure.' );
            
            self.frames    = frames;
            self.framerate = framerate;
            self.options   = options;
            
            self.update_ui();
            self.select_frame(1);
            
        end
        
        function set_heights(self,controls,sep)
            
            if nargin < 3, sep = 15; end
            if nargin < 2, controls = 30; end
            
            if self.check_ui
                self.handles.box.Heights = [controls,sep,-1];
            end
            
        end
        
        function select_frame(self,num,fast)
            
            if nargin < 3, fast = false; end
            if self.n_frames > 0 && self.check_ui
                
                num = round(num);
                
                if self.check_handle('image') && fast 
                    
                    % replace image data in existing image handle
                    self.handles.image.CData = self.frames(:,:,num); 
                    
                else
                    
                    % interrupt playing
                    self.cb_stop();

                    % display this image
                    hdl = self.handles.axes;
                    set( ancestor(hdl,'figure'), 'currentaxes', hdl );
                    self.handles.image = dk.ui.image( self.frames(:,:,num), self.options );
                    
                end
                
                % update the slider
                self.handles.slider.Value = num;
                self.handles.text.String  = num2str(num);
                
            end
            
        end
        
        function build(self,parent)
        
            % create a vertical box
            self.handles.box = uix.VBox( 'parent', parent, 'padding', 5 );
            
            % build controls
            self.handles.controls = uix.HBox( 'parent', self.handles.box, 'spacing', 10 );
            
            self.handles.button = uicontrol( ...
                'parent', self.handles.controls, ...
                'string', 'Play', 'callback', @self.cb_button );
            
            self.handles.slider = uicontrol( ...
                'parent', self.handles.controls, ...
                'style', 'slider', 'callback', @self.cb_slider ...
            );
        
            self.handles.text = uicontrol( ...
                'parent', self.handles.controls, ...
                'style', 'edit', 'callback', @self.cb_text ...
            );
        
            self.handles.controls.Widths = [ 40 -1 30 ];
        
            % empty separator
            uix.Empty('parent',self.handles.box);
        
            % create axes for image
            self.handles.axes = axes( 'parent', uicontainer('parent',self.handles.box) );
            
            self.set_heights();
            self.update_ui();
            
        end
        
    end
    
    methods (Hidden)
        
        function ok = check_handle(self,name)
            ok = isfield( self.handles, name ) && ishandle( self.handles.(name) );
        end
        
        function ok = check_ui(self)
            ok = self.check_handle('axes') && self.check_handle('slider') && self.check_handle('button');
        end
        
        function update_ui(self)
            
            if self.check_ui
            
                nf = max(1,self.n_frames);
                
                self.handles.slider.Min = 1;
                self.handles.slider.Max = nf;
                self.handles.slider.Value = 1;
                self.handles.slider.SliderStep = (nf > 1) * [ 1, min(10,ceil(nf/3)) ]/nf;
                
                self.handles.text.String = '1';
                
            end
            
        end
        
        function cb_slider(self,hobj,varargin)
            self.select_frame( hobj.Value );
        end
        
        function cb_text(self,hobj,varargin)
            num = dk.math.clamp( round(str2num( hobj.String )), [1,self.n_frames] );
            self.select_frame(num);
        end
        
        function cb_button(self,varargin)
            if self.playing
                self.cb_stop(); 
            else
                self.cb_start();
            end
        end
        
        function cb_stop(self,varargin)
            
            if self.check_ui
                self.playing = false;
                self.handles.button.String = 'Play';
            end
            
        end
        
        function cb_start(self,varargin)
            
            fr = self.framerate;
            assert( isnumeric(fr) && isscalar(fr) && fr > eps, 'Framerate should be a positive scalar.' );
            if self.check_ui
                
                self.handles.button.String = 'Stop';
                self.playing = true;
                
                n = self.current_frame()-1;
                while self.n_frames > 0 && self.playing

                    n = mod(n+1,self.n_frames);
                    self.select_frame( n+1, true );
                    drawnow; pause( 1/fr );

                end
                
            end
            
        end
        
    end
    
end
