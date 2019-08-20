classdef calc_count_count_behav < mi_analysis
    %Note, for now the behavior is hard-coded to give us area under the
    %curve. 
    
    properties
    end
    
    methods
      function obj = calc_count_count_behav(objData,vars)
            % vars- a 2 x 1 vector of two positive integers, specifying the neuron numbers
            
          if length(vars) ~= 2
              error('Expected two variables specified');
          end
          
          obj@mi_analysis(objData, vars);
          
          if nargin < 3 
              obj.verbose = 1; 
          end
        end
        
        function buildMIs(obj)
            % So I propose that we use this method to prep the
            % count_behavior data for the MI core and go ahead and run MI
            % core from here. Then we can use the output of MI core to fill
            % in the MI, kvalue, and errors.



            % First, segment neuron 1 data into breath cycles
            neuron = obj.vars(1);
            n1 = obj.objData.getCount(neuron)';
            
            % Next segment neuron 2 data into cycles
    	    neuron = obj.vars(2);
            n2 = obj.objData.getCount(neuron)';
            
            % Set up x data
            xGroups{1,1} = [n1 n2];
            
            % Segment behavioral data into cycles
            % RC- we should change this to choose what we want to do with
            % the pressure. How do we do this? 
            if nargin < 6
                y = obj.objData.processBehavior();
            elseif nargin == 6
                y = obj.objData.processBehavior();
            end
            
            % Set up y data
            yGroups{1,1} = y;
            
            % For this set the coeff will always be 1
            coeffs ={1};
            
            buildMIs@mi_analysis(obj,{xGroups yGroups coeffs});
        end
    end
end

