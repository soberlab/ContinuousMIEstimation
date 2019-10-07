classdef mi_data_pressure < mi_data_behavior
    %    
    % Class defined to load and process data from Intan RHD files for
    % air pressure assuming that the air pressure is recorded in the
    % board_adc channel
    %
   properties
       
   end
   methods
        function set_source(obj, obj_files)
            %% takes a struct array of data files
            obj.raw_source = obj_files; 
        end
        
        function calc_cycles(obj, method)
            %% take raw pressure data, segment into cycles, save MAT file, calc onset times
            
            % Need to add Parser input to validate method
            obj.cycleMethod = method;
            
            cycle_wavs = [];
            for i=1:length(obj.raw_source)
                if obj.verbose > 0
                    disp('===== ===== ===== ===== =====');
                    disp(['Processing file ' num2str(i) ' of ' num2str(length(obj.raw_source))]);
                    disp(['File: ' obj.raw_source(i).folder '\' obj.raw_source(i).name]);
                end
                [pressure_ts pressure_wav] = read_Intan_RHD2000_nongui_adc([obj.raw_source(i).folder '\' obj.raw_source(i).name], obj.verbose);
                
                % use RC's low pass filter
                % Convolve the gaussian window with the behavior data
                behav_smooth = smoothdata(pressure_wav, 'gaussian', 1024); % provides best local smoothing by trial and error

                cycle_ixs = [];
                if strcmp(obj.cycleMethod, 'threshold');
                    cycle_thresh = (max(behav_smooth) - min(behav_smooth))*0.25 + min(behav_smooth); % use 25% of waveform amplitude to trigger cycle onsets
                    cycle_ixs = find(diff(sign(behav_smooth-cycle_thresh)) == 2);
                    cycle_ixs = cycle_ixs(2:end-1); % automatically drop first and last due to impartial cycles

                    % scrub cycles for too short or too long
                    cycle_len = diff(cycle_ixs);
                    
                    bad_cycle = find(isoutlier(cycle_len)==1);
                    if obj.verbose > 1; disp(['--> Dropping ' num2str(length(bad_cycle)) ' cycles!']); end
                    
                    if ~isempty(bad_cycle)
                        cycle_ixs(bad_cycle) = [];
                        cycle_len(bad_cycle) = [];
                    end
                    
                    % plot resulting behavior cycles to visualize analysis
                    if obj.verbose > 2
                        figure();
                        plot(pressure_ts, pressure_wav, 'k-', 'LineWidth', 2);
                        hold on;
                        plot(pressure_ts, behav_smooth, 'g-');
                        plot(pressure_ts([1 end]), [cycle_thresh cycle_thresh], 'r-');
                        scatter(pressure_ts(cycle_ixs), behav_smooth(cycle_ixs), 80, 'r', 'filled');
                    end
                end
            
                % populate data structures
                tmp_cycle_wavs = nan(length(cycle_ixs), max(cycle_len));   
                
                % matrix for current data file
                for j=1:length(cycle_ixs)
                    if j < length(cycle_ixs)
                        wav_len = min(cycle_ixs(j+1) - cycle_ixs(j), size(tmp_cycle_wavs,2)); % pull waveform duration matching length of dataset
                    else
                        wav_len = min(size(pressure_wav,2) - cycle_ixs(j), size(tmp_cycle_wavs,2));
                    end
                   tmp_cycle_wavs(j,1:wav_len) = pressure_wav(cycle_ixs(j):cycle_ixs(j)+wav_len-1);
                end
                
                % add data to full dataset
                obj.cycleTimes = horzcat(obj.cycleTimes, pressure_ts(cycle_ixs));
            
                if size(cycle_wavs,2) > size(tmp_cycle_wavs,2)
                    nCols = size(cycle_wavs,2)-size(tmp_cycle_wavs,2);
                    tmp_cycle_wavs(:,end+1:end+nCols) = nan(size(tmp_cycle_wavs,1), nCols);
                elseif size(cycle_wavs,2) < size(tmp_cycle_wavs,2)
                    nCols = size(tmp_cycle_wavs,2)-size(cycle_wavs,2);
                    cycle_wavs(:,end+1:end+nCols) = nan(size(cycle_wavs,1), nCols);
                end
                cycle_wavs(end+1:end+size(tmp_cycle_wavs,1),:) = tmp_cycle_wavs;
                
                disp('');
            
            end
            
            % save data in object
            obj. cycleData = cycle_wavs;
        end
        
        function r = get_feature(obj, format)
            %% Implemented to return different features of behavior cycles
            % i.e., raw data, PCA, residual, area
           
            switch(format)
                case('raw')
                    % need to implement from RC's code
                case('phase')
                    % need to implement from RC's code                    
            end
            
        end       
   end    
end