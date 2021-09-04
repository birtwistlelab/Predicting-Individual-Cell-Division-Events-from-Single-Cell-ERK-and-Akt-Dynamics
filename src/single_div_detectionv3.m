%% pulling files
load maxtimeBC
myFolder=pwd;
filePattern = fullfile(myFolder, 'joined_1hr_parsed B*.mat');
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
    
    %%NOW WE ARE GOING TO SEPERATE BASED ON DIV OR NO DIV
    div = ismember(cell2mat(joined_1hr_parsed(3,:)),1);
    joined_div=joined_1hr_parsed(:,div);
    nodiv=ismember(cell2mat(joined_1hr_parsed(3,:)),0) ;
    joined_nodiv=joined_1hr_parsed(:,nodiv);
    
    for i=1:length(joined_div)
        endtime=joined_div{4,i};
        joined_div{5,i}=joined_div{1,i}(1:endtime,:);
        
    end
    
    for i=1:length(joined_nodiv)
        endtime=joined_nodiv{4,i};
        if endtime==0;
            joined_nodiv{5,i}=joined_nodiv{1,i};
        else
            continue
        end
    end
%% before we plot we need to get the medians of div and no div pops
% DIV
% nan pad the data so its all the same
sizes=[];
maxsize=[];
padsizes=[];
for i=1:length(joined_div)
    sizes(i)=length(joined_div{5,i}.Ratio);
end
maxsize=max(sizes);
padsizes=maxsize-sizes;
for i=1:length(joined_div)
    joined_div{6,i}=padarray(joined_div{5,i}.Ratio,padsizes(i),nan,'post');
end

% ND
sizes=[];
maxsizeND=[];
padsizes=[];
for i=1:length(joined_nodiv)
    sizes(i)=length(joined_nodiv{1,i}.Ratio);
end
maxsizeND=max(sizes);
padsizes=maxsizeND-sizes;
for i=1:length(joined_nodiv)
    joined_nodiv{6,i}=padarray(joined_nodiv{1,i}.Ratio,padsizes(i),nan,'post');
end

% med_div
valueholder=[];
med_DIV=[];
for ii=1:maxsize
    for i=1:length(joined_div)
        valueholder(i)=joined_div{6,i}(ii);
    end
    med_DIV(ii)=nanmedian(valueholder) ;
end

% med_noDIV=[];
valueholdernd=[];
med_NODIV=[];
for ii=1:maxsizeND
    for i=1:length(joined_nodiv)
        valueholdernd(i)=joined_nodiv{6,i}(ii);
    end
    med_NODIV(ii)=nanmedian(valueholdernd) ;
end

save (['joined_div',wellname],'joined_div')
save (['joined_nodiv',wellname],'joined_nodiv')

%%
figure
for i=1:length(joined_div)
    plot(joined_div{5,i}.Ratio,'b')
    hold on
end
for i=1:length(joined_nodiv)
    plot(joined_nodiv{1,i}.Ratio,'r')
    hold on
end
plot(med_DIV,'linewidth',3,'Color',[0 0 .5 .8]) % for alpha= 0 to 1 the lines will be more clear
plot(med_NODIV,'linewidth',3,'Color',[.5 0 0 .8]) % for alpha= 0 to 1 the lines will be more clear
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
savefig(gcf,[wellname,' Div_nd'])
print([wellname,' Div_nd'],'-dpng','-r300')
end

    %% pulling and joining all the data together that was egf and ins treated
myFolder=pwd
filePattern = fullfile(myFolder, 'joined_div B*.mat');
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
myFolder=pwd
filePattern = fullfile(myFolder, 'joined_nodiv B*.mat');
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
% all_non_div
all_non_div=horzcat(joined_nodiv_all{:});
save (['all_div_cells'],'all_div_cells')
save (['all_non_div'],'all_non_div')
%% need nan padding again
% DIV
% nan pad the data so its all the same
sizes=[];
maxsize=[];
padsizes=[];
for i=1:length(all_div_cells)
    sizes(i)=length(all_div_cells{5,i}.Ratio);
end
maxsize=max(sizes);
padsizes=maxsize-sizes;
for i=1:length(all_div_cells)
    all_div_cells{6,i}=padarray(all_div_cells{5,i}.Ratio,padsizes(i),nan,'post');
end
% ND
sizes=[];
maxsizeND=[];
padsizes=[];
for i=1:length(all_non_div)
    sizes(i)=length(all_non_div{1,i}.Ratio)
end
maxsizeND=max(sizes);
padsizes=maxsizeND-sizes;
for i=1:length(all_non_div)
    all_non_div{6,i}=padarray(all_non_div{1,i}.Ratio,padsizes(i),nan,'post');
end

% med_div
valueholder=[];
med_DIV=[];
for ii=1:maxsize
    for i=1:length(all_div_cells)
        valueholder(i)=all_div_cells{6,i}(ii);
    end
    allmed_DIV(ii)=nanmedian(valueholder) ;
end
% med_noDIV=[];
valueholdernd=[];
med_NODIV=[];
for ii=1:maxsizeND
    for i=1:length(all_non_div)
        valueholdernd(i)=all_non_div{6,i}(ii);
    end
    allmed_NODIV(ii)=nanmedian(valueholdernd) ;
end
%%
figure
for i=1:length(all_div_cells)
    plot(all_div_cells{5,i}.Ratio,'b')
    hold on
end

for i=1:length(all_non_div)
    plot(all_non_div{1,i}.Ratio,'r')
    hold on
end
save (['allmed_DIV'],'allmed_DIV')
save (['allmed_NODIV'],'allmed_NODIV')

plot(allmed_DIV,'linewidth',3,'Color',[0 0 .5 .8]) % for alpha= 0 to 1 the lines will be more clear
plot(allmed_NODIV,'linewidth',3,'Color',[.5 0 0 .8]) % for alpha= 0 to 1 the lines will be more clear
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
savefig(gcf,['all_data_Div_nd'])
print(['all_data_Div_nd'],'-dpng','-r300')
close all