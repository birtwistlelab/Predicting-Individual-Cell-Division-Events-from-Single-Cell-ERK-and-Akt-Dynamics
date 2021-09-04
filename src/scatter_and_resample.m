% to run this you need to load up the seperated division and non div data
% note the time window you want to run this in
load all_div_cells
load all_non_div

w2 = [40 166]; % in TPs
windows = w2;
size_window = size(windows);
div_cells_scatter = [];
erkdata = [];
aktdata = [];
j = 1;

for i = 1:length(all_div_cells)
    erkdata(:, i) = all_div_cells{6, i}(windows(j, 1):windows(j, 2));
    aktdata(:, i) = all_div_cells{7, i}(windows(j, 1):windows(j, 2));
end

erkdata(isnan(erkdata)) = [];
aktdata(isnan(aktdata)) = [];
window_ERK_div{1, j} = erkdata;
window_Akt_div{1, j} = aktdata;
erkdata = [];
aktdata = [];

for i = 1:length(all_non_div)
    erkdata(:, i) = all_non_div{6, i}(windows(j, 1):windows(j, 2));
    aktdata(:, i) = all_non_div{7, i}(windows(j, 1):windows(j, 2));
end

erkdata(isnan(erkdata)) = [];
aktdata(isnan(aktdata)) = [];
window_ERK_nddiv{1, j} = erkdata;
window_Akt_nddiv{1, j} = aktdata;
erkdata = [];
aktdata = [];

%%
div_cells_scatter = [];
nd_cells_scatter = [];

for i = 1
    akt_div_temp = reshape(window_Akt_div{1, i}, [], 1);
    erk_div_temp = reshape(window_ERK_div{1, i}, [], 1);
    akt_nddiv_temp = reshape(window_Akt_nddiv{1, i}, [], 1);
    erk_nddiv_temp = reshape(window_ERK_nddiv{1, i}, [], 1);
    div_cells_scatter(i) = unique(corr(akt_div_temp, erk_div_temp, 'rows', 'complete'));
    nd_cells_scatter(i) = unique(corr(akt_nddiv_temp, erk_nddiv_temp, 'rows', 'complete'));
    figure
    scatplot(erk_div_temp, akt_div_temp)
    gcf;
    ylim([0 1.5])
    xlim([0 1.5])
    xlabel('ERK activity')
    ylabel('Akt activity')
    savefig(gcf, strcat('global interval div', '_', num2str(i)))
    print(strcat('global interval div', '_', num2str(i)), '-dpng', '-r300')
    figure
    scatplot(erk_nddiv_temp, akt_nddiv_temp)
    gcf;
    ylim([0 1.5])
    xlim([0 1.5])
    xlabel('ERK activity')
    ylabel('Akt activity')
    savefig(gcf, strcat('global interval nddiv', '_', num2str(i)))
    print(strcat('global interval nddiv', '_', num2str(i)), '-dpng', '-r300')
end

%% here we are going to get a binomial distribution sampling going
% Multivariate normal random numbers
% here we are going to get a binomial distribution sampling for div
meanERK = mean(erk_div_temp);
meanAKT = mean(akt_div_temp);
mu = [meanERK, meanAKT];
varERK = var(erk_div_temp);
varAkt = var(akt_div_temp);
corr_sigma = corr(erk_div_temp, akt_div_temp);
C = cov(erk_div_temp, akt_div_temp)
% Sigma=[varERK corr_sigma;corr_sigma varAkt];
n = length(erk_div_temp);
% now we make the random dist, sample many times and take corr coef
parfor i = 1:n
    R = [];
    R = mvnrnd(mu, C, n);
    corr_coef_randomsample(i) = (corr(R(:, 1), R(:, 2)));
end

min_max_corr = [min(corr_coef_randomsample), max(corr_coef_randomsample)];
%% making figs
% here we are going to get a binomial distribution sampling for nondiv
% Multivariate normal random numbers
meanERK = mean(erk_nddiv_temp);
meanAKT = mean(akt_nddiv_temp);
mu = [meanERK, meanAKT];
varERK = var(erk_nddiv_temp);
varAkt = var(akt_nddiv_temp);
corr_sigma = corr(erk_nddiv_temp, akt_nddiv_temp);
C = cov(erk_nddiv_temp, akt_nddiv_temp);
% [var erk covarerk   ]
% [covarakt    var Akt]
Sigma = [varERK corr_sigma; corr_sigma varAkt];
n = length(erk_nddiv_temp);

parfor i = 1:n
    R_nd = [];
    R_nd = mvnrnd(mu, C, n);
    corr_coef_randomsample_ND(i) = (corr(R_nd(:, 1), R_nd(:, 2)));
end

min_max_corr_ND = [min(corr_coef_randomsample_ND), max(corr_coef_randomsample_ND)];
percent_5_div = prctile(corr_coef_randomsample, 5);
percent_95_div = prctile(corr_coef_randomsample, 95);
percentiledif = percent_95_div - percent_5_div;
percent_5_nddiv = prctile(corr_coef_randomsample_ND, 5);
percent_95_nddiv = prctile(corr_coef_randomsample_ND, 95);
percentiledif_nd = percent_95_nddiv - percent_5_nddiv;

save(['scatter_results'], 'min_max_corr_ND', 'percent_5_div', 'percent_95_div', 'percentiledif', 'percent_5_nddiv', 'percent_95_nddiv', 'percentiledif_nd')
close all
