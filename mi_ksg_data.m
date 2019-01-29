classdef mi_ksg_data < handle
    %  MI_KSG_data is used to set up a data object with all of the data
    %  for a given recording session
    % WE MAY WANT TO CHANGE PROPERTY NAMES TO GENERIC VARIABLES
    properties
        neurons % cell array
                % 1 x N array of spike timing vectors- spike times in MS. 
                % where N is the number of neurons recorded during this session. 
        behavior % 1 x N vector of the continuous pressure where N is the total samples
        cycleTimes % 1 x N vector of onset times in MS of each breath cycle
                    % where N is the total number of breath cycles
        Nbreaths % integer which indicates length of breathTimes
        bFs % sample frequency of pressure wave
        nFs % sample frequency of neural data  
    end

    methods
       function obj = mi_ksg_data(nFs,pFs)
           % This function loads the spiking data raw pressure data and documents the sample frequencies
           % Note that I need to add the proper functions once Bryce sends me his code  
           if nargin > 0
               obj.bFs = pFs;
               obj.nFs = nFs;
           end
           
           obj.neurons = {};
       end
       
       function add_spikes(obj, spike_times)
           % BC-20190123: Added function
           obj.neurons{end+1} = spike_times;
           
           % BC-20190123: Can add an index to neurons for explicit tracking
           % across classes?
       end
       
       function add_behavior(obj, behavior)
           % BC-20190123: Added function
           obj.behavior = behavior;
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
           if verbose > 1; disp([newline 'Running: dataByCycles' newline]); end

           spike_ts = obj.neurons{dataNum};
           cycle_ts = obj.cycleTimes;

           % Find the number of spikes in each cycle
           cycle_spike_counts = getCount(dataNum, verbose);

           % Calculate relative spike times for each breathing cycle
           if verbose > 1; disp('-> Calculating relative spike times by cycle'); end
           cycle_spike_ts = nan(size(cycle_ts,1)-1, max(cycle_spike_counts));
           for cycle_ix = 1:(size(cycle_ts,1)-1)
               cycle_spikes_ix = find((spike_ts > cycle_ts(cycle_ix)) & (spike_ts < cycle_ts(cycle_ix+1)));
               if ~isempty(cycle_spikes_ix)
                   cycle_spike_ts(cycle_ix,1:length(cycle_spikes_ix)) = spike_ts(cycle_spikes_ix)-cycle_ts(cycle_ix);
               end
           end
           r = cycle_spike_ts;
       
       end
       
       function r = getCount(dataNum, verbose)
           spike_ts = obj.neurons{dataNum};
           cycle_ts = obj.cycleTimes;

           % Find the number of spikes in each cycle
           cycle_spike_counts = zeros(1,size(cycle_ts,1));
           for cycle_ix = 1:(size(cycle_ts,1)-1)
               cycle_spikes_ix = find((spike_ts > cycle_ts(cycle_ix)) & (spike_ts < cycle_ts(cycle_ix+1)));
               if ~isempty(cycle_spikes_ix)
                 cycle_spike_counts(cycle_ix) = length(cycle_spikes_ix);
               end
           end
           r = cycle_spike_counts;
       end
       
       function r = getPressure(desiredLength, verbose)
           % desiredLength- the number of pressure dimensions you want to
           % include. 

           %NOTE We may want to run PCA or something else on the pressure
           %waves.
           % Currently this code resamples pressure data so that pressure
           % data all the same length- meaning that we look at pressure
           % values at consistent phases within the cycle. The user can
           % specify the length. In Kyle's analysis, they take this a step
           % further by looking at residual pressure. We can add that if we
           % want. 
           % Converts from single pressure vector to matrix separated by
           % cycles
           % Convert cycle times from ms to samples
            
           cycle_times = obj.cycleTimes;
           cycle_seconds = cycle_times./1000;
           cycle_samples = cycle_seconds .* obj.pFs;
           cycle_lengths = diff(cycle_samples);
           
           p = obj.behavior;
           
           nCycles = length(cycle_lengths);
           cycle_pressure_wave = nan(nCycles, desiredLength);
           
           for cycle_ix = 1:size(cycle_samples,1)-1
               cycle_pressure = p(cycle_samples(cycle_ix):cycle_samples(cycle_ix+1));
               resampled_cycle_pressure = resample(cycle_pressure,desiredLength,cycle_lengths(cycle_ix));
               cycle_pressure_wave(cycle_ix, 1:desiredLength) = resampled_cycle_pressure;
           end
           r = cycle_pressure_wave;
       end
    end
end
    
