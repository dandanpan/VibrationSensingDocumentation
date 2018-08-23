classdef SurfaceRenderer < handle
    %SURFACERENDERER a class to generate a plot for a surface
    
    properties
        surface
        fig
        points
    end
    
    methods
        
        function obj = SurfaceRenderer(surface)
           if nargin < 1
              error('Must provide a surface to render'); 
           end
           
           obj.surface = surface;
           obj.points = [];
        end
        
        function plot(obj, fig)
            
            if nargin < 2
                % create a new figure
                obj.fig = figure();   % save the handle to the figure
            else
                obj.fig = figure(fig); % use the given figure
            end
            
            % set the plot axes
            dimen = obj.surface.dimensions;
            
            margins = dimen .* 0.5;
            
            axis([-margins(1) dimen(1)+margins(1) -margins(2) dimen(2)+margins(2)]);
            set(gca, 'Ydir', 'reverse');
            
            xlabel('X');
            ylabel('Y');
            grid on;
            hold on;
            sensorPlacements = obj.surface.getSensorPlacements();
            scatter(sensorPlacements(:,1),sensorPlacements(:,2),'k');
            hold off;
            % plot existing points
            if ~isempty(obj.points)
                hold on;
                scatter(obj.points(:,1), obj.points(:,2));
                hold off;
            end
        end
        
        function addPoints(obj, p, animate)
            if nargin < 3
               animate = false;
            end
            obj.points = [obj.points; p];
            if isobject(obj.fig)
               if size(p,1) > 1
                   c = linspace(1,10,length(p));
               else
                   c = 'r';
               end
               % plot the new point
               figure(obj.fig);
               hold on;
               
               if animate
                   for idx = 1:size(p,1)
                       scatter(p(idx,1),p(idx,2),[],c(idx));
                       drawnow;
                   end
               else
                   scatter(p(:,1),p(:,2),[],c);
               end
               axis equal;
               hold off;
            end
        end
        
        function plotPoints(obj, p)
            obj.points = [obj.points; p];
            if isobject(obj.fig)
               % plot the new point
               figure(obj.fig);
               hold on;
               scatter(p(:,1),p(:,2));
               axis equal;
               hold off;
            end
        end
        
    end
    
end

