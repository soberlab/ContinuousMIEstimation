classdef calc_count_count_behav < mi_analysis
    %Each of these objects sets the stage to calculate the mutual
    %information between spike count and behavior and stores the results of
    %the calculation. 
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
      function obj = calc_count_count_behav(objData,vars, verbose)
            % vars- a 2 x 1 vector of two positive integers, specifying the neuron numbers
          if nargin < 3; obj.verbose = 1; end
          if length(vars) ~= 2
              error('Expected two variables specified');
          end
          obj@mi_analysis(objData, vars);
        end
        
        function buildMIs(obj,verbose)
            % So I propose that we use this method to prep the
            % count_behavior data for the MI core and go ahead and run MI
            % core from here. Then we can use the output of MI core to fill
            % in the MI, kvalue, and errors.

	  if nargin == 1
    	      verbose = obj.verbose;
          end

	  % First, segment neuron 1 data into breath cycles
	    neuron = obj.vars(1);
            n1 = obj.objData.getCount(neuron,verbose);
            
            % Next segment neuron 2 data into cycles
    	    neuron = obj.vars(2)
	    n2 = obj.objData.getCount(neuron,verbose);
            
            % Set up x data
            xGroups{1,1} = [n1,n2];
            
            % Segment behavioral data into cycles
            y = objData.getPressure();
            
            % Set up y data
            yGroups{1,1} = y;
            
            
            % For this set the coeff will always be 1
            Coeffs ={1};
            
            buildMIs@mi_analysis(obj,(xGroups yGroups coeffs}, verbose);
        end
    end
end

