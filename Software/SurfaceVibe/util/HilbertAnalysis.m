function [ raw, filtered, tdoas, swipe ] = HilbertAnalysis( surface, band, velocity, event )

    e = event.copy();
    
    % cut data
    e.data = e.data(10500:end-2500,:);
    
    % get sampling frequency
    raw = e.data;    
    
    Fs = 1/(raw(2,1) - raw(1,1));

    bFilter = GainVaryingFilter(Fs);
    bFilter.addBand(band-1, band+1, 3);
    
    hilbertTdoa = HilbertTdoaCalculator(band);

    e.filter(bFilter);
    
	e.data = e.data(10000:end-2500,:);
    
    tdoas = e.getTdoa(hilbertTdoa);
    
    % remove mean from tdoas
    for tIdx = 1:size(tdoas,2)
       tdoas(:,tIdx) = tdoas(:,tIdx) - mean(tdoas(:,tIdx)); 
    end
    
    filtered = e.data;
    
    localizer = PairLocalizer(surface, [1,1,1,1,1,1].*velocity);
    
    dTdoa = downsample(tdoas,500);
    swipe = localizer.resolve(dTdoa);

end

