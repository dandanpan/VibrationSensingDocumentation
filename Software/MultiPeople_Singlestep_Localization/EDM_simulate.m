close all, clear all, clc;
% The EDM method for echo combination
% The simulation is based on 4 localized microphones 
% sampling frequency is 6500 Hz and the frequency is 55Hz, time is 0.4s

%% parameter setting
% geophones positions and persons positions
geophone_number=4;
geophone_position=[-1.5,-1.5,1.5,1.5;2,-2,2,-2];

% get the people's position
person1_position=[0;0];
person2_position=[-1.5;-1.5];
range=4;
person1_position=range*rand(2,1)-range/2;
person2_position=range*rand(2,1)-range/2;

%% save localization that make wrong localization for test
% load('wrong_position.mat');
% person1_position=wrong_person1_position(:,2);
% person2_position=wrong_person2_position(:,2);
% 

% wrong_person1_position=[wrong_person1_position, person1_position];
% wrong_person2_position=[wrong_person2_position, person2_position];
% save('wrong_position','wrong_person1_position','wrong_person2_position');



% The vibration waves construct later
% The EDM of localized geophones
D_geophone=zeros(geophone_number);
for i=1:geophone_number
    for j=1:geophone_number
        D_geophone(i,j)=norm(geophone_position(:,i)-geophone_position(:,j),2)
    end
end

 
%% suppose we know the arriving time of two persons's waves to four geophones
person_number=2;
person12gephone=sum((geophone_position-person1_position).^2); % calculate the distance
person22gephone=sum((geophone_position-person2_position).^2);
distance_raw=[person12gephone;person22gephone];  % remember the correct peaks matching

%% add noise to distance, is the smae as add noise to TDOA
noise=0.3*randn(size(distance_raw));
distance_raw=distance_raw+noise;

distance=sort(distance_raw); % the distance from two person to geophones with no order, which waiting for sorting later
% distance is how many peaks* geophone number




%% add more peaks for testing searching and finding the right place
cell_distance={};
for i=1:geophone_number
    peaks_diff=rand(2,1)-1/2;
    peaks_once=distance(:,i)
    for j=1:length(peaks_diff)
        peaks_once=[peaks_once;distance(:,i)+peaks_diff(j)];
    end
    peaks_once=max(0,sort(peaks_once));
    cell_distance{i}=peaks_once;
end

% pick the correct peaks matching for testing later
correct_peaks=zeros(geophone_number,person_number); % column is the peaks of one person
for personi=1:person_number
    for geophonej=1:geophone_number
    [pos, value]=find(cell_distance{geophonej}==distance_raw(personi,geophonej))
    correct_peaks(geophonej,personi)=pos;
    end
end


% function of Echo sorting
num_matching=length(cell_distance{1})*2;
matchedposition=zeros(2,num_matching);
sort_peaks=zeros(geophone_number,num_matching);
all_score=zeros(num_matching,1);
already_matching=[];
for i=1:length(cell_distance{1})
    for j=1:2
        sort_peaks(1,(i-1)*2+j)=i;
        peak_for_match=i;
        d1=cell_distance{1}(i);
        [matchedposition(:,(i-1)*2+j),sort_peaks(:,(i-1)*2+j),all_score((i-1)*2+j)]...
            =Echo_sorting(geophone_position,D_geophone,d1,cell_distance,already_matching,peak_for_match);
        already_matching=[already_matching,sort_peaks(:,(i-1)*2+j)];
    end
end


figure;
plot(geophone_position(1,:),geophone_position(2,:),'r*');
hold on
plot(person1_position(1),person1_position(2),'bo');
plot(person2_position(1),person2_position(2),'bo');
plot(matchedposition(1,:),matchedposition(2,:),'g+');


