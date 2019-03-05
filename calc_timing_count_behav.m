classdef calc_timing_count_behav < mi_analysis
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
      function obj = calc_timing_count_behav(objData, vars, verbose)
            % vars - 2 x 1 vector specifying neuron numbers

            if length(vars) ~= 2
                error('Expected two variables specified');
            end

            obj@mi_analysis(objData, vars);
            if nargin < 3 
                obj.verbose = 1; 
            end
        end
        
        function buildMIs(obj, desiredLength,verbose)
            % So I propose that we use this method to prep the
            % count_behavior data for the MI core and go ahead and run MI
            % core from here. Then we can use the output of MI core to fill
            % in the MI, kvalue, and errors.
            
            
            % First, segment neural data into breath cycles
            neuron = obj.vars(1);
            n1 = obj.objData.getTiming(neuron,verbose);
           
            % Find different subgroups
            n1Counts = obj.objData.getCount(neuron,verbose);
            n1Conds = unique(n1Counts);

            % Find count values for neuron 2
            neuron = obj.vars(2);
            n2Counts = obj.objData.getCount(neuron,verbose);
            
            % Segment behavioral data into cycles
            % RC- we should change this to choose what we want to do with
            % the pressure. How do we do this? 
            %y = obj.objData.getPressure(desiredLength, verbose);
            % For now, we are using area under the curve for pressure
            y = obj.objData.behavior;
            
            %Both neurons collectively will make up the x group. We will
            %concatonate each condition. 
            xGroups = {};
            yGroups = {};
            coeffs = {};
            iGroup = 1;
            noteCount = 1;
            for in1Cond = 1:length(n1Conds)
                n1Cond = n1Conds(in1Cond);
                n1groupIdx = find(n1Counts == n1Cond);
                if n1Cond == 0
                    num = sum(n1Counts == n1Cond);
                    ratio = (num/length(n1Counts))*100;
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
                elseif n1Cond > sum(n1Counts == n1Cond)
                    num = sum(n1Counts == n1Cond);
                    ratio = (num/length(n1Counts))*100;
                    note = strcat('Omitting ', num2str(ratio), 'percent of cycles, where n1Cond = ' , num2str(n1Cond), 'because more spikes than data.');
                    disp(note)
                    obj.notes{noteCount,1} = note;
                    noteCount = noteCount + 1;
                    continue
                end
                n1Group = n1(n1groupIdx,1:n1Cond);
                n2Group = n2Counts(n1groupIdx)';
                xGroup = [n1Group,n2Group];
                xGroups{iGroup,1} = xGroup;
                yGroup = y(n1groupIdx,1:end);
                yGroups{iGroup,1} = yGroup;
                coeffs{iGroup,1} = length(n1groupIdx)/length(n1Counts);
                iGroup = iGroup + 1;
            end
                buildMIs@mi_analysis(obj, {xGroups yGroups coeffs},verbose);     
            end

            % From here, each entry in xGroups and yGroups will feed into
            % the MI calculator. 
            % Figure out how each subgroup is going to feed into the 
            % MI_sim_manager and set up the data for that (maybe via
            % different lists). 
            
            
        end
    end

