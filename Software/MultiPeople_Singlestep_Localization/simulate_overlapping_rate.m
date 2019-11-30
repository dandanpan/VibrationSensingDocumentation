%% simulate the overlapping rate of two steps' peaks
clear all;clc;close all;
m=1e7;
offset=0.1;
wide=10;
leng=10;

sensor1=[0,0];
sensor2=[0,leng];
point1_x=wide*rand(m,1);
point1_y=leng*rand(m,1);
point1=[point1_x,point1_y];
point2_x=wide*rand(m,1);
point2_y=leng*rand(m,1);
point2=[point2_x,point2_y];

%% the pdf of distance from peaks to sensors
distance=sqrt(sum(point2.^2,2))-sqrt(sum(point1.^2,2));
figure;
h1=histogram(distance,500,'Normalization','pdf');

%% the pdf of interval of peaks arriving
T=0.57;
velocity=200;
t1=T*rand(m,1);
t2=T*rand(m,1);

arrive1=t1;
arrive2=t2+distance/velocity;
delta_t=abs(arrive2-arrive1);
figure;
h2=histogram(delta_t,500,'Normalization','pdf');

% %% the seperatable rate
% thre_sep=0.035;
% seperatable=delta_t>thre_sep;
% figure;
% histogram(seperatable,10,'Normalization','cdf');
% 
% %% fix velocity, distance
% T=0.57;
% velocity=300;
% t1=T*rand(m,1);
% t2=T*rand(m,1);
% 
% 
% dis_range=0:0.5:5;
% distance=diag(dis_range)*ones(length(dis_range),m);
% distance=distance';
% seperable=zeros(length(dis_range),1);
% for i=1:length(dis_range)
%     arrive1=t1;
%     arrive2=t2+distance(:,i)/velocity;
%     seperable(i)=sum(abs(arrive2-arrive1)>thre_sep)/m;
% end
% figure;
% plot(dis_range,seperable);
% xlabel('distance');
% ylabel('peaks seperatable rate');
% title('fix velocity=300m/s');
% 
% % fix distance, change velocity
% T=0.57;
% t1=T*rand(m,1);
% t2=T*rand(m,1);
% 
% 
% velocity_range=200:50:600;
% distance=200*ones(m,1);
% seperable=zeros(length(velocity_range),1);
% for i=1:length(velocity_range)
%     arrive1=t1;
%     arrive2=t2+distance/velocity_range(i);
%     seperable(i)=sum(abs(arrive2-arrive1)>thre_sep)/m;
% end
% figure;
% plot(velocity_range,seperable);
% xlabel('velocity');
% ylabel('peaks seperatable rate');
% title('fix distance=3m');

%% fix the distance of sensors and get switch rate
dis_range=3:20:200;
switch_rate=zeros(length(dis_range),1);
for i=1:length(dis_range)
%% get random points 1 and 2
wide=dis_range(i);
leng=dis_range(i);

sensor1=[0,0];
sensor2=[0,leng];
point1_x=wide*rand(m,1);
point1_y=leng*rand(m,1);
point1=[point1_x,point1_y];
point2_x=wide*rand(m,1);
point2_y=leng*rand(m,1);
point2=[point2_x,point2_y];
    
%calculate the switching rate

distance2sensor1=sqrt(sum(point2.^2,2))-sqrt(sum(point1.^2,2));  %% the point2 - point1
distance_array_point1sensor2=point1-repmat(sensor2,m,1);
distance_array_point2sensor2=point2-repmat(sensor2,m,1);
distance2sensor2=sqrt(sum(distance_array_point2sensor2.^2,2))...
    -sqrt(sum(distance_array_point1sensor2.^2,2));

%% the pdf of interval of peaks arriving
velocity=300;
arrive2sensor1=t2-t1+distance2sensor1/velocity;
arrive2sensor2=t2-t1+distance2sensor2/velocity;


switch_peaks1=(arrive2sensor1>0).*(arrive2sensor2>0);
switch_peaks2=(arrive2sensor1<0).*(arrive2sensor2<0);
switch_rate(i)=sum(switch_peaks1+switch_peaks2<1)/m; %% smaller than 1 means switch
end
figure;
plot(dis_range,switch_rate);
xlabel('Distance between two sensors');
ylabel('switching rate of two points into two sensors');
title('Probability of switching peaks');