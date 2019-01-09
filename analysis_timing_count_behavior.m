classdef analysis_timing_count_behavior < MI_KSG_data_analysis
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
  function obj = make_timing_behavior(objData,var1,var2, var3)
            % var1- positive integer (neuron number)- timing neuron
            % var2- positive integer (neuron number)- count neuron
            % var3 - -1 for pressure
  obj =  MI_KSG_data_analysis(objData, var1, var2, var3);
        end
        
        function [xGroups, yGroups] = setXYvars(obj, verbose)
            % So I propose that we use this method to prep the
            % count_behavior data for the MI core and go ahead and run MI
            % core from here. Then we can use the output of MI core to fill
            % in the MI, kvalue, and errors.
            
            % First, segment neural data into breath cycles
            n1 = objData.dataByCycles(var1,verbose);
           
            % Find different subgroups for neuron 1
            n1Counts = sum(~isnan(x),2);
            n1Conds = unique(n1Counts);

            % Segment neuron 2 into breath cycles
            n2 = objData.dataByCycles(var2,verbose);

            % Find count values for neuron 2
            n2Counts = sum(~isnan(n2),2);
            
            % Segment behavioral data into cycles
            y = objData.dataByCycles(var3,verbose);
            
            %Both neurons collectively will make up the x group. We will
            %concatonate each condition. 
            xGroups = {};
            yGroups = {};
            for in1Group = 1:length(n1Conds)
                in1Cond = n1Conds(in1Group);
                n1groupIdx = find(n1Counts == in1Cond);
                n1Group = n1(n1groupIdx,1:in1Cond);
                n2Group = n2Counts(n1groupIdx,1);
                xGroup = [n1Group,n2Group];
                xGroups{in1Group,1} = xGroup;
                yGroup = y(xgroupIdx,1:end);
                yGroups{in1Group,1} = yGroup;
                Coeffs(in1Group,1) = length(xgroupIdx)/length(n1Counts);
            end
            % Document Probabilities
            obj.coeffs = Coeffs;
            % From here, each entry in xGroups and yGroups will feed into
            % the MI calculator. 
            % Figure out how each subgroup is going to feed into the 
            % MI_sim_manager and set up the data for that (maybe via
            % different lists). 
 
            
        end
    end
end

