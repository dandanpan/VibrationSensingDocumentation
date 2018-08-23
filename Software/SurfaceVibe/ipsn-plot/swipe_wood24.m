close all

init();

load('./dataset/wood24-swipe.mat');
selectedScale = 5;
velocity = 22000;
% wood 5/22000
% tile 20/16000
% iron 24/10000
% cement 14/17000
% stone

wFilter = WaveletFilter();
wFilter.noiseMaxScale=selectedScale;
freqList = scal2frq([1:1024],'mexh',1/25000);

selectedFrq = round(freqList(selectedScale));%625;
bFilter = GainVaryingFilter(Fs);
% bFilter.addBand(75,90,2,1);
bFilter.addBand(selectedFrq-1,selectedFrq+1,2,1);
bFilter.addBand(2*selectedFrq-1,2*selectedFrq+1,3,0.75);


surf = Surface([40 40]);
surf.addSensor(0,0);
surf.addSensor(1,0);
surf.addSensor(0,1);
surf.addSensor(1,1);
localizer = PairLocalizer(surf, [1,1,1,1,1,1].*velocity);

% Base frequency
f = selectedFrq;
P = 1/f;
Ps = floor(P*Fs);
wSize = 500;%5*Ps;
for dirIdx = 1:8
    for eIdx = 1%:length(events{dirIdx})
        
        e = events{dirIdx}(eIdx);
        % separate the signal initial part and the rest
        [ initLoc, initIdx, e ] = initPartExtract( e, Fs, wFilter, localizer );
        
        h = figure;
        subplot(4,4,[2 3 4]);
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
        
        % get the tdoa of each window
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
                [ lagDiff, lagVal, candidateDiff, candidateVal ] = TDoAMinShift( refS, s);
                tdoas(idx,sIdx-1) = lagDiff;
                conf(idx,sIdx-1) = lagVal;
                tdoaCandidates{idx,sIdx-1} = [candidateDiff; candidateVal'];
            end

            if sum(energy(idx,:)) < prctile(energyProfile,0.3) || min(conf(idx,:)) < 0.3
                tdoas(idx,:) = [NaN NaN NaN];
            else
                timeIdxs = [timeIdxs wStartIdx];
            end

        end
        
        %% based on the NaN, cut tdoas into different clusters
        testingArray = isnan(tdoas(:,1));
        clusterIdx = 1;
        clusterID{clusterIdx} = [];
        isdata = 1;
        for aIdx = 1:length(testingArray)
            if testingArray(aIdx) == 1
                isdata = 0;
            elseif testingArray(aIdx) == 0
                if isdata == 0
                    isdata = 1;
                    clusterIdx = clusterIdx + 1;
                    clusterID{clusterIdx} = [];
                end
                clusterID{clusterIdx} = [clusterID{clusterIdx}, aIdx];
            end
        end
        clusterIdx
        %% for each chunk optimal then replace the tdoa value in the tdoas
        vectors={};
        for clusterIdx = 1:length(clusterID)
            if isempty(clusterID{clusterIdx})
                continue;
            end
            tempCandi = tdoaCandidates(clusterID{clusterIdx},:);
            % pairing through different combination
            for sIdx = 1:3 % sensor 2-4
                candiE = [];
                for candIdx = 1:3 % +- 1 peak tdoa options
                    candi{sIdx,candIdx} = [];
                    for idx = 1:size(tempCandi,1)
                        if idx == 1
                            candi{sIdx,candIdx} = [candi{sIdx,candIdx}, tempCandi{idx,sIdx}(1,candIdx)];
                        else
                            % consider history 
                            distPossible = abs(tempCandi{idx,sIdx}(1,:) - candi{sIdx,candIdx}(end));
                            [~,closestChoice] = min(distPossible);
                            candi{sIdx,candIdx} = [candi{sIdx,candIdx}, tempCandi{idx,sIdx}(1,closestChoice)];
                        end
                    end
    %                 figure;plot(candi{sIdx,candIdx});
    %                 title(['sensor:' num2str(sIdx),', choice:' num2str(candIdx)]);
                    candiE = [candiE, sum(abs(candi{sIdx,candIdx}))];
                end
                [~, choice] = min(candiE);
                tdoas(clusterID{clusterIdx},sIdx) = candi{sIdx,choice}';
                % choose the minimum energy one
            end
            chunkTdoas = tdoas(clusterID{clusterIdx},:);
            chunkTdoas = chunkTdoas./Fs;
            chunkTdoas = [zeros(size(chunkTdoas,1),1), chunkTdoas];
            chunkPoints = localizer.resolve(chunkTdoas);
            % filter the points
            chunkPoints = chunkPoints(chunkPoints(:,1) > 0,:);
            chunkPoints = chunkPoints(chunkPoints(:,1) < 40,:);
            chunkPoints = chunkPoints(chunkPoints(:,2) > 0,:);
            chunkPoints = chunkPoints(chunkPoints(:,2) < 40,:);
            % get direction of the points
            if size(chunkPoints,1) >= 5
                brob = robustfit(chunkPoints(:,1),chunkPoints(:,2));
            end
            % vectorization
            x = chunkPoints(:,1);
            x = [x(1) x(end)];
            y = x*brob(2) + brob(1);
            vectors{length(vectors)+1} = [x' y'];
        end
        
        %% plot the vectors
        figure;
        lastPoint = initLoc;
        for vIdx = 1:length(vectors)
           vector = vectors{vIdx};
           hold on;
           nextPoint = lastPoint + diff(vector);
           plot([lastPoint(1) nextPoint(1)], [lastPoint(2) nextPoint(2)]);
           lastPoint = nextPoint;
        end
        title(['Vector ' num2str(dirIdx) '-' num2str(eIdx)]);
        axis([0 40 0 40]);
        axis equal;
        %%
        tdoas = tdoas./Fs;
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
        
        stdoas = zeros(size(t,1), 4);
        span=10;
    %     stdoas(:,2) = smooth(t(:,1),0.2,'rloess');
    %     stdoas(:,3) = smooth(t(:,2),0.2,'rloess');
    %     stdoas(:,4) = smooth(t(:,3),0.2,'rloess');
        stdoas(:,2) = t(:,1);
        stdoas(:,3) = t(:,2);
        stdoas(:,4) = t(:,3);
        points = localizer.resolve(stdoas);

        renderer = SurfaceRenderer(surf);
        pIdxs = 1:16;
        pIdxs([1 2 3 4 5 9 13]) = [];
        subplot(4,4,pIdxs);
        renderer.plot(gcf);
        renderer.addPoints(initLoc);
        renderer.addPoints(points,false);
        title(['direction: ' num2str(dirIdx)]);
        numPoints = length(points);
    end
end
