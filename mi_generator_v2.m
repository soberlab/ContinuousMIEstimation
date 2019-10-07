
classdef mi_generator_v2 < handle
    % This file will contain the data generator class 
    % to synthesize data based on various ISI distributions
    
    properties
        cycleFreq % Default: 1.76 -average breath cycle frequency from some data
        b_noiseAmplitude 
        b_amplitude % Default: 11258 - averge breath cycle amplitude from some data
        smoothingWindow
        n_targetSNR
        Fs
        
    end
    methods
        function obj = mi_generator_v2(varargin)
            
            % Set up inputParser
            p = inputParser;           
           
            % Set default cycleFreq from data
            default_cycleFreq = 1.76;
            
            % Set default b_amplitude from data
            default_b_amplitude = 11258;
            
            %Set default sampleFreq from data
            default_Fs = 30000;
            
            % Set default smoothingWindow
            default_smoothingWindow = 4;
            
            % Add optional inputs
            p.addOptional('cycleFreq',default_cycleFreq);
            
            %Parse cycleFreq
            p.parse();
            obj.cycleFreq = p.Results.cycleFreq;
            
            % Parse b_amplitude
            p.addOptional('b_amplitude',default_b_amplitude);
            p.parse();
            obj.b_amplitude = p.Results.b_amplitude;
            
            % Parse sampleFreq
            p.addOptional('Fs',default_Fs);
            p.parse();
            obj.Fs = p.Results.Fs;  
            
            % Parse smoothingWindow
            p.addOptional('smoothingWindow', default_smoothingWindow)
            p.parse();
            obj.smoothingWindow = p.Results.smoothingWindow;
            
        end
        
        function [cycles] = makeCycles(obj,nCycles)
            
            % Convert nCycles to samples
            nSeconds = (1/obj.cycleFreq)*nCycles;
            nSamples = nSeconds*obj.Fs;
            
            % Make time vector
            timeSamples = 1:nSamples;
            timeSeconds = timeSamples/obj.Fs;
            
            % Make behavior cycles
            cycles = obj.b_amplitude*sin(2*pi*obj.cycleFreq.*timeSeconds);
            
        end
        
        function [spikes] = makeSpikes(obj,nCycles, nNeurons, varargin)
            % This generates spike times that encode lung pressure with a
            % rate code
            
            % Set up inputParser
            p = inputParser;           
           
            % Set default scale factor for poisson rate
            default_rateScaleFactor = 20;
            
            % Add optional input
            p.addOptional('rateScaleFactor',default_rateScaleFactor);
            
            %Parse cycleFreq
            p.parse();
            rateScaleFactor = p.Results.rateScaleFactor;
            
            % Make cycles
            cycles = makeCycles(obj,nCycles);
            
            % Expiratory muscle should be active when pressure is large.
            poissonRate = cycles;
            
            % Find min  poisson rate to normalize:
            minRate = min(poissonRate);
            
            % Make the rate positive or zero
            negIdx_poissonRate = find(poissonRate < 0);
            poissonRatePositive = poissonRate;
            poissonRatePositive(negIdx_poissonRate) = 0;
            
            % Find max rate
            maxRate = max(poissonRatePositive);
            
            % Normalize rate
            poissonRateNormalized = poissonRatePositive./maxRate;
            
            % Optional: modify rate by a scale factor
            poissonRateScaled = poissonRateNormalized*rateScaleFactor;
            
            % Generate probability of spike in ms bins 
            spikeProbVector = resample(poissonRateScaled,1000,obj.Fs)*.001;
            
            % Generate probability matrix for nNeurons
            spikeProbMatrix = repmat(spikeProbVector,nNeurons,1);
            
            % Generate random numbers from the uniform distribution 
            % for each matrix index
            randMatrix = rand(size(spikeProbMatrix));
            
            % Set a spike only if the value of the random matrix is less
            % than or equal to the probability of a spike in that index
            spike_idx = find(randMatrix <= spikeProbMatrix);
            
            spikes = zeros(size(randMatrix));
            
            spikes(spike_idx) = 1;
                        

            
        end
        
        function [behavior] = getBehavior(obj,cycles, spikes)
            % Gaussian smooth each spike train
            
            % generate a gaussian window with 64 samples and a std of ~4
            alpha = (64 - 1)/(2*obj.smoothingWindow);
            stddev = (64 - 1) / (2*alpha);
            g = gausswin(64,alpha);
            
            % Set up 
            smoothedSpikes_matrix = zeros(size(spikes,1),length(cycles));
            
            % Get time vector with ms samples
            time_ms = (1:size(spikes,2)) .* 1/1000;
            
            % Get time vector for spikes with Fs samples
            time_samples = (1:length(cycles)) .* 1/obj.Fs;
            
            
            for iNeuron = 1:size(spikes,1)
                
                smoothedSpikes = conv(spikes(iNeuron,:), g, 'same');
                
                smoothedSpikes = circshift(smoothedSpikes,ceil(stddev));
                smoothedSpikes(1:ceil(stddev)) = zeros(1,ceil(stddev));
                
                newSmoothedSpikes = interp1(time_ms,smoothedSpikes,time_samples);
                
                
                % Scale the spikes to have 1/100 of the amplitude of the
                % behavior
                scaledSmoothedSpikes = newSmoothedSpikes .* (max(cycles)/100);
                
                smoothedSpikes_matrix(iNeuron,1:end) = scaledSmoothedSpikes;                                
            end
            
            spikesImpact = sum(smoothedSpikes_matrix,1);
            
            behavior = cycles + spikesImpact;
            
        end
        
        function spikeTimes = getSpikeTimes(obj,spikes)
            spikeTimes = {};
            for iNeuron = 1:size(spikes,1)
                
                % Find the indices where there is a spike for each neuron
                spikes_ms = find(spikes(iNeuron,:));
                
                % Convert idx in ms to time value in seconds (and add very
                % low amplitude jitter so that there aren't degenerate
                % spike times. 
                spikes_seconds = spikes_ms./1000;
                
                % For now, add random noise to the times
                spikes_seconds = spikes_seconds + rand(size(spikes_seconds));
                
                spikeTimes{iNeuron,1} = spikes_seconds;
                
            end
           
        end
        
        
    end
end

