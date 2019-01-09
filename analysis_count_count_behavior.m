classdef analysis_count_count_behavior < MI_KSG_data_analysis
    %Each of these objects sets the stage to calculate the mutual
    %information between spike count and behavior and stores the results of
    %the calculation. 
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = make_count_count(objData,var1,var2,var3)
            % var1- positive integer (neuron number)
            % var2- positive integer (neuron number)
            obj =  MI_KSG_data_analysis(objData, var1, var2, var3);
        end
        
        function [xGroups, yGroups] = setXYvars(obj,verbose)
            % So I propose that we use this method to prep the
            % count_behavior data for the MI core and go ahead and run MI
            % core from here. Then we can use the output of MI core to fill
            % in the MI, kvalue, and errors.
            
            % First, segment neuron 1 data into breath cycles
            n1 = objData.dataByCycles(var1,verbose);
            n1 = sum(~isnan(n1),2);
            
            % Next segment neuron 2 data into cycles
            n2 = objData.dataByCycles(var2,verbose);
            n2 = sum(~isnan(n2),2);
            
            % Set up x data
            xGroups{1,1} = [n1,n2];
            
            % Segment behavioral data into cycles
            y = objData.dataByCycles(var3,verbose);
            
            % Set up y data
            yGroups{1,1} = y;
            
            
            % For this set the coeff will always be 1
            obj.coeffs = 1;
            
            
        end
    end
end

