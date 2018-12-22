load('bl21lb21_171218_spikedata-0002-CH5.mat');
ts = spikedata.ts(:,1)*1000;
isi = diff(ts);

sim_manager = MI_KSG_sim_manager;

core1 = MI_KSG_core(sim_manager, isi(1:end-1), isi(2:end), [3 4 5], -1);

run_sims(sim_manager);

