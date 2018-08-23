function [ overallResults ] = crossValidationSVM( allStepFeature, stepIdxInfo, svmkernel )
%CROSSVALIDATIONSVM Summary of this function goes here
%   allStepFeature: each column is a feature
%   svmkernel: 0 -- linear; 1 -- poly; 2 -- rbf

        overallResults = [];
        for crossValid = 1 : 4
            configuration_setup;
            addpath('./libsvm-master/matlab/');
            
            trainingTraceID = [crossValid:crossValid+6];
            % find the traceID that fits profile
            trainingIdx = [];
            for i = 1:length(trainingTraceID)
                tempIdx = find(stepIdxInfo(:,3) == trainingTraceID(i));
                trainingIdx = [trainingIdx; tempIdx];
            end
            trainingData = allStepFeature(trainingIdx,:);
            trainingDataLabel = stepIdxInfo(trainingIdx,1);
            
            testingData = allStepFeature;
            testingDataLabel = stepIdxInfo(:,1);
            testingData(trainingIdx,:) = [];
            testingDataLabel(trainingIdx) = [];
            
            if svmkernel == 0
                svmstruct = svmtrain(trainingDataLabel, trainingData, ['-s 0 -t 0 -b 1 -g 10 -c 1000']);
            elseif svmkernel == 1
                svmstruct = svmtrain(trainingDataLabel, trainingData, ['-s 0 -t 1 -b 1 -g 10 -c 1000']);
            elseif svmkernel == 2
                svmstruct = svmtrain(trainingDataLabel, trainingData, ['-s 0 -t 2 -b 1 -g 10 -c 1000']);
            end
            [predicted_label, accuracy, decision_values] = svmpredict(testingDataLabel, testingData, svmstruct,'-b 1');
            overallResults = [overallResults, accuracy(1)];
        end
end

