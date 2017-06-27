classdef SliderStrip < uipanelwrapper
    % SLIDERSTRIP - Class for ui slider strip
    %
    % Basic layout of slider strip includes a panel comprising:
    %
    %  1. textbox (not edit) label
    %  2. editable textbox for slider's Value
    %  3. editable textbox for slider's Max
    %  4. slider
    %  5. editable textbox for slider's Min
    %
    % Callbacks implementing slider-textbox relations are set
    % automatically.
    %
    % Michael R. Walker II 6/21/2017
    
    properties (Dependent)
        % Slider value - set this to update both slider & textbox
        val;
        % Slider bounds - set this to update both slider & textbox
        bounds;
    end
    properties
        % handle to label (not-edit) textbox
        hlbl;
        % handle to value textbox
        hval;
        % handle to max textbox
        hmax;
        % handle to slider
        hslider;
        % handle to min textbox
        hmin;
    end
   
    properties (Access = protected)
        % Edit textbox size
        editSize = [40,20]; % w h
        % Layout spacing
        spacer = 5;
        % Slider size
        sliderSize = [30,200];
    end
    methods
        function obj = SliderStrip(varargin)
            % SLIDERSTRIP - Place Strip in current figure
            
            % Allow layout size parameters to change on construction
            if nargin > 0
                set(obj,varargin{:});
            end
            layout(obj);
            updateTextboxes(obj);
        end
        function updateTextboxes(obj)
            obj.hval.String = num2str(obj.hslider.Value);
            obj.hmax.String = num2str(obj.hslider.Max);
            obj.hmin.String = num2str(obj.hslider.Min);
        end
        function layout(obj)
            % LAYOUT - Place uicontrols in panel and assign default
            % callbacks.
            
            % Create panel
            obj.hpanel = uipanel('Units','pixels');
            
            % Add 'min' edit box
            pos = [obj.spacer obj.spacer obj.editSize];
            obj.hmin = uicontrol(obj.hpanel,'Style','edit',...
                'Units','pixels','Position',pos,...
                'Callback',@obj.cb_min,'Parent',obj.hpanel);
            
            % Add vertical slider
            pos(2) = pos(2) + obj.spacer + pos(end);
            pos(1) = obj.spacer + floor((obj.editSize(1) - obj.sliderSize(1))*0.5);
            pos(3:4) = obj.sliderSize;
            obj.hslider = uicontrol(obj.hpanel,'Style','Slider',...
                'Units','pixels','Position',pos,'Parent',obj.hpanel);
            % This callback is a little different. The standard callback is
            % only executed after mouse button up. With this approach, it
            % will be called continuously while button down.
            addlistener(obj.hslider,'Value','PostSet',@obj.cb_slider);
            
            % Add 'max' edit box
            pos(1) = obj.spacer;
            pos(2) = pos(2) + obj.spacer + pos(end);
            pos(2) = pos(2) -1; % little correction
            pos(3:4) = obj.editSize;
            obj.hmax = uicontrol(obj.hpanel,'Style','edit',...
                'Units','pixels','Position',pos,...
                'Callback',@obj.cb_max,'Parent',obj.hpanel);
            
            % Add 'val' edit box
            pos(2) = pos(2) + obj.spacer + pos(end);
            obj.hval = uicontrol(obj.hpanel,'Style','edit',...
                'Units','pixels','Position',pos,...
                'Callback',@obj.cb_val,'Parent',obj.hpanel);
            
            % Add 'label' text
            pos(2) = pos(2) + pos(end);
            obj.hlbl = uicontrol(obj.hpanel,'Style','text',...
                'String','x','Units','pixels','Position',pos,'Parent',obj.hpanel);
            
            % Update size of panel
            pos(4) = pos(2) + obj.spacer + pos(end)+2;
            pos(3) = 2*obj.spacer + 3 + obj.editSize(1);
            pos(1:2) = obj.spacer;
            obj.hpanel.Position = pos;
        end
        
        %% CALLBACKS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function cb_val(obj,src,~)
            % CB_VAL - Callback for val textbox
            %
            % Update slider position if value is numeric and within bounds.
            %
            x = str2double(src.String);
            if x >= obj.hslider.Min && x <= obj.hslider.Max
                obj.hslider.Value = x;
            else
                src.String = num2str(obj.hslider.Value,'%.3g');
            end
        end
        function cb_max(obj,src,~)
            % CB_MAX - Callback for max textbox
            %
            % Update slider max if value is greater than slider min. Also,
            % if value is less than slider, update slider to new max.
            %
            x = str2double(src.String);
            if x < obj.hslider.Min
                src.String = num2str(obj.hslider.Max,'%.3g');
            else
                if x < obj.hslider.Value
                    obj.hslider.Value = x;
                end
                obj.hslider.Max = x;
            end
        end
        function cb_min(obj,src,~)
            % CB_MIN - Callback for min textbox
            %
            % Update slider min if value is less than slider max. Also, if
            % value is greater than slider, update slider to new min.
            %
            x = str2double(src.String);
            if x > obj.hslider.Max
                src.String = num2str(obj.hslider.Min,'%.3g');
            else
                if x > obj.hslider.Value
                    obj.hslider.Value = x;
                end
                obj.hslider.Min = x;
            end
        end
        function cb_slider(obj,~,~)
            % CB_SLIDER - Slider callback
            %
            % When slider value changes, update val textbox.
            %
            obj.hval.String = num2str(obj.hslider.Value,'%.3g');
        end
        %% ACCESS METHODS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function set.bounds(obj,b)
            validateattributes(b,{'numeric'},{'size',[1 2],'nondecreasing'});
            tmp = min(max(b(1),obj.hslider.Value),b(2));
            set(obj.hslider,'Min',b(1),'Value',tmp,'Max',b(2));
            updateTextboxes(obj);
        end
        function b = get.bounds(obj)
            b = [obj.hslider.Min, obj.hslider.Max];
        end
        function set.val(obj,val)
            validateattributes(val,{'numeric'},{'scalar'});
            obj.hslider.Value = val;
            obj.hval.String = num2str(obj.hslider.Value);
        end
        function val = get.val(obj)
            val = obj.hslider.Value;
        end
    end
end


