%% EFFECT refers to the swipe is not at the center of the board


clear all
close all
clc

init();

filename{1} = 'wood40-8grid-effect4-un-swipe.mat';
filename{2} = 'wood40-8grid-effect4-swipe.mat';
selectedScale{1} = 10;
selectedVelocity{1} = 20000;
selectedScale{2} = 10;
selectedVelocity{2} = 20000;

for lIdx = 1:9
    lines{lIdx} = [10*(lIdx-1) 50; 10*(lIdx-1) 30];
end

for fileIdx = 1:2
    fileIdx
    load(filename{fileIdx});
    scaleFrq = scal2frq(1:1024,'mexh',1/25000);
    selectedFrq = scaleFrq(selectedScale{fileIdx});
    bFilter = GainVaryingFilter(Fs);
    bFilter.addBand(selectedFrq-1,selectedFrq+1,2,1);
    bFilter.addBand(2*selectedFrq-1,2*selectedFrq+1,3,0.75);
    
    wFilter = WaveletFilter();
    wFilter.noiseMaxScale=selectedScale{fileIdx};
    
    s = Surface([80 80]);
    s.addSensor(0,0);
    s.addSensor(1,0);
    s.addSensor(0,1);
    s.addSensor(1,1);
    localizer = PairLocalizer(s, [1,1,1,1,1,1].*selectedVelocity{fileIdx});

    % Base frequency
    P = 1/selectedFrq;
    Ps = floor(P*Fs);
    wSize = 500;
    dirIdxSet = 1:9;
    for dirIdx = dirIdxSet
        dirIdx
        line = lines{dirIdx};
        ep1 = line(1,:);
        ep2 = line(2,:);
        for eIdx = 1:length(events{dirIdx})
            h = figure;
            subplot(4,4,[2 3 4]);
            e = events{dirIdx}(eIdx);
            
            [ initLoc, initIdx, e ] = initPartExtract( e, Fs, wFilter, localizer );
            
            e.plot(0,h);
            axis tight;
            
%             e.filter(bFilter);
            sig = e.getSignals();
            g=figure; e.plot(0,g);

            time = e.getTime();
            timeIdxs = [];

            startIdxs = 1:(wSize):(length(sig)-1);
            startIdxs = startIdxs(1:end-2);
                
            % number of detected windows
            n = length(startIdxs);

            tdoas = zeros(n,3);
            conf = zeros(n,3);
            energy = zeros(n,4);
            energyProfile = zeros(n,1);
            
            % use sensor1 signal as reference
            sRef =sig(:,1);
            % get the energy profile of the entire window array 
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

            % get the tdoa of the window array and filter by xcorr and energy 
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
                    sNorm = SignalNormalization(sWindow);
                    % this is only used for filtered signals
                    [ lagDiff, lagVal, candidateDiff, candidateVal  ] = TDoAMinShift( refS, sNorm );
                    tdoas(idx,sIdx-1) = lagDiff/Fs;
                    conf(idx,sIdx-1) = lagVal;
                    tdoaCandidates{idx,sIdx-1} = [candidateDiff; candidateVal'];
                end
                %% fitler the signal segments
                if sum(energy(idx,:)) < prctile(energyProfile, 0.1) || min(conf(idx,:)) < 0
                    tdoas(idx,:) = [NaN NaN NaN];
                else
                    timeIdxs = [timeIdxs wStartIdx];
                end
%                 timeIdxs = [timeIdxs wStartIdx];
            end

            % moving average filter
            t = downsample(tdoas,2);
            figure(h);
            timePoints = time(timeIdxs) - time(1);
            subplot(4,4,1);
            e.plot(0,h);
            subplot(4,4,[2 3 4]);
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
            stdoas(:,2) = t(:,1);
            stdoas(:,3) = t(:,2);
            stdoas(:,4) = t(:,3);
            points = localizer.resolve(stdoas);

            % plot the points
            renderer = SurfaceRenderer(s);
            pIdxs = 1:16;
            pIdxs([1 2 3 4 5 9 13]) = [];
            subplot(4,4,pIdxs);
            renderer.plot(gcf);
            renderer.addPoints(initLoc);
            title(['scenario: ' num2str(dirIdx) ', #points:' num2str(length(points))]);
            validPoints = points(~isnan(points(:,1)),:);
            validConf = conf(~isnan(points(:,1)),:);
            validConf = validConf(validPoints(:,1)< 80 & validPoints(:,1)> 0,:);
            validPoints = validPoints(validPoints(:,1)< 80 & validPoints(:,1)> 0,:);
            validConf = validConf(validPoints(:,2)< 80 & validPoints(:,2)> 0,:);
            validPoints = validPoints(validPoints(:,2)< 80 & validPoints(:,2)> 0,:);
            % build the gaussian mixture model to remove outliers
            bTh = 3;
            if size(validPoints,1) > bTh 
                obj = gmdistribution.fit(validPoints,1);
                pointDist = mahal(obj,validPoints);
                % 5 is selected based on the grid size
                
%                 if dirIdx > 1 && dirIdx < 9
%                      
%                     pdTh = 10;
%                     validPoints = validPoints(pointDist < pdTh,:);
%                     validConf = validConf(pointDist < pdTh,:);
%                     validPoints = distanceFilter( validPoints, validConf );
%                 else
%                     mV = min(validConf,[],2);
%                     validPoints = validPoints(mV > 0.15,:);
%                     validConf = validConf(mV > 0.15,:);
%                    
%                 end

                pdTh = 3;
                validPoints = validPoints(pointDist < pdTh,:);
                validConf = validConf(pointDist < pdTh,:);
                distanceJumpTh = 5;
                validPointTemp = distanceFilter( validPoints, validConf, distanceJumpTh);
                if size(validPointTemp,1) < bTh
                    validPoints = distanceFilter( validPoints, validConf, distanceJumpTh*2);
                else
                    validPoints = validPointTemp;
                end
                if size(validPoints,1) > bTh
                    evaluation{fileIdx, dirIdx, eIdx} = evaluateSwipeWInit(validPoints, initLoc, [ep1; ep2], s, bTh);
                end
            end
            % add the high confidence point part
            renderer.addPoints(validPoints,true);
        end
        close all;
    end
end
save('compare_effect_4_2.mat','evaluation')