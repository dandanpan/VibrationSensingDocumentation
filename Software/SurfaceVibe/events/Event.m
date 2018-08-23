classdef Event < handle
    %EVENT data of a single event
    properties
        Filename
        Date
        data
    end
    
    methods
        
        function obj = Event(filename, date, data)
           if nargin < 3
              error('Must provide all event data') 
           end
           obj.Filename = filename;
           obj.Date = date;
           obj.data = data;
        end
        
        function aCopy = copy(obj)
           aCopy = Event(obj.Filename, obj.Date, obj.data);
        end

        function tdoas = getTdoa(obj, calc)
            tdoas = calc.calculate(obj.getTime(), obj.getSignals());
        end
        
        function filter(obj, filterObject)
            obj.data = filterObject.filter(obj.data);
        end
        
        function time = getTime(obj)
           time = obj.data(:,1); 
        end
        
        function signals = getSignals(obj)
           signals = obj.data(:,2:end); 
        end
        
        function energyWindows = getEnergyTrace(obj, windowSize, idxs)
            signals = obj.getSignals();
            if nargin < 3
               idxs = 1:(size(signals,2));
            end
            
            signals = signals(:,idxs);
           
            startIdxs = 1:(windowSize/2):(length(signals)-1);
            n = length(startIdxs)-1;
            energyWindows = zeros(n,1);
   
            for idx = 1:n
                wStartIdx = startIdxs(idx);
                window = signals(wStartIdx:wStartIdx + windowSize, :);
                windowEnergy = sum(sum(window.*window));
                energyWindows(idx) = windowEnergy;
            end
            
        end
        
        function plot(obj,col,fig,keepOffset)
            if nargin < 4
               keepOffset = false; 
            end
            if nargin < 3
               figure();
            else 
               figure(fig);
            end
            if nargin < 2
               col = 0; 
            end
            f = gcf;
            f.Name = [obj.Filename ' - ' obj.Date];
            
            time = obj.data(:,1);
            if ~keepOffset 
                time = time - min(time);
            end
            
            [~,n] = size(obj.data);
            
            for idx = 2:n
                if col > 0
                   subplot(n-1,col,idx-1);
                   title(['Channel ' num2str(idx-1)]);
                end
                hold on;
                plot(time, obj.data(:,idx));
                hold off;
            end 
        end
        
    end
    
end

