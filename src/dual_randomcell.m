% making plots of dividing and non-dividing
% this should be ran once you open up the joined_div and joined_nodiv files
% that were generated from the div detection script
% pick a number of divding and nondividing to show
load all_div_cells
load all_non_div

load med_DIV_ERK
load med_NODIV_ERK
med_DIV_ERK=allmed_DIV_ERK;
med_NODIV_ERK=allmed_NODIV_ERK;
%load joined_div
%load joined_nodiv
numofcells = 40;
%all_div_cells=joined_div;
%all_non_div=joined_nodiv;
len_min = min(length(all_non_div), length(all_div_cells))
random_cells = randi([1 len_min], 1, numofcells);
%random_cells = randi([1 length(all_non_div)],1,numofcells);
%%
figure

for i = 1:length(random_cells)
    plot(all_div_cells{6, random_cells(i)}, 'Color', [0 0 .8 .3])
    hold on
end

for i = 1:length(random_cells)
    plot(all_non_div{6, random_cells(i)}, 'Color', [.8 0 0 .2])
    hold on
end

plot(med_DIV_ERK, 'LineWidth', 3, 'Color', [0 0 1 1])
hold on
plot(med_NODIV_ERK, 'LineWidth', 3, 'Color', [1 0 0 1])
hold on
xlim([1 197])
ylim([0.5 1.4])
hrs = [-1	0 2 8.5	23 40 48]; %OG
tickPos = [1 6 14 40 97 165 197]; %OG

for i = 1:length(hrs)
    hrslabel{i} = num2str(hrs(i));
end

ax = gca;
set(gca, 'XTick', tickPos);
ax.XAxis.TickLabels = hrslabel;
xtickangle(45)
box(ax, 'off')
f = gcf;
ax.LineWidth = 1;
ax.FontSize = 10;
ax.Position = [0.076587301701027, 0.141638712772494, 0.891628786968138, 0.813123191989412];
hold off
set(gcf, 'PaperPositionMode', 'manual', 'PaperUnits', 'inches', 'PaperPosition', [0 0 3.5 2]);
savefig(gcf, ['randomERK'])
print(['randomERK'], '-dpng', '-r300')

load med_DIV_Akt
load med_NODIV_Akt
med_DIV_Akt=allmed_DIV_Akt;
med_NODIV_Akt=allmed_NODIV_Akt;
figure

for i = 1:length(random_cells)
    plot(all_div_cells{7, random_cells(i)}, 'Color', [0 0 .8 .3])
    hold on
end

for i = 1:length(random_cells)
    plot(all_non_div{7, random_cells(i)}, 'Color', [.8 0 0 .2])
    hold on
end

plot(med_DIV_Akt, 'LineWidth', 3, 'Color', [0 0 1 1])
hold on
plot(med_NODIV_Akt, 'LineWidth', 3, 'Color', [1 0 0 1])
hold on

xlim([1 198])
ylim([0.5 1.4])
hrs = [-1	0 2 8.5	23 40 48];
tickPos = [1 6 14 40 98 166 198];

for i = 1:length(hrs)
    hrslabel{i} = num2str(hrs(i));
end

% title(legendCell);
% xlabel('Time (Hrs)');
% ylabel('KTR Fluorescence A.U');
ax = gca;
set(gca, 'XTick', tickPos);
ax.XAxis.TickLabels = hrslabel;
xtickangle(45)
box(ax, 'off')
f = gcf;
ax.LineWidth = 1;
ax.FontSize = 10;
ax.Position = [0.073015873129598, 0.186876808010589, 0.891628786968138, 0.813123191989411]
hold off
set(gcf, 'PaperPositionMode', 'manual', 'PaperUnits', 'inches', 'PaperPosition', [0 0 3.5 2])
savefig(gcf, ['randomAkt'])
print(['randomAkt'], '-dpng', '-r300')
close all
