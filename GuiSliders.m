classdef GuiSliders < uipanelwrapper
    % GUISLIDERS - uipanel of sliders with user-configurable bounds
    %  
    % Syntax
    %
    % h = GuiSliders(x0)
    % h = GuiSliders(...,Name,Value) 
    %
    %
    % Description 
    %
    % This class provides a user interface similar to that of an audio
    % mixer. The number of sliders is configurable. All changes to the
    % slider values are funneled up through a single event: SliderUpdate.
    % This event data will include both an array of all current slider
    % 'Values,' and also the 'Index' of the last-effected slider.
    %
    %
    % Examples
    %
    %   hg = GuiSliders(x0);
    %   addlistener(hg,'SliderUpdate',@updateHandler);
    %
    %
    % Input Arguments
    %
    % x0 - Array of initial slider values
    %
    %
    % Name-Value Pair Arguments
    %
    % 'bounds' - Nx2 Matrix of bounds for slider values
    % 
    % 'labels' - Cell array of slider labels. DEFAULT = {'x1','x2', ... }
    %
    % 'Parent' - Optionally set parent container. DEFAULT = gcf.
    %
    %
    % Tips
    %
    % In some ways this class acts like a 'uipanel'. Properties 'Position'
    % and 'Parent' are defined. The complete slider strip can be moved to a
    % new figure window by updating the 'Parent' property. See
    % uipanelwrapper.
    %
    %
    % See also SliderUpdateEventData, SliderStrip
    %
    % Michael R. Walker II 6/21/2017
    
    events
        % Notified when any slider changes
        SliderUpdate;
    end
    properties        
        % Array of SliderStrips
        ss = SliderStrip.empty(1,0);
        % Label val, max, and min
        lbls = matlab.ui.control.UIControl.empty(3,0);
    end  
    methods
        function obj = GuiSliders(varargin)
            p = inputParser;
            addRequired(p,'x0',@isnumeric);
            addParameter(p,'bounds',[],@isnumeric);
            addParameter(p,'labels',{},@iscell);
            addParameter(p,'Parent',gcf,@ishandle);
            parse(p,varargin{:});
            
            % Check inputs
            x0 = reshape(p.Results.x0,[],1);
            N = numel(x0);
            
            bounds = p.Results.bounds;
            if isempty(bounds)
                d = max([abs(x0);1]);
                bounds = [x0 - d,x0+d];
            elseif ~isequal(size(bounds),[N,2])
                error('Bounds must be an Nx2 matrix, where N == numel(x0)');
            end
            
            labels = p.Results.labels;
            if isempty(labels)
                % Default labels
                labels = arrayfun(@(x)sprintf('x%d',x),1:N,...
                    'UniformOutput',false);
            elseif numel(labels) ~= N
                error('Number of labels does not match x0');
            end
            
            % Create panel
            obj.hpanel = uipanel('Units','pixels','Visible','off','Parent',p.Results.Parent);            
            
            % Make room for a textbox labels
            tbSize = [30,20]; % w h
            spacer = 5;
            idx = 1;
            obj.ss(idx) = SliderStrip; % New instance
            obj.ss(idx).Position(1) = spacer + tbSize(1);
            set(obj.ss(idx),'Parent',obj.hpanel,'Tag',sprintf('Slider%d',idx));
            for idx = 2:N
                obj.ss(idx) = SliderStrip; % New instance
                obj.ss(idx).Position(1) = sum([obj.ss(idx-1).Position([1,3]),-2]);
                set(obj.ss(idx),'Parent',obj.hpanel,'Tag',sprintf('Slider%d',idx));
            end
            
            % Update Panel Size
            obj.hpanel.Position(3) = sum([obj.ss(end).Position([1,3]),spacer]);
            obj.hpanel.Position(4) = sum([obj.ss(end).Position([2,4]),spacer]);
            
            % Make 'val' label
            tmp = obj.ss(1).hval.Position([2,4]);
            pos = [0 0, tbSize];
            pos(1) = floor(0.5*spacer);
            pos(2) = floor((tmp(2) - tbSize(2))*0.5) + tmp(1) + obj.ss(1).Position(2);
            obj.lbls(1) = uicontrol('Style','text','String','val','Position',pos,'Parent',obj.hpanel);
            
            % Make 'max' label
            tmp = obj.ss(1).hmax.Position([2,4]);
            pos = [0 0, tbSize];
            pos(1) = floor(0.5*spacer);
            pos(2) = floor((tmp(2) - tbSize(2))*0.5) + tmp(1) + obj.ss(1).Position(2);
            obj.lbls(2) = uicontrol('Style','text','String','max','Position',pos,'Parent',obj.hpanel);
            
            % Make 'min' label
            tmp = obj.ss(1).hmin.Position([2,4]);
            pos = [0 0, tbSize];
            pos(1) = floor(0.5*spacer);
            pos(2) = floor((tmp(2) - tbSize(2))*0.5) + tmp(1) + obj.ss(1).Position(2);
            obj.lbls(3) = uicontrol('Style','text','String','min','Position',pos,'Parent',obj.hpanel);
            
            % Single-slider assignments
            for idx = 1:N
                
                % Bounds - then x0
                obj.ss(idx).bounds = bounds(idx,:);
                obj.ss(idx).val = x0(idx);
                
                % Label
                obj.ss(idx).hlbl.String = labels{idx};
                
                % Create listener for each slider - Notify for THIS event
                addlistener(obj.ss(idx).hslider,'Value','PostSet',...
                    @(~,~)notify(obj,'SliderUpdate',...
                    SliderUpdateEventData([obj.ss.val],idx)));
            end
            
            % All done.
            obj.hpanel.Visible = 'on';
        end
        
    end
    
end

