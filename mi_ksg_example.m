%% THINK ABOUT THIS
% 1. Upload data and instantiate data object
% 2. Format data (i.e., phase, timing, etc.)
% 3. Run analysis class
% 4. Make plots
% 5. Repeat 2 - 4 for different variable/formatting combinations

% For auditing purposes, we probably need to include in the analysis
% object, a single struct that copies the parameters of data parameters adn
% stores it for good will

% It might actually be most advantageous to create another class.... for
% storing results objects --> this would include, sims objects and
% parameters.


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
MI_isi = calc_isi_isi(neural_data, [1], 1, 200);

buildMIs(MI_isi);

% --> update k-values, etc.

MI_isi.arrMIcore{1}.opt_k = 0;
MI_isi.arrMIcore{1}.k_values = 3:8;

% Run mutual information calculations
calcMIs(MI_isi);


%% MAKE DATA PLOTS
core1 = MI_isi.arrMIcore{1};
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


%% TIMING_COUNT EXAMPLE- WORKING AS OF 03042019
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


%% COUNT-COUNT-BEHAVIOR EXAMPLE - WORKING AS OF 03042019

% RC:
clear
load('D:\EMG_Data\chung\for_analysis\bl21lb21_20171218\bl21lb21_trial1_ch1_ch16\bl21lb21_171218_nmsort_spikedata-CH1.mat')
ts1 = spikedata.ts(:,1)*1000;

load('D:\EMG_Data\chung\for_analysis\bl21lb21_20171218\bl21lb21_trial1_ch1_ch16\bl21lb21_171218_nmsort_spikedata-CH5.mat')
ts2 = spikedata.ts(:,1)*1000;

load('D:\EMG_Data\chung\for_analysis\bl21lb21_20171218\bl21lb21_trial1_ch1_ch16\bl21lb21_171218_dtvw-pressure.mat')
ptimes = spikedata.ts(:,1)*1000;

clearvars -except ts1 ts2 ptimes

% Load Pressure data- for area under the curve
% load('bl21lb21_171218_dtvw-pressure.mat')
pressure = spikedata.ts(1:end,5);
% Load Pressure data - for raw pressure (smaller files)
% fid = fopen('bl21lb21_171218_130932_180s_CH1-2-3-4-5-6-7-8_Fs30000_Filt300-7500.bin','r');
% data = fread(fid,[9,540280],'double');
% pressure = data(9,1:end);

clearvars -except ts1 ts2 ptimes pressure



% Instantiate data object
neural_data = mi_data(30000,30000);
add_spikes(neural_data, ts1);
add_spikes(neural_data, ts2);
add_behavior(neural_data, pressure)


% Add pressure times
neural_data.cycleTimes = ptimes;

clearvars -except neural_data


% Instantiate analysis object(s)
MI_ccb = calc_count_count_behav(neural_data, [1 2]);

buildMIs(MI_ccb, 5 , MI_ccb.verbose)

calcMIs(MI_ccb);
%% COUNT-BEHAVIOR EXAMPLE - WORKING AS OF 03052019

% RC:
clear
load('bl21lb21_171218_dtvw-0002.mat')
ts1 = spikedata.ts(:,1)*1000;


load('bl21lb21_171218_dtvw-pressure.mat')
ptimes = spikedata.ts(:,1)*1000;

clearvars -except ts1 ts2 ptimes

% Load Pressure data- for area under the curve
load('bl21lb21_171218_dtvw-pressure.mat')
pressure = spikedata.ts(1:end,5);
% Load Pressure data - for raw pressure (smaller files)
% fid = fopen('bl21lb21_171218_130932_180s_CH1-2-3-4-5-6-7-8_Fs30000_Filt300-7500.bin','r');
% data = fread(fid,[9,540280],'double');
% pressure = data(9,1:end);

clearvars -except ts1 ptimes pressure



% Instantiate data object
neural_data = mi_data(30000,30000);
add_spikes(neural_data, ts1);
add_behavior(neural_data, pressure)


% Add pressure times
neural_data.cycleTimes = ptimes;

clearvars -except neural_data


% Instantiate analysis object(s)
MI_cb = calc_count_behav(neural_data, 1);

buildMIs(MI_cb, 5 , MI_cb.verbose)

calcMIs(MI_cb);
%% TIMING_TIMING EXAMPLE- WORKING AS OF 03052019
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
MI_tt = calc_timing_timing(neural_data, [1 2]);

buildMIs(MI_tt, MI_tt.verbose);

calcMIs(MI_tt);

%% TIMING_TIMING_BEHAV EXAMPLE- WORKING AS OF 03052019
% RC:
clear

load('bl21lb21_171218_dtvw-0002.mat')
ts1 = spikedata.ts(:,1)*1000;

load('bl21lb21_171218_dtvw-0003.mat')
ts2 = spikedata.ts(:,1)*1000;

load('bl21lb21_171218_dtvw-pressure.mat')
ptimes = spikedata.ts(:,1)*1000;

% Load Pressure data- for area under the curve
load('bl21lb21_171218_dtvw-pressure.mat')
pressure = spikedata.ts(1:end,5);
% Load Pressure data - for raw pressure (smaller files)
% fid = fopen('bl21lb21_171218_130932_180s_CH1-2-3-4-5-6-7-8_Fs30000_Filt300-7500.bin','r');
% data = fread(fid,[9,540280],'double');
% pressure = data(9,1:end);

clearvars -except ts1 ts2 pressure ptimes

% Instantiate data object
neural_data = mi_data(30000,30000);
add_spikes(neural_data, ts1);
add_spikes(neural_data, ts2);
add_behavior(neural_data, pressure)

% Add pressure times
neural_data.cycleTimes = ptimes;

clearvars -except neural_data


% Instantiate analysis object(s)
MI_ttb = calc_timing_timing_behav(neural_data, [1 2]);

buildMIs(MI_ttb,5, MI_ttb.verbose);

calcMIs(MI_ttb);

%% TIMING_COUNT_BEHAV EXAMPLE-WORKING AS OF 03052019
% RC:
clear

load('bl21lb21_171218_dtvw-0002.mat')
ts1 = spikedata.ts(:,1)*1000;

load('bl21lb21_171218_dtvw-0003.mat')
ts2 = spikedata.ts(:,1)*1000;

load('bl21lb21_171218_dtvw-pressure.mat')
ptimes = spikedata.ts(:,1)*1000;

% Load Pressure data- for area under the curve
load('bl21lb21_171218_dtvw-pressure.mat')
pressure = spikedata.ts(1:end,5);
% Load Pressure data - for raw pressure (smaller files)
% fid = fopen('bl21lb21_171218_130932_180s_CH1-2-3-4-5-6-7-8_Fs30000_Filt300-7500.bin','r');
% data = fread(fid,[9,540280],'double');
% pressure = data(9,1:end);

clearvars -except ts1 ts2 pressure ptimes

% Instantiate data object
neural_data = mi_data(30000,30000);
add_spikes(neural_data, ts1);
add_spikes(neural_data, ts2);
add_behavior(neural_data, pressure)

% Add pressure times
neural_data.cycleTimes = ptimes;

clearvars -except neural_data


% Instantiate analysis object(s)
MI_tcb = calc_timing_count_behav(neural_data, [1 2]);

buildMIs(MI_tcb,5, MI_tcb.verbose);

calcMIs(MI_tcb);

%% TIMING_BEHAV EXAMPLE- WORKING AS OF 03052019
% RC:
clear

load('bl21lb21_171218_dtvw-0002.mat')
ts1 = spikedata.ts(:,1)*1000;


% Load Pressure data- for area under the curve
load('bl21lb21_171218_dtvw-pressure.mat')
ptimes = spikedata.ts(:,1)*1000;
pressure = spikedata.ts(1:end,5);
% Load Pressure data - for raw pressure (smaller files)
% fid = fopen('bl21lb21_171218_130932_180s_CH1-2-3-4-5-6-7-8_Fs30000_Filt300-7500.bin','r');
% data = fread(fid,[9,540280],'double');
% pressure = data(9,1:end);

clearvars -except ts1 pressure ptimes

% Instantiate data object
neural_data = mi_data(30000,30000);
add_spikes(neural_data, ts1);
add_behavior(neural_data, pressure);

% Add pressure times
neural_data.cycleTimes = ptimes;

clearvars -except neural_data


% Instantiate analysis object(s)
MI_tb = calc_timing_behav(neural_data, [1 2]);

buildMIs(MI_tb,5, MI_tb.verbose);

calcMIs(MI_tb);

%% Pressure Phase Code 
clear
% Load Data
load('bl21lb21_171218_125431_300s_CH1-2-3-4-5-6-7-8_Fs30000_Filt300-7500-analog (1).mat')

% Instantiate data object
obj = mi_data(32000,32000);

% Add pressure data to object
obj.add_behavior( wav_tmp(9,:));

% Clear variables
clearvars -except obj

% Get Cycle times for object
obj.get_cycleTimes();

% Get pressure cycles - phase
% pressure_cycles = obj.getPressure();

% Get pressure cycles - time
pressure_cycles = obj.getPressure('time');
%%

if size(core1.mi_data,1) > length(core1.k_values)
    a = core1.k_values;
    b = 1:10;

    m = cell2mat(core1.mi_data(:,1));
    c = reshape(m, length(b), length(a));

    figure();
    % plot mi surface
    surf(a, b, c, 'FaceAlpha', 0.5);
    hold on;
    
    % plot mi along data fracs = 1
    plot3(core1.k_values, ones(1,length(core1.k_values)), c(1,:), 'k-', 'LineWidth', 5);

    % plot optimal k-value
    k_ix = core1.k_values == core1.opt_k;
    k_ixs = [core1.mi_data{:,4}] == core1.opt_k;
    plot3(ones(1,length(b))*core1.opt_k, 1:10, c(:,k_ix), 'r-', 'LIneWidth', 5);
    
    xlabel('k-value');
    ylabel('Data Fraction (1/N)');
    zlabel('MI (bits)');
end
