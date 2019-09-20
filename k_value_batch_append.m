% Initiate files to use in for loop
currentDirectory = uigetdir;

fileString = fullfile(currentDirectory, '*.mat');

files = dir(fileString);

%% FOR MI_xx files: Initiate for loop to batch run new k_value sims
newFileSavePath = '/Users/Rachel/ContinuousMIEstimation/Ilya_09062019/bl21lb21_171218_nmsort_k1-9/';

%for iFile = 1:length(files)
    fileName = 'mi_tc_1-2.mat';
    % Load current data file
    load(fileName);
    
    % Set MI object (NOTE- this needs to be customized for each type
    obj = MI_tc;
    
    % Next, find the number of subgroups in the calculation: 
    n_subgroups = size(obj.arrMIcore,1);
    
    % Iterate through each subgroup to change the k_value for each core
    % object
    for iSubgroup = 1:n_subgroups
        
        % Change the values of k to include for the core object for each
        % subgroup
        obj.arrMIcore{iSubgroup,1}.k_values = 1:9;
        
    end
    
    % Run the sims for the new k values
    calcMIs(obj,1);
    
    MI_tc = obj;
    
    saveFilePath = strcat(newFileSavePath,fileName);
    
    save(saveFilePath,'MI_tc')
    
    clearvars -except currentDirectory fileString files iFile newFileSavePath
    
%end