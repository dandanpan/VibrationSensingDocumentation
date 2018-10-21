function F = buildLocEq( TDoAPairs, sensorLoc, x, v )
%BUILDLOCEQ Summary of this function goes here
%   Detailed explanation goes here
    F = [];
    pairNum = size(TDoAPairs,1);
    for pairID = 1:pairNum
        F = [F; norm(x(1:2)-sensorLoc{TDoAPairs(pairID, 1)}(:)) - norm(x(1:2)-sensorLoc{TDoAPairs(pairID, 2)}(:)) - v*TDoAPairs(pairID, 3)];
    end
end

