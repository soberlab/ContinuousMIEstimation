close('all');

load('bl21lb21_171218_spikedata-0002-CH5.mat');
ts = spikedata.ts(:,1)*1000;
isi = diff(ts);

% identify only consecutive ISIs that are less than 200 ms

consec_isi = [isi(1:end-1) isi(2:end)];
consec_isi_ixs = find(sum(consec_isi,2) < 200 == 1);
isi = consec_isi(consec_isi_ixs,:);

sim_manager = MI_KSG_sim_manager;

core1 = MI_KSG_core(sim_manager, isi(:,1), isi(:,2), [3 4 5 6 7], 1);

run_sims(sim_manager);



viz = MI_KSG_data_viz;

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