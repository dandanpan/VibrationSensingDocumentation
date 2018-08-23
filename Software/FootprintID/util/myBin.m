function [ bin ] = myBin( data, clusterNum )
%MYBIN Summary of this function goes here
%   Detailed explanation goes here
    bin = zeros(clusterNum+1,1);
    dataNum = length(data);
    
    for dataID = 1:dataNum
        bin(data(dataID)+1) = bin(data(dataID)+1) + 1;
    end
%     if min(data) == 0
%         for dataID = 1:dataNum
%             bin(data(dataID)+1) = bin(data(dataID)+1) + 1;
%         end
%     else
%         for dataID = 1:dataNum
%             bin(data(dataID)) = bin(data(dataID)) + 1;
%         end
%     end
end

