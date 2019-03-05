
classdef mi_generator < handle
    % This file will contain the data generator class 
    % to synthesize data based on various ISI distributions
    
    properties
        % Consider setting phase, duration, etc. as a reference to a
        % function. We can specify which function is called (gaussianData,
        % other distributions). All of them are by default gaussian. 
        phase % 3 x 1 vector indicating [distribution , mean, variance]
         % of the phase within each cycle the firing begins, dist (gaussian
         % defualt)
         % Distribution key: 'N'- normal
        duration % [dist , mean , variance] for how long in ms each cycle lasts
        burstLength % phase of cycle that the burst lasts - hard coded for now
        rate %  avg firing rate of burst (Hz) - stationary for now
        waveform % action potential waveform- takes up 1 ms. 
        refract % refractory period in ms - hard coded for now
        SNR % desired signal to noise ratio
        Fs % Sample frequency of simulated data- default 32kHz
        noise % default is gaussian white noise
    end
    methods
        function obj = mi_generator()
            if nargin == 0
                % All default params - NOTE CURRENTLY ARBITRARY
                obj.phase = {'N', 5*pi/4 , pi/16 };
                % Use an anonymous function for more flexibility
                % obj.phase = @(s) normrnd(mu, sigma, s);
                % call: obj.phase([N nSamp]) 
                % In this case, we will set a default mu and sigma. 
                obj.duration = {'N', 200 , 3 };
                obj.burstLength = pi/2;
                obj.rate = 200;
                obj.Fs = 32000;
                % For the wavform. I need to think about whether the
                % wavefore needs to be at the sampling frequency of the
                % data. If we have an action potential waveform, we will
                % need to resample based on the sample frequency and the
                % waveform duration. Probably use the resample function to
                % do this. We will either extract the waveform. 
                obj.waveform = sin(0:2*pi/(obj.Fs/1000):2*pi); 
                % Revisit the refractory period in the exponential
                % distribution. 
                obj.refract = 1;
                obj.SNR = 4;
                
            end
            
        end
        
        function [simData] = makeVoltageData(obj, nCycles, lCutoff, lCutoff)
            % Condition on nargin to determine whether to filter. 
            % Generate spike sequences within cycles fromd distributions. 
            [spikes, durations] = obj.sampleCycles(nCycles);
            % Put Cycles into one spike train
            [spikeTimes] = obj.getTimes(spikes, durations);
            % Convert spike times into a noiseless voltage trace
            [data] = obj.voltageTrace(spikeTimes);
            % Add noise to the voltage trace
            [simData] = addNoise(obj, data);
            
        end
        function [spikes, durations] = sampleCycles(obj, nCycles)
            spikes = {};
            phases = normrnd( obj.phase{2} , obj.phase{3} , [1 , nCycles] );
            durations = normrnd( obj.duration{2} , obj.duration{3} , [1 , nCycles] );
            % convert phase to start times in ms
            burstStart = phases.*(durations/(2*pi));
            % convert burstLength to ms
            burstDurations = obj.burstLength.*(durations./(2*pi));
            for iCycle = 1:length(phases)
                isis = [];
                idx = 1;
                postStartTime = [];
                
                % sample exprrnd MORE than needed: ts = exprnd(mu, [N+10])
                % sumTs = cumsum(ts);
                % ixs = sumTs < duration;
                % cycleTs = sumTs(ixs);
                
                
                while sum(isis) < burstDurations(iCycle)
                    isiSeconds = exprnd(1/obj.rate);
                    isiMS = isiSeconds * 1000; 
                    if isiMS > obj.refract
                        isis(idx) = isiMS;
                        % Take out conditional. Create an array of isis
                        % from the exponential then use cumsum() after the
                        % while loop. 
                        if idx > 1
                            postStartTime(idx) = sum(isis);
                        else
                            postStartTime(idx) = isiMS;
                        end
                    end
                    idx = idx + 1;
                end
                spikes{1,iCycle} = horzcat(burstStart(1,iCycle), (postStartTime + burstStart(1,iCycle)));
            end
            
        end
        function [spikeTimes] = getTimes(obj,spikes, durations)
            for iCycle = 1:length(spikes)
                if iCycle == 1
                    spikeTimes = spikes{1,iCycle};
                else 
                    spikeTimes = [spikeTimes , sum(durations(1,1:iCycle)) + spikes{1,iCycle}];
                end
            end
        end
        function [data] = voltageTrace(obj, spikeTimes)
            % Currently this function aligns the peak of the spike
            % waveforms to the spike times
            Fs = obj.Fs;
            recordLength = max(spikeTimes);
            % FOR NOW, simulate 20ms past the last spike
            recordLength = recordLength + 20;
            % Convert to samples
            recordLengthSamples = ceil((recordLength/1000)*Fs);
            voltage = zeros(1,recordLengthSamples);
            spikeSamples = round((spikeTimes/1000)*Fs);
            for iSample = 1:length(obj.waveform)
                spike = obj.waveform(iSample);
                idxs = spikeSamples + iSample - 4;
                voltage(1,idxs) = spike;
            end
            % EDIT TO TRY: Try a binary with a one at each spike index then convolve
            % with the waveform. 
            data = voltage;
        end
        function [simData] = addNoise(obj, data)
            % Currently noise default is white gaussian noise. I would like
            % to change this so that I can add other kinds of noise
            % data is the output of voltageTrace
            % Fs is the desired sample frequency
            % SNR is the desired SNR we want to achieve, default is 2.
            SNR = obj.SNR;
            noise = wgn(1,length(data),1);
            
            % Currently assuming waveform is a sinusoid, and using rms to
            % calculate SNR
            A = sqrt(2)*rms(noise)*SNR;
            data = data * A;
            simData = data + noise;          
        end
    end
end

