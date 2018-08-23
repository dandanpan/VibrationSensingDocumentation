function [ location ] = radioLoc( radioReadings, SensorLocations )
%RADIOLOC Summary of this function goes here
%   Detailed explanation goes here

    options = optimoptions('fsolve','Algorithm','levenberg-marquardt','Display','none');
    x0 = [0;0];
    pc = SensorLocations(1,:);
    pi = SensorLocations(2,:);
    pj = SensorLocations(3,:);
    v12 = 1;
    v13 = 1;

    tic = radioReadings(2)-radioReadings(1);
    tjc = radioReadings(3)-radioReadings(1);
    [location, fval, exitflag] = fsolve(@(x) localizationEquations( x, pi, pj, pc, tic, tjc, v12, v13 ),x0,options);  

end

