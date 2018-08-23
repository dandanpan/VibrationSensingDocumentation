classdef DataLoader < handle
    %DATALOADER Loads data for all four channels of a given filename
    properties
        Filename
        Directory
        data
    end
    
    methods
        function obj = DataLoader(filename, directory)
            if nargin < 1
                error('Must provide filename')
            end
            if nargin == 1
               directory = '.';
            end
            obj.Filename = filename;
            obj.Directory = [directory '/'];
            obj.loadChannels();
        end
        function loadChannels(obj)
            channel1 = csvread(strcat(obj.Directory, 'C1', obj.Filename), 5, 0);
            channel2 = csvread(strcat(obj.Directory, 'C2', obj.Filename), 5, 0);
            channel3 = csvread(strcat(obj.Directory, 'C3', obj.Filename), 5, 0);
            channel4 = csvread(strcat(obj.Directory, 'C4', obj.Filename), 5, 0);
            obj.data = [channel1(:,1) channel1(:,2) channel2(:,2) channel3(:,2) channel4(:,2)];
        end
        function data = getData(obj)
            data = obj.data;
        end
        function ch = getChannel(obj, channelNumber)
            if channelNumber < 1 || channelNumber > 4
                error('Channel must be between 1 and 4')
            else
                ch = obj.data(:,1+channelNumber); 
            end
        end
        function time = getTime(obj)
           time = obj.data(:,1); 
        end
        function plot(obj)
            figure;
            subplot(411);
            plot(obj.data(:,1), obj.data(:,2), 'k');
            subplot(412);
            plot(obj.data(:,1), obj.data(:,3), 'k');
            subplot(413);
            plot(obj.data(:,1), obj.data(:,4), 'k');
            subplot(414);
            plot(obj.data(:,1), obj.data(:,5), 'k');
        end
    end
    
end

