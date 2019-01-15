classdef MI_KSG_data
    %  MI_KSG_data is used to set up a data object with all of the data
    %  for a given recording session
    % WE MAY WANT TO CHANGE PROPERTY NAMES TO GENERIC VARIABLES
    properties
        neurons % 1 x N array of spike timing vectors- spike times in MS. 
                % where N is the number of neurons recorded during this session. 
        pressure % 1 x N vector of the continuous pressure where N is the total samples
        breathTimes % 1 x N vector of onset times in MS of each breath cycle
                    % where N is the total number of breath cycles
        Nbreaths % integer which indicates length of breathTimes
        pFs % sample frequency of pressure wave
        nFs % sample frequency of neural data  
    end

    methods
       function obj = MI_KSG_data(dataFileName, nFs,pFs)
      % This function loads the spiking data raw pressure data and documents the sample frequencies
      % Note that I need to add the proper functions once Bryce sends me his code
          obj.neurons = neurons;
          obj.behavior = pressure;
          obj.cycleTimes = cycle_ts;
          obj.Ncycles = sum(cycle_ts, [INSERT DIMENSION]); 
          obj.bFs = pFs;
          obj.nFs = nFs;

       end

       function r = getTiming(dataNum, verbose)
	 % Makes matrices of pressure data  need to decide what units to use and spiking data based on what we have      
     % NOTE- currently as the code is written, we omit any neural or pressure data that occurs	 
     % before the onset of the first cycle or after the onset of the last cycle
	 %  - additionally, we are segmenting spikes based on the cycle times rather than trying
	 % to keep bursts together and using negative spike times 
	 %
	 % INPUT
	 % dataNum : positive integer neuron number to specify neuron of interest
	 %
         % Return an m x n matrix of data with m cycles and n sample points (if pressure) 
         % or n maximum spikes (if neuron data) 
	 %
	   if verbose
           disp([newline 'Running: dataByCycles' newline]);
       end
	   neuron = obj.neurons{1,dataNum};
	   cycle_ts = obj.cycleTimes;


         % Find the number of spikes in each cycle

        for cycle_ix = 1:(size(cycle_ts,1)-1)
        cycle_spikes_ix = find((spike_ts > cycle_ts(cycle_ix)) & (spike_ts < cycle_ts(cycle_ix+1)));
            if length(cycle_spikes_ix) > 0
              cycle_spike_counts(cycle_ix) = length(cycle_spikes_ix);
            else
              cycle_spike_counts(cycle_ix) = 0;
            end
        end
	   
       % Calculate relative spike times for each breathing cycle
         if verbose > 1
             disp('-> Calculating relative spike times by cycle');
         end
         cycle_spike_ts = nan(size(cycle_ts,1)-1,max(cycle_spike_counts));
         for cycle_ix = 1:(size(cycle_ts,1)-1)
             cycle_spikes_ix = find((spike_ts > cycle_ts(cycle_ix)) & (spike_ts < cycle_ts(cycle_ix+1)));
             if length(cycle_spikes_ix) > 0
                 cycle_spike_ts(cycle_ix,1:length(cycle_spikes_ix)) = spike_ts(cycle_spikes_ix)-cycle_ts(cycle_ix);
             end
         end
	     r = cycle_spike_ts;
       
       end
       
       function r = getCount(dataNum, verbose)
           r = getTiming(dataNum,verbose);
           r = sum(~isnan(r));
       end
       function r = getPressure(verbose)
           %NOTE We may want to 
           % Converts from single pressure vector to matrix separated by
           % cycles
            % Convert cycle times from ms to samples
         cycle_samples = obj.cycleTimes;
         cycle_samples = cycle_samples./1000;
         cycle_samples = cycle_samples .* obj.pFs;
         cycle_lengths = diff(cycle_samples);
         p = obj.behavior;
         cycle_pressure = nan(size(cycle_samples,1) -1,max(cycle_lengths));
         for cycle_ix = 1:size(cycle_samples,1)-1
            cycle_pressure_wave(cycle_ix,1:cycle_lengths(cycle_ix)) = p(cycle_samples(cycle_ix):cycle_samples(cycle_ix+1));
         end
          r = cycle_pressure_wave;
        end
	

    end
end
    
