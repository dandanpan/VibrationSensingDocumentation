init;

Fs = 6500;
Fil1 = 50;
Fil2 = 60;
DenoiseDegree = 3;

vs1 = vs1 - mean(vs1);
fil_sig = signalFilter( vs1, Fs, Fil1, Fil2 );
vs1_filter = signalDenoise(fil_sig, DenoiseDegree);


vs2 = vs2 - mean(vs2);
fil_sig2 = signalFilter( vs2, Fs, Fil1, Fil2 );
vs2_filter = signalDenoise(fil_sig2, DenoiseDegree);


vs3 = vs3 - mean(vs3);
fil_sig3 = signalFilter( vs3, Fs, Fil1, Fil2 );
vs3_filter = signalDenoise(fil_sig3, DenoiseDegree);


vs4 = vs4 - mean(vs4);
fil_sig4 = signalFilter( vs4, Fs, Fil1, Fil2 );
vs4_filter = signalDenoise(fil_sig4, DenoiseDegree);

figure;
plot(ts1, vs1_filter);hold on;
plot(ts2, vs2_filter);hold on;
plot(ts3, vs3_filter);hold on;
plot(ts4, vs4_filter);hold off;
% plot(ts1, vs1_filter);hold on;
% plot(ts2, vs2_filter);hold on;
% plot(ts3, vs3_filter);hold on;
% plot(ts4, vs4_filter);hold off;
% plot(vs1_filter);hold on;
% plot(vs2_filter);hold on;
% plot(vs2_filter);hold off;


