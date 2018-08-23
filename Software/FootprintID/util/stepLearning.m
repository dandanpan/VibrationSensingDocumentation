function [ testLabel ] = stepLearning( selectedFeature, selectedLabel, testFeature, clusterSimilarity )
%STEPLEARNING Summary of this function goes here
%   Detailed explanation goes here
    %% SVM
%     svmstruct = svmtrain(selectedLabel, selectedFeature, '-s 0 -t 2 -b 1');
%     [testLabel, ~, conf] = svmpredict(testLabelGT, testFeature, svmstruct,'-b 1');
    %% KNN
    mdl = fitcknn(selectedFeature,selectedLabel,'NumNeighbors',3);
    testLabel = predict(mdl,testFeature);       
end

