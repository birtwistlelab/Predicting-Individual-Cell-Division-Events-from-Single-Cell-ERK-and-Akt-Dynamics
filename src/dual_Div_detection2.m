% run this on your data to find dividing cells only start with this first
% then you can run div_detection v3 to plot data after you refined the results
% point me in the directrion of where the 48 hr data is
myFolder=pwd; %or change to the dir
filePattern = fullfile(myFolder, 'joined_1hr C*.mat');
matFiles = dir(filePattern);
expression='(joined_1hr)  | \w*';

for k = 1:length(matFiles)
well_extract = regexp(matFiles(k).name,expression,'match');
baseFileName = matFiles(k).name;
  fullFileName = fullfile(myFolder, baseFileName)
  fprintf(1, 'Now reading %s\n', fullFileName);
fileID = load(fullFileName,'-mat');
joined_1hr=fileID.joined_1hr;
wellname=well_extract{1};
%% applying additional filtering?
extracted_data={}
for i=1:length(joined_1hr)
extracted_data{1,i}=joined_1hr{1,i}.AktRatio;
extracted_data{2,i}=strcat(num2str(joined_1hr{1,i}.NUCTrackObjects_Label_65(1)),',',num2str(joined_1hr{1,i}.ImageMetadata_Site(1))); % cell name, site
joined_1hr{2,i}=extracted_data{2,i};
end
% here we are setting the search for the KTR feature that is unqiue to
for i =1:length(extracted_data)
invertedY = max(extracted_data{1, i}) - extracted_data{1, i};
invertedY=invertedY(6:end,:);
[pks,locs,w,p]= findpeaks(invertedY,'MinPeakWidth',.1);
[maxvalue loc]=max(pks);
timecourse_location=locs(loc)+5;
backtrack=timecourse_location-5;
M(i,4)=extracted_data{1,i}(backtrack)-extracted_data{1,i}(timecourse_location);
M(i,5)=backtrack;
extracted_data{3,i}=backtrack;
end
% cant have a dividing cell in the first 20 tps right?
for i=1:length(joined_1hr)
    if M(i,4)>=.24 && M(i,5)>20
        joined_1hr{3,i}=1;
        joined_1hr{4,i}=M(i,5);
    else
        joined_1hr{3,i}=0;
    end
end
% now getting the real non dividers
for i=1:length(joined_1hr)
    if joined_1hr{3,i}==0 && height(joined_1hr{1,i})>=197;
        joined_1hr{4,i}=0;
    else
        continue
    end
end
notemptycols=[];
notemptycols=cellfun(@isempty,joined_1hr(4,:),'uniformoutput',false);
notemptycols=cell2mat(notemptycols);
notemptycols=~notemptycols;
joined_1hr(:,notemptycols<1)=[];
joined_1hr_parsed=joined_1hr;
% seperate between the two pops
keep = all(~cellfun('isempty',joined_1hr), 1);
joined_1hr_parsed = joined_1hr(:,keep);
%% here we are going to save the data from joiend_1hr_parsed
save (['joined_1hr_parsed',wellname],'joined_1hr_parsed')
%%NOW WE ARE GOING TO SEPERATE BASED ON DIV OR NO DIV
div = ismember(cell2mat(joined_1hr_parsed(3,:)),1);
joined_div={};
joined_div=joined_1hr_parsed(:,div);
nodiv=ismember(cell2mat(joined_1hr_parsed(3,:)),0);
joined_nodiv=joined_1hr_parsed(:,nodiv);
sz=size(joined_div);
sz_nd=size(joined_nodiv);
for i=1:sz(2)
    endtime=joined_div{4,i};
    joined_div{5,i}=joined_div{1,i}(1:endtime,:);
end
for i=1:sz_nd(2)
    endtime=joined_nodiv{4,i};
    joined_nodiv{5,i}=joined_nodiv{1,i}(1:endtime,:);
end
%% before we plot we need to get the medians of div and no div pops
% DIV
% nan pad the data so its all the same
sizes=[];
maxsize=[];
padsizes=[];
for i=1:sz(2)
    sizes(i)=length(joined_div{5,i}.Ratio);
end
maxsize=max(sizes);
padsizes=maxsize-sizes;
for i=1:sz(2)
    joined_div{6,i}=padarray(joined_div{5,i}.Ratio,padsizes(i),nan,'post');
end
% ND
sizes=[];
maxsizeND=[];
padsizes=[];
sz_nd=size(joined_nodiv)
for i=1:sz_nd(2)
    sizes(i)=length(joined_nodiv{1,i}.Ratio);
end
maxsizeND=max(sizes);
padsizes=maxsizeND-sizes;
for i=1:sz_nd(2)
    joined_nodiv{6,i}=padarray(joined_nodiv{1,i}.Ratio,padsizes(i),nan,'post');
end
% med_div
valueholder=[];
med_DIV=[];
for ii=1:maxsize
    for i=1:sz(2)
        valueholder(i)=joined_div{6,i}(ii);
    end
    med_DIV(ii)=nanmedian(valueholder) ;
end
% med_noDIV=[];
valueholdernd=[];
med_NODIV=[];
for ii=1:maxsizeND
    for i=1:sz_nd(2)
        valueholdernd(i)=joined_nodiv{6,i}(ii);
    end
    med_NODIV(ii)=nanmedian(valueholdernd) ;
end
save (['joined_div',wellname],'joined_div')
save (['joined_nodiv',wellname],'joined_nodiv')
%%
% dividing cells are blue and non div are red
figure
for i=1:sz(2)
    plot(joined_div{5,i}.Ratio,'b')
    hold on
end
for i=1:sz_nd(2)
    plot(joined_nodiv{1,i}.Ratio,'r')
    hold on
end
plot(med_DIV,'linewidth',4,'Color',[0 0 .5 .8]) % for alpha= 0 to 1 the lines will be more clear
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
% now you run this part of the code which processes div and no-div data
%% pulling and joining all the data together that was 
myFolder='M:\EGF_INS 7 10 20\csv\c\DIV_SEPERATED'
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
% run the code below if you are happy with the parsed results.
%otherwise run div_detectionv3

% %% we should not concider b02 or any 02
% myFolder='M:\EGF_INS 7 10 20\csv\c\DIV_SEPERATED'
% filePattern = fullfile(myFolder, 'joined_nodiv C*.mat');
% matFiles = dir(filePattern);
% expression='(joined_div)  | \w*';
% joined_nodiv_all={};
% for k = 1:length(matFiles)
% well_extract = regexp(matFiles(k).name,expression,'match');
% wellname=well_extract{1};
% if strcmp(wellname(4),'2')==0
% baseFileName = matFiles(k).name;
  % fullFileName = fullfile(myFolder, baseFileName)
  % fprintf(1, 'Now reading %s\n', fullFileName);
% fileID = load(fullFileName,'-mat');
% joined_nodiv_all{k}=fileID.joined_nodiv;
% wellname=well_extract{1};
% else
    % continue
% end
% end
% % all_non_div
% all_non_div=horzcat(joined_nodiv_all{:});

% save (['all_div_cells'],'all_div_cells')
% save (['all_non_div'],'all_non_div')

% %% need nan padding again
% % DIV
% % nan pad the data so its all the same
% sizes=[];
 % maxsize=[];
 % padsizes=[];
% for i=1:length(all_div_cells)
    % sizes(i)=length(all_div_cells{5,i}.Ratio);
% end
% maxsize=max(sizes);
% padsizes=maxsize-sizes;
% for i=1:length(all_div_cells)
   % all_div_cells{6,i}=padarray(all_div_cells{5,i}.Ratio,padsizes(i),nan,'post');
% end

% % ND
% sizes=[];
% maxsizeND=[];
% padsizes=[];
% for i=1:length(all_non_div)
    % sizes(i)=length(all_non_div{1,i}.Ratio)
 % end
% maxsizeND=max(sizes);
% padsizes=maxsizeND-sizes;
% for i=1:length(all_non_div)
     % all_non_div{6,i}=padarray(all_non_div{1,i}.Ratio,padsizes(i),nan,'post');
% end

% % med_div
% valueholder=[];
% med_DIV=[];
% for ii=1:maxsize
    % for i=1:length(all_div_cells)
        % valueholder(i)=all_div_cells{6,i}(ii);
    % end
% allmed_DIV(ii)=nanmedian(valueholder) ;
% end

% % med_noDIV=[];
% valueholdernd=[];
% med_NODIV=[];
% for ii=1:maxsizeND
    % for i=1:length(all_non_div)
        % valueholdernd(i)=all_non_div{6,i}(ii);
    % end
% allmed_NODIV(ii)=nanmedian(valueholdernd) ;
% end
% %%

% figure
% for i=1:length(all_div_cells)
% plot(all_div_cells{5,i}.Ratio,'b')
% hold on
% end

% for i=1:length(all_non_div)
% plot(all_non_div{1,i}.Ratio,'r')
% hold on
% end

% plot(allmed_DIV,'linewidth',4,'Color',[0 0 .5 .8]) % for alpha= 0 to 1 the lines will be more clear
% plot(allmed_NODIV,'linewidth',4,'Color',[.5 0 0 .8]) % for alpha= 0 to 1 the lines will be more clear
% hrs=[0:2:48 49];
% [LogArray,Loc]=ismember(hrs,maxtimes(:,2));
% tickPos=Loc;
% set(gca, 'XTick', tickPos);
% for i=1:length(hrs)
    % hrslabel{i}=num2str(hrs(i));
% end
% ax=gca;
% ax.XAxis.TickLabels=hrslabel;
% xtickangle(45)
% set(gca,'linewidth',1)
% set(gca,'FontSize',6)
% % title(position)
% ax=gca
% box(ax,'off')
    % set(gcf, 'PaperPositionMode','manual','PaperUnits','inches','PaperPosition',[0 0 3 2])
    % savefig(gcf,[wellname,' all_data_Div_nd'])
    % print([wellname,' all_data_Div_nd'],'-dpng','-r300')