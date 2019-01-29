classdef mi_ksg_analysis < handle
    %  MI_KSG_data_analysis is a parent class used to set up a separate object for each pair of variables to feed into the MI calculations
    % 
    properties
        verbose
        
        vars % list integer (-1 OR 1-Nneurons)
             % which indicates whether to take in the pressure or which neuron
        
        % BC: This should only ever reference ONE objData
        objData % Reference to which data object to pull from
        
        % BC: This will be a list/cell array of objMIcore instances (may need to index)
        % BC: cell array with structure: {{objMICore} {coeff} {k-value} {coreID}}
        arrMIcore % Reference to MIcore object 
	
        sim_manager % Sim manager reference object
    end

    methods
        function obj = mi_ksg_analysis(objData, vars)
            % This funtion inputs the data object reference and variable references
            if nargin == 2
                % BC 20190124: Design choice needs to be made....
                % When specifying vars variable, we are only instantiating
                % each analysis subclass object once, so vars should
                % include ONLY the variables that are used for analysis
                obj.objData = objData;
                obj.vars = vars;   						
            else
                obj.objData = objData;
                obj.vars = [];
            end	   
	   
            obj.arrMIcore = {};
            obj.sim_manager = MI_KSG_sim_manager();
        end

        function buildMIs(obj, mi_data, verbose)
            % NOTE- we still need to change the default k-value for this. 
	        % BC: Move his for loop into the constructor for MI_KSG_data_analysis subclasses- DONE
            obj.arrMIcore = cell(size(mi_data,1),4);
            
            xGroups = mi_data{1};
            yGroups = mi_data{2};
            coeffs = mi_data{3};
            
            for iGroup = 1:size(mi_data,1)
                x = xGroups{iGroup,1};
                y = yGroups{iGroup,1};
	          
                % BC: Need to append new mi_core instance to the arrMICore object with associated information- DONE
                % RC-  Is it a problem that we name the core object the same thing each iteration? 
              
                while 1 % generate random key to keep track of which MI calculations belong together
                    key = num2str(dec2hex(round(rand(1)*100000)));
                    if ~any(strcmp(obj.arrMIcore{:,4}, key))
                        break;
                    end
                end
                
                core1 = MI_KSG_core(obj.sim_manager, x, y, [3 4 5], -1);
	            obj.arrMIcore(iGroup,:) = {core1 coeffs{iGroup,1} 0 key};
	            % BC: The obj.findMIs function basically calls run_sims
	            % RC- so from my understanding, we do not need the following line of code. 
            end
	    % Sets up an MIcore object to calculate the MI values, and pushes the
	    % data from this object to the MIcore process. 
        end
        
        function calcMIs(obj)
            disp('Calculating mutual information...');
            run_sims(obj.sim_manager);
        end
    end
end
