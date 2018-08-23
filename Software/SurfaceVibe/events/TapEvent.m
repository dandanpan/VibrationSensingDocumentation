classdef TapEvent < Event
    %TAPEVENT 
    
    methods
        
        function obj = TapEvent(filename, date, data)
           obj@Event(filename, date, data);
        end
        
        function [tdoas, tdoas2] = getTdoa(obj, calc)
            [tdoas, tdoas2] = calc.calculate(obj.getTime(), obj.getSignals());
        end
        
    end
    
end

