function [ matrixResult ] = calConfusionMatrix( realLabel, estLabel, numCatergory )
%CALCONFUSIONMATRIX Summary of this function goes here
%   Detailed explanation goes here
        matrixResult = zeros(numCatergory);
        for i = 1 : length(realLabel)
            matrixResult(realLabel(i),estLabel(i)) = matrixResult(realLabel(i),estLabel(i)) + 1;
        end
end

