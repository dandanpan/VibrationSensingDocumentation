function [ denoiseSig ] = signalDenoise( signal, degree )
%SIGNALDENOISE Summary of this function goes here
%   Detailed explanation goes here
    
    [denoiseSig,~] = wiener2(signal,[degree 1]); 

end

