classdef Sensor < handle
    %SENSOR models the placement of a sensor on a surface
    properties
        x       % value between 0 and 1.0 denoting the relative x-location of the sensor
        y       % value between 0 and 1.0 denoting the relative y-location of the sensor
                % origin is defined at the top-left corner of a surface
        invert  % whether or not the sensor readings are inverted
    end
    
    methods
        
        function obj = Sensor(x,y,invert)
           if nargin < 3
              % this sensor should invert the signal data
              invert = false; 
           end
           if nargin < 2
               
           end
           obj.x = x;
           obj.y = y;
           obj.invert = invert;
        end
        
    end
    
end

