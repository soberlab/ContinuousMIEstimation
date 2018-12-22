classdef MI_KSG_core < handle
    % MI_KSG_core is used to set up sets of simulations to determine an
    % optimum k-value for a mutual information estimate and also calculates
    % mutual information and estimation error.
    
    properties
        x % matrix of x data
        y % matrix of y data
        k_values % array of k-values
        mi_data % MI value, error estimate, data fraction
        opt_k % optimized k value; if -1, only runs MI calculation without any error estimate
        data_fracs = 10 % number of data fractions
        
        sim_obj % sim_manager object
    end
    
    methods
        function obj = MI_KSG_core(sim_obj, x, y, ks_arr, opt_k)
            obj.x = x;
            obj.y = y;            
            obj.sim_obj = sim_obj;

            if nargin == 3
                warning('Using default k-value of 3...');
                obj.k_values = 3;
                obj.opt_k = 3;
            elseif nargin == 4
                % Argument options for ks_arr
                % int   calculate MI for k-value
                % arr   calculate MI for multiple k-values
                obj.k_values = ks_arr;
                obj.opt_k = 0;
            elseif nargin == 5
                obj.k_values = ks_arr;
                obj.opt_k = opt_k;
            end
            
            add_sim(sim_obj, obj);
        end
        
        % These methods are used to interface with other classes for data
        % analysis and visualization        
        function r = get_core_dataset(obj)
            % get cell array of data for MI calculation
            r = {};
            if obj.opt_k < 0
                % only run MI calculation without error estimate
                for i=1:length(obj.k_values)
                    r = cat(1, r, {obj.x obj.y obj.k_values(i)});
                end
            else
                for i=1:length(obj.k_values)
                    r = cat(1, r, fractionate_data(obj, obj.k_values(i)));
                end
            end 
        end
        
        function set_core_data(obj, dataset)
            data_keys = unique([dataset{:,3}]);
            tmp_mi_data = cell(0,4);
            for key_ix = 1:length(data_keys)
                tmp_match = strcmp([dataset{:,3}], data_keys(key_ix));
                count = sum(tmp_match);
                data_ixs = find(tmp_match == 1);
                
                mi = [dataset{data_ixs,1}];
                k = dataset{data_ixs(1),2};
                
                tmp_mi_data = cat(1, tmp_mi_data, {mean(mi) var(mi) count k{1}});
            end
            obj.mi_data = sortrows(tmp_mi_data,[4,3]);
        end
        
        function r = get_mi(obj, k)
            % get mutual information and error estimates
            data_ixs = cell2mat(obj.mi_data(:,4)) == k;
            
            listSplitSizes = cell2mat(obj.mi_data(data_ixs,3));
            MIs = cell2mat(obj.mi_data(data_ixs,1));
            listVariances = cell2mat(obj.mi_data(data_ixs,2));
            listVariances = listVariances(2:end);
            
            k = listSplitSizes(2:end);
            variancePredicted = sum((k-1)./k.*listVariances)./sum((k-1));

            r.mi = MIs(1);
            r.err = variancePredicted^.5;
        end
        
%         function r = find_k_value(obj)
%             % determine best k-value to use
%         end
        
        function r = fractionate_data(obj, k)
            % return cell array of fractionated datasets with x-data,
            % y-data, k-value, and ix
            n = length(obj.x);
            r = cell(sum(1:obj.data_fracs),4);
            for frac_n = 1:obj.data_fracs
                a = randperm(n);
                l = round(linspace(0,n,frac_n+1));
                
                while 1
                    key = num2str(dec2hex(round(rand(1)*100000)));
                    if ~any(strcmp(r(:,4), key))
                        break;
                    end
                end
                    
                for j=1:frac_n
                    xT = obj.x(a(l(j)+1:l(j+1)));
                    yT = obj.y(a(l(j)+1:l(j+1)));
                    r(sum(1:(frac_n-1))+j,:) = {xT yT k key};
                end
            end
        end
        
    end
end