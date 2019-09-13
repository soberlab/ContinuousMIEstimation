% Initiate files to use in for loop
currentDirectory = uigetdir;

fileString = fullfile(currentDirectory, '*.mat');

files = dir(fileString);

%% FOR MI_xx files: Initiate for loop

for iFile = 1:length(files)
% Set filename
fileName = files(iFile).name;

figFileName = strcat(fileName(1:end-4),'_dataFracFig.png');

% Load file.
 load(fileName);
 
 % Set MI object (NOTE - this will need to be customized for each file)
 obj = MI_cc;
 
    
 % Next, find the number of subgroups in the calculation: 
 n_subgroups = size(obj.arrMIcore,1);
 
 % Set size of subplot
 
 nRows_plot = ceil(n_subgroups / 5);
 
 newFig = figure;
 
 % NOTE- arrMIcore is supposed to document the k-value used, but it seems
 % that this is currently not happening.We can get the optimal k-value from
 % each mi_ksg_core object in arrMIcore.
 
 % Iterate through each subgroup and make data fraction subplot. 
 for iSubgroup = 1:n_subgroups
     
    % Initiate subplot axes 
    %ax = subplot(nRows_plot,5,iSubgroup);
    ax = subplot(nRows_plot,1,iSubgroup);
    % Identify k value for this subgroup
    coreObj = obj.arrMIcore(iSubgroup,1);
    opt_k = coreObj{1,1}.opt_k;
    
    % Find the data fraction calculations that correspond to the optimized
    % k value
    mi_calcs = cell2mat(coreObj{1,1}.mi_data);
    
    dataFracIdx = find(mi_calcs(:,4) == opt_k);
    
    % Set variables for plot
    xs = mi_calcs(dataFracIdx,3);
    ys = mi_calcs(dataFracIdx,1);
    err = mi_calcs(dataFracIdx,2);
    
    % Make plot
    errorbar(ax,xs,ys,err,'-b','Marker','.','MarkerSize',15);
    
    % Set x limits
    xlim([min(xs)*0.8 max(xs)*1.1]);
    
    % Get rid of x labels
    set(gca,'xtick',[])

    % Set subplot title as the percentage of data in the subgroup
    %percentData = num2str(obj.arrMIcore{iSubgroup,2}*100);

    
    %figTitle = strcat(percentData,'%');
    
    %title(figTitle)
    
 end

 
 set(gca,'xtickMode', 'auto')
 
 saveas(newFig,figFileName);
 
end
%% FOR MI_xx_jitter files: Initiate for loop

for iFile = 1:length(files)
% Set filename
fileName = files(iFile).name;

% Load file.
 load(fileName);
 
 dataStruct = MIs;
 
 dataFields = fields(dataStruct);
 
 for iField = 1:length(dataFields)
     
 
 % Set MI object (NOTE - this will need to be customized for each file)
 obj = dataStruct(1).(dataFields{iField});
 
 
 % Next, find the number of subgroups in the calculation: 
 n_subgroups = size(obj.arrMIcore,1);
 
 % Set size of subplot
 
 nRows_plot = ceil(n_subgroups / 5);
 
 newFig = figure;
 
 % NOTE- arrMIcore is supposed to document the k-value used, but it seems
 % that this is currently not happening.We can get the optimal k-value from
 % each mi_ksg_core object in arrMIcore.
 
 % Iterate through each subgroup and make data fraction subplot. 
 for iSubgroup = 1:n_subgroups
     
    % Initiate subplot axes 
    %ax = subplot(nRows_plot,5,iSubgroup);
    ax = subplot(nRows_plot,1,iSubgroup);
    % Identify k value for this subgroup
    coreObj = obj.arrMIcore(iSubgroup,1);
    opt_k = coreObj{1,1}.opt_k;
    
    % Find the data fraction calculations that correspond to the optimized
    % k value
    mi_calcs = cell2mat(coreObj{1,1}.mi_data);
    
    dataFracIdx = find(mi_calcs(:,4) == opt_k);
    
    % Set variables for plot
    xs = mi_calcs(dataFracIdx,3);
    ys = mi_calcs(dataFracIdx,1);
    err = mi_calcs(dataFracIdx,2);
    
    % Make plot
    errorbar(ax,xs,ys,err,'-b','Marker','.','MarkerSize',15);
    
    % Set x limits
    xlim([min(xs)*0.8 max(xs)*1.1]);
    
    % Get rid of x labels
    set(gca,'xtick',[])
    
    % Set subplot title as the percentage of data in the subgroup
    %percentData = num2str(obj.arrMIcore{iSubgroup,2}*100);

    
    %figTitle = strcat(percentData,'%');
    
    %title(figTitle)

 end

 figFileName = strcat(fileName(1:end-4),dataFields{iField},'_dataFracFig.png');
 
 
 
 set(gca,'xtickMode', 'auto')
 
 saveas(newFig,figFileName);
 
 close all
 
 end
 
end