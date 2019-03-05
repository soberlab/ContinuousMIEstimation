classdef calc_timing_timing_behav < mi_analysis
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
       function obj = calc_timing_timing_behav(objData,vars, verbose)
            if length(vars) ~= 2
                error('Expected two variables specified');
            end

            obj@mi_analysis(objData, vars);
            if nargin < 3 
                obj.verbose = 1; 
            end
        end
        
        function buildMIs(obj,desiredLength, verbose)
            % So I propose that we use this method to prep the
            % count_behavior data for the MI core and go ahead and run MI
            % core from here. Then we can use the output of MI core to fill
            % in the MI, kvalue, and errors.
            
            % First, segment neural data into breath cycles
            neuron = obj.vars(1);
            n1 = obj.objData.getTiming(neuron,verbose);
           
            % Find different subgroups for neuron 1
            n1Counts = obj.objData.getCount(neuron,verbose);
            n1Conds = unique(n1Counts);

            % Segment neuron 2 into breath cycles
            % Segment neuron 2 into breath cycles
            neuron = obj.vars(2);
            n2 = obj.objData.getTiming(neuron,verbose);

            % Find different subgroups for neuron 2
            n2Counts = obj.objData.getCount(neuron,verbose);
            n2Conds = unique(n2Counts);
            
            % Segment behavioral data into cycles
            % RC- we should change this to choose what we want to do with
            % the pressure. How do we do this? 
            % y = obj.objData.getPressure(desiredLength, verbose);
            % For now, we are using area under the curve for pressure
            y = obj.objData.behavior;
            
            %Both neurons collectively will make up the x group. We will
            %concatonate each condition. 
            xGroups = {};
            yGroups = {};
            coeffs = {};
            groupCounter = 1;
            noteCount = 1;
            for in1Cond = 1:length(n1Conds)
                n1Cond = n1Conds(in1Cond);
                n1groupIdx = find(n1Counts == n1Cond);
                if n1Cond == 0
                    num = sum(n1Counts == n1Cond);
                    ratio = (num/length(n1Counts))*100;
                    note = strcat('Omitting ', num2str(ratio), ' percent of cycles because zero spikes in x.');
                    disp(note)
                    obj.notes{noteCount,1} = note;
                    noteCount = noteCount + 1;
                    continue
                end
                for in2Cond = 1:length(n2Conds)
                    n2Cond = n2Conds(in2Cond);
                    n2groupIdx = find(n2Counts == n2Cond);
                    xgroupIdx = intersect(n1groupIdx,n2groupIdx);
                    if n2Cond == 0
                        num = sum(n2Counts == n2Cond);
                        ratio = (num/length(n2Counts))*100;
                        note = strcat('Omitting ', num2str(ratio), ' percent of cycles because zero spikes in y.');
                        disp(note)
                        obj.notes{noteCount,1} = note;
                        noteCount = noteCount + 1;
                        continue
                    elseif n1Cond + n2Cond > length(xgroupIdx)
                        num = sum(n2Counts == n2Cond);
                        ratio = (num/length(n2Counts))*100;
                        note = strcat('Omitting ', num2str(ratio), ' percent of cycles,','where n1Cond = ',num2str(n1Cond), ' and n2Cond = ', num2str(n2Cond), 'because more spikes than data.');
                        disp(note)
                        obj.notes{noteCount,1} = note;
                        noteCount = noteCount + 1;
                        continue
                    end
%                     elseif n1Cond > length(xgroupIdx)
%                         num = sum(n1Counts == n1Cond);
%                         ratio = (num/length(n1Counts))*100;
%                         note = strcat('Omitting ', num2str(ratio), ' percent of cycles, where n1Cond = ', num2str(n1Cond), 'because more spikes than data.');
%                         disp(note)
%                         obj.notes{noteCount,1} = note;
%                         noteCount = noteCount + 1;
%                         continue 
%                     elseif n2Cond > length(xgroupIdx)
%                         num = sum(n2Counts == n2Cond);
%                         ratio = (num/length(n2Counts))*100;
%                         note = strcat('Omitting ', num2str(ratio), ' percent of cycles, where n2Cond = ', num2str(n2Cond), 'because more spikes than data.');
%                         disp(note)
%                         obj.notes{noteCount,1} = note;
%                         noteCount = noteCount + 1;
%                         continue   
                    n1Group = n1(xgroupIdx,1:n1Cond);
                    n2Group = n2(xgroupIdx,1:n2Cond);
                    xGroup = [n1Group,n2Group];

                    xGroups{groupCounter,1} = xGroup;
                    yGroup = y(xgroupIdx,1:end);
                    if length(xGroup) ~= length(yGroup)
                        keyboard
                    end
                    yGroups{groupCounter,1} = yGroup;
                    coeffs{groupCounter,1} = length(xgroupIdx)/length(n1Counts);
                    groupCounter = groupCounter + 1;
                end
                
            end
            buildMIs@mi_analysis(obj, {xGroups yGroups coeffs},verbose); 
            
        end
    end
end


