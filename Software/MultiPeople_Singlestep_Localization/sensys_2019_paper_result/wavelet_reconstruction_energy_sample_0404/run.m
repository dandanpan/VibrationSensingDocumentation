load('./../../wavelet_energy_sample_0404.mat');
channels=4;
for i=1:channels
        isshow=1;
        [COEFS,maxscale,energy_scale(i,:)]= Getwavelet(data_test(i,:), isshow);
        coef_all_sensors{i}=COEFS;
    end