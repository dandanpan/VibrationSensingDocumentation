clear all
close all
clc

init();
load('./dataset/steps.mat');
load('./dataset/step_time_cluster_all_020.mat');
load('./dataset/direction_info.mat');
load('./dataset/area_step.mat');

totalTraceID = 1:10;
selectSpeed = 4;
totalResult = zeros(5);
totalResultT = zeros(5);
   
for foldID = 1:10

    trainingTraceID = [foldID:foldID+5];
    trainingTraceID(trainingTraceID>10) = trainingTraceID(trainingTraceID>10)-10;
    testingTraceID = totalTraceID;
    testingTraceID(ismember(totalTraceID, trainingTraceID)) = [];
 

    newPattern = [stepInfoAll(:,5), stepPattern];
    results = zeros(5);
    resultsT = zeros(5);
    for areaID = 1:5
        for compareAreaID = 1:5
            % use areaID data for training
            % and use compareAreaID data for testing
            trainingSet = [];
            trainingLabel = [];
            for personID = 1:10
                trainingAreaInfo = area{areaID,personID}(area{areaID,personID}(:,2) == selectSpeed,:);
                for traceID = 1:length(trainingTraceID)
                    tIdx = trainingAreaInfo(ismember(trainingAreaInfo(:,3),trainingTraceID),6);
                    tLabel = trainingAreaInfo(ismember(trainingAreaInfo(:,3),trainingTraceID),1);
                    trainingSet = [trainingSet; newPattern(tIdx,:)];
                    trainingLabel = [trainingLabel; tLabel];
                end
            end

            testingSet = [];
            testingLabel = [];
            for personID = 1:10
                testingAreaInfo = area{compareAreaID,personID}(area{compareAreaID,personID}(:,2) == selectSpeed,:);
                for traceID = 1:length(testingTraceID)
                    tIdx = testingAreaInfo(ismember(testingAreaInfo(:,3),testingTraceID),6);
                    tLabel = testingAreaInfo(ismember(testingAreaInfo(:,3),testingTraceID),1);
                    testingSet = [testingSet; newPattern(tIdx,:)];
                    testingLabel = [testingLabel; tLabel];
                end
            end

            svmstruct = svmtrain(trainingLabel, trainingSet, ['-s 0 -t 2 -b 1 -g 1 -c 100' ]);
            [tr, ~, decision_values] = svmpredict(testingLabel, testingSet, svmstruct,'-b 1');
            
            %% get trace level results
            [ stepLevelAcc, traceLevelAcc ] = accCal( tr, testingLabel, 3 );

            
            results(areaID, compareAreaID) = stepLevelAcc;
            resultsT(areaID, compareAreaID) = traceLevelAcc;
        end
    end
    totalResult = totalResult + results;
    totalResultT = totalResultT + resultsT;
end

%%
figure;
results = totalResultT./10;
imagesc(results);
colormap(gray);
axis equal;

textStrings = num2str(results(:),'%0.2f');  %# Create strings from the matrix values
textStrings = strtrim(cellstr(textStrings));  %# Remove any space padding
[x,y] = meshgrid(1:5);   %# Create x and y coordinates for the strings
hStrings = text(x(:),y(:),textStrings(:),...      %# Plot the strings
                'HorizontalAlignment','center');
midValue = mean(get(gca,'CLim'));  %# Get the middle value of the color range
textColors = repmat(results(:) < midValue,1,3);  %# Choose white or black for the
                                             %#   text color of the strings so
                                             %#   they can be easily seen over
                                             %#   the background color
set(hStrings,{'Color'},num2cell(textColors,2));  %# Change the text colors

set(gca,'XTick',1:5,...                         %# Change the axes tick marks
        'XTickLabel',{'1','2','3','4','5'},...  %#   and tick labels
        'YTick',1:5,...
        'YTickLabel',{'1','2','3','4','5'},...
        'TickLength',[0 0]);

%%
save('./dataset/area_compare.mat','totalResult','totalResultT');

%%

