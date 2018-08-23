close all

init();

load('stone24-swipe.mat');
selectedFrq = 284;%223;
bFilter = GainVaryingFilter(Fs);
% bFilter.addBand(75,90,2,1);
bFilter.addBand(selectedFrq-1,selectedFrq+1,2,1);
bFilter.addBand(2*selectedFrq-1,2*selectedFrq+1,3,0.5);%.75

% Base frequency
f = selectedFrq;
P = 1/f;
Ps = floor(P*Fs);
wSize = 600;%5*Ps;
for dirIdx = 1:8
    for eIdx = 1:length(events{dirIdx})
        h = figure;
        subplot(4,4,[2 3 4]);
        e = events{dirIdx}(eIdx);
        e.plot(0,h);
        axis tight;
    %     data = e.getSignals();
    %     figure(); spectrogram(data(:,1));
        e.filter(bFilter);
        sig = e.getSignals();

        g=figure; e.plot(0,g);

        time = e.getTime();
        timeIdxs = [];

        startIdxs = 1:(wSize):(length(sig)-1);
        startIdxs = startIdxs(1:end-2);

        n = length(startIdxs);

         tdoas = zeros(n,3);
         conf = zeros(n,3);
         energy = zeros(n,4);
         energyProfile = zeros(n,1);
         % signal ref
        sRef =sig(:,1);
        % get the energy information
        for idx = 1:n
            wStartIdx = startIdxs(idx);
            windowE = zeros(1,4);
            for sIdx = 1:size(sig,2)
                sWindow = sig(wStartIdx:wStartIdx + wSize,sIdx);
                sE = sqrt(sum(sWindow.*sWindow));
                windowE(sIdx) = sE;
            end
            energyProfile(idx) = sum(windowE);
        end
        
        % get the 
        for idx = 1:n
            wStartIdx = startIdxs(idx);
            refWindow = sRef(wStartIdx:wStartIdx + wSize);
            refE = sum(refWindow.*refWindow);
            refS = SignalNormalization(refWindow);
            energy(idx,1) = refE;
            for sIdx = 2:size(sig,2)
                sWindow = sig(wStartIdx:wStartIdx + wSize,sIdx);
                sE = sum(sWindow.*sWindow);
                energy(idx,sIdx) = sE;
                s = SignalNormalization(sWindow);
                [ lagDiff, lagVal ] = TDoAMinShift( refS, s);
                tdoas(idx,sIdx-1) = lagDiff/Fs;
                conf(idx,sIdx-1) = lagVal;
            end

            if sum(energy(idx,:)) < prctile(energyProfile,0.2) || min(conf(idx,:)) < 0.3
                tdoas(idx,:) = [NaN NaN NaN];
            else
                timeIdxs = [timeIdxs wStartIdx];
            end

        end

        % moving average filter
        t = downsample(tdoas,2);
        figure(h);
        timePoints = time(timeIdxs) - time(1);
        subplot(4,4,1);
        e.plot(0,h);
        subplot(4,4,[2 3 4]);
    %     figure(g);
        hold on;
        scatter(timePoints , zeros(size(timePoints)), [], linspace(1,10,length(timePoints)));
        axis tight;
        figure(h);
        subplot(4,4,5);
        plot([0 length(t)], [0 0]);
        axis tight;
        hold on;
        plot(t);
        axis tight;
        subplot(4,4,9);
        plot(conf);
        axis tight;
        subplot(4,4,13);
        plot(energy);
        axis tight;

        s = Surface([40 40]);
        s.addSensor(0,0);
        s.addSensor(1,0);
        s.addSensor(0,1);
        s.addSensor(1,1);
        velocity = 16000;
        localizer = Localizer(s, [1,1,1,1].*velocity);

        stdoas = zeros(size(t,1), 4);
        span=10;
    %     stdoas(:,2) = smooth(t(:,1),0.2,'rloess');
    %     stdoas(:,3) = smooth(t(:,2),0.2,'rloess');
    %     stdoas(:,4) = smooth(t(:,3),0.2,'rloess');
        stdoas(:,2) = t(:,1);
        stdoas(:,3) = t(:,2);
        stdoas(:,4) = t(:,3);
        points = localizer.resolve(stdoas);

        renderer = SurfaceRenderer(s);
        pIdxs = 1:16;
        pIdxs([1 2 3 4 5 9 13]) = [];
        subplot(4,4,pIdxs);
        renderer.plot(gcf);
        renderer.addPoints(points,false);
        title(['direction: ' num2str(dirIdx)]);
        numPoints = length(points)
    end
end
