function [tdoaBands, points, errors] = tap_calibration(surface, events, bands, velocities, expected)

    tdoaCalc = FirstPeakTdoaCalculator();
    nBands = length(bands);
    nVelocities = length(velocities);
    errors = cell(nBands, nVelocities);
    tdoaBands = cell(nBands, 1);
    points = cell(nBands, nVelocities);
    nEvents = length(events);
    
    % extract tdoas, these only depend on the band used
    for bIdx = 1:nBands
       band = bands(bIdx);
       bFilter = WaveletFilter();
       bFilter.noiseMaxScale=band;
       
       tdoas = zeros(nEvents, 4);
       
       parfor eIdx = 1:nEvents
           e = copy(events(eIdx));
           e.filter(bFilter);
           oneTdoa = e.getTdoa(tdoaCalc);
           tdoas(eIdx,:) = oneTdoa;
       end
       
       tdoaBands{bIdx} = tdoas; 
       
       % for each tdoa, try out different velocities
       parfor vIdx = 1:nVelocities
            velocity = velocities(vIdx);
            localizer = Localizer(surface, [1,1,1,1].*velocity);
            p = localizer.resolve(tdoas);

            points{bIdx, vIdx} = p;
            
            % get the error from ground truth for each point
            e = ones(size(p,1),1) * NaN;
            for pIdx = 1:size(p,1)
                point = p(pIdx,:);
                gt = expected(pIdx,:);
                e(pIdx) = norm(point-gt);
            end
            
            errors{bIdx, vIdx} = e;
       end
       
    end

end

