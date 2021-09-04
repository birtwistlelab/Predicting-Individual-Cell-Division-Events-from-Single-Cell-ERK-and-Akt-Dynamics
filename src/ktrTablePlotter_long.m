% Pick a maxtime based on the dataset 
load a
load maxtimeBC
% load maxtimeEF
for k=1:length(a)
%% Parsing out the important data, and adding Cyto:Nuc ratios for 15min timepoint
vars={'ImageImageNumber','ImageMetadata_Site',...
    'ImageMetadata_Time',...
    'NUCTrackObjects_Lifetime_65',...
    'CytoplasmIntensity_MedianIntensity_ktr',...
    'CytoplasmIntensity_MeanIntensity_ktr',...
    'NUCTrackObjects_Label_65',...
    'NUCIntensity_MedianIntensity_ktr',...
    'NUCIntensity_MeanIntensity_ktr','ImageMetadata_TP',...
    'NUCTrackObjects_FinalAge_65',...
    'NUCIntensity_MeanIntensity_DNA',...
    'CytoplasmIntensity_MeanIntensity_ktr',...
    'NUCIntensity_MeanIntensity_ktr'};
CellComputations1hr=a{1,k}(:,vars);
varname=[];
CellComputations1hr.Ratio=(CellComputations1hr.CytoplasmIntensity_MeanIntensity_ktr)./(CellComputations1hr.NUCIntensity_MeanIntensity_ktr);
fields=unique(a{k}.ImageMetadata_Site);

for i=1:length(fields)
    rows1hr=CellComputations1hr.ImageMetadata_Site==fields(i);
    byfielddata1hr{i}=CellComputations1hr(rows1hr,:);
end

for i=1:length(byfielddata1hr)
    rowsdeempty(1,i)=~isempty(byfielddata1hr{1,i});
end
byfielddata1hr=byfielddata1hr(rowsdeempty);
realfields=[];
for i=1:length(byfielddata1hr)
    realfields(1,i)=byfielddata1hr{1,i}.ImageMetadata_Site(1);
end
fields=realfields;
varname=convertStringsToChars(a{k}.ImageMetadata_Well(1));
% varname=strcat(wellname,num2str(a{k}.ImageMetadata_Well(1)));
save (['byfielddata1hr',' ',varname],'byfielddata1hr')
save (['CellComputations1hr',' ',varname],'CellComputations1hr')
save(['fields',' ',varname],'fields')
%% Life time suggested cells
LTvars={'ImageImageNumber','ImageMetadata_Time','ImageMetadata_Site','NUCTrackObjects_Label_65','NUCTrackObjects_FinalAge_65'...,
    'ImageMetadata_TP','NUCTrackObjects_Lifetime_65'};
Lifetime=CellComputations1hr(:,LTvars);
colzz={'NUCTrackObjects_Label_65','ImageMetadata_Site'};
for i=1:length(fields)
    rows1hr=Lifetime.ImageMetadata_Site==fields(i);
    byLIFEdata1hr{i}=CellComputations1hr(rows1hr,:);
    j=max((byLIFEdata1hr{i}.NUCTrackObjects_FinalAge_65)); %changed from finalage to lifetime
    rowsMaxLife1hr=byLIFEdata1hr{i}.NUCTrackObjects_FinalAge_65==j;
    HighbyLIFEdata1hr{i}=byLIFEdata1hr{i}(rowsMaxLife1hr,:);
    SuggestedCells1hr{i}=HighbyLIFEdata1hr{i}(:,colzz);
    SuggestedCells1hr{i}=sortrows(SuggestedCells1hr{i},1);
end
colzz={'NUCTrackObjects_Label_65','ImageMetadata_Site'};
for ii=1:length(fields)
    rows=byLIFEdata1hr{ii}.ImageImageNumber==byLIFEdata1hr{ii}.ImageImageNumber(1); % cells at tp 1
    atleast1hr{ii}=byLIFEdata1hr{ii}(rows,colzz);
    atleast1hr{ii}=sortrows(atleast1hr{ii},1);
end

cellsToPlot1hr={};
cellsToPlot1hr=atleast1hr;
%% table with all of the cells from each field you wanted
counter=1;
colVars={'ImageMetadata_TP','ImageMetadata_Time',...
    'ImageImageNumber','ImageMetadata_Site','NUCTrackObjects_Label_65','Ratio','CytoplasmIntensity_MeanIntensity_ktr','NUCIntensity_MeanIntensity_ktr'...
    'NUCIntensity_MeanIntensity_DNA'};
for j=1:length(fields)
    for jj=1:height(cellsToPlot1hr{j}(:,1))
        rows=byfielddata1hr{j}.NUCTrackObjects_Label_65==table2array(cellsToPlot1hr{j}(jj,1)); % replace j with 1
        joined_1hr{counter}=[byfielddata1hr{j}(rows,colVars)];
        counter=counter+1;
    end
end
for lmnop=1:length(joined_1hr)
    if height(joined_1hr{1,lmnop})<=32 % time filter
        joined_1hr{1,lmnop}=[];
    else
        if median(joined_1hr{1,lmnop}.Ratio(1:5))>1
            joined_1hr{1,lmnop}=[];
        else
            if median(joined_1hr{1,lmnop}.Ratio(6:end)>2)
                joined_1hr{1,lmnop}=[];
            else
            end
        end
    end
end
notemptycols=[];
for g=1:length(joined_1hr)
    notemptycols(g)=isempty(joined_1hr{1,g});
end
notemptycols=~notemptycols;
joined_1hr=joined_1hr(notemptycols);

expression='(\d*)';
for i=1:length(joined_1hr)
    ms_extract = regexp(joined_1hr{1,i}.ImageMetadata_Time,expression,'match');
    S = sprintf('%s ', ms_extract{:});
    ms_extract= sscanf(S, '%f');
    ms_extract_corrected=vertcat(ms_extract(1:5),(ms_extract(6:end)+4500000)); % ms offsets
    time_min=ms_extract_corrected(:,1)./60000; % Min
    time_hr=ms_extract_corrected(:,1)./3600000;% Hr
    joined_1hr{1,i}.time_min=time_min;
    joined_1hr{1,i}.time_hr=time_hr;
    
end
% Here we need to filter out cells that have a huge baseline
for lmnop=1:length(joined_1hr)
    if joined_1hr{1,lmnop}.Ratio>1.2 % time filter
        joined_1hr{1,lmnop}=[];
    else
    end
end
save (['joined_1hr',' ',varname],'joined_1hr')
%% plotting Indvidual cells
stringCell={};
stringField={};
cellLabels={};
for m=1:length(joined_1hr)
    stringCell{m}=num2str(joined_1hr{m}.NUCTrackObjects_Label_65(1),'cell %-d ');
    stringField{m}=num2str(joined_1hr{m}.ImageMetadata_Site(1),' field %-d');
    cellLabels{m}=[stringCell{m} ' ' stringField{m}];
end
gcf;
legendCell = (cellLabels);
%% Normalization 1hr
normalized_plots_1hr={};
for ii=1:length(joined_1hr);
    for jj=1:length(joined_1hr{ii}.Ratio);
        CellNormConst_1hr(1,ii)=median(joined_1hr{ii}.Ratio(1:5)); %Normalization for each individual cell changes for each run
        normalized_plots_1hr{ii}=joined_1hr{ii}(:,colVars);
        normalized_plots_1hr{ii}.Norm=joined_1hr{ii}.Ratio./CellNormConst_1hr(1,ii);
    end
end
save (['normalized_plots_1hr',' ',varname],'normalized_plots_1hr')
%% nuc data
figure;
for m=1:length(joined_1hr)    
        times=1:length(joined_1hr{m}.ImageMetadata_TP(1:end));
        plot(times,joined_1hr{m}.NUCIntensity_MeanIntensity_ktr,'LineWidth',1,'MarkerSize',3, 'MarkerEdgeColor','r')
    hold on
end
legendCell = cellLabels;
legend(legendCell)
xlim([1 198])
title(['All Cells KTR nuc Activity' ' ' varname]);
xlabel('Time (Hrs)');
ylabel('KTR nuc Fluorescence A.U');
% hrs needed
hrs=[0:2:48 49 49.25];
[LogArray,Loc]=ismember(hrs,maxtimes(:,2));
tickPos=Loc;
set(gca, 'XTick', tickPos);
for i=1:length(hrs)
    hrslabel{i}=num2str(hrs(i));
end
ax=gca;
ax.XAxis.TickLabels=hrslabel;
xtickangle(45)
set(gcf, 'PaperPositionMode','manual','PaperUnits','inches','PaperPosition',[10 10 10 10])
savefig(gcf,['48hr KTR nuc dynamics' ' ' varname])
print(['48hr KTR nuc dynamics' ' ' varname],'-dpng','-r300')
hold off
%% KTRdata
figure;
for m=1:length(joined_1hr)    
        times=1:length(joined_1hr{m}.ImageMetadata_TP(1:end));
        plot(times,joined_1hr{m}.Ratio,'LineWidth',1,'MarkerSize',3, 'MarkerEdgeColor','r')
    hold on
end
gcf;
legendCell = cellLabels;
legend(legendCell)
% hrs needed
hrs=[0:2:48 49 49.25];
[LogArray,Loc]=ismember(hrs,maxtimes(:,2));
tickPos=Loc;
set(gca, 'XTick', tickPos);
for i=1:length(hrs)
    hrslabel{i}=num2str(hrs(i));
end
xlim([1 198])
ylim([0 2])
title(['All Cells KTR Activity' ' ' varname]);
xlabel('Time (Hrs)');
ylabel('KTR Fluorescence A.U');
ax=gca;
ax.XAxis.TickLabels=hrslabel;
xtickangle(45)
set(gcf, 'PaperPositionMode','manual','PaperUnits','inches','PaperPosition',[10 10 10 10])
savefig(gcf,['48hr KTR dynamics' ' ' varname])
print(['48hr KTR dynamics' ' ' varname],'-dpng','-r300')
hold off
%% pop median
% figure;
% l=plot(AvgCells,'-k','LineWidth',6);
% gcf;
% xlim([1 150])
% legend(avglab)
% title('Population Median JNK KTR Activity');
% xlabel('Time (Hrs)');
% ylabel('JNK KTR Fluorescence A.U');
% set(gca, 'XTick', 0:6:150);
% ax=gca;
% ax.XAxis.TickLabels=hrslabel;
% xtickangle(45)
% set(gcf, 'PaperPositionMode','manual','PaperUnits','inches','PaperPosition',[10 10 10 10])
% savefig(gcf,'48hr Population JNK KTR dynamics')
% print(sprintf('48hr Population JNK KTR dynamics'),'-dpng','-r300')
%%  KTR subplots 5x5
hrs=[0 12 24 36 49.25];
[LogArray,Loc]=ismember(hrs,maxtimes(:,2));
tickPos=Loc;
for i=1:length(hrs)
    hrslabel{i}=num2str(hrs(i));
end
figure;
for i=1:length(hrs)
    hrslabel{i}=num2str(hrs(i));
end
plotThis=length(joined_1hr);
howmanyloops=ceil(plotThis/25);
counters=[1:1:25];
j=1;
m=1;
subplot = @(m,n,p) subtightplot (m, n, p, [0.1 0.05], [0.05 0.05], [0.05 0.03]);
for i=1:(howmanyloops)
    display(i)
    counters=[m:1:25*i];
    if (i*25)>length(joined_1hr);
        k=1:(length(joined_1hr)-((i-1)*25));
    else k=1:25;
    end
    for j=k
        subplot(5,5,j)
        times=1:length(joined_1hr{counters(j)}.ImageMetadata_TP(1:end));
        %    plot(normalized_plots_1hr{counters(j)}.Norm, ,'LineWidth',3,'MarkerSize',3, 'MarkerEdgeColor','r');
        plot(times,joined_1hr{counters(j)}.Ratio,'LineWidth',1,'MarkerSize',1, 'MarkerEdgeColor','r');
        %         xlabel('Time(Hrs)');
        %         ylabel('KTR');
        ylim([0 1.5])
        xlim([0 198]);
        set(gca, 'XTick', tickPos);
        ax=gca;
        ax.XAxis.TickLabels=hrslabel;
        xtickangle(45)
        title(cellLabels(counters(j)));
        m=m+1;
    end
    set(gcf, 'PaperPositionMode','manual','PaperUnits','inches','PaperPosition',[12 12 12 12])
    savefig([sprintf('KTR%d',i) ' ' varname])
    gcf;
    print([sprintf('KTR%d',i)  ' ' varname],'-dpng','-r200')
    clf
end
%%
clearvars -except a varname k maxtimes
close all
end
