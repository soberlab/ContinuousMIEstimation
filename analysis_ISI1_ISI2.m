classdef analysis_ISI1_ISI2 < MI_KSG_data_analysis
    %Each of these objects sets the stage to calculate the mutual
    %information between spike count and behavior and stores the results of
    %the calculation. 
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = make_ISI1_ISI2(objData,var1, verbose)
            % var1 is a positive integer to indicate neuron number
            obj =  MI_KSG_data_analysis(objData, var1);
            [xGroups,yGroups, Coeffs] = setParams(obj, verbose);
            obj.arrMIcore{1,2} = Coeffs;
            obj.findMIs(xGroups,yGroups,Coeffs,verbose);
        end
        
        function [xGroups, yGroups, Coeffs] = setParams(obj, verbose))
            % So I propose that we use this method to prep the
            % count_behavior data for the MI core and go ahead and run MI
            % core from here. Then we can use the output of MI core to fill
            % in the MI, kvalue, and errors.
            
            % First, get spike times from neuron
            spikeTimes = objData.neurons{1,var1};
            
            % Find ISIs from spike times
            ISIs = diff(spikeTimes);
% BRYCE- can you verify that this is correct? 
            ISIs = ISIs(find(ISIs < 200));
            % Make a vector of the first ISIs
            x = ISIs(1:end-1);
            xGroups{1,1} = x;
            
            % Make a vector of the second ISIs
            y = ISI(2:end);
            yGroups{1,1} = y;
            
            Coeffs = {1};
        end
    end
end

