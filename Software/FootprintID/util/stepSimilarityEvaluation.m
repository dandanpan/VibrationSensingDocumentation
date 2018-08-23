function [ avgSimilarity ] = stepSimilarityEvaluation( allStepFeature, stepIdxInfo )
%STEPSIMILARITYEVALUATION Summary of this function goes here
%   Detailed explanation goes here
    avgSimilarity = [];
    numPeople = max(stepIdxInfo(:,1));
    for personID = 1:numPeople
        pIdx = find(stepIdxInfo(:,1) == personID);
        numTrace = max(stepIdxInfo(pIdx,3));
        for traceID = 1:numTrace
            tIdx = find(stepIdxInfo(:,1) == personID & stepIdxInfo(:,3) == traceID);
            similarityInTracePair = [];
            numStep = length(tIdx);
            for stepID = 1:numStep
                for compareStepID = stepID+1:numStep
                    COEF = corrcoef(allStepFeature(tIdx(stepID),:), allStepFeature(tIdx(compareStepID),:));
                    similarity = COEF(2,1);
                    similarityInTracePair = [similarityInTracePair, similarity];
                end
            end
            avgSimilarity = [avgSimilarity; personID, traceID, mean(similarityInTracePair), std(similarityInTracePair)];
        end
    end

end

