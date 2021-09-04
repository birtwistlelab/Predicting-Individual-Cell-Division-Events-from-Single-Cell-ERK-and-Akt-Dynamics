% here are the time intervals
% when we say 2h we mean 2h after gf addition ect
load all_div_cells
load all_non_div

%  akt and dual reporters use values below
w1s = 14;
w1e = 40;
w2s = 40;
w2e = 166;
w3s = 98;
w3e = 166;

% combine both non and dividing cells
% all_data={};
all_data = horzcat(all_div_cells, all_non_div);
B_w_ERK = {}; % ERK is row 6
B_w_Akt = {}; % Akt is row 7

% make sure that they are all the same size

for i = 1:length(all_data)
    B_w_ERK{1, i} = median(all_data{6, i}(w1s:w1e)); %145
    B_w_Akt{1, i} = median(all_data{7, i}(w1s:w1e)); %145
end

for i = 1:length(all_data)
    B_w_ERK{2, i} = nanmedian(all_data{6, i}(w2s:w2e)); %81
    B_w_Akt{2, i} = nanmedian(all_data{7, i}(w2s:w2e)); %81
end

for i = 1:length(all_data)
    B_w_ERK{3, i} = nanmedian(all_data{6, i}(w3s:w3e)); %41
    B_w_Akt{3, i} = nanmedian(all_data{7, i}(w3s:w3e)); %41
end

save (['B_w_ERK'], 'B_w_ERK')
save (['B_w_Akt'], 'B_w_Akt')
%
% making figures
top = 1.4
bottom = .6
div_values = all_data(3, :);

for i = 1:3
    figure
    bb = notBoxPlot(cell2mat(B_w_ERK(i, :)), cell2mat(div_values), 'markMedian', true)
    bb(1).med.Color = [1 0 0];
    bb(1).mu.Visible = 'off';
    bb(1).med.LineStyle = '-';
    bb(1).med.LineWidth = 2;
    bb(1).data.Marker = '.'
    bb(1).data.MarkerSize = 6
    bb(1).data.Color = [0 0 0]
    bb(1).data.MarkerFaceColor = [0 0 0]
    bb(1).sdPtch.FaceColor = [1 1 1]
    bb(1).sdPtch.EdgeColor = [0 0 0]
    bb(1).sdPtch.LineWidth = 2;
    bb(1).semPtch.FaceColor = [1 1 1]
    bb(1).semPtch.EdgeColor = [1 1 1]
    bb(1).semPtch.Visible = 'off'
    bb(2).data.MarkerSize = 6
    bb(2).med.Color = [1 0 0];
    bb(2).mu.Visible = 'off';
    bb(2).med.LineStyle = '-';
    bb(2).med.LineWidth = 2;
    bb(2).data.Marker = '.'
    bb(2).data.Color = [0 0 0]
    bb(2).data.MarkerFaceColor = [0 0 0]
    bb(2).sdPtch.FaceColor = [1 1 1]
    bb(2).sdPtch.EdgeColor = [0 0 0]
    bb(2).sdPtch.LineWidth = 2;
    bb(2).semPtch.FaceColor = [1 1 1]
    bb(2).semPtch.EdgeColor = [1 1 1]
    bb(2).semPtch.Visible = 'off'
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 3 2];
    xlim([-.5 1.5])
    ylim([bottom top])
    savefig(gcf, strcat('median_w_ERK', '_', num2str(i)))
    print(strcat('median_w_ERK', '_', num2str(i)), '-dpng', '-r300')
    values = [];
    values(1, :) = cell2mat(B_w_ERK(i, :)); %all values for ERK,
    values(2, :) = cell2mat(div_values); % divison status
    rowd = values(2, :) == 1; % rows containing dividing
    rownd = values(2, :) == 0; % rows containing non dividing
    values_div = values(1, rowd); % medians of div
    values_nodiv = values(1, rownd); % medians of non div
    [rankh_ERK(i), rankp_ERK(i)] = ranksum(values_div, values_nodiv, 'Tail', 'Right');
    clear rowd rownd
end

save (['rankh_ERK'], 'rankh_ERK')
save (['rankp_ERK'], 'rankp_ERK')
%%
top = 1.4
bottom = .6
div_values = all_data(3, :);

for i = 1:3
    figure
    bb = notBoxPlot(cell2mat(B_w_Akt(i, :)), cell2mat(div_values), 'markMedian', true)
    bb(1).med.Color = [1 0 0];
    bb(1).mu.Visible = 'off';
    bb(1).med.LineStyle = '-';
    bb(1).med.LineWidth = 2;
    bb(1).data.Marker = '.'
    bb(1).data.MarkerSize = 6
    bb(1).data.Color = [0 0 0]
    bb(1).data.MarkerFaceColor = [0 0 0]
    bb(1).sdPtch.FaceColor = [1 1 1]
    bb(1).sdPtch.EdgeColor = [0 0 0]
    bb(1).sdPtch.LineWidth = 2;
    bb(1).semPtch.FaceColor = [1 1 1]
    bb(1).semPtch.EdgeColor = [1 1 1]
    bb(1).semPtch.Visible = 'off'
    bb(2).data.MarkerSize = 6
    bb(2).med.Color = [1 0 0];
    bb(2).mu.Visible = 'off';
    bb(2).med.LineStyle = '-';
    bb(2).med.LineWidth = 2;
    bb(2).data.Marker = '.'
    bb(2).data.Color = [0 0 0]
    bb(2).data.MarkerFaceColor = [0 0 0]
    bb(2).sdPtch.FaceColor = [1 1 1]
    bb(2).sdPtch.EdgeColor = [0 0 0]
    bb(2).sdPtch.LineWidth = 2;
    bb(2).semPtch.FaceColor = [1 1 1]
    bb(2).semPtch.EdgeColor = [1 1 1]
    bb(2).semPtch.Visible = 'off'
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 3 2];
    xlim([-.5 1.5])
    ylim([.4 1.6])
    savefig(gcf, strcat('median_w_Akt', '_', num2str(i)))
    print(strcat('median_w_Akt', '_', num2str(i)), '-dpng', '-r300')
    values = [];
    values(1, :) = cell2mat(B_w_Akt(i, :));
    values(2, :) = cell2mat(div_values);
    rowd = values(2, :) == 1;
    rownd = values(2, :) == 0;
    values_div = values(1, rowd);
    values_nodiv = values(1, rownd);
    [rankh_Akt(i), rankp_Akt(i)] = ranksum(values_div, values_nodiv) %,'Tail', 'Right');
    clear rowd rownd
    % [vartest_h(i) vartest_p(i)]=vartest2(values_div,values_nodiv);
    % [Ttest_var_unequal_h(i) Ttest_var_unequal_p(i)]=ttest2(values_div,values_nodiv,'Tail','right','Vartype','unequal');
    % [Ttest_var_equal_h(i) Ttest_var_equal_p(i)]=ttest2(values_div,values_nodiv,'Tail','right','Vartype','equal');
end

save (['rankh_Akt'], 'rankh_Akt')
save (['rankp_Akt'], 'rankp_Akt')
%%
for i = 1:3
    figure
    bb = notBoxPlot(cell2mat(B_w_Akt(i, :)), cell2mat(div_values), 'markMedian', true)
    bb(1).med.Color = [1 0 0];
    bb(1).mu.Visible = 'off';
    bb(1).med.LineStyle = '-';
    bb(1).med.LineWidth = 2;
    bb(1).data.Marker = '.'
    bb(1).data.Color = [0 0 0]
    bb(1).data.MarkerFaceColor = [0 0 0]
    bb(1).sdPtch.FaceColor = [1 1 1]
    bb(1).sdPtch.EdgeColor = [0 0 0]
    bb(1).sdPtch.LineWidth = 2;
    bb(1).semPtch.FaceColor = [1 1 1]
    bb(1).semPtch.EdgeColor = [1 1 1]
    bb(1).semPtch.Visible = 'off'
    bb(1).data.MarkerSize = 6
    bb(2).data.MarkerSize = 6
    bb(2).med.Color = [1 0 0];
    bb(2).mu.Visible = 'off';
    bb(2).med.LineStyle = '-';
    bb(2).med.LineWidth = 2;
    bb(2).data.Marker = '.'
    bb(2).data.Color = [0 0 0]
    bb(2).data.MarkerFaceColor = [0 0 0]
    bb(2).sdPtch.FaceColor = [1 1 1]
    bb(2).sdPtch.EdgeColor = [0 0 0]
    bb(2).sdPtch.LineWidth = 2;
    bb(2).semPtch.FaceColor = [1 1 1]
    bb(2).semPtch.EdgeColor = [1 1 1]
    bb(2).semPtch.Visible = 'off'

    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 3 2];
    xlim([-.5 1.5])
    ylim([.6 1.4])
    savefig(gcf, strcat('median_w_Akt', '_', num2str(i)))
    print(strcat('median_w_Akt', '_', num2str(i)), '-dpng', '-r300')
    values = [];
    values(1, :) = cell2mat(B_w_Akt(i, :));
    values(2, :) = cell2mat(div_values);
    rowd = values(2, :) == 1;
    rownd = values(2, :) == 0;
    values_div = values(1, rowd);
    values_nodiv = values(1, rownd);
    [rankh_Akt(i), rankp_Akt(i)] = ranksum(values_div, values_nodiv, 'Tail', 'Right');
    clear rowd rownd
    % [vartest_h(i) vartest_p(i)]=vartest2(values_div,values_nodiv);
    % [Ttest_var_unequal_h(i) Ttest_var_unequal_p(i)]=ttest2(values_div,values_nodiv,'Tail','right','Vartype','unequal');
    % [Ttest_var_equal_h(i) Ttest_var_equal_p(i)]=ttest2(values_div,values_nodiv,'Tail','right','Vartype','equal');
end

save (['rankh_Akt'], 'rankh_Akt')
save (['rankp_Akt'], 'rankp_Akt')

%%
% BP with both erk and akt side by side
% erk div, erk no div, akt div, akt no div 1,2,3,4
howmany_div = length(all_div_cells)
howmany_nd = length(all_non_div)
B_w = horzcat(B_w_ERK, B_w_Akt);
div_values = all_data(3, :);
dual_div_values = [];
dual_div_values = cell2mat(horzcat(div_values, div_values));
dual_div_values(1:howmany_div) = 1;
dual_div_values(howmany_div + 1:howmany_div + howmany_nd) = 2;
dual_div_values(howmany_div + howmany_nd + 1:howmany_div + howmany_nd + howmany_div) = 3;
dual_div_values(howmany_div + howmany_nd + howmany_div + 1:length(dual_div_values)) = 4;
save (['dual_div_values'], 'dual_div_values')

%%
for i = 1:3 % three windows
    figure
    bb = notBoxPlot(cell2mat(B_w(i, :)), dual_div_values, 'markMedian', true)
    bb(1).med.Color = [1 0 0];
    bb(1).mu.Visible = 'off';
    bb(1).med.LineStyle = '-';
    bb(1).med.LineWidth = 2;
    bb(1).data.Marker = '.'
    bb(1).data.Color = [0 0 0]
    bb(1).data.MarkerFaceColor = [0 0 0]
    bb(1).sdPtch.FaceColor = [1 1 1]
    bb(1).sdPtch.EdgeColor = [0 0 0]
    bb(1).sdPtch.LineWidth = 2;
    bb(1).semPtch.FaceColor = [1 1 1]
    bb(1).semPtch.EdgeColor = [1 1 1]
    bb(1).semPtch.Visible = 'off'
    bb(1).data.MarkerSize = 3
    bb(2).data.MarkerSize = 3
    bb(2).med.Color = [1 0 0];
    bb(2).mu.Visible = 'off';
    bb(2).med.LineStyle = '-';
    bb(2).med.LineWidth = 2;
    bb(2).data.Marker = '.'
    bb(2).data.Color = [0 0 0]
    bb(2).data.MarkerFaceColor = [0 0 0]
    bb(2).sdPtch.FaceColor = [1 1 1]
    bb(2).sdPtch.EdgeColor = [0 0 0]
    bb(2).sdPtch.LineWidth = 2;
    bb(2).semPtch.FaceColor = [1 1 1]
    bb(2).semPtch.EdgeColor = [1 1 1]
    bb(2).semPtch.Visible = 'off'
    bb(3).data.MarkerSize = 3
    bb(3).med.Color = [0 0.8 0];
    bb(3).mu.Visible = 'off';
    bb(3).med.LineStyle = '-';
    bb(3).med.LineWidth = 2;
    bb(3).data.Marker = '.'
    bb(3).data.Color = [0 0 0]
    bb(3).data.MarkerFaceColor = [0 0 0]
    bb(3).sdPtch.FaceColor = [1 1 1]
    bb(3).sdPtch.EdgeColor = [0 0 0]
    bb(3).sdPtch.LineWidth = 2;
    bb(3).semPtch.FaceColor = [1 1 1]
    bb(3).semPtch.EdgeColor = [1 1 1]
    bb(3).semPtch.Visible = 'off'
    bb(2).data.MarkerSize = 3
    bb(4).data.MarkerSize = 3
    bb(4).med.Color = [0 0.8 0];
    bb(4).mu.Visible = 'off';
    bb(4).med.LineStyle = '-';
    bb(4).med.LineWidth = 2;
    bb(4).data.Marker = '.'
    bb(4).data.Color = [0 0 0]
    bb(4).data.MarkerFaceColor = [0 0 0]
    bb(4).sdPtch.FaceColor = [1 1 1]
    bb(4).sdPtch.EdgeColor = [0 0 0]
    bb(4).sdPtch.LineWidth = 2;
    bb(4).semPtch.FaceColor = [1 1 1]
    bb(4).semPtch.EdgeColor = [1 1 1]
    bb(4).semPtch.Visible = 'off'
    fig = gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 3 2];
    xlim([.5 4.5])
    ylim([.4 1.6])
    savefig(gcf, strcat('median_w_all', '_', num2str(i)))
    print(strcat('median_w_all', '_', num2str(i)), '-dpng', '-r300')
end
close all