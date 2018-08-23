classdef Surface < handle
    %SURFACE model of the surface being tested on
    
    properties
        dimensions   % a 2x1 matrix indicating the length and width
        sensors      % an array of sensor objects
    end
    
    methods
        
        function obj = Surface(dimensions, sensors)
            if nargin < 2
                sensors = [];
            end
            if nargin < 1
               error('Must provide surface dimensions!');
            end
            obj.dimensions = dimensions;
            obj.sensors = sensors;
        end
        
        function addSensor(obj, x, y, invert)
           if nargin < 4
              invert = false;
           end    
           
           if nargin < 3
              error('Must provide sensor location');
           end
           
           s = Sensor(x,y,invert);
           obj.sensors = [obj.sensors s];
        end
        
        function sensorPlacements = getSensorPlacements(obj)
            n = length(obj.sensors);
            x = obj.dimensions(1);
            y = obj.dimensions(2);
            sensorPlacements = zeros(n,2);
            for idx = 1:n
                s = obj.sensors(idx);
                sensorPlacements(idx,:) = [(s.x * x)  (s.y * y)];
            end
        end
        
    end
    
end

