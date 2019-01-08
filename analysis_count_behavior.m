classdef analysis_count_behavior < MI_KSG_data_analysis
    %Each of these objects sets the stage to calculate the mutual
    %information between spike count and behavior and stores the results of
    %the calculation. 
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = make_count_behavior(objData,var1,var2)
            % Construct an instance of this class
            %   Detailed explanation goes here
            obj =  MI_KSG_data_analysis(objData, var1, var2);
        end
        
        function [xGroups, yGroups] = setXYvars(obj)
            % So I propose that we use this method to prep the
            % count_behavior data for the MI core and go ahead and run MI
            % core from here. Then we can use the output of MI core to fill
            % in the MI, kvalue, and errors.
            
            % First, segment neural data into breath cycles
            x = objData.dataByCycles(var1,verbose);
            
            % Find total spike count in a cycle
            x = sum(~isnan(x),2);
            xGroups{1,1} = x;
            
            % Next segment pressure data into cycles
            y = objData.dataByCycles(var2,verbose);
            yGroups{1,1} = y;
            
            obj.coeffs = 1;
            
            % Next run the MI calculation and k optimization
            obj.kvalue = [INSERT RELEVANT CODE];
            obj.MI = [INSERT RELEVANT CODE];
            obj.error = [INSERT RELEVANT CODE];
            
        end
    end
end

