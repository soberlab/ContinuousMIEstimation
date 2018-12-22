classdef MI_KSG_sim_manager < handle
    properties
        verbose % set level of output for reference and debugging
        
        mi_core_arr = {} % array of mi_core objects
        
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
            else
                obj.par_mode = true;
                obj.verbose = 0;
            end
            
            % determine number of available cores
            c = parcluster('local');
            obj.thread_count = c.NumWorkers;
            
            % ===== ===== ===== ===== =====
            % Should a line be added to automatically determine whether it
            % will be more efficient to run the simulations in serial or in
            % parallel?
            
        end

        function add_sim(obj, obj_mi_core)
            % add a MI core object to list of simulations
            tmp_core_arr = obj.mi_core_arr;
            if isempty(tmp_core_arr)
                key = num2str(dec2hex(round(rand(1)*100000)));
            else
                while 1
                    key = num2str(dec2hex(round(rand(1)*100000)));
                    if ~any(strcmp(tmp_core_arr(:,2), key))
                        break;
                    end
                end
            end
            obj.mi_core_arr = cat(1, tmp_core_arr, {obj_mi_core key});
            
        end
        
        function remove_sim(obj, idx)            
            % remove a simulation from the list of sims
            obj.mi_core_arr(idx) = {};
        end
        
        function run_sims(obj)
            % run simulations in parallel or in serial
            
            % retrive simulation data and parameters from each mi_core object
            % populate single cell matrix of all data/params
            sim_set = cell(0,5);
            for i=1:size(obj.mi_core_arr,1)
                [tmp_core, tmp_key] = obj.mi_core_arr{i,:};
                tmp_set = get_core_dataset(tmp_core);
                tmp_set(:,5) = {tmp_key};
                sim_set = cat(1, sim_set, tmp_set);
            end
            
            % run MI calculations
            sim_data = cell(size(sim_set,1),4);
            if obj.par_mode > 0
                parfor i=1:length(sim_set)
                    tmp_sim_set = sim_set(i,:);
                    MI = MIxnyn(tmp_sim_set{1}, tmp_sim_set{2}, tmp_sim_set{3});
                    sim_data(i,:) = {MI tmp_sim_set(3) tmp_sim_set(4) tmp_sim_set(5)};
                end
            else
                for i=1:length(sim_set)
                    tmp_sim_set = sim_set(i,:);
                    MI = MIxnyn(tmp_sim_set{1}, tmp_sim_set{2}, tmp_sim_set{3});
                    sim_data(i,:) = {MI tmp_sim_set(3) tmp_sim_set(4) tmp_sim_set(5)};
                end
            end
            
            % return MI calculations to respective mi_core objects
            core_keys = unique([sim_data{:,4}]);
            for key_ix = 1:length(core_keys)
                data_ixs = find(strcmp([sim_data{:,4}], core_keys(key_ix)) == 1);
                core_ix = find(strcmp([obj.mi_core_arr(:,2)], core_keys(key_ix)) == 1);
                set_core_data(obj.mi_core_arr{core_ix}, sim_data(data_ixs,1:3));
            end
        end
        
    end
    
end