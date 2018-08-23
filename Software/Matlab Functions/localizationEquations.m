function F = localizationEquations( x, pi, pj, pc, tic, tjc, v12, v13 )
%LOCALIZATIONEQUATIONS Summary of this function goes here
%   Detailed explanation goes here
    F = [ norm(x(1:2)-pi(:)) - norm(x(1:2)-pc(:)) - v12*tic;
          norm(x(1:2)-pj(:)) - norm(x(1:2)-pc(:)) - v13*tjc];
end

