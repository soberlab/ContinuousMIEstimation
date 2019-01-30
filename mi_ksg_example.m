%% DATA ANALYSIS SAMPLE SCRIPT
close('all');

% Load spike times
% BC: 
% load('bl21lb21_171218_spikedata-0002-CH5.mat');

% RC:
clear
load('bl21lb21_171218_dtvw-0002.mat')
ts = spikedata.ts(:,1)*1000;

% Load pressure data


% Instantiate data object
neural_data = mi_data(30000,30000);
add_spikes(neural_data, ts);

% Instantiate analysis object(s)
MI_isi = calc_isi_isi(neural_data, [1]);

buildMIs(MI_isi);

% --> update k-values, etc.

calcMIs(MI_isi);

%sim_manager = MI_KSG_sim_manager;

%core1 = MI_KSG_core(sim_manager, isi(1:end-1), isi(2:end), [3 4 5], -1);

%run_sims(sim_manager);


%% MAKE DATA PLOTS
viz = mi_ksg_viz;

make_ksg_graph(viz, core1);
plot_k_dependence(viz, core1);

for i=1:length(core1.k_values)
    plot_data_fraction(viz, core1, core1.k_values(i));
end


a = core1.k_values;
b = 1:10;

m = cell2mat(core1.mi_data(:,1));
c = reshape(m, length(b), length(a));

figure();
surf(a, b, c, 'FaceAlpha', 0.5);
hold on;
plot3(core1.k_values, ones(1,length(core1.k_values)), c(1,:), 'k-', 'LineWidth', 5);

xlabel('k-value');
ylabel('Data Fraction (1/N)');
zlabel('MI (bits)');

%% COUNT-COUNT EXAMPLE - working as of 20190129
% RC:
clear
load('bl21lb21_171218_dtvw-0002.mat')
ts1 = spikedata.ts(:,1)*1000;

load('bl21lb21_171218_dtvw-0003.mat')
ts2 = spikedata.ts(:,1)*1000;

load('bl21lb21_171218_dtvw-pressure.mat')
ptimes = spikedata.ts(:,1)*1000;

clearvars -except ts1 ts2 ptimes

% Instantiate data object
neural_data = mi_data(30000,30000);
add_spikes(neural_data, ts1);
add_spikes(neural_data, ts2);

% Add pressure times
neural_data.cycleTimes = ptimes;

clearvars -except neural_data


% Instantiate analysis object(s)
MI_cc = calc_count_count(neural_data, [1 2]);

buildMIs(MI_cc, MI_cc.verbose);

calcMIs(MI_cc);


%% TIMING_COUNT EXAMPLE
% RC:
clear

load('bl21lb21_171218_dtvw-0002.mat')
ts1 = spikedata.ts(:,1)*1000;

load('bl21lb21_171218_dtvw-0003.mat')
ts2 = spikedata.ts(:,1)*1000;

load('bl21lb21_171218_dtvw-pressure.mat')
ptimes = spikedata.ts(:,1)*1000;

clearvars -except ts1 ts2 ptimes

% Instantiate data object
neural_data = mi_data(30000,30000);
add_spikes(neural_data, ts1);
add_spikes(neural_data, ts2);

% Add pressure times
neural_data.cycleTimes = ptimes;

clearvars -except neural_data


% Instantiate analysis object(s)
MI_tc = calc_timing_count(neural_data, [1 2]);

buildMIs(MI_tc, MI_tc.verbose);

calcMIs(MI_tc);


%% COUNT-COUNT-BEHAVIOR EXAMPLE - WAITING ON RAW PRESSURE DATA FROM BRYCE

% RC:
clear
load('bl21lb21_171218_dtvw-0002.mat')
ts1 = spikedata.ts(:,1)*1000;

load('bl21lb21_171218_dtvw-0003.mat')
ts2 = spikedata.ts(:,1)*1000;

load('bl21lb21_171218_dtvw-pressure.mat')
ptimes = spikedata.ts(:,1)*1000;

clearvars -except ts1 ts2 ptimes

% Instantiate data object
neural_data = mi_data(30000,30000);
add_spikes(neural_data, ts1);
add_spikes(neural_data, ts2);

% Add pressure times
neural_data.cycleTimes = ptimes;

clearvars -except neural_data


% Instantiate analysis object(s)
MI_ccb = calc_count_count_behav(neural_data, [1 2]);

buildMIs(MI_ccb, MI_ccb.verbose);

calcMIs(MI_ccb);