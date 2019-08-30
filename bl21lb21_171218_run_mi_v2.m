%% Load data
load('D:\EMG_Data\chung\for_analysis\bl21lb21_20171218\bl21lb21_trial1_ch1_ch16\bl21lb21_171218_nmsort.mat');

load('D:\EMG_Data\chung\for_analysis\bl21lb21_20171218\bl21lb21_trial1_ch1_ch16\bl21lb21_171218_dtvw-pressure.mat');
ptimes = spikedata.ts(:,1)*1000.;
pressure = spikedata.ts(1:end,5);

% sig = [1 2 3 5 10 20];
sig = [0 1 2 3 5 10 20];
% sig = [1 2 3 5 10 20];

% %% COUNT-BEHAV
% comparisons = [1 1; 2 1; 3 1];
% 
% for k=1:size(comparisons,1)
%     MIs = struct();
%     for i = 1:length(sig)
%     % Run count-count
%         disp([newline '===== STARTING Count-Count: Unit ' num2str(comparisons(k,1)) ' v Unit ' num2str(comparisons(k,2)) ' =====']);
%         try
%             % Instantiate data object
%             neural_data = mi_data(30000,30000);
% 
%             ts1 = dtvw_spikedata.(['Unit' num2str(comparisons(k,1))]).peak_times*1000.;
%             ts2 = dtvw_spikedata.(['Unit' num2str(comparisons(k,2))]).peak_times*1000.;
% 
%             jitter = normrnd(0, sig(i), size(ts1));
%             add_spikes(neural_data, ts1+jitter);
% 
%             jitter = normrnd(0, sig(i), size(ts2));
%             add_spikes(neural_data, ts2+jitter);
%             
%             add_behavior(neural_data, pressure);
% 
%             % Add pressure times
%             neural_data.cycleTimes = ptimes;
% 
%             clearvars -except neural_data i k noises MIs ptimes ts1 ts2 comparisons sig dtvw_spikedata pressure
% 
% 
%             % Instantiate analysis object(s)
%             MI_cb = calc_count_behav(neural_data, 1);
%             MI_cb.verbose = 1;
% 
% %             MI_cb.sim_manager.par_mode = -1;
% 
%             buildMIs(MI_cb, 5, MI_cb.verbose);
% 
%             MI_cb.arrMIcore{1}.opt_k = 0;
%             MI_cb.arrMIcore{1}.k_values = 3;
% 
%             calcMIs(MI_cb);
% 
%             MIs.(['sig' num2str(sig(i))]) = MI_cb;
%             
%             disp(['done with sig = ' num2str(sig(i))]);
%         catch e
%             disp([newline '---> ERROR WITH Count-Behav: Unit ' num2str(comparisons(k,1)) ' v Unit ' num2str(comparisons(k,2))]);
%             disp(e.message);
%         end
% 
%         disp(['----- DONE WITH Count-Count: Unit ' num2str(comparisons(k,1)) ' v Unit ' num2str(comparisons(k,2)) ' -----']); 
%     end
%     
%     fname = 'C:\Users\bpchung\Google Drive\_Research\__SOBER\__PROJECTS\Mutual Information\bl21lb21_171218_nmsort\mi_cb.mat';
%     fname = strrep(fname, '.mat', ['_' num2str(comparisons(k,1)) '-' num2str(comparisons(k,2)) '_jitter.mat']);
%     save(fname, 'MIs');
% 
% end




% %% TIMING-BEHAV
% comparisons = [1 1; 2 1; 3 1];
% 
% for k=1:size(comparisons,1)
%     MIs = struct();
%     for i=1:length(sig)
%         disp([newline '===== STARTING Timing-Behavior: Unit ' num2str(comparisons(k,1)) ' v Unit ' num2str(comparisons(k,2)) ' =====']);
%         try
%             ts1 = dtvw_spikedata.(['Unit' num2str(comparisons(k,1))]).peak_times*1000.;
%             ts2 = dtvw_spikedata.(['Unit' num2str(comparisons(k,2))]).peak_times*1000.;
% 
%             % Instantiate data object
%             neural_data = mi_data(30000,30000);
%             
%             jitter = normrnd(0, sig(i), size(ts1));
%             add_spikes(neural_data, ts1+jitter);
% 
%             jitter = normrnd(0, sig(i), size(ts2));
%             add_spikes(neural_data, ts2+jitter);
%             
%             add_behavior(neural_data, pressure);
% 
%             % Add pressure times
%             neural_data.cycleTimes = ptimes;
% 
%             clearvars -except neural_data k i comparisons ptimes dtvw_spikedata sig MIs pressure
% 
% 
%             % Instantiate analysis object(s)
%             MI_tb = calc_timing_behav(neural_data, [1 2]);
%             MI_tb.verbose = 1;
% 
%             buildMIs(MI_tb, 5, MI_tb.verbose);
% 
%             for j=1:size(MI_tb.arrMIcore,1)
%                 MI_tb.arrMIcore{j}.opt_k = 0;
%                 MI_tb.arrMIcore{j}.k_values = 3;
%             end
% 
% %             MI_tb.sim_manager.par_mode = -1;
%             
%             calcMIs(MI_tb);
% 
%             MIs.(['sig' num2str(sig(i))]) = MI_tb;
%             
%             disp(['done with sig = ' num2str(sig(i))]);
%         catch e
%             disp([newline '---> ERROR WITH Count-Timing: Unit ' num2str(comparisons(k,1)) ' v Unit ' num2str(comparisons(k,2))]);
%             disp(e);
%         end
% 
%         disp(['----- DONE WITH Timing-Behavior: Unit ' num2str(comparisons(k,1)) ' v Unit ' num2str(comparisons(k,2)) ' -----']); 
%     end
%     fname = 'C:\Users\bpchung\Google Drive\_Research\__SOBER\__PROJECTS\Mutual Information\bl21lb21_171218_nmsort\mi_tb.mat';
%     fname = strrep(fname, '.mat', ['_' num2str(comparisons(k,1)) '-' num2str(comparisons(k,2)) '_jitter.mat']);
%     save(fname, 'MIs');
%     
% end




% %% COUNT-COUNT-BEHAV
% comparisons = [1 1; 1 2; 1 3; 2 2; 2 3; 3 3];
% 
% for k = 1:size(comparisons,1)
%     MIs = struct();
%     for i=1:length(sig)
%         disp([newline '===== STARTING Count-Count-Behav: Unit ' num2str(comparisons(k,1)) ' v Unit ' num2str(comparisons(k,2)) ' =====']);
%         try
%             ts1 = dtvw_spikedata.(['Unit' num2str(comparisons(k,1))]).peak_times*1000.;
%             ts2 = dtvw_spikedata.(['Unit' num2str(comparisons(k,2))]).peak_times*1000.;
% 
%             % Instantiate data object
%             neural_data = mi_data(30000,30000);
%             
%             jitter = normrnd(0, sig(i), size(ts1));
%             add_spikes(neural_data, ts1+jitter);
% 
%             jitter = normrnd(0, sig(i), size(ts2));
%             add_spikes(neural_data, ts2+jitter);
%             
%             add_behavior(neural_data, pressure);
% 
%             % Add pressure times
%             neural_data.cycleTimes = ptimes;
% 
%             clearvars -except neural_data k i comparisons ptimes dtvw_spikedata sig MIs pressure
% 
% 
%             % Instantiate analysis object(s)
%             MI_ccb = calc_count_count_behav(neural_data, [1 2]);
%             MI_ccb.verbose = 1;
% 
% %             MI_ccb.sim_manager.par_mode = -1;
%             
%             buildMIs(MI_ccb, 5, MI_ccb.verbose);
% 
%             for j=1:size(MI_ccb.arrMIcore,1)
%                 MI_ccb.arrMIcore{j}.opt_k = 0;
%                 MI_ccb.arrMIcore{j}.k_values = 3;
%             end
% 
%             calcMIs(MI_ccb);
%             
%             MIs.(['sig' num2str(sig(i))]) = MI_ccb;
%             
%             disp(['done with sig = ' num2str(sig(i))]);
%         catch e
%             disp([newline '---> ERROR WITH Count-Count-Behav: Unit ' num2str(comparisons(k,1)) ' v Unit ' num2str(comparisons(k,2))]);
%             disp(e);
%         end
% 
%         disp(['----- DONE WITH Count-Count-Behav: Unit ' num2str(comparisons(k,1)) ' v Unit ' num2str(comparisons(k,2)) ' -----']); 
%     end
% 
%     fname = 'C:\Users\bpchung\Google Drive\_Research\__SOBER\__PROJECTS\Mutual Information\bl21lb21_171218_nmsort\mi_ccb.mat';
%     fname = strrep(fname, '.mat', ['_' num2str(comparisons(k,1)) '-' num2str(comparisons(k,2)) '_jitter.mat']);
%     save(fname, 'MIs');    
% end

%% TIMING-COUNT-BEHAV
comparisons = [1 1; 1 2; 1 3; 2 1; 2 2; 2 3; 3 1; 3 2; 3 3];

for k = 1:size(comparisons,1)
    MIs = struct();
    for i=1:length(sig)
        disp([newline '===== STARTING Timing-Count-Behav: Unit ' num2str(comparisons(k,1)) ' v Unit ' num2str(comparisons(k,2)) ' =====']);
%         try
            ts1 = dtvw_spikedata.(['Unit' num2str(comparisons(k,1))]).peak_times*1000.;
            ts2 = dtvw_spikedata.(['Unit' num2str(comparisons(k,2))]).peak_times*1000.;

            % Instantiate data object
            neural_data = mi_data(30000,30000);
            
            jitter = normrnd(0, sig(i), size(ts1));
            add_spikes(neural_data, ts1+jitter);

            jitter = normrnd(0, sig(i), size(ts2));
            add_spikes(neural_data, ts2+jitter);

            add_behavior(neural_data, pressure);
            
            % Add pressure times
            neural_data.cycleTimes = ptimes;

            clearvars -except neural_data k i comparisons ptimes dtvw_spikedata sig MIs pressure


            % Instantiate analysis object(s)
            MI_tcb = calc_timing_count_behav(neural_data, [1 2]);
            MI_tcb.verbose = 1;

            buildMIs(MI_tcb, 5, MI_tcb.verbose);

            MI_tcb.sim_manager.par_mode = -1;
            
            for j=1:size(MI_tcb.arrMIcore,1)
                MI_tcb.arrMIcore{j}.opt_k = 0;
                MI_tcb.arrMIcore{j}.k_values = 3;
            end

            calcMIs(MI_tcb);
            
            MIs.(['sig' num2str(sig(i))]) = MI_tcb;
            
            disp(['done with sig = ' num2str(sig(i))]);
%         catch e
%             disp([newline '---> ERROR WITH Timing-Count-Behav: Unit ' num2str(comparisons(k,1)) ' v Unit ' num2str(comparisons(k,2))]);
%             disp(e);
%         end

        disp(['----- DONE WITH Timing-Count-Behav: Unit ' num2str(comparisons(k,1)) ' v Unit ' num2str(comparisons(k,2)) ' -----']); 
    end

    fname = 'C:\Users\bpchung\Google Drive\_Research\__SOBER\__PROJECTS\Mutual Information\bl21lb21_171218_nmsort\mi_tcb.mat';
    fname = strrep(fname, '.mat', ['_' num2str(comparisons(k,1)) '-' num2str(comparisons(k,2)) '_jitter.mat']);
    save(fname, 'MIs');    
end

%% TIMING-TIMING-BEHAV
comparisons = [1 1; 1 2; 1 3; 2 2; 2 3; 3 3];

for k = 1:size(comparisons,1)
    MIs = struct();
    for i=1:length(sig)
        disp([newline '===== STARTING Timing-Timing-Behav: Unit ' num2str(comparisons(k,1)) ' v Unit ' num2str(comparisons(k,2)) ' =====']);
        try
            ts1 = dtvw_spikedata.(['Unit' num2str(comparisons(k,1))]).peak_times*1000.;
            ts2 = dtvw_spikedata.(['Unit' num2str(comparisons(k,2))]).peak_times*1000.;

            % Instantiate data object
            neural_data = mi_data(30000,30000);
            
            jitter = normrnd(0, sig(i), size(ts1));
            add_spikes(neural_data, ts1+jitter);

            jitter = normrnd(0, sig(i), size(ts2));
            add_spikes(neural_data, ts2+jitter);
            
            add_behavior(neural_data, pressure);

            % Add pressure times
            neural_data.cycleTimes = ptimes;

            clearvars -except neural_data k i comparisons ptimes dtvw_spikedata sig MIs pressure


            % Instantiate analysis object(s)
            MI_ttb = calc_timing_timing_behav(neural_data, [1 2]);
            MI_ttb.verbose = 1;

            buildMIs(MI_ttb, 5, MI_ttb.verbose);

            for j=1:size(MI_ttb.arrMIcore,1)
                MI_ttb.arrMIcore{j}.opt_k = 0;
                MI_ttb.arrMIcore{j}.k_values = 3;
            end

            calcMIs(MI_ttb);
            
            MIs.(['sig' num2str(sig(i))]) = MI_ttb;
            
            disp(['done with sig = ' num2str(sig(i))]);
        catch e
            disp([newline '---> ERROR WITH Timing-Timing-Behav: Unit ' num2str(comparisons(k,1)) ' v Unit ' num2str(comparisons(k,2))]);
            disp(e);
        end

        disp(['----- DONE WITH Timing-Timing-Behav: Unit ' num2str(comparisons(k,1)) ' v Unit ' num2str(comparisons(k,2)) ' -----']); 
    end

    fname = 'C:\Users\bpchung\Google Drive\_Research\__SOBER\__PROJECTS\Mutual Information\bl21lb21_171218_nmsort\mi_ttb.mat';
    fname = strrep(fname, '.mat', ['_' num2str(comparisons(k,1)) '-' num2str(comparisons(k,2)) '_jitter.mat']);
    save(fname, 'MIs');    
end