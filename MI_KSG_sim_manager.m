classdef MI_KSG_sim_manager
    properties
        verbose; % set level of output for reference and debugging
        sim_params; % array of simulation data and k-values
        sim_data; % matrix of mutual information calculation points
    end
    methods
        function obj = MI_KSG_sim_manager(verbose)
            if nargin == 1
                obj.verbose = verbose;
            else
                obj.verbose = 0;
            end
            obj.sim_params = {};
            obj.sim_data = [];
        end
        
        function idx = add_sim(obj, x, y, k)
            % add a simulation to the list of sims            
            obj.sim_params = cat(1, obj.sim_params, {x y k});            
            idx = size(obj.sim_params,1); % return index for simulation results
        end
        function r = remove_sim(obj, idx)
            % remove a simulation from the list of sims
            obj.sim_params(idx,:) = {[]};
            r = true;
        end
        function r = run_par_sims(obj)
            % run list of simulations in parallel
            obj.sim_data = nan(size(obj.sim_params,1),1); % initiate results arrays
            
            % iterate through all mutual information parameters in parallel
            for i=1:size(obj.sim_params,1)
                obj.sim_data(i) = MIxnyn(obj.sim_params(i,1), obj.sim_params(i,2), obj.sim_params(i,3));
            end
            r = true;
        end
    end
end