function [ selectedBand ] = bandSelection( event, band, Fs )
%BANDSELECTION Summary of this function goes here
%   Detailed explanation goes here
    minPara = 10000;selectedBand = -1;
    for f = band-20:5:band+20
        rawSig = copy(event);
        hilbertTdoa = HilbertTdoaCalculator(f);
        bFilter = GainVaryingFilter(Fs);
        bFilter.addBand(f-1,f+1,3,1);
        rawSig.filter(bFilter);
        paraAllSensor = 0;
        for sIdx = 1:4
            envelopSig{sIdx} = findpeaks(rawSig.data(:,sIdx+1));
            [PCK,~,~,P] = findpeaks(-envelopSig{sIdx});
            threshold = -max(envelopSig{sIdx})/20;threshold2 = max(envelopSig{sIdx})/10;
            selectPeak = find(PCK>threshold); 
            selectPerm = find(P>threshold2);
            sel = intersect(selectPeak,selectPerm);
            if ~isempty(sel)
                paraOneSensor = sum(1./(-PCK(sel)).*P(sel))/length(sel);
            else
                paraOneSensor = 0;
            end
            paraAllSensor = paraAllSensor + paraOneSensor;
        end
        if paraAllSensor < minPara
            minPara = paraAllSensor;
            selectedBand = f;
        end
    end

end

