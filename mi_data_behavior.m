classdef mi_data_behavior < handle
    properties
        raw_source % array or struct of raw files and data information
        
        cycleMethod % method used to calculate cycle times
        cycleTimes % cycle onset times
        cycleData % MAT object of raw data for each cycle
        
        verbose % boolean flag used to track progress and errors
    end
    
    methods
        function obj = mi_data_behavior(varargin)
            p = inputParser;
            addParameter(p, 'verbose', 1);
            parse(p, varargin{:});
            obj.verbose = p.Results.verbose;
        end
        
        function set_source()
            %% This function is implemented to set the raw source variable based on data collection and storage methods
            warning('Not implemented error: set_source()');
        end
        
        function calc_cycles()
            %% Implemented to take raw behavior recording and identify onset times
            warning('Not implemented error: calc_cycles()');
        end
        
        function get_feature()
            %% Implemented to return different features of behavior cycles
            % i.e., raw data, PCA, residual, area
            warning('Not implemented error: get_feature()');
        end
    end
end