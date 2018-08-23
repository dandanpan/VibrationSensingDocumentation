function [ reconstructedSig ] = waveletFilterTemplate( COEFS, maxScale )
    sigMask = zeros(size(COEFS.cfs));
    sigMask(maxScale,:) = ones(length(maxScale),size(COEFS.cfs,2));
    COEFS.cfs = sigMask.*COEFS.cfs;
    reconstructedSig = icwtft(COEFS);
end

