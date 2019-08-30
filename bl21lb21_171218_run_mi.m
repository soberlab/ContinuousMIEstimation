%% Load data
load('D:\EMG_Data\chung\for_analysis\bl21lb21_20171218\bl21lb21_trial1_ch1_ch16\bl21lb21_171218_nmsort.mat');

load('D:\EMG_Data\chung\for_analysis\bl21lb21_20171218\bl21lb21_trial1_ch1_ch16\bl21lb21_171218_dtvw-pressure.mat');
ptimes = spikedata.ts(:,1)*1000.;

% sigma = [1 2 3 5 10 20];
sigma = [0 1 2 3 5 10 20];


%% COUNT-COUNT
comparisons = [1 1; 1 2; 1 3; 2 2; 2 3;3 3];

for k=1:size(comparisons,1)
    MIs = struct();
    for i = 1:length(sigma)
    % Run count-count
        disp([newline '===== STARTING Count-Count: Unit ' num2str(comparisons(k,1)) ' v Unit ' num2str(comparisons(k,2)) ' =====']);
        try
            % Instantiate data object
            neural_data = mi_data(30000,30000);

            ts1 = dtvw_spikedata.(['Unit' num2str(comparisons(k,1))]).peak_times*1000.;
            ts2 = dtvw_spikedata.(['Unit' num2str(comparisons(k,2))]).peak_times*1000.;

            jitter = normrnd(0, sigma(i), size(ts1));
            add_spikes(neural_data, ts1+jitter);

            jitter = normrnd(0, sigma(i), size(ts2));
            add_spikes(neural_data, ts2+jitter);

            % Add pressure times
            neural_data.cycleTimes = ptimes;

            clearvars -except neural_data i k noises MIs ptimes ts1 ts2 comparisons sigma dtvw_spikedata


            % Instantiate analysis object(s)
            MI_cc = calc_count_count(neural_data, [1 2]);
            MI_cc.verbose = 1;


            buildMIs(MI_cc, MI_cc.verbose);

            MI_cc.arrMIcore{1}.opt_k = 0;
            MI_cc.arrMIcore{1}.k_values = 3:8;

            calcMIs(MI_cc);

            MIs.(['sig' num2str(sigma(i))]) = MI_cc;
            
            disp(['done with sigma = ' num2str(sigma(i))]);
        catch e
            disp([newline '---> ERROR WITH Count-Count: Unit ' num2str(comparisons(k,1)) ' v Unit ' num2str(comparisons(k,2))]);
            disp(e.message);
        end

        disp(['----- DONE WITH Count-Count: Unit ' num2str(comparisons(k,1)) ' v Unit ' num2str(comparisons(k,2)) ' -----']); 
    end
    
    fname = 'C:\Users\bpchung\Google Drive\_Research\__SOBER\__PROJECTS\Mutual Information\bl21lb21_171218_nmsort\mi_cc.mat';
    fname = strrep(fname, '.mat', ['_' num2str(comparisons(k,1)) '-' num2str(comparisons(k,2)) '_discrete.mat']);
    save(fname, 'MIs');

end




%% Run count-timing
comparisons = [1 1; 1 2; 1 3; 2 1; 2 2; 2 3; 3 1; 3 2; 3 3];

for k=1:size(comparisons,1)
    MIs = struct();
    for i=1:length(sigma)
        disp([newline '===== STARTING Count-Timing: Unit ' num2str(comparisons(k,1)) ' v Unit ' num2str(comparisons(k,2)) ' =====']);
        try
            ts1 = dtvw_spikedata.(['Unit' num2str(comparisons(k,1))]).peak_times*1000.;
            ts2 = dtvw_spikedata.(['Unit' num2str(comparisons(k,2))]).peak_times*1000.;

            % Instantiate data object
            neural_data = mi_data(30000,30000);
            
            jitter = normrnd(0, sigma(i), size(ts1));
            add_spikes(neural_data, ts1+jitter);

            jitter = normrnd(0, sigma(i), size(ts2));
            add_spikes(neural_data, ts2+jitter);

            % Add pressure times
            neural_data.cycleTimes = ptimes;

            clearvars -except neural_data k i comparisons ptimes dtvw_spikedata sigma MIs


            % Instantiate analysis object(s)
            MI_tc = calc_timing_count(neural_data, [1 2]);
            MI_tc.verbose = 1;

            buildMIs(MI_tc, MI_tc.verbose);

            for j=1:length(MI_tc.arrMIcore)
                MI_tc.arrMIcore{j}.opt_k = 0;
                MI_tc.arrMIcore{j}.k_values = 3:8;
            end

            calcMIs(MI_tc);

            MIs.(['sig' num2str(sigma(i))]) = MI_tc;
            
            disp(['done with sigma = ' num2str(sigma(i))]);
        catch e
            disp([newline '---> ERROR WITH Count-Timing: Unit ' num2str(comparisons(k,1)) ' v Unit ' num2str(comparisons(k,2))]);
            disp(e);
        end

        disp(['----- DONE WITH Count-Timing: Unit ' num2str(comparisons(k,1)) ' v Unit ' num2str(comparisons(k,2)) ' -----']); 
    end
    fname = 'C:\Users\bpchung\Google Drive\_Research\__SOBER\__PROJECTS\Mutual Information\bl21lb21_171218_nmsort\mi_tc.mat';
    fname = strrep(fname, '.mat', ['_' num2str(comparisons(k,1)) '-' num2str(comparisons(k,2)) '_jitter.mat']);
    save(fname, 'MIs');
    
end


sigma = [1 2 3 5 10 20];


%% Run timing-timing
comparisons = [1 1; 1 2; 1 3; 2 2; 2 3; 3 3];

for k = 1:size(comparisons,1)
    MIs = struct();
    for i=1:length(sigma)
        disp([newline '===== STARTING Timing-Timing: Unit ' num2str(comparisons(k,1)) ' v Unit ' num2str(comparisons(k,2)) ' =====']);
        try
            ts1 = dtvw_spikedata.(['Unit' num2str(comparisons(k,1))]).peak_times*1000.;
            ts2 = dtvw_spikedata.(['Unit' num2str(comparisons(k,2))]).peak_times*1000.;

            % Instantiate data object
            neural_data = mi_data(30000,30000);
            
            jitter = normrnd(0, sigma(i), size(ts1));
            add_spikes(neural_data, ts1+jitter);

            jitter = normrnd(0, sigma(i), size(ts2));
            add_spikes(neural_data, ts2+jitter);

            % Add pressure times
            neural_data.cycleTimes = ptimes;

            clearvars -except neural_data k i comparisons ptimes dtvw_spikedata sigma MIs


            % Instantiate analysis object(s)
            MI_tt = calc_timing_timing(neural_data, [1 2]);
            MI_tt.verbose = 1;

            buildMIs(MI_tt, MI_tt.verbose);

            for j=1:length(MI_tt.arrMIcore)
                MI_tt.arrMIcore{j}.opt_k = 0;
                MI_tt.arrMIcore{j}.k_values = 3:8;
            end

            calcMIs(MI_tt);
            
            MIs.(['sig' num2str(sigma(i))]) = MI_tt;
            
            disp(['done with sigma = ' num2str(sigma(i))]);
        catch e
            disp([newline '---> ERROR WITH Count-Timing: Unit ' num2str(comparisons(k,1)) ' v Unit ' num2str(comparisons(k,2))]);
            disp(e);
        end

        disp(['----- DONE WITH Timing-Timing: Unit ' num2str(comparisons(k,1)) ' v Unit ' num2str(comparisons(k,2)) ' -----']); 
    end

    fname = 'C:\Users\bpchung\Google Drive\_Research\__SOBER\__PROJECTS\Mutual Information\bl21lb21_171218_nmsort\mi_tt.mat';
    fname = strrep(fname, '.mat', ['_' num2str(comparisons(k,1)) '-' num2str(comparisons(k,2)) '_jitter.mat']);
    save(fname, 'MIs');    
end