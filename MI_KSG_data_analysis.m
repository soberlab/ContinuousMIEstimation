classdef MI_KSG_data_analysis
    %  MI_KSG_data_analysis is a parent class used to set up a separate object for each pair of variables to feed into the MI calculations
    % 

    properties
        var1 % an integer (-1 OR 1-Nneurons)
             % which indicates whether to take in the pressure or which neuron
        var2 % OPTIONAL same as var 1
        var3 % OPTIONAL same as var 2
	% BC: This should only ever reference ONE objData
        objData % Reference to which data object to pull from
	% BC: This will be a list/cell array of objMIcore instances (may need to index)
	% BC: cell array with structure: {{objMICore} {coeff} {k-value} {coreID}}
        arrMIcore % Reference to MIcore object 
	
	sim_manager % Sim manager reference object
	
	% BC: Get rid of these class parameters
        MIs % 1 x n vector of MI values, where n is the number of subgroups for the subclass
        kvalues % 1 x n vector of k values, which will be found from the MIcore
        coeffs % 1 x n vector of probabilities for each subgroup
        errors % 1 x n vector of error for each MI subgroup- including error propogation
        
    end

    methods
       function obj =  MI_KSG_data_analysis(objData, var1, var2)
           % This funtion inputs the data object reference and variable references
	   % Note that var2 is an optional input
           if nargin == 2
               obj.objData = objData;
               obj.var1 = var1;
           elseif nargin == 3
               obj.objData = objData;
               obj.var1 = var1;
               obj.var2 = var2;   						
           end	   
	   
	   % BC: Need to instantiate sim_manager object
       end

       function findMIs(obj, verbose)
           % Find x and y data to send to MIcore.
           [xGroups, yGroups] = setXYvars(obj, verbose);
           
           %DECIDE- for or parfor (I think we need to just use for)
	   % BC: Move his for loop into the constructor for MI_KSG_data_analysis subclasses
           for iGroup = 1:length(xGroups)
               x = xGroups{iGroup,1};
               y = yGroups{iGroup,1};
	       % BC: Need to append new mi_core instance to the arrMICore object with associated information
               core1 = MI_KSG_core(sim_manager, x, y, [3 4 5], -1);
	       % BC: The obj.findMIs function basically calls run_sims
               run_sims(sim_manager);
           end
	 % Sets up an MIcore object to calculate the MI values, and pushes the
	 % data from this object to the MIcore process. 
       end

       
	 
   end
       
end
