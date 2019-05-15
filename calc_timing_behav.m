classdef calc_timing_behav < mi_analysis
    %Each of these objects sets the stage to calculate the mutual
    %information between spike count and behavior and stores the results of
    %the calculation. 
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
       function obj = calc_timing_behav(objData,vars, verbose)
            % vars - 2 x 1 vector specifying neuron numbers

            if length(vars) ~= 2
                error('Expected two variables specified');
            end

            obj@mi_analysis(objData, vars);
            if nargin < 3 
                obj.verbose = 1; 
            end

        end
        
        function buildMIs(obj, desiredLength, verbose)
            % So I propose that we use this method to prep the
            % count_behavior data for the MI core and go ahead and run MI
            % core from here. Then we can use the output of MI core to fill
            % in the MI, kvalue, and errors.
            
            % First, segment neural data into breath cycles
            neuron = obj.vars(1);
            x = obj.objData.getTiming(neuron,verbose);
           
            % Find different subgroups
            xCounts = obj.objData.getCount(neuron,verbose);
            xConds = unique(xCounts);

            % Segment behavioral data into cycles
            % RC- we should change this to choose what we want to do with
            % the pressure. How do we do this? 
            %y = obj.objData.getPressure(desiredLength, verbose);
            % For now, we are using area under the curve for pressure
            y = obj.objData.behavior;

            % Figure out how each subgroup is going to feed into the 
            % MI_sim_manager
            % AS WRITTEN- we put each subgroup for the calculation into an array. 
            % NOTE currently as this code is written, we dont worry about data limitations. 
            xGroups = {};
            coeffs = {};
            yGroups = {};

                % Segment x and y data into subgroups based on x spike count
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
                yGroups{groupCount,1} = y(groupIdx,1:end);
                groupCount = groupCount + 1;
            end
            buildMIs@mi_analysis(obj, {xGroups yGroups coeffs},verbose); 
   
        end
    end
end

