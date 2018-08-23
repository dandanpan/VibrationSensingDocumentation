init();

for i = 1:8

    d = DataLoader(['table40pen-sp120-len10dir' num2str(i) '00000.txt'], 'data/20160818/swipes-length10');
    d.plot();

    % Build a noise model
    windowSize = 5000;
    data = d.getData();
    nModel = NoiseModel(data(1:100000,:), windowSize);

    threshold = 10;
    minLength = 5 * windowSize;
    detector = SwipeDetector(nModel, threshold, minLength);
    events = detector.sweep(data);

    % plot all detected events
    length(events)
    for idx = 1:length(events)
       e = events(idx);
       e.plot(1, gcf, true);
    end

end