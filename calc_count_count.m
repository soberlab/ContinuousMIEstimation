classdef calc_count_count < mi_analysis
    %Each of these objects sets the stage to calculate the mutual
    %information between spike count and behavior and stores the results of
    %the calculation. 
    %   Detailed explanation goes here
    
    properties
    end
    
    methods

       function obj = calc_count_count(objData,vars)
            % Construct an instance of this class
            %   Detailed explanation goes here
            if nargin < 3; verbose = 1; end
            if length(vars) ~= 2
                error('Expected two variables specified');
            end

            obj@mi_analysis(objData, vars);
        end
        
        function  buildMIs(obj)
         % Build the data and core objects necessary to run the sim manager for this analysis class. 

            % Find total spike count in a cycle for neuron 1 
            neuron  = obj.vars(1);
       	    x = obj.objData.getCount(neuron);

            % Set groups that will serve as x variable
            xGroups{1,1} = x + normrnd(0, 1e-4);
            
            % Next find spike count for neuron 2
            neuron = obj.vars(2);
            y = obj.objData.getCount(neuron);

            % Set groups that will serve as y variable
            yGroups{1,1} = y + normrnd(0, 1e-4);

            % Set coefficients for groups
            coeffs = {1};

            buildMIs@mi_analysis(obj, {xGroups yGroups coeffs});
        end
    end
end

