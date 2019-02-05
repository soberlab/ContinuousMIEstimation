
classdef mi_generator < handle
    % This file will contain the data generator class 
    % to synthesize data based on various ISI distributions
    
    properties
        phase % 3 x 1 vector indicating [distribution , mean, variance]
         % of the phase within each cycle the firing begins, dist (gaussian
         % defualt)
         % Distribution key: 'N'- normal
        duration % [dist , mean , variance] for how long in ms each cycle lasts
        burstLength % phase of cycle that the burst lasts - hard coded for now
        rate %  avg firing rate of burst (Hz) - stationary for now
        waveform % action potential waveform 
        refract % refractory period in ms - hard coded for now
        noise % [color, amplitude]
    end
    methods
        function obj = mi_generator()
            if nargin == 0
                % All default params - NOTE CURRENTLY ARBITRARY
                obj.phase = {'N', 5*pi/4 , pi/8 };
                obj.duration = {'N', 200 , 20 };
                obj.burstLength = pi/2;
                obj.rate = 200;
                obj.waveform = sin(0:pi/8:2*pi);
                obj.refract = 4;
            end
            
        end
        function [spikes, durations] = sampleCycles(obj, Ncycles)
            spikes = {};
            phases = normrnd( obj.phase{2} , obj.phase{3} , [1 , Ncycles] );
            durations = normrnd( obj.duration{2} , obj.duration{3} , [1 , Ncycles] );
            % convert phase to start times in ms
            burstStart = phases.*(durations/(2*pi));
            % convert burstLength to ms
            burstDurations = obj.burstLength.*(durations./(2*pi));
            for iCycle = 1:length(phases)
                isis = [];
                idx = 1;
                while sum(isis) < burstDurations(iCycle)
                    isiSeconds = exprnd(1/obj.rate);
                    isiMS = isiSeconds * 1000;
                    % THIS IS NOT WORKING. NEED TO TROUBLESHOOT. 
                    if isiMS > obj.refract
                        isis(idx) = isiMS;
                    else
                        continue
                    end
                    idx = idx + 1;
                end
                spikes{1,iCycle} = horzcat(burstStart(1,iCycle), (isis + burstStart(1,iCycle)));
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
        function [data] = voltageTrace(obj, spikeTimes, Fs)
            % Currently this function aligns the peak of the spike
            % waveforms to the spike times
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
            data = voltage;
        end
    end
end

