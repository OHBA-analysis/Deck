classdef ImageBox < handle
%
% A vertical box with a selector (popup menu) on top of an image axes.
% The selector choices are the titles of the images. Selection can be set externally.
%

    properties (SetAccess = private)
        handles;
        images;
    end
    
    properties (Dependent)
        n_images;
    end
    
    methods
        
        function self = ImageBox(varargin)
            self.clear();
            if nargin > 0
                self.build(varargin{:});
            end
        end
        
        function clear(self)
            self.handles = struct();
            self.images  = [];
        end
                
        function n = get.n_images(self)
            n = numel(self.images);
        end
        
        function [val,name] = current_selection(self)
            
            val = NaN; name = '';
            
            if self.check_handle('popup')
                val  = self.handles.popup.Value;
                name = self.handles.popup.String{val};
            end
        end
        
        function set_images(self,data)
        %
        % Input data should be a struct-array with fields:
        %   img
        %       Required image (matrix or cell array).
        %   name
        %       Required name of the image as will appear in the popup menu.
        %   opt
        %       Required structure of options for dk.ui.image
        
            assert( isstruct(img), 'Input should be a struct-array.' );
            self.images = data;
            
            if self.check_handle('popup')
                
                self.handles.popup.String = arrayfun( @(x) x.name, self.images, 'UniformOutput', false );
                self.select_image(1);
                
            end
            
        end
        
        function set_heights(self,selector,sep)
            
            if nargin < 3, sep = 5; end
            if nargin < 2, selector = 30; end
            
            if self.check_handle('image')
                self.handles.box.Heights = [selector,sep,-1];
            end
            
        end
        
        function select_image(self,num)
            
            if self.check_handle('image')
                
                % get corresponding image
                hdl = self.handles.image;
                dat = self.images(num);
                
                % display this image
                set( ancestor(hdl,'figure'), 'currentaxes', hdl );
                dk.ui.image( dat.img, dat.opt );
                
                % update the selector
                self.handles.popup.Value = num;
                
            end
            
        end
        
        function build(self,parent,varargin)
        %
        % You can specify key-value options for the popup (see uicontrol, popup).
            
            % create a vertical box
            self.handles.box = uix.VBox( 'parent', parent, 'padding', 10 );
            
            % build the selector
            if self.n_images == 0
                tstr = {'---'};
            else
                tstr = arrayfun( @(x) x.name, self.images, 'UniformOutput', false );
            end
            
            self.handles.popup = uicontrol( ...
                'parent', self.handles.box, ...
                'style', 'popup', ...
                'string', tstr, ...
                'callback', @self.callback_select ...
            );
        
            % empty separator
            uix.Empty('parent',self.handles.box);
        
            % set popup options
            if nargin > 2
                opt  = struct(varargin{:});
                fopt = fieldnames(opt);
                for i = 1:numel(fopt)
                    f = fopt{i};
                    self.handles.popup.(f) = opt.(f);
                end
            end
        
            % create axes for image
            self.handles.image = axes( 'parent', uicontainer('parent',self.handles.box) );
            self.set_heights();
            
        end
        
    end
    
    methods (Hidden)
        
        function ok = check_handle(self,name)
            ok = isfield( self.handles, name ) && ishandle( self.handles.(name) );
        end
        
        function callback_select(self,hobj,edata)
            
            % retrieve selection from the box
            val = hobj.Value;
            
            % select that image
            self.select_image(val);
            
        end
        
    end
    
end
