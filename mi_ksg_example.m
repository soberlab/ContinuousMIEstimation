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


a = core1.k_values;
b = 1:10;

m = cell2mat(core1.mi_data(:,1));
c = reshape(m, length(b), length(a));

figure();
surf(a, b, c, 'FaceAlpha', 0.5);
hold on;
plot3(core1.k_values, ones(1,length(core1.k_values)), c(1,:), 'k-', 'LineWidth', 5);

xlabel('k-value');
ylabel('Data Fraction (1/N)');
zlabel('MI (bits)');
