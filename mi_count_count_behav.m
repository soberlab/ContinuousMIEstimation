classdef mi_count_count_behav < MI_KSG_data_analysis
    %Each of these objects sets the stage to calculate the mutual
    %information between spike count and behavior and stores the results of
    %the calculation. 
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
      function obj = mi_count_count_behav(objData,var1,var2,var3, verbose)
            % var1- positive integer (neuron number)
            % var2- positive integer (neuron number)
            obj =  MI_KSG_data_analysis(objData, var1, var2, var3);
            [xGroups,yGroups, Coeffs] = setParams(obj,pressureLength, verbose);
            obj.arrMIcore{1,2} = Coeffs;
            obj.findMIs(xGroups,yGroups,Coeffs,verbose);
        end
        
        function [xGroups, yGroups, Coeffs] = setParams(obj,pressureLength,verbose)
            % So I propose that we use this method to prep the
            % count_behavior data for the MI core and go ahead and run MI
            % core from here. Then we can use the output of MI core to fill
            % in the MI, kvalue, and errors.
            
            % First, segment neuron 1 data into breath cycles
            n1 = objData.getCount(var1,verbose);
            
            % Next segment neuron 2 data into cycles
            n2 = objData.getCount(var2,verbose);
            
            % Set up x data
            xGroups{1,1} = [n1,n2];
            
            % Segment behavioral data into cycles
            y = objData.getPressure(var3, pressureLength, verbose);
            
            % Set up y data
            yGroups{1,1} = y;
            
            
            % For this set the coeff will always be 1
            Coeffs ={1};
            
            
        end
    end
end

