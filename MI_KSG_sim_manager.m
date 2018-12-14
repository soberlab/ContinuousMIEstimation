classdef MI_KSG_sim_manager
    properties
        verbose % set level of output for reference and debugging
        sim_params % array of simulation data and k-values
        sim_data % matrix of mutual information calculation points
        thread_count % number of available cores for parallel
        par_mode % flag to run in parallel mode
    end
    methods
        function obj = MI_KSG_sim_manager(mode, verbose)
            if nargin == 1
                obj.par_mode = mode;
                obj.verbose = 0;
            elseif nargin == 2
                obj.par_mode = mode;
                obj.verbose = verbose;
            elseif nargin > 2
                error([newline 'MI_KSG_sim_manager >> Too many constructor arguments!']);
            else
                obj.par_mode = true;
                obj.verbose = 0;
            end
            
            obj.sim_params = {};
            obj.sim_data = [];
            
            % determine number of available cores
            c = parcluster('local');
            obj.thread_count = c.NumWorkers;
            
            % ===== ===== ===== ===== =====
            % Should a line be added to automatically determine whether it
            % will be more efficient to run the simulations in serial or in
            % parallel?
            
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
            if obj.par_mode > 0
                % set up memory and variable management for parfor
                tmp_sim_data = obj.sim_data;
                xs = obj.sim_params(:,1);
                ys = obj.sim_params(:,2);
                ks = obj.sim_params(:,3);
                
                parfor i=1:size(obj.sim_params,1)
                    tmp_sim_data(i) = MIxnyn(xs, ys, ks);
                end
            else
                % if few sims to run, run in serial to avoid overhead of
                % setting up parallel pool
                for i=1:size(obj.sim_params,1)
                        obj.sim_data(i) = MIxnyn(obj.sim_params(i,1), obj.sim_params(i,2), obj.sim_params(i,3));
                end
            end
            obj.sim_data = tmp_sim_data;
            r = true;
        end
    end
end