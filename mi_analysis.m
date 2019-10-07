classdef mi_analysis < handle
    %  MI_KSG_data_analysis is a parent class used to set up a separate object for each pair of variables to feed into the MI calculations
    % 
    properties
        
        vars % 2 x Nvariables list integer {(-1 OR 1-Nneurons), 'phase' or 'time';...}
             % which indicates whether to take in the pressure or which neuron
        
        % BC: This should only ever reference ONE objData
        objData % Reference to which data object to pull from
        
        % BC: This will be a list/cell array of objMIcore instances (may need to index)
        % BC: cell array with structure: {{objMICore} {coeff} {k-value} {coreID}}
        arrMIcore % Reference to MIcore object 
	
        sim_manager % Sim manager reference object
        notes % Optional property, used to indicate how much data has been omitted
    end

    methods
        function obj = mi_analysis(objData, vars)
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
                obj.vars = {};
            end	   
	   
            obj.arrMIcore = {};
            % FOR RC 20190129:
            obj.sim_manager = mi_ksg_sims(0,3);
            %obj.sim_manager = mi_ksg_sims();
        end

        function buildMIs(obj, mi_data)
            % NOTE- we still need to change the default k-value for this. 
	        % BC: Move his for loop into the constructor for MI_KSG_data_analysis subclasses- DONE
            obj.arrMIcore = cell(size(mi_data,1),4);
            
            xGroups = mi_data{1};
            yGroups = mi_data{2};
            coeffs = mi_data{3};
            
            for iGroup = 1:size(xGroups,1)
                x = xGroups{iGroup,1};
                y = yGroups{iGroup,1};
                
                if obj.objData.reparamData == 1
                    for iDimension = 1:size(x,1)
                        x(iDimension,:) = obj.objData.reparameterizeData(x(iDimension,:));
                    end
                    for iDimension = 1:size(y,1)
                        y(iDimension,:) = obj.objData.reparameterizeData(y(iDimension,:));
                    end
                end
	          
                % BC: Need to append new mi_core instance to the arrMICore object with associated information- DONE
                % RC-  Is it a problem that we name the core object the same thing each iteration? 
              
                while 1 % generate random key to keep track of which MI calculations belong together
                    key = num2str(dec2hex(round(rand(1)*100000)));
                    % break the while loop if the key has not already been
                    % assigned.
                    if iGroup == 1
                        break
                    elseif ~ismember({obj.arrMIcore{1:end,4}}, key)
                        break
                    end
                end
                % RC: Why do we set the k values in the core object and in
                % the arrMIcore?
                % RC 20190918: Consider changing this so that a the k
                % values are an optional input and for there to be a
                % default. 
                core1 = mi_ksg_core(obj.sim_manager, x, y, 3:8, 0);
	            obj.arrMIcore(iGroup,:) = {core1 coeffs{iGroup,1} 0 key};
	            % BC: The obj.findMIs function basically calls run_sims
            end
	    % Sets up an MIcore object to calculate the MI values, and pushes the
	    % data from this object to the MIcore process. 
        end
        
        function calcMIs(obj, varargin)
                        
            % Set optional input: append 
            % When append = True, then we compare the k_values in the core obj
            % with those that have already been calculated. 
            % If append = False, then we re-calculate everything for all
            % the values of k. 
            default_append = true;
            %validate_append = @(x) assert(isboolean(x),'append must be a boolean value');
            p = inputParser;            
            p.addOptional('append', default_append);
            
            p.parse(varargin{:});
            
            append = p.Results.append;
            
            disp('Calculating mutual information...');
            run_sims(obj.sim_manager, append);
        end
    end
end
