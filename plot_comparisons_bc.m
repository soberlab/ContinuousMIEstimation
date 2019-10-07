%% Plot Consecutive ISI vs. Permutation

series = 'cc';
comparison = '2-3';


close('all');

% mi_consec = load('C:\Users\bpchung\Google Drive\_Research\__SOBER\__PROJECTS\Mutual Information\bl21lb21_171218_nmsort\consecutive_isi-Unit1.mat');
% mi_shuff = load('C:\Users\bpchung\Google Drive\_Research\__SOBER\__PROJECTS\Mutual Information\bl21lb21_171218_nmsort\consecutive_isi-Unit1-shuff.mat');

% mi_obj = load(['/Users/brycechung/Google Drive/_Research/__SOBER/__PROJECTS/Mutual Information/bl21lb21_171218_nmsort/mi_' series '_' comparison '_jitter.mat']);
% mi_shuff = load('/Users/brycechung/Google Drive/_Research/__SOBER/__PROJECTS/Mutual Information/bl21lb21_171218_nmsort/consecutive_isi-Unit2-shuff.mat');

% mi_consec = load('/Users/brycechung/Google Drive/_Research/__SOBER/__PROJECTS/Mutual Information/bl21lb21_171218_nmsort/mi_tc_1-3_jitter.mat');
% mi_shuff = load('C:\Users\bpchung\Google Drive\_Research\__SOBER\__PROJECTS\Mutual Information\bl21lb21_171218_nmsort\consecutive_isi-Unit3-z-shuff.mat');

k = 3;
noises = [0 1 2 3 5 10 20];
noises_offset = 0.2;


fig = figure();
set(gcf, 'color', 'w');

xs = zeros(length(noises),1);
errs = zeros(length(noises),1);

for i=1:length(noises)
    if strcmp(series, 'cc')
        % NEED TO RECODE THIS
        try
            mi_obj = load(['/Users/brycechung/Google Drive/_Research/__SOBER/__PROJECTS/Mutual Information/bl21lb21_171218_nmsort/mi_' series '_' comparison '_jitter.mat']);
            mi_core = mi_obj.MIs.(['sig' num2str(noises(i))]).arrMIcore{1};
        catch
            mi_obj = load(['/Users/brycechung/Google Drive/_Research/__SOBER/__PROJECTS/Mutual Information/bl21lb21_171218_nmsort/mi_' series '_' comparison '.mat']);
            mi_core = mi_obj.(['MI_' series]).arrMIcore{1};
        end
        
        mi = mi_core.get_mi(mi_core.opt_k);
    
        xs(i) = mi.mi;
        errs(i) = mi.err;
    else
        arr_mi = zeros(length(mi_cores),1);
        arr_p = zeros(length(mi_cores),1);
        arr_err = zeros(length(mi_cores),1);

        try
            mi_cores = mi_obj.MIs.(['sig' num2str(noises(i))]).arrMIcore;
%             disp('hello');
        catch
            mi_consec = load(['/Users/brycechung/Google Drive/_Research/__SOBER/__PROJECTS/Mutual Information/bl21lb21_171218_nmsort/mi_' series '_' comparison '.mat']);
            mi_cores = mi_consec.(['MI_' series]).arrMIcore;
        end
        
        for j=1:length(mi_cores)
            mi_core = mi_cores(j,:);
            mi = mi_core{1}.get_mi(mi_core{1}.opt_k);
            arr_mi(j) = max(mi.mi, 0);
            arr_err(j) = mi.err;
            
            arr_p(j) = mi_cores{j,2};
        end
        
        xs(i) = sum(arr_mi.*arr_p);
        errs(i) = (sum((arr_p(~isnan(arr_err)).*arr_err(~isnan(arr_err))).^2))^0.5;
        
    end

end

% xs_shuff = zeros(length(fields(mi_shuff.MIs)),1);
% errs_shuff = zeros(length(fields(mi_shuff.MIs)),1);
% 
% for i=1:length(xs_shuff)
%     mi = mi_shuff.MIs.(['sig' num2str(noises(i))]).arrMIcore{1}.get_mi(k);
%     xs_shuff(i) = mi.mi;
%     errs_shuff(i) = mi.err;
% end



% fill([noises flip(noises)], [(xs_shuff+errs_shuff)' flip(xs_shuff-errs_shuff)'], 'r', 'FaceAlpha', 0.1, 'EdgeColor', 'none');
hold on;
fill([noises flip(noises)], [(xs+errs)' flip(xs-errs)'], 'k', 'FaceAlpha', 0.1, 'EdgeColor', 'none');
hold on;

% plot(noises, xs_shuff, 'r', 'LineWidth', 1);
plot(noises, xs, 'k', 'LineWidth', 2);

xlim([noises(1)-1 noises(end)+1]);
xlabel('Noise (sigma)');
ylabel('Mutual Information (bits)');

suptitle([series ': ' comparison]);

%% Calculate MI for timing-timing

load('mi_tc_3-3.mat');

n_terms = length(MI_tc.arrMIcore);

mi = zeros(n_terms,1);
ps = zeros(n_terms,1);

for i=1:n_terms
    mi(i) = MI_tc.arrMIcore{i}.get_mi(MI_tc.arrMIcore{i}.opt_k).mi;
    ps(i) = MI_tc.arrMIcore{i,2};
end

total_tt_mi = sum(mi.*ps);

