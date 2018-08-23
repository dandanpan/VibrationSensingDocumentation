function [ location ] = vibLoc( vibPeakIdx, SensorLocations, v )
%VIBLOC Summary of this function goes here
%   Detailed explanation goes here

    options = optimoptions('fsolve','Algorithm','levenberg-marquardt','Display','none');
    x0 = [0;0];
    pc = SensorLocations(1,:);
    pi = SensorLocations(2,:);
    pj = SensorLocations(3,:);
    v12 = v;
    v13 = v*0.5;

    tic = vibPeakIdx(2)-vibPeakIdx(1);
    tjc = vibPeakIdx(3)-vibPeakIdx(1);
    [location, fval, exitflag] = fsolve(@(x) localizationEquations( x, pi, pj, pc, tic, tjc, v12, v13 ),x0,options);

end

