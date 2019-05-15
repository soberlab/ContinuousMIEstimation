classdef calc_timing_timing < mi_analysis
    %Each of these objects sets the stage to calculate the mutual
    %information between spike timing of neuron 1 and spike timing of neuron 2 and stores the results of
    %the calculation. 
    
    % For this type of calculation, it is likely that we will have to be creative
    % maybe we will use the average ISI in a breath cycle
    % maybe we will use only the first spike
    % We will have to see how much data we have. 
    
    properties
    end
    
    methods
       function obj = calc_timing_timing(objData,vars, verbose)
            if length(vars) ~= 2
                error('Expected two variables specified');
            end

            obj@mi_analysis(objData, vars);
            if nargin < 3 
                obj.verbose = 1; 
            end
        end
        
       function buildMIs(obj, verbose)
            % So I propose that we use this method to prep the
            % count_behavior data for the MI core and go ahead and run MI
            % core from here. Then we can use the output of MI core to fill
            % in the MI, kvalue, and errors.
            
            % First, segment neural data into breath cycles
            neuron = obj.vars(1);
            x = obj.objData.getTiming(neuron,verbose);
           
            % Find different subgroups for neuron 1
            xCounts = obj.objData.getCount(neuron,verbose);
            xConds = unique(xCounts);

            % Segment neuron 2 into breath cycles
            neuron = obj.vars(2);
            y = obj.objData.getTiming(neuron,verbose);

            % Find different subgroups for neuron 2
            yCounts = obj.objData.getCount(neuron,verbose);
            yConds = unique(yCounts);
            
            % AS WRITTEN- we put each subgroup for the calculation into an array. 
            % NOTE currently as this code is written, we dont worry about data limitations.

            xGroups = {};
            yGroups = {};
            coeffs = {};
            % Set Group Counter
            noteCount = 1;
            groupCounter = 1;
            for ixCond = 1:length(xConds)
                xCond = xConds(ixCond);
                xgroupIdx = find(xCounts == xCond);
                if xCond == 0
                    num = sum(xCounts == xCond);
                    ratio = (num/length(xCounts))*100;
                    note = strcat('Omitting ', num2str(ratio), ' percent of cycles because zero spikes in x.');
                    disp(note)
                    obj.notes{noteCount,1} = note;
                    noteCount = noteCount + 1;
                    continue
                end
                for iyCond = 1:length(yConds)
                    yCond = yConds(iyCond);
                    ygroupIdx = find(yCounts == yCond);
                    xygroupIdx = intersect(xgroupIdx,ygroupIdx);
                    if yCond == 0
                        num = sum(yCounts == yCond);
                        ratio = (num/length(yCounts))*100;
                        note = strcat('Omitting ', num2str(ratio), ' percent of cycles because zero spikes in y.');
                        disp(note)
                        obj.notes{noteCount,1} = note;
                        noteCount = noteCount + 1;
                        continue
                    elseif xCond > length(xygroupIdx)
                        num = sum(xCounts == xCond);
                        ratio = (num/length(xCounts))*100;
                        note = strcat('Omitting ', num2str(ratio), ' percent of cycles, where xCond = ', num2str(xCond), 'because more spikes than data.');
                        disp(note)
                        obj.notes{noteCount,1} = note;
                        noteCount = noteCount + 1;
                        continue 
                    elseif yCond > length(xygroupIdx)
                        num = sum(yCounts == yCond);
                        ratio = (num/length(yCounts))*100;
                        note = strcat('Omitting ', num2str(ratio), ' percent of cycles, where yCond = ', num2str(yCond), 'because more spikes than data.');
                        disp(note)
                        obj.notes{noteCount,1} = note;
                        noteCount = noteCount + 1;
                        continue   
                    end
                    xGroup = x(xygroupIdx,1:xCond);
                    xGroups{groupCounter,1} = xGroup;
                    yGroup = y(xygroupIdx,1:yCond);
                    yGroups{groupCounter,1} = yGroup;
                    coeffs{groupCounter,1} = length(xygroupIdx)/length(xCounts);
                    groupCounter = groupCounter + 1;
                end
            end
            
           buildMIs@mi_analysis(obj, {xGroups yGroups coeffs},verbose);     
            
        end
    end
end

