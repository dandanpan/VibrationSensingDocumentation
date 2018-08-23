function [ dist ] = distHist( hist1, hist2, method )
%DISTHIST Summary of this function goes here
%   Detailed explanation goes here
    if method == 1
        % chi-square
        hist1 = hist1./sum(hist1);
        hist2 = hist2./sum(hist2);
        dist = sum((hist1-hist2).^2./hist1);
    elseif method == 2
        % intersection
        dist = sum(min(hist1, hist2));
    elseif method == 3
        hist1 = hist1./sum(hist1);
        hist2 = hist2./sum(hist2);
        dist = sum(min(hist1, hist2));
    end

end

