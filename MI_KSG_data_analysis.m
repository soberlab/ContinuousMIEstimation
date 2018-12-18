classdef MI_KSG_data_analysis
    %  MI_KSG_data_analysis is a parent class used to set up a separate object for each pair of variables to feed into the MI calculations
    % 

    properties
        var1 % an integer (-1 OR 1-Nneurons)
             % which indicates whether to take in the pressure or which neuron
        var2 % OPTIONAL same as var 
        objData % Reference to which data object to pull from
        objMIcore % Reference to MIcore object (I cant remember what this was for
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

       function r = get_breathTimes()
	 % uses pressure wave and pFS to segment breaths into cycles and determines Nbreaths [NOTE BRYCE'S CODE MAY ALREADY DO THIS]
       end

       function r = databyCycles()
	 % Takes in neuron times or pressure wave, breath times, and nFs or pFs and makes a matrix of pressure cycles or spikes within cycles
           
       end
	 
   end
       
end
