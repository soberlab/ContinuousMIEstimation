classdef mi_data < handle
    %  MI_KSG_data is used to set up a data object with all of the data
    %  for a given recording session
    % WE MAY WANT TO CHANGE PROPERTY NAMES TO GENERIC VARIABLES
    properties
        neurons % cell array
                % 1 x N array of spike timing vectors- spike times in MS. 
                % where N is the number of neurons recorded during this session. 
        n_timebase % either 'phase' or 'time'
        behavior % N x n vector of the continuous pressure where N is the total cycles and n is the maximum 
                 % number of samples per cycle
        cycleTimes % {1 x 2} array with 1: 1 x N vector of onset times in seconds of each breath cycle
                    % and 2: 1 x N vector of the peaks corresponding to the breathcycles
                    % where N is the total number of breath cycles 
        b_timebase % either 'phase' or 'time'
        b_Length % An integer to indicate number of points to keep for each behavioral cycle
        b_startPhase % either a radian angle or a time in ms indicating to relativel time/phase
                   % to document the behavior relative to the cycle onset
                   % time. This must be in the same units as b_timebase
        b_dataTransform % either 'none, 'pca', or 'residual' - THIS CAN BE ADDED TO
        % RC: 05182019- do we use Nbreaths?        
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
           % Set properties to empty arrays temporarily 
           obj.neurons = {};
           obj.n_timebase = {};
           obj.behavior = {};
           obj.cycleTimes = {};
           obj.b_timebase = {};
           obj.b_Length = {};
           obj.b_startPhase = {};
           obj.b_dataTransform = {};
       end
       
       function add_spikes(obj, spike_times, varargin)                 
           % BC-20190123: Can add an index to neurons for explicit tracking
           % across classes?
           % RC: 20190517: Not sure what this would look like...

           % Set default optional parameter value
           default_n_timebase = 'time';
           validate_n_timebase = @(x) assert(ismember(x,{'time','phase'}),'timebase must be either phase or time');
           
           % Set up inputParser
           p = inputParser;
           % SpikeTimes are required if they haven't been specified
           if isempty(obj.neurons)
               p.addRequired('spike_times');
               p.parse(spike_times);
               
           elseif ~isempty(obj.neurons)
               p.addOptional('spike_times',[]);
               p.parse(spike_times);
           end

           % Add a set of spike times to object unless the spikes weren't
           % specified
           if ~isempty(spike_times)
               obj.neurons{end+1} = spike_times;
           end
           
           % Determine n_timebase has been set
           if isempty(obj.n_timebase)
               % If n_timebase has not been defined yet, set it to the
               % default or specified value
               p.addParameter('timebase',default_n_timebase,validate_n_timebase)
           elseif ~isempty(obj.n_timebase)
               % If n_timebase has been defined, the default is the
               % pre-assigned value, and it should only change if timebase
               % is an input. 
               p.addParameter('timebase',obj.n_timebase,validate_n_timebase);
           end
           p.parse(spike_times);
           obj.n_timebase = p.Results.timebase;

       end
       
       function add_behavior(obj, behavior, cycleFreq, cutoffFreq, filterFreq, varargin)
            p = inputParser;
            if isempty(obj.behavior)
               % Behavior input is required if it has not been defined yet.
               p.addRequired('behavior');
            elseif ~isempty(obj.behavior)
               % If the behavior is already specified for the object, then
               % it defaults to the pre-set value, and the input is not
               % necessary.
               p.addOptional('behavior',obj.behavior);
            end

            % Convert behavior to cycles if its not already in cycles
            if size(behavior,1) == 1

                % Set optional inputs relevant for obtaining cycle times
                p.addOptional('cycleFreq',2);
                p.addOptional('cutoffFreq',10);
                p.addOptional('filterFreq', 100)
                parse(p,behavior);            
% --------------Consider making this into a separate function-----------
                % Add cycle times to object. 
                obj.cycleTimes = obj.make_cycleTimes(behavior, p.Results.cycleFreq, p.Results.cutoffFreq);

               % Find cycle onset times
               cycle_times = obj.cycleTimes{1,1};
               % Convert from onset times in seconds to samples
               cycle_samples = ceil(cycle_times .* obj.bFs);
               % Find the length of each cycle
               cycle_lengths = diff(cycle_samples);

               % Find maximum cycle length
               maxLength = max(cycle_lengths);

               % Find total number of cycles
               nCycles = length(cycle_lengths);

               % Make an NaN matrix to hold cycle data. 
               behaviorCycles = nan(nCycles,maxLength);

               % Filter Pressure Waves
               filterData = obj.filterBehavior(behavior, p.Results.cycleFreq,p.Results.filterFreq);

                % Assign pressure waves to matrix rows
                for iCycle = 1:nCycles
                    behaviorCycles(iCycle,1:cycle_lengths(iCycle)) = behavior(cycle_samples(iCycle):(cycle_samples(iCycle+1)-1));
                end
%-----------------------------------------------------------------------
                % Store behavior
                obj.behavior = behaviorCycles;
            end
            

            % Set behavioral property defaults
            default_b_timebase = 'phase';
            validate_b_timebase = @(x) assert(ismember(x,{'phase','time'}), 'timebase must be either phase or time');
            default_b_Length = 11;
            validate_b_Length = @(x) assert(isinteger(x),'length must be an integer value');
            default_b_startPhase = .8*pi;
            default_b_dataTransform = 'residual'; 
            validate_b_dataTransform = @(x) assert(ismember(x,{'none','residual','pca'}), 'dataTransform must be none, residual, or pca');

            % Set behavior timebase value
            if isempty(obj.b_timebase)
                % set n_timebase to default or inputed value
                p.addParameter('timebase',default_b_timebase, validate_b_timebase);
            elseif ~isempty(obj.b_timebase)
                % overwrite current n_timebase setting only if the value is
                % inputted
                p.addParameter('timebase',obj.b_timebase, validate_b_timebase);
            end
            p.parse(behavior,varargin{:});
            % Set behavior timebase property
            obj.b_timebase = p.Results.timebase;

            % Set behavior length 
            if isempty(obj.b_Length)
                % set b_Length to default or inputed value
                p.addParameter('Length',default_b_Length, validate_b_Length);
            elseif ~isempty(obj.b_Length)
                % overwrite current b_Length setting only if the value is
                % inputted
                p.addParameter('Length',obj.b_Length, validate_b_Length);
            end


            % Set behavior Length property
            p.parse(behavior,varargin{:});
            obj.b_Length = p.Results.Length;

            % Set behavior startPhase 
            % Adjust startPhase validation depending on timebase property
            if obj.b_timebase == 'phase'
                validate_b_startPhase = @(x) assert(0 <= x && x < 2*pi,'startPhase units must be in radians to match timebase');
            elseif obj.b_timebase == 'time'
                validate_b_startPhase = @(x) assert(isinteger(x) && x >= 0,'startPhase units must be a positive integer in milliseconds to match timebase');
            end
            % Set behavior startPhase
            if isempty(obj.b_startPhase)
                % set n_startPhase to default or inputed value
                p.addParameter('startPhase',default_b_startPhase, validate_b_startPhase);
            elseif ~isempty(obj.b_startPhase)
                % overwrite current b_startPhase setting only if the value is
                % inputted
                p.addParameter('startPhase',obj.b_startPhase, validate_b_startPhase);
            end
            % Set behavior startPhase property
            p.parse(behavior,varargin{:});
            obj.b_startPhase = p.Results.startPhase;

            % Set behavior dataTransform
            if isempty(obj.b_dataTransform)
                % set n_dataTransform to default or inputed value
                p.addParameter('dataTransform',default_b_dataTransform, validate_b_dataTransform);
            elseif ~isempty(obj.b_dataTransform)
                % overwrite current b_dataTransform setting only if the value is
                % inputted
                p.addParameter('dataTransform',obj.b_dataTransform, validate_b_dataTransform);
            end
            % Set behavior startPhase property
            p.parse(behavior,varargin{:});
            obj.b_dataTransform = p.Results.dataTransform;

       end
       
       function [Times] = make_cycleTimes(obj, behavior, cycleFreq, cutoffFreq)
           % This function takes in raw behavioral data, applies a low pass filter
           % and identifies the onset of cycle times based on the
           % negative peaks. 
           % NOTE- this function does not deal with cycles that need to be
           % omitted. 
           % Set sample Frequency
           Fs = obj.bFs;
           
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
           behaviorSmoothed = conv(behavior,g,'same');

           % Find the negative peaks of the pressure cycles to determine the onset
           % times

           % We use the negative pressure vector to find negative peaks
           behaviorForPeaks = -1*behaviorSmoothed;
           [pks, locs] = findpeaks(behaviorForPeaks,Fs, 'MinPeakDistance', cycleLengthSeconds/1.3);
           
           % BC 20190515: struct may come with additional overheadx
           % RC 20190520: I don't remember how we wanted to change this...
           Times = {locs,pks};
           obj.cycleTimes = Times;

       end
       
       function [filterData] = filterBehavior(obj, behavior, cycleFreq, filterFreq)
           % This function prepares the raw behavioral data for analysis
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
           
           filterData = conv(behavior,g,'same');

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
       
       
       % BC 20190515: change to get_behavior
       % BC 20190515: All analysis classes will only need to call three
       % class methods: get_count, get_timing, get_behavior
       function r = behaviorByCycles(obj, behaviorSpec, desiredLength, startPhase, residual, windowOfInterest)
           % behaviorSpec - 'phase' or 'time' - indicating whether you want
           % to include pressure as a phase or time variable
           % desiredLength- the number of pressure dimensions you want to
           % include. 

                               
           % Choose phase or time sequence
           switch(behaviorSpec)
               case('phase')   
                   % BC 20190515: Return behavior as.....
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
                   % BC 20190515: Return behavior as ...
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
       
       % BC 20190515: move this to get_behaviorbycycles function
       % BC 20190515: analysis classes only see get_behaviorbycycles
       % function call and then a parameter specifies "resid" or "wave"
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
    
