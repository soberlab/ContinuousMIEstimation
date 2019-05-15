classdef calc_count_behav < mi_analysis
    %Each of these objects sets the stage to calculate the mutual
    %information between spike count and behavior and stores the results of
    %the calculation. 
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
       function obj = calc_count_behav(objData,vars, verbose)

           if length(vars) ~= 1
               error('Expected one variable specified')
           end

           obj@mi_analysis(objData, vars);
           if nargin < 3 
               obj.verbose = 1; 
           end

        end
        
        function buildMIs(obj, desiredLength, verbose)
            if nargin < 2
                desiredLength = 200;
                verbose = obj.verbose;
            elseif nargin < 3
                verbose = obj.verbose;
            end

            % First, segment neural data into breath cycles
  	    neuron = obj.vars(1);
            x = obj.objData.getCount(neuron,verbose);
            
            xGroups{1,1} = x;
            
            % Segment behavioral data into cycles
            % RC- we should change this to choose what we want to do with
            % the pressure. How do we do this? 
            %y = obj.objData.getPressure(desiredLength, verbose);
            % For now, we are using area under the curve for pressure
            y = obj.objData.behavior;
            yGroups{1,1} = y;
            
            coeffs = {1};

            buildMIs@mi_analysis(obj, {xGroups yGroups coeffs},verbose);          
            
            
        end
    end
end

