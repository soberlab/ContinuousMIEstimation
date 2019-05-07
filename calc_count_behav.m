classdef calc_count_behav < mi_analysis
    %Each of these objects sets the stage to calculate the mutual
    %information between spike count and behavior and stores the results of
    %the calculation. 
    %   Detailed explanation goes here
    
    properties
    end
    
    methods
       function obj = calc_count_behav(objData,vars, verbose)

           if size(vars,1) ~= 2
               error('Expected two variables specified')
           end

           obj@mi_analysis(objData, vars);
           if nargin < 3 
               obj.verbose = 1; 
           end

        end
        
        function buildMIs(obj, desiredLength, verbose)
            if nargin < 2
                desiredLength = 20;
                verbose = obj.verbose;
            elseif nargin < 3
                verbose = obj.verbose;
            end

            % First, segment neural data into cycles
            switch(obj.vars{1,2})
                case 'time'
                    neuron = obj.vars{1,1};
                    x = obj.objData.getCount(neuron,verbose);
                case 'phase'
                    fprintf('Warning: this feature has not been added yet')
            end
            
            xGroups{1,1} = x;
           
            % Next, segment behavioral data into cycles
            y = obj.objData.behaviorByCycles();

            yGroups{1,1} = y;
            
            % For data with only one group, the coeff is 1. 
            
            coeffs = {1};

            buildMIs@mi_analysis(obj, {xGroups yGroups coeffs},verbose);          
            
            
        end
    end
end

