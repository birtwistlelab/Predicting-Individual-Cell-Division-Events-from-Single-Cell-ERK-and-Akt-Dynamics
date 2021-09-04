% a=bc;
load a
%timeused is the jump distance value set inb CellProfiler
timeused={}; 
timeused='50';
FinalAge=strcat('NUCTrackObjects_FinalAge_',timeused);
Objects_Lifetime=strcat('NUCTrackObjects_Lifetime_',timeused);
Objects_Label=strcat('NUCTrackObjects_Label_',timeused);

vars={'ImageImageNumber','ImageMetadata_Site',...
       Objects_Lifetime,...
    'CytoplasmIntensity_MedianIntensity_ktr',...
    'CytoplasmIntensity_MeanIntensity_ktr',...
    Objects_Label,...
    'NUCIntensity_MedianIntensity_ktr',...
    'NUCIntensity_MeanIntensity_ktr',...
    'ImageMetadata_TP',...
    FinalAge};   
reporterused={};
reporterused='ERK';
%%
for k=1:length(a) 
%% Parsing out the important data, and adding Cyto:Nuc Ratios
CellComputations1hr=a{1,k}(:,vars);
varname=[];
CellComputations1hr.Ratio=(CellComputations1hr.CytoplasmIntensity_MeanIntensity_ktr)./(CellComputations1hr.NUCIntensity_MeanIntensity_ktr);
CellComputations1hr.Nuc=1./(CellComputations1hr.NUCIntensity_MeanIntensity_ktr);
CellComputations1hr.Nuc=1./(CellComputations1hr.NUCIntensity_MeanIntensity_ktr);
fields=unique(a{k}.ImageMetadata_Site); %these are the fields that will be used

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
varname=convertStringsToChars(a{k}.ImageMetadata_Row(1));
varname=strcat(varname,num2str(a{k}.ImageMetadata_Column(1)));
save (['byfielddata1hr',' ',varname],'byfielddata1hr') % data seperated by field
save (['CellComputations1hr',' ',varname],'CellComputations1hr')
save(['fields',' ',varname],'fields')
%% Life time suggested cells
% Here's where you'll get a list of cell tracks sorted by time
LTvars={'ImageImageNumber','ImageMetadata_Site', Objects_Label,Objects_Lifetime...,
    'ImageMetadata_TP'};
Lifetime=CellComputations1hr(:,LTvars);
colz={Objects_Label,'ImageMetadata_Site'};
for i=1:length(fields)
    rows1hr=Lifetime.ImageMetadata_Site==fields(i);
    byLIFEdata1hr{i}=CellComputations1hr(rows1hr,:);
    j=max((byLIFEdata1hr{i}.(FinalAge))); % make sure to change this to the right number
    rowsMaxLife1hr=byLIFEdata1hr{i}.FinalAge==j;  % make sure to change this to the right number
    HighbyLIFEdata1hr{i}=byLIFEdata1hr{i}(rowsMaxLife1hr,:);
    SuggestedCells1hr{i}=HighbyLIFEdata1hr{i}(:,colz);
    SuggestedCells1hr{i}=sortrows(SuggestedCells1hr{i},1);
end
colz={Objects_Label,'ImageMetadata_Site'};
for ii=1:length(fields)
    rows=byLIFEdata1hr{ii}.ImageImageNumber==byLIFEdata1hr{ii}.ImageImageNumber(1); % cells at tp 1
    atleast1hr{ii}=byLIFEdata1hr{ii}(rows,colz);
    atleast1hr{ii}=sortrows(atleast1hr{ii},1);
end
cellsToPlot1hr={};
cellsToPlot1hr=atleast1hr;
%% table with all of the cells from each field
counter=1;
colVars={'ImageMetadata_TP','ImageImageNumber','ImageMetadata_Site',Objects_Label,'Ratio','NUCIntensity_MeanIntensity_ktr'};
for j=1:length(fields)
    for jj=1:height(SuggestedCells1hr{j}(:,1))
        rows=byfielddata1hr{j}.(Objects_Label)==table2array(SuggestedCells1hr{j}(jj,1));
        joined_1hr{counter}=[byfielddata1hr{j}(rows,colVars)];
        counter=counter+1;
    end
end
for lmnop=1:length(joined_1hr)
    if joined_1hr{1,lmnop}.Ratio(1)>1.2 % cells above this ratio are probably bad
        joined_1hr{1,lmnop}=[];
    else
    end
end
joined_1hr=joined_1hr(~cellfun('isempty',joined_1hr));
notemptycols=[];
for g=1:length(joined_1hr)
    notemptycols(g)=isempty(joined_1hr{1,g});
end
notemptycols=~notemptycols
joined_1hr=joined_1hr(notemptycols);

expression='(\d*)';
% for i=1:length(joined_1hr)
% % ms_extract = regexp(joined_1hr{1,i}.ImageMetadata_Time,expression,'match');
% S = sprintf('%s ', ms_extract{:});
% ms_extract= sscanf(S, '%f');
% ms_extract_corrected=vertcat(ms_extract(1:5),(ms_extract(6:end)+4500000)); % ms offsets
% %make to min and hrs.
% time_min=ms_extract_corrected(:,1)./60000; % Min
% time_hr=ms_extract_corrected(:,1)./3600000;% Hr
% joined_1hr{1,i}.time_min=time_min;
% joined_1hr{1,i}.time_hr=time_hr;

% Here we need to filter out cells that have a huge baseline, as well as
% cells that have a C:N >2 at any given time

%% 1hr plotting Indvidual cells
stringCell={};
stringField={};
cellLabels={};
for m=1:length(joined_1hr)
    stringCell{m}=num2str(joined_1hr{1,m}.Objects_Label(1),'cell %-d ');
    stringField{m}=num2str(joined_1hr{1,m}.ImageMetadata_Site(1),' field %-d');
    cellLabels{m}=[stringCell{m} ' ' stringField{m}];
end
gcf;
legendCell = (cellLabels);
joined_1hr(2,:)=cellLabels;
save (['joined_1hr',' ',varname],'joined_1hr')
%% Normalization if you want to normalize
% normalized_plots_1hr={};
% % colVars={'ImageMetadata_TP','ImageImageNumber','ImageMetadata_Site','NUCTrackObjects_Label_50','Ratio'};
% for ii=1:length(joined_1hr);
%     for jj=1:length(joined_1hr{1,ii}.Ratio);
% %         CellNormConst_1hr(1,ii)=median(joined_1hr{1,ii}.Ratio(1:5)); %Normalization for each individual cell changes for each run
%         CellNormConst_1hr(1,ii)=median(joined_1hr{1,ii}.Ratio(1:5)); %Normalization for each individual cell changes for each run
%         normalized_plots_1hr{ii}=joined_1hr{1,ii}(:,colVars);
%         normalized_plots_1hr{ii}.Norm=joined_1hr{1,ii}.Ratio./CellNormConst_1hr(1,ii);
% %         normalized_plots_1hr{ii}.AktNorm=joined_1hr{1,ii}.Ratio./CellNormConst_1hr(1,ii);
%     end
% end
% save (['normalized_plots_1hr',' ',varname],'normalized_plots_1hr')
% % here we normalize the NUCs
% normalized_plots_1hr={};
% % colVars={'ImageMetadata_TP','ImageImageNumber','ImageMetadata_Site','NUCTrackObjects_Label_50','Ratio'};
% for ii=1:length(joined_1hr);
%     for jj=1:length(joined_1hr{1,ii}.Ratio);
%         CellNormConst_1hrnuc(1,ii)=median(joined_1hr{1,ii}.Nuc(1:6)); %Normalization for each individual cell changes for each run
%         CellNormConst_1hrnuc(1,ii)=median(joined_1hr{1,ii}.Nuc(1:6)); %Normalization for each individual cell changes for each run
%         normalized_plots_1hr{ii}=joined_1hr{1,ii}(:,colVars);
%           joined_1hr{1,ii}.NORMNucERK=joined_1hr{1,ii}.NucERK./CellNormConst_1hrnuc(1,ii);
%         joined_1hr{1,ii}.NORMNucAkt=joined_1hr{1,ii}.NucAkt./CellNormConst_1hrnuc(1,ii);
%     
%     end
% end

%% Here we get the meds, we should nan pad just incase
maxsize=max(a{1,1}.ImageMetadata_TP);
valueholder=[];
valueholder=[];
valueholder_nucERK=[];
valueholder_nucAkt=[];
med=[];
standard=[];
sz=size(joined_1hr);
for ii=1:maxsize
    for i=1:sz(2)
        valueholder(i)=joined_1hr{1,i}.Ratio(ii);
        med(ii)=nanmedian(valueholder) ;
        standard(ii)=std(valueholder);
    end
    medsaver{k}=med;
    standardsaver{k}=standard;
    save (['med',varname],'med')
    save (['standard',varname],'standard')
end
%%
figure;
for m=1:length(joined_1hr)
    times=1:length(joined_1hr{1,m}.ImageMetadata_TP(1:end));
    plot(times,joined_1hr{1,m}.Ratio,'LineWidth',1,'Color',[.5 .5 .5 .3])
    hold on
end
plot(med,'linewidth',3,'Color','k')
box off
xlim([1 maxsize])
ylim([0.6 1.4])
title([strcat('All ',reporterused,' KTR Activity', ' ', varname)]);
set(gca, 'XTick', 1:2:maxsize);
min=[0:6:(maxsize-1)*3];
minlabel={};
for i=1:length(min)
    minlabel{i}=num2str(min(i));
end
ax=gca;
ax.XAxis.TickLabels=minlabel;
xtickangle(45)
set(gcf, 'PaperPositionMode','manual','PaperUnits','inches','PaperPosition',[0 0 3 2])
savefig(gcf,[' KTR dynamics' ' ' varname])
print([' KTR dynamics' ' ' varname],'-dpng','-r300')
hold off
clf()
x=1:maxsize;
shadedErrorBar(x,med',standard','lineProps',{'k','LineWidth',2})
box off
xlim([1 maxsize])
ylim([0.6 1.4])
set(gca, 'XTick', 1:2:maxsize);
min=[0:6:(maxsize-1)*3];
minlabel={};
for i=1:length(min)
    minlabel{i}=num2str(min(i));
end
ax=gca;
ax.XAxis.TickLabels=minlabel;
xtickangle(45)
set(gcf, 'PaperPositionMode','manual','PaperUnits','inches','PaperPosition',[0 0 3 2])
savefig(gcf,[' shaded' ' ' varname])
print([' shaded' ' ' varname],'-dpng','-r300')
hold off
clearvars -except a varname k maxtimes medsaver standardsaver
end
