classdef MI_KSG_core
    % MI_KSG_core is used to set up sets of simulations to determine an
    % optimum k-value for a mutual information estimate and also calculates
    % mutual information and estimation error.
    
    properties
        x % matrix of x data
        y % matrix of y data
        k_values % array of k-values
        err_estimates % matrix of error estimates
        mi_estimates % matrix of mutual information estimates
        opt_k % optimized k value
    end
    
    methods
        function obj = MI_KSG_core(x, y, ks_arr)
            obj.x = x;
            obj.y = y;
            if nargin == 2
                warning('Using default k-value of 3...');
                obj.k_values = 3;
                obj.opt_k = 3;
            elseif nargin == 3
                obj.k_values = ks_arr;
                obj.opt_k = 0;
            end
            
            err_estimates = [];
            mi_estimates = [];
        end
        
        % These methods are used to interface with other classes for data
        % analysis and visualization
        function r = add_mi_estimate()
        end
        
        function r = get_mi_estimate()
        end
        
        % These methods interact with sim_manager to set up and run
        % simulations
        function r = set_sim()
            % add sim parameters in sim_manager
        end
        
        function r = run_sims()
            % run simulations in sim_manager
        end
        
        function r = get_sims()
            % retrieve data from sim_manager
        end
        
        % These methods use the results of simulations from sim_manager
        % to calculate and determine mutual information estimates and other
        % parameters
        function r = calc_error()
            % calculate the error estimate from simulated data
        end
        
        function r = find_k_value()
            % determine best k-value to use
        end
        
    end
end