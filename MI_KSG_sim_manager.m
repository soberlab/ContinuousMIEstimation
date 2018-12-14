classdef MI_KSG_sim_manager
    properties
        sim_params % struct of simulation parameters
        sim_data % matrix of mutual information calculation points
    end
    methods
        function r = add_sim()
            % add a simulation to the list of sims
        end
        function r = remove_sim()
            % remove a simulation from the list of sims
        end
        function r = run_par_sims()
            % run list of simulations in parallel
        end
    end
end