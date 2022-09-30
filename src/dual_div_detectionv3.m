%% pulling files that were cleaned from div detectionv2
% use this if youy fiddled with the output from detectionv2
myFolder='C:\Users\elit3\Documents\dual reporter\12 18 20\fixed\testing c\joinedParsed\cleaned\joinedparseviews\very clean' % or just your working folder.. 6 or half dozen
filePattern = fullfile(myFolder, 'joined_1hr_parsed C*.mat');
matFiles = dir(filePattern);
expression='(joined_1hr_parsed)  | \w*';

for k = 1:length(matFiles)
well_extract = regexp(matFiles(k).name,expression,'match');
baseFileName = matFiles(k).name;
fullFileName = fullfile(myFolder, baseFileName)
fprintf(1, 'Now reading %s\n', fullFileName);
fileID = load(fullFileName,'-mat');
joined_1hr_parsed=fileID.joined_1hr_parsed;
wellname=well_extract{1};

%%NOW WE ARE GOING TO SEPERATE BASED ON DIV OR NO DIV, while also trimming
%%the data to the point of dividison or the entire time deries
i=[];
div = ismember(cell2mat(joined_1hr_parsed(3,:)),1);
joined_div=joined_1hr_parsed(:,div);
nodiv=ismember(cell2mat(joined_1hr_parsed(3,:)),0) ;
joined_nodiv=joined_1hr_parsed(:,nodiv);
sizejoined_div=size(joined_div,2);
sizejoined_nodiv=size(joined_nodiv,2);
for i=1:sizejoined_div
    endtime=joined_div{4,i};
    joined_div{5,i}=joined_div{1,i}(1:endtime,:);
    
end
i=[];
for i=1:sizejoined_nodiv
    endtime=joined_nodiv{4,i};
    if endtime==0;
        joined_nodiv{5,i}=joined_nodiv{1,i};
    else
        continue
    end
end

celldiv=~cellfun(@isempty,joined_nodiv(5,:));
joined_nodiv=joined_nodiv(:,celldiv);

%% before we plot we need to get the medians  of div and no div pops
% DIV
% nan pad the data so its all the same to 198
sz=size(joined_div);
sz_nd=size(joined_nodiv);

sizes=[];
maxsize=[];
padsizes=[];
for i=1:sizejoined_div
    sizes(i)=length(joined_div{5,i}.ERKRatio);
end
maxsize=198;
padsizes=maxsize-sizes;
for i=1:sizejoined_div
    joined_div{6,i}=padarray(joined_div{5,i}.ERKRatio,padsizes(i),nan,'post');
    joined_div{7,i}=padarray(joined_div{5,i}.AktRatio,padsizes(i),nan,'post');
    
end
% ND
sizes=[];
maxsizeND=[];
padsizes=[];
for i=1:sizejoined_nodiv
    sizes(i)=length(joined_nodiv{1,i}.ERKRatio);
end
maxsizeND=max(sizes);
padsizes=maxsizeND-sizes;
for i=1:sizejoined_nodiv
    joined_nodiv{6,i}=padarray(joined_nodiv{1,i}.ERKRatio,padsizes(i),nan,'post');
    joined_nodiv{7,i}=padarray(joined_nodiv{1,i}.AktRatio,padsizes(i),nan,'post');
end
% getting the meds
valueholder_ERK=[];
valueholder_Akt=[];
med_DIV=[];
for ii=1:maxsize
    for i=1:sz(2)
        valueholder_ERK(i)=joined_div{6,i}(ii);
        valueholder_Akt(i)=joined_div{7,i}(ii);
    end
    med_DIV_ERK(ii)=nanmedian(valueholder_ERK) ;
    med_DIV_Akt(ii)=nanmedian(valueholder_Akt) ;
    
end
% med_noDIV=[];
valueholdernd_ERK=[];
valueholdernd_Akt=[];
med_NODIV=[];
for ii=1:maxsizeND
    for i=1:sz_nd(2)
        valueholdernd_ERK(i)=joined_nodiv{6,i}(ii);
        valueholdernd_Akt(i)=joined_nodiv{7,i}(ii);
    end
    med_NODIV_ERK(ii)=nanmedian(valueholdernd_ERK) ;
    med_NODIV_Akt(ii)=nanmedian(valueholdernd_Akt) ;
    
end
save (['joined_div',wellname],'joined_div')
save (['joined_nodiv',wellname],'joined_nodiv')
save (['med_NODIV_ERK',wellname],'med_NODIV_ERK')
save (['med_DIV_ERK',wellname],'med_DIV_ERK')
save (['med_NODIV_Akt',wellname],'med_NODIV_Akt')
save (['med_DIV_Akt',wellname],'med_DIV_Akt')
%% ERK div no div
%ERK IS ROW 6 
figure
for i=1:sz(2)
    plot(joined_div{6,i},'b')
    hold on
end
for i=1:sz_nd(2)
    plot(joined_nodiv{6,i},'r')
    hold on
end
plot(med_DIV_ERK,'linewidth',3,'Color',[0 0 .5 .8])
plot(med_NODIV_ERK,'linewidth',3,'Color',[.5 0 0 .8])
hrs=[0:2:48 49];
[LogArray,Loc]=ismember(hrs,maxtimes(:,2));
tickPos=Loc;
set(gca, 'XTick', tickPos);
for i=1:length(hrs)
    hrslabel{i}=num2str(hrs(i));
end
ax=gca;
ax.XAxis.TickLabels=hrslabel;
xtickangle(45)
set(gca,'linewidth',1)
set(gca,'FontSize',6)
% title(position)
ax=gca
box(ax,'off')
set(gcf, 'PaperPositionMode','manual','PaperUnits','inches','PaperPosition',[0 0 3 2])
savefig(gcf,[wellname,' ERK'])
print([wellname,' ERK'],'-dpng','-r300')
%% Akt 
figure
for i=1:sz(2)
    plot(joined_div{7,i},'b')
    hold on
end
for i=1:sz_nd(2)
    plot(joined_nodiv{7,i},'r')
    hold on
end
plot(med_DIV_Akt,'linewidth',3,'Color',[0 0 .5 .8]) % for alpha= 0 to 1 the lines will be more clear
plot(med_NODIV_Akt,'linewidth',3,'Color',[.5 0 0 .8]) % for alpha= 0 to 1 the lines will be more clear
hrs=[0:2:48 49];
[LogArray,Loc]=ismember(hrs,maxtimes(:,2));
tickPos=Loc;
set(gca, 'XTick', tickPos);
for i=1:length(hrs)
    hrslabel{i}=num2str(hrs(i));
end
ax=gca;
ax.XAxis.TickLabels=hrslabel;
xtickangle(45)
set(gca,'linewidth',1)
set(gca,'FontSize',6)
ax=gca
box(ax,'off')
set(gcf, 'PaperPositionMode','manual','PaperUnits','inches','PaperPosition',[0 0 3 2])
savefig(gcf,[wellname,' AKT'])
print([wellname,' AKT'],'-dpng','-r300')
end

    %% pulling and joining all the data for dividing cells
myFolder='C:\Users\elit3\Documents\dual reporter\12 18 20\fixed\testing c\joinedParsed\cleaned\joinedparseviews\very clean'
filePattern = fullfile(myFolder, 'joined_div C*.mat');
matFiles = dir(filePattern);
expression='(joined_div)  | \w*';
joined_div_all={};
for k = 1:length(matFiles)
    well_extract = regexp(matFiles(k).name,expression,'match');
    wellname=well_extract{1};
    if strcmp(wellname(4),'2')==0
        baseFileName = matFiles(k).name;
        fullFileName = fullfile(myFolder, baseFileName)
        fprintf(1, 'Now reading %s\n', fullFileName);
        fileID = load(fullFileName,'-mat');
        joined_div_all{k}=fileID.joined_div;
    else
        continue
    end
end
all_div_cells={};
all_div_cells=horzcat(joined_div_all{:});
%% we should not concider b02 or any 02
myFolder='C:\Users\elit3\Documents\dual reporter\12 18 20\fixed\testing c\joinedParsed\cleaned\joinedparseviews\very clean'
filePattern = fullfile(myFolder, 'joined_nodiv C*.mat');
matFiles = dir(filePattern);
expression='(joined_div)  | \w*';
joined_nodiv_all={};
for k = 1:length(matFiles)
    well_extract = regexp(matFiles(k).name,expression,'match');
    wellname=well_extract{1};
    if strcmp(wellname(4),'2')==0
        baseFileName = matFiles(k).name;
        fullFileName = fullfile(myFolder, baseFileName)
        fprintf(1, 'Now reading %s\n', fullFileName);
        fileID = load(fullFileName,'-mat');
        joined_nodiv_all{k}=fileID.joined_nodiv;
        wellname=well_extract{1};
    else
        continue
    end
end
all_non_div=horzcat(joined_nodiv_all{:});
save (['all_div_cells'],'all_div_cells')
save (['all_non_div'],'all_non_div')
%% getting the meds across all cells from all wells
% med_div_ERK and Akt
valueholder_ERK=[];
valueholder_Akt=[];
med_DIV=[];
med_DIV_ERK=[];
med_DIV_Akt=[];
for ii=1:maxsize
    for i=1:sz(2)
        valueholder_ERK(i)=all_div_cells{6,i}(ii);
        valueholder_Akt(i)=all_div_cells{7,i}(ii);
        
    end
    med_DIV_ERK(ii)=nanmedian(valueholder_ERK) ;
    med_DIV_Akt(ii)=nanmedian(valueholder_Akt) ;
    
end
% med_noDIV=[];
valueholdernd_ERK=[];
valueholdernd_Akt=[];
med_NODIV=[];
for ii=1:maxsizeND
    for i=1:sz_nd(2)
        valueholdernd_ERK(i)=all_non_div{6,i}(ii);
        valueholdernd_Akt(i)=all_non_div{7,i}(ii);
    end
    med_NODIV_ERK(ii)=nanmedian(valueholdernd_ERK) ;
    med_NODIV_Akt(ii)=nanmedian(valueholdernd_Akt) ;
end
save (['med_DIV_ERK'],'med_DIV_ERK')
save (['med_NODIV_ERK'],'med_NODIV_ERK')
save (['med_DIV_Akt'],'med_DIV_Akt')
save (['med_NODIV_Akt'],'med_NODIV_Akt')
%% ERK div and no dive
figure
for i=1:length(all_div_cells)
    plot(all_div_cells{6,i},'b')
    hold on
end

for i=1:length(all_non_div)
    plot(all_non_div{6,i},'r')
    hold on
end

plot(med_DIV_ERK,'linewidth',3,'Color',[0 0 .5 .8]) % for alpha= 0 to 1 the lines will be more clear
plot(med_NODIV_ERK,'linewidth',3,'Color',[.5 0 0 .8]) % for alpha= 0 to 1 the lines will be more clear
hrs=[0:2:48 49];
[LogArray,Loc]=ismember(hrs,maxtimes(:,2));
tickPos=Loc;
set(gca, 'XTick', tickPos);
for i=1:length(hrs)
    hrslabel{i}=num2str(hrs(i));
end
ax=gca;
ax.XAxis.TickLabels=hrslabel;
xtickangle(45)
set(gca,'linewidth',1)
set(gca,'FontSize',6)
% title(position)
ax=gca
box(ax,'off')
    set(gcf, 'PaperPositionMode','manual','PaperUnits','inches','PaperPosition',[0 0 3 2])
    savefig(gcf,[wellname,' all_data_Div_nd'])
    print([wellname,' all_data_Div_nd'],'-dpng','-r300')
%% Akt div and no dive
figure
for i=1:length(all_div_cells)
    plot(all_div_cells{7,i},'b')
    hold on
end
for i=1:length(all_non_div)
    plot(all_non_div{7,i},'r')
    hold on
end
plot(med_DIV_Akt,'linewidth',3,'Color',[0 0 .5 .8]) % for alpha= 0 to 1 the lines will be more clear
plot(med_NODIV_Akt,'linewidth',3,'Color',[.5 0 0 .8]) % for alpha= 0 to 1 the lines will be more clear
hrs=[0:2:48 49];
[LogArray,Loc]=ismember(hrs,maxtimes(:,2));
tickPos=Loc;
set(gca, 'XTick', tickPos);
for i=1:length(hrs)
    hrslabel{i}=num2str(hrs(i));
end
ax=gca;
ax.XAxis.TickLabels=hrslabel;
xtickangle(45)
set(gca,'linewidth',1)
set(gca,'FontSize',6)
% title(position)
ax=gca
box(ax,'off')
set(gcf, 'PaperPositionMode','manual','PaperUnits','inches','PaperPosition',[0 0 3 2])
savefig(gcf,[wellname,' all_data_Div_nd'])
print([wellname,' all_data_Div_nd'])