% Find peak of spikes

plot_flag = false;

Intan_Fs = 30000;
DataView_SamplingInterval = 0.0333;

fnames = dir('*.rhd');   

disp('Loading DataView spike data...');
dtvw_spikedata.Unit1 = load('D:/EMG_Data/chung/for_analysis/bl21lb21_20171218/bl21lb21_trial1_ch1_ch16/bl21lb21_171218_spikedata-0003-CH8.mat');
dtvw_spikedata.Unit1.CH = 8;
dtvw_spikedata.Unit1.peak_times = [];

dtvw_spikedata.Unit2 = load('D:/EMG_Data/chung/for_analysis/bl21lb21_20171218/bl21lb21_trial1_ch1_ch16/bl21lb21_171218_spikedata-0002-CH5.mat');
dtvw_spikedata.Unit2.CH = 5;
dtvw_spikedata.Unit2.peak_times = [];

dtvw_spikedata.Unit3 = load('D:/EMG_Data/chung/for_analysis/bl21lb21_20171218/bl21lb21_trial1_ch1_ch16/bl21lb21_171218_spikedata-0001-CH4.mat');
dtvw_spikedata.Unit3.CH = 1;
dtvw_spikedata.Unit3.peak_times = [];

dtvw_spikedata.Unit4 = load('D:/EMG_Data/chung/for_analysis/bl21lb21_20171218/bl21lb21_trial1_ch1_ch16/bl21lb21_171218_spikedata-0004-CH1.mat');
dtvw_spikedata.Unit4.CH = 1;
dtvw_spikedata.Unit4.peak_times = [];

dtvw_spikedata.Unit5 = load('D:/EMG_Data/chung/for_analysis/bl21lb21_20171218/bl21lb21_trial1_ch1_ch16/bl21lb21_171218_spikedata-0005-CH1.mat');
dtvw_spikedata.Unit5.CH = 1;
dtvw_spikedata.Unit5.peak_times = [];



spike_units = fieldnames(dtvw_spikedata);
%spike_units = {'Unit5'};

exit_flag = false;
for ix_fname = 1:length(fnames)
    fname = fnames(ix_fname).name;
    disp([newline, newline, 'Loading Intan file: ', fname]);
    [t_amplifier, t_board_adc, amplifier_data, frequency_parameters] = read_Intan_RHD2000_nongui(fname);
    
    t_start = t_amplifier(1);
    t_end = t_amplifier(end);
    
    % Calculate offset due to rounding of sampling inteval in DataView
    % i.e., Intan time scaled to DataView time
    % 2 ms in Intan = 1.998 ms in DataView
    ix_adjustment = round(mod(1,DataView_SamplingInterval)*t_amplifier(1)/DataView_SamplingInterval*(Intan_Fs*DataView_SamplingInterval));
    
    for ix_unit = 1:length(spike_units)
        spike_ontimes = dtvw_spikedata.(spike_units{ix_unit}).spikedata.ts(:,1);
        spike_durs = dtvw_spikedata.(spike_units{ix_unit}).spikedata.ts(:,2);
        chan = dtvw_spikedata.(spike_units{ix_unit}).CH;

        peak_times = dtvw_spikedata.(spike_units{ix_unit}).peak_times;
        
        if length(chan) == 1
            wav = bandpass_filtfilt(amplifier_data(chan,:), Intan_Fs, 300, 7500, 'hanningfir');
        elseif length(chan) == 2
            wav = bandpass_filtfilt(amplifier_data(chan(2),:)-amplifier_data(chan(1),:), Intan_Fs, 300, 7500, 'hanningfir');
        else
            error('!! Invalid channel number type !!');
        end
        
        first_spike = find(spike_ontimes >= t_start);
        if length(first_spike) > 0
            first_spike = first_spike(1);
        else
            first_spike = 1;
        end
        
        last_spike = find(spike_ontimes <= t_end);
        if length(last_spike) > 0
            last_spike = last_spike(end);
        else
            last_spike = -1;
        end
        
        if last_spike < 0
            search_spikes = spike_ontimes(first_spike:end);
        else
            search_spikes = spike_ontimes(first_spike:last_spike);
        end

        if length(search_spikes) == 0
            continue;
        end
        
        disp('Processing spike peaks...');
        
        for ix_spike = 1:length(search_spikes)
            t1_ix = round((search_spikes(ix_spike)-t_amplifier(1))*1000/DataView_SamplingInterval)+ix_adjustment;
            t_window = round(spike_durs(ix_spike)*30);
        
            %if strcmp(spike_units{ix_unit}, 'Unit3')
%             if (strfind(fnames(ix_fname).name, '125731') > 0) & ix_spike == 348
%                 disp('hello');
%             end
            
            % Catches indexing errors due to scaling of time between Intan
            % and DataView -- should only affect no more than the first or
            % last event in a data file
            if (t1_ix < 1) | (t1_ix+t_window > length(t_amplifier))
                continue;
            end
            
            spike_wav = wav(t1_ix:t1_ix+t_window);
            [pks locs] = findpeaks(spike_wav); % Find all peaks in spike window
            max_pk = max(pks); % Use the tallest peak
            max_ix = find(pks == max_pk);
            
            peak_times = [peak_times t_amplifier(t1_ix+locs(max_ix))];
            
        end
        dtvw_spikedata.(spike_units{ix_unit}).peak_times = peak_times;
        
        if plot_flag
            figure;
            plot(t_amplifier, wav);
            hold on;
            yrange = get(gca, 'YLim');
            scatter(peak_times, ones(length(peak_times), 1)*0.9*max(yrange), 'kd');

            user_cont = input('Continue? [Y]/N (P to enter breakpoint)', 's');
            if strcmp(user_cont, 'n') | strcmp(user_cont, 'N')
                exit_flag = true;
                break;
            elseif strcmp(user_cont, 'p') | strcmp(user_cont, 'P')
                disp('User prompted script break...');            
            end
        
            close();
        end
    end
    if exit_flag
        break;
    end
end