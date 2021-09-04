%% pulling files that were cleaned from div detectionv2
% use this if youy fiddled with the output from detectionv2

load maxtime_198
myFolder = pwd;
filePattern = fullfile(myFolder, 'joined_1hr_parsed B*.mat');
matFiles = dir(filePattern);
expression = '(joined_1hr_parsed)  | \w*';

for k = 1:length(matFiles)
    well_extract = regexp(matFiles(k).name, expression, 'match');
    baseFileName = matFiles(k).name;
    fullFileName = fullfile(myFolder, baseFileName)
    fprintf(1, 'Now reading %s\n', fullFileName);
    fileID = load(fullFileName, '-mat');
    joined_1hr_parsed = fileID.joined_1hr_parsed;
    wellname = well_extract{1};
    div = ismember(cell2mat(joined_1hr_parsed(3, :)), 1);
    joined_div = {}
    joined_div = joined_1hr_parsed(:, div);
    nodiv = ismember(cell2mat(joined_1hr_parsed(3, :)), 0);
    joined_nodiv = joined_1hr_parsed(:, nodiv);
    sz = size(joined_div);
    sz_nd = size(joined_nodiv);

    for i = 1:sz(2)
        endtime = joined_div{4, i};
        joined_div{5, i} = joined_div{1, i}(1:endtime, :);
    end

    for i = 1:sz_nd(2)
        endtime = joined_nodiv{4, i};
        joined_nodiv{5, i} = joined_nodiv{1, i}(1:endtime, :);
    end

    %% before we plot we need to get the medians  of div and no div pops
    % DIV
    % nan pad the data so its all the same
    sizes = [];
    maxsize = [];
    padsizes = [];

    for i = 1:sz(2)
        sizes(i) = height(joined_div{5, i});
    end

    maxsize = max(sizes);
    padsizes = maxsize - sizes;

    for i = 1:sz(2)
        joined_div{6, i} = padarray(joined_div{5, i}.ERKRatio, padsizes(i), nan, 'post');
        joined_div{7, i} = padarray(joined_div{5, i}.AktRatio, padsizes(i), nan, 'post');

    end

    % ND
    sizes = [];
    maxsizeND = [];
    padsizes = [];
    sz_nd = size(joined_nodiv);

    for i = 1:sz_nd(2)
        sizes(i) = length(joined_nodiv{1, i}.ImageMetadata_TP);
    end

    maxsizeND = max(sizes);
    padsizes = maxsizeND - sizes;

    for i = 1:sz_nd(2)
        joined_nodiv{6, i} = padarray(joined_nodiv{1, i}.ERKRatio, padsizes(i), nan, 'post');
        joined_nodiv{7, i} = padarray(joined_nodiv{1, i}.AktRatio, padsizes(i), nan, 'post');
    end

    %% ERK,akt pop median
    % med_div_ERK joined_div {6}
    valueholder_ERK = [];
    valueholder_Akt = [];

    ERK_med_DIV = [];
    Akt_med_DIV = [];

    for ii = 1:maxsize

        for i = 1:sz(2)
            valueholder_ERK(i) = joined_div{6, i}(ii);
            valueholder_Akt(i) = joined_div{7, i}(ii);
        end

        ERK_med_DIV(ii) = nanmedian(valueholder_ERK);
        Akt_med_DIV(ii) = nanmedian(valueholder_Akt);

    end

    % med_noDIV=[];
    valueholdernd_ERK = [];
    valueholdernd_Akt = [];

    ERK_med_NODIV = [];
    Akt_med_NODIV = [];

    for ii = 1:maxsizeND

        for i = 1:sz_nd(2)
            valueholdernd_ERK(i) = joined_nodiv{6, i}(ii);
            valueholdernd_Akt(i) = joined_nodiv{7, i}(ii);

        end

        ERK_med_NODIV(ii) = nanmedian(valueholdernd_ERK);
        Akt_med_NODIV(ii) = nanmedian(valueholdernd_Akt);

    end

    save (['joined_div', wellname], 'joined_div')
    save (['joined_nodiv', wellname], 'joined_nodiv')

    %% ERK-6
    figure

    for i = 1:sz(2)
        plot(joined_div{5, i}.ERKRatio, 'b')
        hold on
    end

    for i = 1:sz_nd(2)
        plot(joined_nodiv{1, i}.ERKRatio, 'r')
        hold on
    end

    plot(ERK_med_DIV, 'linewidth', 3, 'Color', [0 0 .5 .8]) % for alpha= 0 to 1 the lines will be more clear
    plot(ERK_med_NODIV, 'linewidth', 3, 'Color', [.5 0 0 .8]) % for alpha= 0 to 1 the lines will be more clear
    ylim([0 1.6])

    hrs = [0:2:48 49];
    [LogArray, Loc] = ismember(hrs, maxtimes(:, 2));
    tickPos = Loc;
    set(gca, 'XTick', tickPos);

    for i = 1:length(hrs)
        hrslabel{i} = num2str(hrs(i));
    end

    ax = gca;
    ax.XAxis.TickLabels = hrslabel;
    xtickangle(45)
    set(gca, 'linewidth', 1)
    set(gca, 'FontSize', 6)
    % title(position)
    ax = gca
    box(ax, 'off')
    set(gcf, 'PaperPositionMode', 'manual', 'PaperUnits', 'inches', 'PaperPosition', [0 0 3 2])
    savefig(gcf, [wellname, ' ERK_Div_nd'])
    print([wellname, ' ERK_Div_nd'], '-dpng', '-r300')
    %% Akt-7
    figure

    for i = 1:sz(2)
        plot(joined_div{5, i}.AktRatio, 'b')
        hold on
    end

    for i = 1:sz_nd(2)
        plot(joined_nodiv{1, i}.AktRatio, 'r')
        hold on
    end

    plot(Akt_med_DIV, 'linewidth', 3, 'Color', [0 0 .5 .8]) % for alpha= 0 to 1 the lines will be more clear
    plot(Akt_med_NODIV, 'linewidth', 3, 'Color', [.5 0 0 .8]) % for alpha= 0 to 1 the lines will be more clear
    ylim([0 1.6])

    hrs = [0:2:48 49];
    [LogArray, Loc] = ismember(hrs, maxtimes(:, 2));
    tickPos = Loc;
    set(gca, 'XTick', tickPos);

    for i = 1:length(hrs)
        hrslabel{i} = num2str(hrs(i));
    end

    ax = gca;
    ax.XAxis.TickLabels = hrslabel;
    xtickangle(45)

    set(gca, 'linewidth', 1)
    set(gca, 'FontSize', 6)
    % title(position)
    ax = gca
    box(ax, 'off')
    set(gcf, 'PaperPositionMode', 'manual', 'PaperUnits', 'inches', 'PaperPosition', [0 0 3 2])
    savefig(gcf, [wellname, ' Akt_Div_nd'])
    print([wellname, ' Akt_Div_nd'], '-dpng', '-r300')

end

%% pulling and joining all the data together that was egf and ins treated
myFolder = pwd
filePattern = fullfile(myFolder, 'joined_div B*.mat');
matFiles = dir(filePattern);
expression = '(joined_div)  | \w*';
joined_div_all = {};

for k = 1:length(matFiles)
    well_extract = regexp(matFiles(k).name, expression, 'match');
    wellname = well_extract{1};

    if strcmp(wellname(4), '2') == 0
        baseFileName = matFiles(k).name;
        fullFileName = fullfile(myFolder, baseFileName)
        fprintf(1, 'Now reading %s\n', fullFileName);
        fileID = load(fullFileName, '-mat');
        joined_div_all{k} = fileID.joined_div;
    else
        continue
    end

end

all_div_cells = {};
all_div_cells = horzcat(joined_div_all{:});

%% we should not concider b02 or any 02
myFolder = pwd
filePattern = fullfile(myFolder, 'joined_nodiv B*.mat');
matFiles = dir(filePattern);
expression = '(joined_div)  | \w*';
joined_nodiv_all = {};

for k = 1:length(matFiles)
    well_extract = regexp(matFiles(k).name, expression, 'match');
    wellname = well_extract{1};

    if strcmp(wellname(4), '2') == 0
        baseFileName = matFiles(k).name;
        fullFileName = fullfile(myFolder, baseFileName)
        fprintf(1, 'Now reading %s\n', fullFileName);
        fileID = load(fullFileName, '-mat');
        joined_nodiv_all{k} = fileID.joined_nodiv;
        wellname = well_extract{1};
    else
        continue
    end

end

% all_non_div
all_non_div = horzcat(joined_nodiv_all{:});

save (['all_div_cells'], 'all_div_cells')
save (['all_non_div'], 'all_non_div')

%% need nan padding again
%DIV
% nan pad the data so its all the same
sizes = [];
maxsize = [];
padsizes = [];

for i = 1:length(all_div_cells)
    sizes(i) = all_div_cells{4, i};
end

maxsize = max(sizes);
padsizes = maxsize - sizes;

for i = 1:length(all_div_cells)
    all_div_cells{6, i} = padarray(all_div_cells{5, i}.ERKRatio, padsizes(i), nan, 'post');
    all_div_cells{7, i} = padarray(all_div_cells{5, i}.AktRatio, padsizes(i), nan, 'post');
end

% ND
sizes = [];
maxsizeND = [];
padsizes = [];

for i = 1:length(all_non_div)
    sizes(i) = length(all_non_div{1, i}.ImageMetadata_TP);
end

maxsizeND = max(sizes);
padsizes = maxsizeND - sizes;
% for i=1:length(all_non_div)
%      all_non_div{6,i}=padarray(all_non_div{1,i}.Ratio,padsizes(i),nan,'post');
% end

%% all_med_div for ERK and Akt
valueholder_ERK = [];
valueholder_Akt = [];
allmed_DIV_ERK = [];
allmed_DIV_Akt = [];

for ii = 1:maxsize

    for i = 1:length(all_div_cells)
        valueholder_ERK(i) = all_div_cells{6, i}(ii);
        valueholder_Akt(i) = all_div_cells{7, i}(ii);
    end

    allmed_DIV_ERK(ii) = nanmedian(valueholder_ERK);
    allmed_DIV_Akt(ii) = nanmedian(valueholder_Akt);
end

% med_noDIV=[];
valueholdernd_ERK = [];
valueholdernd_Akt = [];
allmed_NODIV_ERK = [];
allmed_Div_Akt = [];

for ii = 1:maxsizeND

    for i = 1:length(all_non_div)
        valueholdernd_ERK(i) = all_non_div{6, i}(ii);
        valueholdernd_Akt(i) = all_non_div{7, i}(ii);

    end

    allmed_NODIV_ERK(ii) = nanmedian(valueholdernd_ERK);
    allmed_NODIV_Akt(ii) = nanmedian(valueholdernd_Akt);

end

save (['all_div_cells'], 'all_div_cells')
save (['all_non_div'], 'all_non_div')
save (['allmed_DIV_ERK'], 'allmed_DIV_ERK')
save (['allmed_DIV_Akt'], 'allmed_DIV_Akt')
save (['allmed_NODIV_ERK'], 'allmed_NODIV_ERK')
save (['allmed_NODIV_Akt'], 'allmed_NODIV_Akt')
%%
% akt-7
figure

for i = 1:length(all_div_cells)
    plot(all_div_cells{5, i}.AktRatio, 'b')
    hold on
end

for i = 1:length(all_non_div)
    plot(all_non_div{1, i}.AktRatio, 'r')
    hold on
end

plot(allmed_DIV_Akt, 'linewidth', 3, 'Color', [0 0 .5 .8]) % for alpha= 0 to 1 the lines will be more clear
plot(allmed_NODIV_Akt, 'linewidth', 3, 'Color', [.5 0 0 .8]) % for alpha= 0 to 1 the lines will be more clear
hrs = [0:2:48 49];
[LogArray, Loc] = ismember(hrs, maxtimes(:, 2));
tickPos = Loc;
set(gca, 'XTick', tickPos);

for i = 1:length(hrs)
    hrslabel{i} = num2str(hrs(i));
end

ax = gca;
ax.XAxis.TickLabels = hrslabel;
xtickangle(45)
ylim([0 1.6])

set(gca, 'linewidth', 1)
set(gca, 'FontSize', 6)
% title(position)
ax = gca
box(ax, 'off')
set(gcf, 'PaperPositionMode', 'manual', 'PaperUnits', 'inches', 'PaperPosition', [0 0 3 2])
savefig(gcf, [' AKT_all_data_Div_nd'])
print([' AKT_all_data_Div_nd'], '-dpng', '-r300')

%%
% ERK-6
figure

for i = 1:length(all_div_cells)
    plot(all_div_cells{5, i}.ERKRatio, 'b')
    hold on
end

for i = 1:length(all_non_div)
    plot(all_non_div{1, i}.ERKRatio, 'r')
    hold on
end

plot(allmed_DIV_ERK, 'linewidth', 3, 'Color', [0 0 .5 .8]) % for alpha= 0 to 1 the lines will be more clear
plot(allmed_NODIV_ERK, 'linewidth', 3, 'Color', [.5 0 0 .8]) % for alpha= 0 to 1 the lines will be more clear
hrs = [0:2:48 49];
[LogArray, Loc] = ismember(hrs, maxtimes(:, 2));
tickPos = Loc;
set(gca, 'XTick', tickPos);

for i = 1:length(hrs)
    hrslabel{i} = num2str(hrs(i));
end

ax = gca;
ax.XAxis.TickLabels = hrslabel;
xtickangle(45)
ylim([0 1.6])

set(gca, 'linewidth', 1)
set(gca, 'FontSize', 6)
% title(position)
ax = gca
box(ax, 'off')
set(gcf, 'PaperPositionMode', 'manual', 'PaperUnits', 'inches', 'PaperPosition', [0 0 3 2])
savefig(gcf, [' ERK_all_data_Div_nd'])
print([' ERK_all_data_Div_nd'], '-dpng', '-r300')

%% plotting both ERK and Akt all medians single traces
figure
plot(allmed_DIV_ERK, 'linewidth', 3, 'Color', [0 0 .5 .8])
hold on % for alpha= 0 to 1 the lines will be more clear
plot(allmed_NODIV_ERK, 'linewidth', 3, 'Color', [.5 0 0 .8]) % for alpha= 0 to 1 the lines will be more clear
hrs = [0:2:48 49];
[LogArray, Loc] = ismember(hrs, maxtimes(:, 2));
tickPos = Loc;
set(gca, 'XTick', tickPos);

for i = 1:length(hrs)
    hrslabel{i} = num2str(hrs(i));
end

ylim([0 1.6])

ax = gca;
ax.XAxis.TickLabels = hrslabel;
xtickangle(45)
set(gca, 'linewidth', 1)
set(gca, 'FontSize', 6)
% title(position)
ax = gca
box(ax, 'off')
set(gcf, 'PaperPositionMode', 'manual', 'PaperUnits', 'inches', 'PaperPosition', [0 0 3 2])
savefig(gcf, [' ERK_Med_Div_nd'])
print([' ERK_Med_Div_nd'], '-dpng', '-r300')

%%
figure
plot(allmed_DIV_Akt, 'linewidth', 3, 'Color', [0 0 .5 .8])
hold on % for alpha= 0 to 1 the lines will be more clear
plot(allmed_NODIV_Akt, 'linewidth', 3, 'Color', [.5 0 0 .8]) % for alpha= 0 to 1 the lines will be more clear
hrs = [0:2:48 49];
[LogArray, Loc] = ismember(hrs, maxtimes(:, 2));
tickPos = Loc;
set(gca, 'XTick', tickPos);
ylim([0 1.6])

for i = 1:length(hrs)
    hrslabel{i} = num2str(hrs(i));
end

ax = gca;
ax.XAxis.TickLabels = hrslabel;
xtickangle(45)
set(gca, 'linewidth', 1)
set(gca, 'FontSize', 6)
% title(position)
ax = gca
box(ax, 'off')
set(gcf, 'PaperPositionMode', 'manual', 'PaperUnits', 'inches', 'PaperPosition', [0 0 3 2])
savefig(gcf, [' Akt_Med_Div_nd'])
print([' Akt_Med_Div_nd'], '-dpng', '-r300')

%%
%plotting both ERK and Akt Div and then ERK and Akt no div
figure
plot(allmed_DIV_ERK, 'linewidth', 3, 'Color', [.9 0 0 .8])
hold on % for alpha= 0 to 1 the lines will be more clear
plot(allmed_DIV_Akt, 'linewidth', 3, 'Color', [0 .8 0 .8]) % for alpha= 0 to 1 the lines will be more clear
hrs = [0:2:48 49];
[LogArray, Loc] = ismember(hrs, maxtimes(:, 2));
tickPos = Loc;
set(gca, 'XTick', tickPos);

for i = 1:length(hrs)
    hrslabel{i} = num2str(hrs(i));
end

ax = gca;
ylim([0 1.6])

ax.XAxis.TickLabels = hrslabel;
xtickangle(45)
set(gca, 'linewidth', 1)
set(gca, 'FontSize', 6)
% title(position)
ax = gca
box(ax, 'off')
set(gcf, 'PaperPositionMode', 'manual', 'PaperUnits', 'inches', 'PaperPosition', [0 0 3 2])
savefig(gcf, [' ERK_Akt_Med_Div'])
print([' ERK_Akt_Med_Div'], '-dpng', '-r300')
%%
figure
plot(allmed_NODIV_ERK, 'linewidth', 3, 'Color', [.9 0 0 .8])
hold on % for alpha= 0 to 1 the lines will be more clear
plot(allmed_NODIV_Akt, 'linewidth', 3, 'Color', [0 .8 0 .8]) % for alpha= 0 to 1 the lines will be more clear
hrs = [0:2:48 49];
[LogArray, Loc] = ismember(hrs, maxtimes(:, 2));
tickPos = Loc;
ylim([0 1.6])

set(gca, 'XTick', tickPos);

for i = 1:length(hrs)
    hrslabel{i} = num2str(hrs(i));
end

ax = gca;
ax.XAxis.TickLabels = hrslabel;
xtickangle(45)
set(gca, 'linewidth', 1)
set(gca, 'FontSize', 6)
% title(position)
ax = gca
box(ax, 'off')
set(gcf, 'PaperPositionMode', 'manual', 'PaperUnits', 'inches', 'PaperPosition', [0 0 3 2])
savefig(gcf, [' ERK_Akt_Med_NoDiv'])
print([' ERK_Akt_Med_NoDiv'], '-dpng', '-r300')

close all
