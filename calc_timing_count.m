classdef calc_timing_count < mi_analysis
    %Each of these objects sets the stage to calculate the mutual
    %information between spike count and behavior and stores the results of
    %the calculation. 
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
        function obj = calc_timing_count(objData,vars)
            % vars - 2 x 1 vector specifying neuron numbers

            if length(vars) ~= 2
                error('Expected 2 variables specified');
            end

            obj@mi_analysis(objData, vars);

        end
        
        function buildMIs(obj)
% Build the data and core objects necessary to run the sim manager for this analysis class            
            % First, segment neural data into breath cycles
            neuron = obj.vars(1);
            x = obj.objData.getTiming(neuron);
           
            % Find different subgroups
            xCounts = obj.objData.getCount(neuron);
            xConds = unique(xCounts);

            % Next segment other neuron into cycles and find the count
            neuron = obj.vars(2);
            y = obj.objData.getCount(neuron);


            % AS WRITTEN- we put each subgroup for the calculation into an array. 
            % NOTE currently as this code is written, we dont worry about data limitations. 
            xGroups = {};
            coeffs = {};
            yGroups = {};

            % Segment x and y data into roups based on x spike count
            % Set Group counter
            groupCount = 1;
            noteCount = 1;
            for iCond = 1:length(xConds)
                Cond = xConds(iCond);
                groupIdx = find(xCounts == Cond);
                if Cond == 0
                    num = sum(xCounts == Cond);
                    ratio = (num/length(xCounts))*100;
                    note = strcat('Omitting ', num2str(ratio), 'percent of cycles because zero spikes');
                    disp(note)
                    obj.notes{noteCount,1} = note;
                    noteCount = noteCount + 1;
                    % When there are zero spikes, the MI from timing is zero. This
                    % can't be accounted for in the calculation because
                    % there are no time values to send to MIxnyn.
                    % Therefore, we are setting the coeff for this group to
                    % zero. The percent will be accounted for in the rest
                    % of the Coeffs (the Coeffs will sum to 1 - n(zero)
                    continue
                elseif Cond > sum(xCounts == Cond)
                    num = sum(xCounts == Cond);
                    ratio = (num/length(xCounts))*100;
                    note = strcat('Omitting ', num2str(ratio), 'percent of cycles, where Cond = ' , num2str(Cond), 'because more spikes than data.');
                    disp(note)
                    obj.notes{noteCount,1} = note;
                    noteCount = noteCount + 1;
                    continue
                end
                ixGroup =  x(groupIdx,1:Cond);
                xGroups{groupCount,1} = ixGroup;
                coeffs{groupCount,1} = length(ixGroup)/length(xCounts);
                yGroups{groupCount,1} = y(groupIdx)';
                groupCount = groupCount + 1;
            end
	    
            buildMIs@mi_analysis(obj, {xGroups yGroups coeffs});          
            
        end
    end
end

