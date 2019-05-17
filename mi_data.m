classdef mi_data < handle
    %  MI_KSG_data is used to set up a data object with all of the data
    %  for a given recording session
    % WE MAY WANT TO CHANGE PROPERTY NAMES TO GENERIC VARIABLES
    properties
        neurons % cell array
                % 1 x N array of spike timing vectors- spike times in MS. 
                % where N is the number of neurons recorded during this session. 
        behavior % 1 x N vector of the continuous pressure where N is the total samples
        cycleTimes % {1 x 2} array with 1: 1 x N vector of onset times in MS of each breath cycle
                    % and 2: 1 x N vector of the peaks corresponding to the breathcycles
                    % where N is the total number of breath cycles
        Nbreaths % integer which indicates length of breathTimes
        bFs % sample frequency of pressure wave
        nFs % sample frequency of neural data  
    end

    methods
       function obj = mi_data(nFs,pFs)
           % This function documents the sample frequencies
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
       function add_params(varargin)
           % Specifies the parameters that will be used for the data. 
            if rem(varargin,2) ~= 0
                error('Expected nargin to be divisible by 2');
            end
            
       end
       
       function make_cycleTimes(obj,cycleFreq, cutoffFreq)
           % This function takes in raw behavioral data, applies a low pass filter
           % and identifies the onset of cycle times based on the
           % negative peaks. 
           % NOTE- this function does not deal with cycles that need to be
           % omitted. 
           % Set sample Frequency
           Fs = obj.bFs;
           if nargin < 2
               % Set default Cycle Frequency (Hz)
               cycleFreq = 2;
           end
           if nargin < 3
               % Set cutoff frequency (Hz)
               cutoffFreq = 10;
           end
           
           % Convert cycle frequency to Samples
           cycleLengthSeconds = 1/cycleFreq;
           cycleLengthSamples = cycleLengthSeconds*Fs;           

           % Convert cutoff freq to width of gaussian in samples
           cutoffSeconds = 1/cutoffFreq;
           cutoffSamples = cutoffSeconds*Fs;

           % Find alpha value for input into gausswin Function
           alpha = (cycleLengthSamples - 1)/(2*cutoffSamples);
           
           % Generate Gaussian Window
           g = gausswin(cycleLengthSamples,alpha);

           % Convolve the gaussian window with the behavior data
           behavhiorSmoothed = conv(obj.behavior,g,'same');

           % Find the negative peaks of the pressure cycles to determine the onset
           % times

           % We use the negative pressure vector to find negative peaks
           behaviorForPeaks = -1*behavhiorSmoothed;
           [pks, locs] = findpeaks(behaviorForPeaks,Fs, 'MinPeakDistance', cycleLengthSeconds/1.3);
           
           obj.cycleTimes = {locs,pks};
       end
       
       function [processedData] = processBehavior(obj, cycleFreq, filterFreq)
           % This function prepares the raw behavioral data for analysis
           % Both arguments are optional and have default values
           if nargin < 2
               cycleFreq = 2;
               filterFreq = 100;             
           elseif nargin < 3
               filterFreq = 100;
           end

           
           % Convert cycle freq to length of gaussian in samples
           cycleLengthSeconds = 1/cycleFreq;
           cycleLengthSamples = cycleLengthSeconds * obj.bFs;
           % Convert filter freq to width of gaussian in samples
           filterWinSeconds = 1/filterFreq;
           filterWinSamples = filterWinSeconds * obj.bFs;
           
           % Find alpha value for input to gaussian window function.
           alpha = (cycleLengthSamples - 1)/(2*filterWinSamples);
           
           % Generate the gaussian window for filter
           g = gausswin(cycleLengthSamples, alpha);
           
           processedData = conv(obj.behavior,g,'same');

       end

       function r = getTiming(obj, dataNum)
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
           % if verbose > 1; disp([newline 'Running: dataByCycles' newline]); end

           spike_ts = obj.neurons{dataNum};
           cycle_ts = obj.cycleTimes{1,1};

           % Find the number of spikes in each cycle
           cycle_spike_counts = obj.getCount(dataNum);

           % Calculate relative spike times for each breathing cycle
           % if verbose > 1; disp('-> Calculating relative spike times by cycle'); end
           cycle_spike_ts = nan(size(cycle_ts,1)-1, max(cycle_spike_counts));
           for cycle_ix = 1:(size(cycle_ts,1)-1)
               cycle_spikes_ix = find((spike_ts > cycle_ts(cycle_ix)) & (spike_ts < cycle_ts(cycle_ix+1)));
               if ~isempty(cycle_spikes_ix)
                   cycle_spike_ts(cycle_ix,1:length(cycle_spikes_ix)) = spike_ts(cycle_spikes_ix)-cycle_ts(cycle_ix);
               end
           end
           r = cycle_spike_ts;
       
       end
       
       function r = getCount(obj, dataNum)
           spike_ts = obj.neurons{dataNum};
           cycle_ts = obj.cycleTimes{1,1};

           % Find the number of spikes in each cycle
           % We include data that comes after the onset of the first cycle
           % and before the onset of the last cycle
           cycle_spike_counts = zeros(1,size(cycle_ts,1)-1);
           for cycle_ix = 1:(size(cycle_ts,1)-1)
               cycle_spikes_ix = find((spike_ts > cycle_ts(cycle_ix)) & (spike_ts < cycle_ts(cycle_ix+1)));
               if ~isempty(cycle_spikes_ix)
                 cycle_spike_counts(cycle_ix) = length(cycle_spikes_ix);
               end
           end
           r = cycle_spike_counts;
       end
       
       
       function r = behaviorByCycles(obj, behaviorSpec, desiredLength, startPhase, residual, windowOfInterest)
           % behaviorSpec - 'phase' or 'time' - indicating whether you want
           % to include pressure as a phase or time variable
           % desiredLength- the number of pressure dimensions you want to
           % include. 
%------------RC MOVED TO ANALYSIS SUBCLASSES---------------------
%            % Specify default parameters
%            if nargin < 2
%                behaviorSpec = 'phase';
%                desiredLength = 11;
%                startPhase = .8*pi;
%                residual = true; 
%            elseif nargin < 3
%                desiredLength = 11;
%                startPhase = .8*pi;
%                residual = true;
%            elseif nargin < 4
%                startPhase = .8*pi;
%                residual = true; 
%            elseif nargin < 5
%                residual = true;
%            end
% --------------------------------------------------------------
           
           % Find cycle onset times
           cycle_times = obj.cycleTimes{1,1};
           % Convert from onset times in seconds to samples
           cycle_samples = ceil(cycle_times .* obj.bFs);
           % Find the length of each cycle
           cycle_lengths = diff(cycle_samples);
           % Find the start time in samples from the onset of each cycle
           start_offset = ceil(cycle_lengths.*(startPhase/(2*pi)));
           % Find the start time for each cycle from the beginning of the
           % recording
           start_sample = cycle_samples(1,1:end-1) + start_offset;
           
           % Process Pressure Waves
           processedData = processBehavior(obj);
                               
           % Choose phase or time sequence
           switch(behaviorSpec)
               case('phase')   
                   % Specify default parameter
                   if nargin < 6
                       windowOfInterest = pi;
                   end
                   
                   % Find lengths of windowOfInterest
                   windowOfInterest_samples = ceil((windowOfInterest.*cycle_lengths)./(2*pi));
                   
                   % Find the offset time for each cycle from the beginning
                   % of the recording
                   stop_sample = start_sample + windowOfInterest_samples;
                   
                   % Set up empty matrix to store pressure data.
                   nCycles = length(cycle_lengths);
                   cycle_behavior = nan(nCycles, desiredLength);
                                                          
                   % Fill in cycles
                   for cycle_ix = 1:nCycles
                       % Document all of the data points for the window of
                       % interest
                       cycle_data = processedData(start_sample(cycle_ix):stop_sample(cycle_ix));
                       % Resample to get only the desired number of points
                       resampled_cycle_data = resample(cycle_data,desiredLength,length(cycle_data));
                       cycle_behavior(cycle_ix, 1:desiredLength) = resampled_cycle_data;   
                   end
                   r = cycle_behavior;
                   
               case('time')
                   if nargin< 6
                       windowOfInterest = 150;
                   end
                   
                   % Find lengths in samples of windowOfInterest
                   windowOfInterest_seconds = windowOfInterest/1000;
                   windowOfInterest_samples = windowOfInterest_seconds*obj.bFs;
                   
                   % Find the offset time for each cycle from the beginning
                   % of the recording
                   stop_sample = start_sample + windowOfInterest_samples;
                   
                   % Set up empty matrix to store pressure data.
                   nCycles = length(cycle_lengths);
                   cycle_behavior = nan(nCycles, desiredLength);
                   
                   % Fill in cycles
                   for cycle_ix = 1:nCycles
                       % Document all of the data points for the window of
                       % interest
                       cycle_data = processedData(start_sample(cycle_ix):stop_sample(cycle_ix));
                       % Resample to get only the desired number of points
                       resampled_cycle_data = resample(cycle_data,desiredLength,length(cycle_data));
                       cycle_behavior(cycle_ix, 1:desiredLength) = resampled_cycle_data;   
                   end
                   r = cycle_behavior;
           end
           if residual
               r = obj.get_behavior_residuals(r);
           end
       end
       function r = get_behavior_residuals(obj, data_cycles)
           % FOR NOW this function averages the pressure wave across the
           % entire data set. We will need to adjust the averaging window.
           % It is unclear how best to implement a sliding averaging
           % window consistently across the whole data set. 
           average_behavior = mean(data_cycles,1);
           data_residuals = data_cycles - average_behavior;
           r = data_residuals;
           
           
       end
           
   
    end
end
    
