clear all
close all
clc


s1 = importdata('./1-1.txt');
s2 = importdata('./1-2.txt');
s3 = importdata('./1-3.txt');
Fs = 1000;

subplot(3,1,1);
plot([1:length(s1)]/Fs,s1);
subplot(3,1,2);
plot([1:length(s2)]/Fs,s2,'r');
subplot(3,1,3);
plot([1:length(s3)]/Fs,s3,'g');