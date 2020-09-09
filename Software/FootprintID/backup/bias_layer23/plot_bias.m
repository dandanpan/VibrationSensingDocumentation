table = [];
table1 = [];
table2 = [];

for jj = 1:12
    tmp5 = 0;
    tmp6 = [];
    for i = 1:10
        if i<10
            load(['bias23_' num2str(i) '  ' num2str(jj) '.mat']);
        elseif jj<10
            load(['bias23_' num2str(i) '   ' num2str(jj) '.mat']);
        else
            load(['bias23_' num2str(i) '  ' num2str(jj) '.mat']);
        end
        tmp5 = tmp5 + acc_after;
        tmp6 = [tmp6, acc_after];
    end
    tmp5 = tmp5/10;
    tmp_mean = mean(tmp6);
    tmp_std = std(tmp6);
    table = [table tmp5];
    table1 = [table1 tmp_mean];
    table2 = [table2 tmp_std];
end

table
table = reshape(table,[4 3])';
table
table1 = reshape(table1,[4 3])';
table2 = reshape(table2,[4 3])';

figure; bar(table);
figure; imagesc(table1);
figure; imagesc(table2);

%%
figure;
imagesc(table1);
colormap(gray);
% grid on;
axis equal;

textStrings = num2str(table1(:),'%0.2f');  %# Create strings from the matrix values
textStrings = strtrim(cellstr(textStrings));  %# Remove any space padding
[x,y] = meshgrid(1:4,1:3);   %# Create x and y coordinates for the strings
hStrings = text(x(:),y(:),textStrings(:),...      %# Plot the strings
                'HorizontalAlignment','center');
midValue = mean(get(gca,'CLim'));  %# Get the middle value of the color range
textColors = repmat(table1(:) < midValue,1,3);  %# Choose white or black for the
                                             %#   text color of the strings so
                                             %#   they can be easily seen over
                                             %#   the background color
set(hStrings,{'Color'},num2cell(textColors,2));  %# Change the text colors

set(gca,'XTick',1:5,...                         %# Change the axes tick marks
        'XTickLabel',{'1','2','3','4'},...  %#   and tick labels
        'YTick',1:5,...
        'YTickLabel',{'1','2','3'},...
        'TickLength',[0 0]);
%% 
baseline_compare = 0.623;
table1 = (table1-baseline_compare)./baseline_compare;
figure;
imagesc(table1);
colormap(gray);
% grid on;
axis equal;

textStrings = num2str(table1(:)*100,'%0.0f');  %# Create strings from the matrix values
textStrings = strtrim(cellstr(textStrings));  %# Remove any space padding
for i = 1:size(textStrings,1)
    textStrings{i} = [textStrings{i} '%'];
end
[x,y] = meshgrid(1:4,1:3);   %# Create x and y coordinates for the strings
hStrings = text(x(:),y(:),textStrings(:),...      %# Plot the strings
                'HorizontalAlignment','center');
midValue = mean(get(gca,'CLim'));  %# Get the middle value of the color range
textColors = repmat(table1(:) < midValue,1,3);  %# Choose white or black for the
                                             %#   text color of the strings so
                                             %#   they can be easily seen over
                                             %#   the background color
set(hStrings,{'Color'},num2cell(textColors,2));  %# Change the text colors

set(gca,'XTick',1:5,...                         %# Change the axes tick marks
        'XTickLabel',{'1','2','3','4'},...  %#   and tick labels
        'YTick',1:5,...
        'YTickLabel',{'1','2','3'},...
        'TickLength',[0 0]);    


% num
% 1     2     3     4
% 5     6     7     8
% 9    10    11    12

% if num == 1
%     num_trace_hist = [1 1 1 1 1 1 1 1 1 8];
% elseif num == 2
%     num_trace_hist = [2 2 2 2 2 2 2 2 2 7];
% elseif num == 3
%     num_trace_hist = [3 3 3 3 3 3 3 3 3 6];
% elseif num == 4
%     num_trace_hist = [4 4 4 4 4 4 4 4 4 5];
% elseif num == 5
%     num_trace_hist = [1 1 1 1 1 8 8 8 8 8];
% elseif num == 6
%     num_trace_hist = [2 2 2 2 2 7 7 7 7 7];
% elseif num == 7
%     num_trace_hist = [3 3 3 3 3 6 6 6 6 6];
% elseif num == 8
%     num_trace_hist = [4 4 4 4 4 5 5 5 5 5];
% elseif num == 9
%     num_trace_hist = [1 8 8 8 8 8 8 8 8 8];
% elseif num == 10
%     num_trace_hist = [2 7 7 7 7 7 7 7 7 7];
% elseif num == 11
%     num_trace_hist = [3 6 6 6 6 6 6 6 6 6];
% elseif num == 12
%     num_trace_hist = [4 5 5 5 5 5 5 5 5 5];
% end