% Load spike times
load('bl21lb21_171218_spikedata-0002-CH5.mat');
ts = spikedata.ts(:,1)*1000;

% Load pressure data


% Instantiate data object
neural_data = MI_KSG_data(30000,30000);
add_spikes(neural_data, ts);

% Instantiate analysis object(s)
MI_isi = analysis_ISI1_ISI2(neural_data, [1]);

buildMIs(MI_isi);

% --> update k-values, etc.

calcMIs(MI_isi);

%sim_manager = MI_KSG_sim_manager;

%core1 = MI_KSG_core(sim_manager, isi(1:end-1), isi(2:end), [3 4 5], -1);

%run_sims(sim_manager);

