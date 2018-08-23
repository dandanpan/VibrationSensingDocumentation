function [ outputSig, outputIdx ] = timestampAlignment( signal, timestamps, timestampIdx )
%TIMESTAMPALIGNMENT Summary of this function goes here
%   Detailed explanation goes here
        count = 0;
        aveDelta = [];
        outputSig = [];
        outputIdx = [];
        
        for i = 1 : length(timestampIdx)-1
            count = count + 1;
            subSig{count} = [signal(timestampIdx(i)+1:timestampIdx(i+1)-1)];
            deltaTime = (timestamps(i+1)-timestamps(i))/length(subSig{count}+1);
            subIdx{count} = zeros(length(subSig{count}),1);
            subIdx{count}(1) = timestamps(i);
            for j = 2 : length(subSig{count})
                subIdx{count}(j) = subIdx{count}(j-1)+deltaTime;
            end
        end
        
        for i = 1 : length(subSig);
            outputSig = [outputSig; subSig{i}];
            outputIdx = [outputIdx; subIdx{i}];
        end
        
end

