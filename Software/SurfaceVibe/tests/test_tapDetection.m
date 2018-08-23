init();

for i = 0:15

    d = DataLoader(['table40tap1000'  num2str(i,'%02d') '.txt'], 'data/20160818/taps');
    d.plot();

    % Build a noise model
    windowSize = 500;
    data = d.getData();
    nModel = NoiseModel(data(1:80000,:), windowSize);

    threshold = 3;
    startMargin = 1000;
    endMargin = 1000;
    detector = TapDetector(nModel, threshold, startMargin, endMargin);
    [events, energyWindows] = detector.sweep(data);

    % plot all detected events
    length(events)
    for idx = 1:length(events)
       e = events(idx);
       e.plot(1, gcf, true);
       axis tight;
    end
    
    subplot(4,1,1);
    hold on;
    plot(energyWindows);
    axis tight;
    hold off;
    

end