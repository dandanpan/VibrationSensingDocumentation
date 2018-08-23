function [ outputSignal ] = insertTimePlaceHolder( signal, insertIdx, insertLen, insertValue )
%INSERTTIMEPLACEHOLDER Summary of this function goes here
%   Detailed explanation goes here
    sigSize = size(signal);
    if sigSize(1) > sigSize(2)
        signal = signal';
    end
    
    insertNum = length(insertIdx);
    if insertNum == 0
        outputSignal = signal;
    end
    
    for i = 1 : insertNum-1
        subSig{i} = signal(insertIdx(i):insertIdx(i+1)-1);
    end
    subSig{insertNum} = signal(insertIdx(insertNum):end);
    
    outputSignal = signal(1:insertIdx(1));
    for i = 1 : insertNum
        outputSignal = [outputSignal, ones(1, uint32(insertLen(i)))*insertValue, subSig{i}];
    end
    
    if sigSize(1) > sigSize(2)
        outputSignal = outputSignal';
    end
end

