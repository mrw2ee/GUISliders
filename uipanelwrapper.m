classdef uipanelwrapper < matlab.mixin.SetGet
    % UIPANELWRAPPER - Custom wrapper for builtin uipanel
    %
    % Couldn't subclass matlab.ui.container.Panel, so defined a similar
    % standard interface. Some common get/set routines are implemented.
    %
    % See also uipanel
    %
    % Michael R. Walker II 6/21/2017
    
    
    properties
        hpanel = matlab.ui.container.Panel.empty(0,1);
    end
    properties (Dependent)
        % Panel Tag
        Tag;
        % Panel Position
        Position;
        % Panel Parent
        Parent;
    end
    methods
        function val = get.Parent(obj)
            val = obj.hpanel.Parent;
        end
        function set.Parent(obj,val)
            obj.hpanel.Parent = val;
        end
        function val = get.Position(obj)
            val = obj.hpanel.Position;
        end
        function set.Position(obj,val)
            obj.hpanel.Position = val;
        end
        function val = get.Tag(obj)
            val = obj.hpanel.Tag;
        end
        function set.Tag(obj,val)
            obj.hpanel.Tag = val;
        end
    end
end

