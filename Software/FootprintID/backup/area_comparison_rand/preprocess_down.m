function [directionInfo, stepInfoAll, traceIDLabel, speedIDLabel, stepPattern, personIDLabel] = preprocess_down(directionInfo, stepInfoAll,traceIDLabel, speedIDLabel, stepPattern, personIDLabel, set_selected)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% tic
% reverse_list = [];
% num = size(directionInfo,1);
% set_selected = [];
% if isempty(set_selected)
%     set_selected = sort(randsample(7,3)');
% end
% 
% for i = 1:size(stepInfoAll,1)
%     
%     tmp = sum(abs(repmat(stepInfoAll(i,1:3),[num 1])-directionInfo(:,1:3)),2);
%     
%     reverse_list = [reverse_list; directionInfo(tmp==0,4)];
%     
% end
% 
% ind_retain = [];
% 
% for i = 1:size(stepInfoAll,1)/7
%     ind_start = (i-1)*7+1;
%     ind_end = i*7;
%     if sum(reverse_list(ind_start:ind_end)) == -7
%         tmp = ind_end+1-set_selected;
%         ind_retain = [ind_retain tmp(end:-1:1)];
%     elseif sum(reverse_list(ind_start:ind_end)) == 7
%         tmp = ind_start-1+set_selected;
%         ind_retain = [ind_retain tmp];
%     else
%         disp('error')
%     end
% end

% directionInfo =directionInfo(ind_retain,:);

ind_retain = [];

for i = 1:size(stepInfoAll,1)/7
    ind_start = (i-1)*7+1;
    ind_end = i*7;
    tmp =ind_start:ind_end;
    ind_retain = [ind_retain; tmp(sort(randsample(7,3)))'];
end

stepInfoAll = stepInfoAll(ind_retain,:);
traceIDLabel = traceIDLabel(ind_retain,:);
speedIDLabel =speedIDLabel(ind_retain,:);
stepPattern = stepPattern(ind_retain,:);
personIDLabel = personIDLabel(ind_retain,:);

% toc
end

