classdef analysis_ISI1_ISI2 < MI_KSG_data_analysis
    %Each of these objects sets the stage to calculate the mutual
    %information between spike count and behavior and stores the results of
    %the calculation. 
    %   Detailed explanation goes here
    
    properties
        isi_cutoff % ms
    end
    
    methods
        function obj = analysis_ISI1_ISI2(objData, vars, isi_cutoff, verbose)
            
            % BC 20190124: ADD CHECK TO SEE IF vars INCLUDES NEURONS FROM objData
            
            if nargin < 3; isi_cutoff = 200; end
            if nargin < 4; verbose = 1; end
            
            if length(vars) > 1
                error('Expected one variable specified.');
            end
            
            obj@MI_KSG_data_analysis(objData, vars);
            obj.isi_cutoff = isi_cutoff;
            obj.verbose = verbose;            
        end
        
        function buildMIs(obj, verbose)
            % So I propose that we use this method to prep the
            % count_behavior data for the MI core and go ahead and run MI
            % core from here. Then we can use the output of MI core to fill
            % in the MI, kvalue, and errors.
            
            if nargin == 1
                verbose = obj.verbose;
            end
            
            % First, get spike times from neuron
            spikeTimes = obj.objData.neurons{obj.vars(1)};
            
            % Find ISIs from spike times
            ISIs = diff(spikeTimes);
            % Check ISIs against cutoff. 
            ISIs = ISIs(find(ISIs < obj.isi_cutoff));
            
            % Make a vector of the first ISIs
            x = ISIs(1:end-1);
            xGroups{1,1} = x;
            
            % Make a vector of the second ISIs
            y = ISIs(2:end);
            yGroups{1,1} = y;
            
            coeffs = {1};
            
            buildMIs@MI_KSG_data_analysis(obj, {xGroups yGroups coeffs}, verbose);
        end
    end
end

