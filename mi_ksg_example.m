%% DATA ANALYSIS SAMPLE SCRIPT
close('all');

% Load spike times
load('bl21lb21_171218_spikedata-0002-CH5.mat');
ts = spikedata.ts(:,1)*1000;

% Load pressure data


% Instantiate data object
neural_data = mi_data(30000,30000);
add_spikes(neural_data, ts);

% Instantiate analysis object(s)
MI_isi = calc_isi_isi(neural_data, [1], 1, 200);

buildMIs(MI_isi);

% --> update k-values, etc.

MI_isi.arrMIcore{1}.opt_k = 0;
MI_isi.arrMIcore{1}.k_values = 3:8;

% Run mutual information calculations
calcMIs(MI_isi);


%% MAKE DATA PLOTS
core1 = MI_isi.arrMIcore{1};
viz = mi_ksg_viz;

make_ksg_graph(viz, core1);
plot_k_dependence(viz, core1);

for i=1:length(core1.k_values)
    plot_data_fraction(viz, core1, core1.k_values(i));
end

if size(core1.mi_data,1) > length(core1.k_values)
    a = core1.k_values;
    b = 1:10;

    m = cell2mat(core1.mi_data(:,1));
    c = reshape(m, length(b), length(a));

    figure();
    % plot mi surface
    surf(a, b, c, 'FaceAlpha', 0.5);
    hold on;
    
    % plot mi along data fracs = 1
    plot3(core1.k_values, ones(1,length(core1.k_values)), c(1,:), 'k-', 'LineWidth', 5);

    % plot optimal k-value
    k_ix = core1.k_values == core1.opt_k;
    k_ixs = [core1.mi_data{:,4}] == core1.opt_k;
    plot3(ones(1,length(b))*core1.opt_k, 1:10, c(:,k_ix), 'r-', 'LIneWidth', 5);
    
    xlabel('k-value');
    ylabel('Data Fraction (1/N)');
    zlabel('MI (bits)');
end