classdef analysis_timing_count < MI_KSG_data_analysis
    %Each of these objects sets the stage to calculate the mutual
    %information between spike count and behavior and stores the results of
    %the calculation. 
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
       function obj = analysis_timing_behavior(objData,var1,var2, verbose)
            % var1- positive integer (neuron number)
            % var2-  positive integer (neuron number) - always the count variable
            obj =  MI_KSG_data_analysis(objData, var1, var2);
            [xGroups,yGroups, Coeffs] = setParams(obj,pressureLength, verbose);
            obj.arrMIcore{1,2} = Coeffs;
            obj.findMIs(xGroups,yGroups,Coeffs,verbose);
        end
        
        function [xGroups, yGroups, Coeffs]] = setParams(obj, verbose)
            % So I propose that we use this method to prep the
            % count_behavior data for the MI core and go ahead and run MI
            % core from here. Then we can use the output of MI core to fill
            % in the MI, kvalue, and errors.
            
            % First, segment neural data into breath cycles
            x = objData.getTiming(var1,verbose);
           
            % Find different subgroups
            xCounts = getCount(var1,verbose)
            xConds = unique(xCounts);

            % Next segment other neuron into cycles and find the count
            y = objData.getCount(var2,verbose);


            % Figure out how each subgroup is going to feed into the 
            % MI_sim_manager
            % AS WRITTEN- we put each subgroup for the calculation into an array. 
            % NOTE currently as this code is written, we dont worry about data limitations. 
            xGroups = {};
            Coeffs = {};
            yGroups = {};

                % Segment x and y data into roups based on x spike count
            for iGroup = 1:length(xConds)
                iCond = xGroups(iGroup);
                groupIdx = find(xCounts == iCond);
                ixGroup =  x(groupIdx,1:iCond);
                xGroups{iGroup,1} = iGroup;
                Coeffs{iGroup,1} = length(ixGroup)/length(xCounts);
                yGroups{iGroup,1} = y(groupIdx,1:end);
            end
            
            
        end
    end
end

