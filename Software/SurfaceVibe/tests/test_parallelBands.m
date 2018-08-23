% init();

surface = Surface([40 40]);
surface.addSensor(0,0);
surface.addSensor(1,0);
surface.addSensor(0,1);
surface.addSensor(1,1);

velocity = 5;

% go through each direction in each event
for direction = 1%1:length(events)
   
    eventsPerDirection = events{direction};
    
    % go through each event
    for eventIdx = 1%1:length(eventsPerDirection)
        
        event = eventsPerDirection(eventIdx);
        
        % filter at different bands and plot the following:
        % 1) raw signal
        % 2) filtered signal
        % 3) tdoas
        % 4) swipe trace
        
        bands = 410:5:430; %[390]
        nBands = length(bands);
        rawData = cell(nBands);
        filteredData = cell(nBands);
        tdoaData = cell(nBands);
        swipeData = cell(nBands);
        
        parfor bIdx = 1:nBands
            band = bands(bIdx);
            [raw, filtered, tdoas, swipe] = HilbertAnalysis(surface, band, velocity, event);
            
            rawData{bIdx} = raw;
            filteredData{bIdx} = filtered;
            tdoaData{bIdx} = tdoas;
            swipeData{bIdx} = swipe;
        end
        
        figName = [num2str(direction, 'Direction %d ') num2str(eventIdx, 'Event %d')];
        h = figure('Name', figName);
        for bIdx = 1:nBands
            % raw swipe + band title
            raw = rawData{bIdx};
            subplot(4, nBands, bIdx + 0*nBands);
            plot(raw(:,1), raw(:,2:5));
            title(num2str(bands(bIdx), 'Band %d'));
            
            % filtered signal
            filtered = filteredData{bIdx};
            subplot(4, nBands, bIdx + 1*nBands);
            plot(filtered(:,1), filtered(:,2:5));
            
            % tdoas
            tdoas = tdoaData{bIdx};
            subplot(4, nBands, bIdx + 2*nBands);
            plot( tdoas);
            
            % swipe
            swipe = swipeData{bIdx};
            renderer = SurfaceRenderer(surface);
            subplot(4, nBands, bIdx + 3*nBands);
            renderer.plot(h);
            renderer.addPoints(swipe);
        end
        
    end
        
end