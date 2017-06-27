classdef ExamplePlotter < handle
    % EXAMPLEPLOTTER - Example Plotting Class
    %
    % Plot updates can be slow if you are redrawing the entire figure.
    % Manipulating the lines of interest via handles is considerably
    % faster. Further, this can be done in the background without bringing
    % the figure window to the foreground. 
    %
    % This is a simple example plotting updates to pchip interpolation
    % where the user can modify the control points. We plot the lines,
    % control points, and identify which control point was modified last.
    %
    % h = ExamplePlotter(x)
    %   x - Initial values [x1,x2,...,xN-2,y0,y1,...,yN-1]
    %
    % Michael R. Walker II 6/21/2017
    
    properties
        hline;      % Handle to interpolated line
        hctrl;      % Handle to control points
        hlast;      % Handle to marker for last-modified control point
        N;          % Number of control points
    end
    
    methods
        function obj = ExamplePlotter(x0)
            if mod(numel(x0),2)~=0 || numel(x0)<6
                error('Length of second input should be even');
            end
            obj.N = numel(x0)/2 + 1;
            updatePlot(obj,x0,numel(x0))
        end
        function updatePlot(obj,x0,n)
            % UPDATEPLOT - Plot update interface
            %
            % obj.updatePlot(x0,n) - x0 as specified in construction, n
            % represents the last-modified control point.
            %
            
            % Ensure x are increasing monotonically
            [x,reorder] = sort([0 x0(1:obj.N-2) 1]);
            y = x0(obj.N-1:end);
            y = y(reorder);
            % Avoid repeated values
            idx = diff(x)==0;
            x(idx) = x(idx)-1e-9;
                        
            % Interpolate
            xint = linspace(x(1),x(end),1e2);
            yint = pchip(x,y,xint);
            
            if isempty(obj.hline)
                % First time plotting...
                obj.hline = plot(xint,yint);
                hold on
                obj.hctrl = plot(x,y,'o');
                obj.hlast = plot(x(end),y(end),'*');
            else
                % Update existing...
                set(obj.hline,'Xdata',xint,'Ydata',yint);
                set(obj.hctrl,'Xdata',x,'Ydata',y);
                if n < obj.N-1
                    m = n+1;
                else
                    m = n - 2;
                end
                % We may have reordered for monotonicity...
                m = reorder(m);
                set(obj.hlast,'Xdata',x(m),'Ydata',y(m));
            end
        end
        function handleSliderUpdate(obj,~,evnt)
            % HANDLESLIDERUPDATE - Respond to SliderUpdateEvent
            %
            % SliderUpdateEvents return a custom SliderUpdateEventData.
            % We need to unpackage this data and appropriately call our
            % updatePlot function.
            %
            % See also SliderUpdateEventData
            
            if ~isa(evnt,'SliderUpdateEventData')
                error('Expecting SliderUpdateEventData!');
            end
            updatePlot(obj,evnt.Values,evnt.Index);
        end
        
    end
    
end

