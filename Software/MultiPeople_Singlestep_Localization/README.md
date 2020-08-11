## Publications
Shi, Laixi, Mostafa Mirshekari, Jonathon Fagert, Yuejie Chi, Hae Young Noh, Pei Zhang, and Shijia Pan. "Device-free Multiple People Localization through Floor Vibration." In Proceedings of the 1st ACM International Workshop on Device-Free Human Sensing, pp. 57-61. 2019.

Shi, Laixi, Yue Zhang, Shijia Pan, and Yuejie Chi. "Data Quality-Informed Multiple Occupant Localization using Floor Vibration Sensing." In Proceedings of the 21st International Workshop on Mobile Computing Systems and Applications, pp. 98-98. 2020.

## Function Description:

Main function:
1.localize_3perosn_porterhall.m : the main file dealing with the 3 person experiments in Porter Hall
	(1). MultiPeople_SEDetection: extract steps event out (SEDetection.m: detection for 1 person scenario)
	(2). ShowoneScaleData.m: get the TDOA (other versions: ShowoneScaleData_baseline.m,ShowoneScaleData_velocity.m )
		waveletFiltering: get the reconstructed wavelet signal.
		SelectPossibleScales: return the possible scales in the target band
		Judge_multiple_peaks2: get all the peaks for TDOA (Judge_multiple.m: old version)
		GetTDOAfromSlidingWindow_normalie: use peaks to get TDOA
	(3). Echo_sorting_velocity_scale.m: sweep all velocity and scale for the best localization

	Select_loc_noprior.m: Select localization using no prior information
	simulate_overlapping_rate.m: simulate the two peaks overlapping when two steps is uniformly distributed in an rectangle
	PeaksDetection_withinEvent: separate different steps from one big steps event

2.test_localization_noprior.m, test_localization_noprior_3p4p.m:
No prior to choose the best localizations from the results of every step



For detection:
detected_using_raw_signal.m : draw the figure that using raw signal for detection steps within one event

For baseline:
baseline_localization.m: get the baseline of the localization of the raw
signal, high frequency signal and low frequency signal
baseline_3p_localization.m: for 3 people
baseline_localization_error.m: calculate the error of it

For overlapping rate:
simulate_overlapping_rate.m: simulate the overlapping rate 


Some auxiliary functions for main functions:
Echo_sorting_velocity_scale.m: sweep all velocity and scale for the best localization
Echo_sorting, Echo_sorting_localiza.m: some previous versions or for specific utilization.
ExtractPossibleScale.m: to find the target scale band (the bands suitable for localization)

GetWavelet.m: get wavelet of the raw signal

windowEnergyArray.m: calculate the window energy

localize_3perosn_porterhall.m: latest version:
	localize_1perosn_porterhall.m： for 1person in porter hall
	localize_1person: old version
	localize_oldpeople0405.m: for old people


GetTDOAfromSlidingWindow_normalie: latest version
	GetTDOAfromCOEFS.m, GetTDOAfromSlidingWindow.m, GetTDOAfromSlidingWindow_rawsignal.m : other versions

sstress_core_new.m: latest version: using sstress function to optimize the localization
	sstress_core.m, sstress_core_localize.m: other versions

Some other functions:

SelectPossiblePeaks,FindFirstPeak.m, FindFirstPeak_velocity.m: Some other versions of finding first peaks

velocity_measure.m: get the propagation velocity of the ground in porterhall
Data_Acq_save_111418.m: Collect data using Daq
detection_sample.m: show a sample for detection (just for example, no use)
DFHS2019_pre_signal.m : signal illustration for presentation
display_data.m: display the sample of signal received by sensors
extract_steps: get some steps out
EDM_simulate.m: simulate for EDM, lose function to verify the correctness of algorithm
PreprocessingFixinglength.m: get the data to fixed length
seperate_1p2p.m: separate the 10min uncontrol results to 1p, 2p two trials
signalFilter.m: filter the raw signal


With prior information to select localization:
test_select_localization.m: Main file for using Kalman Filter and prior information to select localization.
Selectlozalization: Select localization from multiple scales' results according
to all the information we have

