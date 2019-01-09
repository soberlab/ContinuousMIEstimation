load('bl21lb21_171218_spikedata-0002-CH5.mat');
ts = spikedata.ts(:,1)*1000;
isi = diff(ts);

%
% INSERT DATA CONDITIONING HERE
%

% User instantiates data class
% sim_data = MI_KSG_data(filename, nFs, pFS);

% User instantiates analysis class
% Call should be: analysis_timing_count(sim_data, var1, var2);

% This function is called WITHIN MI_KSG_data_analysis instances under the constructor
% ... thus, user should never see any MI_KSG_sim_manager class instances
sim_manager = MI_KSG_sim_manager;

% This function is called WITHIN MI_KSG_data_analyasis instances
% ... thus, user should never see any MI_KSG_core class instances
core1 = MI_KSG_core(sim_manager, isi(1:end-1), isi(2:end), [3 4 5], -1);


% User will need to call run_sims
run_sims(sim_manager);

