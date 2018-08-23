function [ entr ] = entropyFromDistribution( p, method )
%ENTROPYFROMDISTRIBUTION Summary of this function goes here
%   method 1, add 1 on all to avoid 0
%   method 2, times the number of non zero cluster as weight
    if method == 1
        p = p+1;
        p = p./sum(p);
        entr = sum(p.*log2(1./p));
    elseif method == 2
        pnonezero = p(p>0);
        p = pnonezero./sum(pnonezero);
        entr = sum(p.*log2(1./p));
        entr = entr*length(pnonezero)/10;
    elseif method == 3
        pnonezero = p(p>0);
        if isempty(p)
            entr = -1;
        else
            p = pnonezero./sum(pnonezero);
            entr = sum(p.*log2(1./p));
        end
    end
end

