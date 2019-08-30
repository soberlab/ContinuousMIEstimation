%% This script runs a test on a known dataset and provides visual plots for audit purposes

clear('all');
close('all');

verbose = 1;

%% Load neural data (Unit 1, Unit 2)
% spike times from spike sorting are in seconds; convert to ms
load('D:/EMG_Data/chung/for_analysis/bl21lb21_20171218/bl21lb21_trial1_ch1_ch16/bl21lb21_171218_nmsort.mat');
unit1_ts = dtvw_spikedata.Unit1.spikedata.ts*1000.; 
unit2_ts = dtvw_spikedata.Unit2.spikedata.ts*1000.;
unit3_ts = dtvw_spikedata.Unit3.spikedata.ts*1000.;

neural_data = mi_data(30000,30000); % set neural and behavioral sampling
neural_data.verbose = verbose;

neural_data.add_spikes(unit1_ts, 'n_timebase', 'time');
neural_data.add_spikes(unit2_ts, 'n_timebase', 'time');
neural_data.add_spikes(unit3_ts, 'n_timebase', 'time');
% --> Do we want to be able to address/index units in "neurons" property?


%% Load pressure data

% remember current directory and navigate to folder with data files
dat_pressure = mi_data_pressure('verbose', verbose);

old_dir = cd('D:/EMG_Data/chung/for_analysis/bl21lb21_20171218/bl21lb21_trial1_ch1_ch16/');

set_source(dat_pressure, dir('*.rhd')); % use all data RHD data files
calc_cycles(dat_pressure, 'threshold');

cd(old_dir); % return working directory to original location

%% add behavior object to mi_data object
neural_data.add_behavior(dat_pressure);
neural_data.set_behavior('timebase', 'time', ...
    'length', 11, ...
    'startPhase', 80, ...
    'windowOfInterest', 100, ...
    'dataTransform', 'pca');

%% Calculate mutual information for consecutive ISI of neural data Unit 1


%% Calculate mutual information for consecutive ISI of neural data Unit 2


%% Calculate mutual information between neural units


%% Calculate mutual information for count-behavior Unit 1, Unit 2
MI_cb = calc_count_behav(neural_data, {2; 'time'});

MI_cb.buildMIs();

calcMIs(MI_cb);

%% Calculate mutual information for timing-behavior Unit 1, Unit 2


%% Calculate mutual information between units and behavior


