classdef MI_KSG_data_analysis
    %  MI_KSG_data_analysis is a parent class used to set up a separate object for each pair of variables to feed into the MI calculations
    % 

    properties
        var1 % an integer (-1 OR 1-Nneurons)
             % which indicates whether to take in the pressure or which neuron
        var2 % OPTIONAL same as var 1
        var3 % OPTIONAL same as var 2
        objData % Reference to which data object to pull from
        objMIcore % Reference to MIcore object 
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
       end

       function findMIs(obj)
	 % Sets up an MIcore object to calculate the MI values, and pushes the
	 % data from this object to the MIcore process. 
       end

       
	 
   end
       
end
