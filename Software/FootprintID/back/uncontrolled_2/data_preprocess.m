
load steps_cookie.mat
% traceIDLabel = mod(traceIDLabel,10)+1;
traceIDLabel = 11*ones(size(traceIDLabel));
num_sample = size(stepFreqMeasure,1);
stepInfoAll =  zeros(num_sample,6);
stepInfoAll(:,5) = stepFreqMeasure;
stepInfoAll_new = stepInfoAll;
traceIDLabel_new = traceIDLabel;
speedIDLabel_new = 8*ones(size(stepFreqMeasure));
stepPattern_new = stepPattern;
personIDLabel_new = personIDLabel;

load ./steps_10p_8s.mat
ind_replace = speedIDLabel==8;
stepInfoAll(ind_replace,:) = [];
traceIDLabel(ind_replace,:) = [];
speedIDLabel(ind_replace,:) = [];
stepPattern(ind_replace,:) = [];
personIDLabel(ind_replace,:) = [];

stepInfoAll = [stepInfoAll; stepInfoAll_new];
traceIDLabel = [traceIDLabel; traceIDLabel_new];
speedIDLabel = [speedIDLabel; speedIDLabel_new];
stepPattern = [stepPattern; stepPattern_new];
personIDLabel = [personIDLabel; personIDLabel_new];

save('uncontrol2.mat')
