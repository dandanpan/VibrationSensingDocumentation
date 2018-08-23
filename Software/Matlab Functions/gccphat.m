function [maxVal, time ] = gccphat( b1,b2 )
%GCCTEST Summary of this function goes here
%   Detailed explanation goes here

    %GCC-PHAT
  fft1=fft(b1);
  fft2=fft(b2);
  G12=fft1.*conj(fft2);
%   denom=max(abs(G12),1e-6);
  denom=abs(G12);
  G=G12./denom;
  g=real(ifft(G));
  g=fftshift(g);
  
  figure;
  subplot(3,1,1);
  plot(b1);
  subplot(3,1,2);
  plot(b2);
  subplot(3,1,3);
  plot(g);
  [maxVal, maxIdx] = max(abs(g));
  time = maxIdx - length(g);  

end


