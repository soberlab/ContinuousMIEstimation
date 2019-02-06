classdef calc_count_behav < mi_analysis
    %Each of these objects sets the stage to calculate the mutual
    %information between spike count and behavior and stores the results of
    %the calculation. 
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
       function obj = calc_count_behav(objData,vars, verbose)
           if nargin < 3; obj.verbose = 1; end
           if length(vars) ~= 1
	       error('Expected one variable specified')
	   end

           obj@mi_analysis(objData, vars);

        end
        
        function buildMIs(obj, pressureLength, verbose)
            if nargin < 2
                pressureLength = 200;
                verbose = obj.verbose;
            elseif nargin < 3
                verbose = obj.verbose;
            end

            % First, segment neural data into breath cycles
  	    neuron = obj.vars(1);
            x = objData.getCount(neuron,verbose);
            
            xGroups{1,1} = x;
            
            % Next segment pressure data into cycles
            y = objData.getPressure(pressureLength,verbose);
            yGroups{1,1} = y;
            
            coeffs = {1};

            buildMIs@mi_analysis(obj, {xGroups yGroups coeffs},verbose);          
            
            
        end
    end
end

