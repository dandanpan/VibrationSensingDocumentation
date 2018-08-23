function [ ax, ay, bx, by ] = switchPoints( ax, ay, bx, by )
%SWITCHPOINTS Summary of this function goes here
%   Detailed explanation goes here
    cx = ax;
    ax = bx;
    bx = cx;
    
    cy = ay;
    ay = by;
    by = cy;
end

