function [ accuracyPerCluster ] = modelEachCluster( trainingPattern, trainingLabel, testingPattern, testingLabel )

    optionksrsc.normalization=1;
    optionksrsc.normMethod='unitl2norm';
    optionksrsc.SCMethod='l1nnlsAS';
    optionksrsc.lambda=0;
    optionksrsc.predicter='knn';
    optionksrsc.kernel='rbf';
    optionksrsc.param=2^0;
    optionksrsc.search=false;
    optionksrsc.ifMissValueImpute=false;
    
    [testClassPredictedKSRSC,sparse,Y,otherOutput]=KSRSCClassifier(trainingPattern',trainingLabel,testingPattern',optionksrsc);
    [performanceKSRSC, conMat]=perform(testClassPredictedKSRSC,testingLabel,10);
    accuracyPerCluster(clusterID) = performanceKSRSC(end-1);

end

