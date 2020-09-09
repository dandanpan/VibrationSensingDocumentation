% this is the Ubicomp Paper Fig.9(c)

clear all
close all
clc

load('./table_fix.mat');

figure;
table = table';
imagesc(table);
colormap(gray);
% grid on;
axis equal;

textStrings = num2str(table(:),'%0.2f');  %# Create strings from the matrix values
textStrings = strtrim(cellstr(textStrings));  %# Remove any space padding
[x,y] = meshgrid(1:7);   %# Create x and y coordinates for the strings
hStrings = text(x(:),y(:),textStrings(:),...      %# Plot the strings
                'HorizontalAlignment','center');
midValue = mean(get(gca,'CLim'));  %# Get the middle value of the color range
textColors = repmat(table(:) < midValue,1,3);  %# Choose white or black for the
                                             %#   text color of the strings so
                                             %#   they can be easily seen over
                                             %#   the background color
set(hStrings,{'Color'},num2cell(textColors,2));  %# Change the text colors

set(gca,'XTick',1:7,...                         %# Change the axes tick marks
        'XTickLabel',{'\mu-3\sigma','\mu-2\sigma','\mu-\sigma','\mu','\mu+\sigma','\mu+2\sigma','\mu+3\sigma'},...  %#   and tick labels
        'YTick',1:7,...
        'YTickLabel',{'\mu-3\sigma','\mu-2\sigma','\mu-\sigma','\mu','\mu+\sigma','\mu+2\sigma','\mu+3\sigma'},...
        'TickLength',[0 0]);
    
 axis tight;
 xlabel('Training set step frequency');
 ylabel('Testing set step frequency');