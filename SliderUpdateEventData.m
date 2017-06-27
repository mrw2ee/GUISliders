classdef (ConstructOnLoad) SliderUpdateEventData < event.EventData
    % SLIDERUPDATEEVENTDATA - Custom event data for GuiSlider SliderUpdate
    %
    % Michael R. Walker II 6/21/2017
   properties
      Values;
      Index;
   end
   
   methods
      function data = SliderUpdateEventData(Values,Index)
         data.Values = Values;
         data.Index = Index;
      end
   end
end