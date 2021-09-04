% a=bc;
% this script can process short timecourse data
maxtime=17; %insert the max time of the time course here
for k=1:length(a) % a is the export from one of the batchreader scripts 
%% Parsing out the important data, and adding Cyto:Nuc ERKRatios for 15min timepoint
% make sure that your vars match correctly (vars are outputs from cellprofiler CSV)
vars={'ImageImageNumber','ImageMetadata_Site',...
    'ImageMetadata_Time',...
    'NUCTrackObjects_Lifetime_65',...
    'CytoplasmIntensity_MedianIntensity_erk',...
    'CytoplasmIntensity_MedianIntensity_akt',...
    'CytoplasmIntensity_MeanIntensity_erk',...
    'CytoplasmIntensity_MeanIntensity_akt'
    'NUCTrackObjects_Label_65',...
    'NUCIntensity_MedianIntensity_erk',...
    'NUCIntensity_MedianIntensity_akt',...
    'NUCIntensity_MeanIntensity_erk',...
    'NUCIntensity_MeanIntensity_akt',...
    'ImageMetadata_TP',...
    'NUCTrackObjects_FinalAge_65',...
    'NUCIntensity_MeanIntensity_DNA',...
    };
CellComputations1hr=a{1,k}(:,vars);
varname=[];
CellComputations1hr.ERKRatio=(CellComputations1hr.CytoplasmIntensity_MeanIntensity_erk)./(CellComputations1hr.NUCIntensity_MeanIntensity_erk);
CellComputations1hr.AktRatio=(CellComputations1hr.CytoplasmIntensity_MeanIntensity_akt)./(CellComputations1hr.NUCIntensity_MeanIntensity_akt);

CellComputations1hr.NucERK=1./(CellComputations1hr.NUCIntensity_MeanIntensity_erk);
CellComputations1hr.NucAkt=1./(CellComputations1hr.NUCIntensity_MeanIntensity_akt);
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
% Here's where you'll get a list of cell tracks sorted by life time, maybe
% you'll think about using one of em
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
%% table with all of the cells from each field
counter=1;
colVars={'ImageMetadata_TP','ImageMetadata_Time',...
    'ImageImageNumber','ImageMetadata_Site','NUCTrackObjects_Label_65','ERKRatio','AktRatio','CytoplasmIntensity_MeanIntensity_erk','NUCIntensity_MeanIntensity_erk',...
    'NUCIntensity_MeanIntensity_DNA','CytoplasmIntensity_MeanIntensity_akt','NUCIntensity_MeanIntensity_akt','NucERK','NucAkt'};
for j=1:length(fields)
    
    for jj=1:height(cellsToPlot1hr{j}(:,1))
        rows=byfielddata1hr{j}.NUCTrackObjects_Label_65==table2array(cellsToPlot1hr{j}(jj,1)); % replace j with 1
        joined_1hr{counter}=[byfielddata1hr{j}(rows,colVars)];
        counter=counter+1;
    end
    
end
%
for lmnop=1:length(joined_1hr)
    if height(joined_1hr{1,lmnop})<maxtime; % time filter
        joined_1hr{1,lmnop}=[];
    else
        if joined_1hr{1,lmnop}.ERKRatio(1)>1.2 || joined_1hr{1,lmnop}.AktRatio(1)>1.2
            joined_1hr{1,lmnop}=[];
        else
            if joined_1hr{1,lmnop}.ERKRatio(1)<.4 % we dont want these cells, they are probably dead
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
notemptycols=~notemptycols
joined_1hr=joined_1hr(notemptycols);

expression='(\d*)';
% this is a time conversion, sometimes the input data wont have this but
% its ok
for i=1:length(joined_1hr)
    ms_extract = regexp(joined_1hr{1,i}.ImageMetadata_Time,expression,'match');
    S = sprintf('%s ', ms_extract{:});
    ms_extract= sscanf(S, '%f');
    ms_extract_corrected=vertcat(ms_extract(1:5),(ms_extract(6:end)+4500000)); % ms offsets
    %make to min and hrs.
    time_min=ms_extract_corrected(:,1)./60000; % Min
    time_hr=ms_extract_corrected(:,1)./3600000;% Hr
    joined_1hr{1,i}.time_min=time_min;
    joined_1hr{1,i}.time_hr=time_hr;
    
end
% Here we need to filter out cells that have a huge baseline, as well as
% cells that have a C:N >2 at any given tim
%% plotting Indvidual cells
stringCell={};
stringField={};
cellLabels={};
for m=1:length(joined_1hr)
    stringCell{m}=num2str(joined_1hr{1,m}.NUCTrackObjects_Label_65(1),'cell %-d ');
    stringField{m}=num2str(joined_1hr{1,m}.ImageMetadata_Site(1),' field %-d');
    cellLabels{m}=[stringCell{m} ' ' stringField{m}];
end
gcf;
legendCell = (cellLabels);
joined_1hr(2,:)=cellLabels;
save (['joined_1hr',' ',varname],'joined_1hr')
%if you want to normalize the data use the code below
%% Normalization 1hr
% we dont show normalized data here 
% normalized_plots_1hr={};
% % colVars={'ImageMetadata_TP','ImageImageNumber','ImageMetadata_Site','NUCTrackObjects_Label_65','ERKRatio'};
% for ii=1:length(joined_1hr);
%     for jj=1:length(joined_1hr{1,ii}.ERKRatio);
%         CellNormConst_1hr_ERK(1,ii)=median(joined_1hr{1,ii}.ERKRatio(1:5)); %Normalization for each individual cell changes for each run
%         CellNormConst_1hr_Akt(1,ii)=median(joined_1hr{1,ii}.AktRatio(1:5)); %Normalization for each individual cell changes for each run
%         normalized_plots_1hr{ii}=joined_1hr{1,ii}(:,colVars);
%         normalized_plots_1hr{ii}.ERKNorm=joined_1hr{1,ii}.ERKRatio./CellNormConst_1hr_ERK(1,ii);
%         normalized_plots_1hr{ii}.AktNorm=joined_1hr{1,ii}.AktRatio./CellNormConst_1hr_Akt(1,ii);
%     end
% end
% save (['normalized_plots_1hr',' ',varname],'normalized_plots_1hr')
% % here we normalize the NUCs
% normalized_plots_1hr={};
% % colVars={'ImageMetadata_TP','ImageImageNumber','ImageMetadata_Site','NUCTrackObjects_Label_65','ERKRatio'};
% for ii=1:length(joined_1hr);
%     for jj=1:length(joined_1hr{1,ii}.ERKRatio);
%         CellNormConst_1hr_ERKnuc(1,ii)=median(joined_1hr{1,ii}.NucERK(1:6)); %Normalization for each individual cell changes for each run
%         CellNormConst_1hr_Aktnuc(1,ii)=median(joined_1hr{1,ii}.NucAkt(1:6)); %Normalization for each individual cell changes for each run
%         normalized_plots_1hr{ii}=joined_1hr{1,ii}(:,colVars);
%           joined_1hr{1,ii}.NORMNucERK=joined_1hr{1,ii}.NucERK./CellNormConst_1hr_ERKnuc(1,ii);
%         joined_1hr{1,ii}.NORMNucAkt=joined_1hr{1,ii}.NucAkt./CellNormConst_1hr_Aktnuc(1,ii);
%     
%     end
% end

%% Here we get the meds, we should nan pad just incase
% if you are plotting normalized data go and uncomment anything with Norm
% in front

maxsize=max(a{1,1}.ImageMetadata_TP);
valueholder_ERK=[];
valueholder_Akt=[];
valueholder_nucERK=[];
valueholder_nucAkt=[];
med_DIV=[];
sz=size(joined_1hr);

for ii=1:maxsize
    for i=1:sz(2)
        valueholder_ERK(i)=joined_1hr{1,i}.ERKRatio(ii);
        valueholder_Akt(i)=joined_1hr{1,i}.AktRatio(ii);
        % valueholder_nucERK(i)=joined_1hr{1,i}.NORMNucERK(ii);
        % valueholder_nucAkt(i)=joined_1hr{1,i}.NORMNucAkt(ii);
    end
    med_ERK(ii)=nanmedian(valueholder_ERK) ;
    med_Akt(ii)=nanmedian(valueholder_Akt) ;
    % mednuc_ERK(ii)=nanmedian(valueholder_nucERK) ;
    % mednuc_Akt(ii)=nanmedian(valueholder_nucAkt);
    standard_ERK(ii)=std(valueholder_ERK);
    standard_Akt(ii)=std(valueholder_ERK);
    % standard_nucERK(ii)=std(valueholder_nucERK);
    % standard_nucAkt(ii)=std(valueholder_nucAkt);
end
save (['med_ERK',varname],'med_ERK')
save (['med_Akt',varname],'med_Akt')
% save (['mednuc_ERK',varname],'mednuc_ERK')
% save (['mednuc_Akt',varname],'mednuc_Akt')


save (['standard_ERK',varname],'standard_ERK')
save (['standard_Akt',varname],'standard_Akt')
% save (['standard_nucERK',varname],'standard_nucERK')
% save (['standard_nucAkt',varname],'standard_nucAkt')

%% erk data
figure;
for m=1:length(joined_1hr)
    times=1:length(joined_1hr{1,m}.ImageMetadata_TP(1:end));
    plot(times,joined_1hr{1,m}.ERKRatio,'LineWidth',1,'Color',[.8 0 0 .3])
    hold on
end
plot(med_ERK,'linewidth',3,'Color',[0 0 0 .8])
box off
xlim([1 maxsize])
ylim([0.6 1.4])
title(['All ERK KTR Activity' ' ' varname]);
set(gca, 'XTick', 1:2:maxsize);
hrs=[0:13:104];
for i=1:length(hrs)
    hrslabel{i}=num2str(hrs(i));
end
ax=gca;
ax.XAxis.TickLabels=hrslabel;
xtickangle(45)
set(gcf, 'PaperPositionMode','manual','PaperUnits','inches','PaperPosition',[0 0 3 2])
savefig(gcf,['ERK KTR dynamics' ' ' varname])
print(['ERK KTR dynamics' ' ' varname],'-dpng','-r300')
hold off
% akt data
figure;
for m=1:length(joined_1hr)
    times=1:length(joined_1hr{1,m}.ImageMetadata_TP(1:end));
    plot(times,joined_1hr{1,m}.AktRatio,'LineWidth',1,'Color',[0 .6 0   .3])
    hold on
end
plot(med_Akt,'linewidth',3,'Color',[0 0 0 .8])
box off
xlim([1 maxsize])
ylim([0.6 1.4])
title(['All Akt KTR Activity' ' ' varname]);
set(gca, 'XTick', 1:2:maxsize);
ax=gca;
ax.XAxis.TickLabels=hrslabel;
xtickangle(45)
set(gcf, 'PaperPositionMode','manual','PaperUnits','inches','PaperPosition',[0 0 3 2])
savefig(gcf,['Akt KTR dynamics' ' ' varname])
print(['Akt KTR dynamics' ' ' varname],'-dpng','-r300')
hold off
figure % for ERK
x=1:maxsize;
shadedErrorBar(x,med_ERK',standard_ERK','lineProps',{'r','LineWidth',2})
box off
xlim([1 maxsize])
ylim([0.6 1.4])
set(gca, 'XTick', 1:2:maxsize);
ax=gca;
ax.XAxis.TickLabels=hrslabel;
xtickangle(45)
set(gcf, 'PaperPositionMode','manual','PaperUnits','inches','PaperPosition',[0 0 3 2])
savefig(gcf,['ERK shaded' ' ' varname])
print(['ERK shaded' ' ' varname],'-dpng','-r300')
hold off
figure % for Akt
x=1:maxsize;
shadedErrorBar(x,med_Akt',standard_Akt','lineProps',{'Color',[0 0.4 0 .8],'LineWidth',2})
box off
xlim([1 maxsize])
ylim([0.6 1.4])
% title(['Akt KTR Activity' ' ' varname]);
set(gca, 'XTick', 1:2:maxsize);
ax=gca;
ax.XAxis.TickLabels=hrslabel;
xtickangle(45)
set(gcf, 'PaperPositionMode','manual','PaperUnits','inches','PaperPosition',[0 0 3 2])
savefig(gcf,['Akt shaded' ' ' varname])
print(['Akt shaded' ' ' varname],'-dpng','-r300')
hold off
%% Nuc ktr values, it should rep the ratios
%Uncomment below for nuc KTR data

% figure;
% for m=1:length(joined_1hr)    
%         times=1:length(joined_1hr{1,m}.ImageMetadata_TP(1:end));
%         plot(times,joined_1hr{1,m}.NORMNucERK,'LineWidth',1,'Color',[.8 0 0 .3])
%     hold on
% end
% plot(mednuc_ERK,'linewidth',3,'Color',[0 0 0 .8])
% box off
% xlim([1 maxsize])
% ylim([0.6 1.4])
% % title(['All nucERK KTR Activity' ' ' varname]);
% set(gca, 'XTick', 1:2:maxsize);
% hrs=[0:13:104];
% for i=1:length(hrs)
%     hrslabel{i}=num2str(hrs(i));
% end
% ax=gca;
% ax.XAxis.TickLabels=hrslabel;
% xtickangle(45)
% set(gcf, 'PaperPositionMode','manual','PaperUnits','inches','PaperPosition',[0 0 3 2])
% savefig(gcf,['ERK nuc dynamics' ' ' varname])
% print(['ERK nuc dynamics' ' ' varname],'-dpng','-r300')
% hold off
% 
% 
% % akt data
% 
% figure;
% for m=1:length(joined_1hr)    
%         times=1:length(joined_1hr{1,m}.ImageMetadata_TP(1:end));
%         plot(times,joined_1hr{1,m}.NORMNucAkt,'LineWidth',1,'Color',[0 .6 0   .3])
%     hold on
% end
% plot(mednuc_Akt,'linewidth',3,'Color',[0 0 0 .8])
% 
% box off
% xlim([1 maxsize])
% ylim([0.6 1.4])
% title(['All Akt nuc Activity' ' ' varname]);
% set(gca, 'XTick', 1:2:maxsize);
% ax=gca;
% ax.XAxis.TickLabels=hrslabel;
% xtickangle(45)
% set(gcf, 'PaperPositionMode','manual','PaperUnits','inches','PaperPosition',[0 0 3 2])
% savefig(gcf,['Akt nuc dynamics' ' ' varname])
% print(['Akt nuc dynamics' ' ' varname],'-dpng','-r300')
% hold off
% % shaded nucs
% % here we get the shaded plots
% figure % for ERK
% x=1:maxsize;
% shadedErrorBar(x,mednuc_ERK',standard_nucERK','lineProps',{'r','LineWidth',2})
% box off
% xlim([1 maxsize])
% ylim([0.6 1.4])
% % title(['ERK KTR Activity' ' ' varname]);
% set(gca, 'XTick', 1:2:maxsize);
% ax=gca;
% ax.XAxis.TickLabels=hrslabel;
% xtickangle(45)
% set(gcf, 'PaperPositionMode','manual','PaperUnits','inches','PaperPosition',[0 0 3 2])
% savefig(gcf,['nucERK shaded' ' ' varname])
% print(['nucERK shaded' ' ' varname],'-dpng','-r300')
% hold off
% 
% figure % for Akt
% x=1:maxsize;
% shadedErrorBar(x,mednuc_Akt',standard_nucAkt','lineProps',{'Color',[0 0.4 0 .8],'LineWidth',2})
% box off
% xlim([1 maxsize])
% ylim([0.6 1.4])
% % title(['Akt KTR Activity' ' ' varname]);
% set(gca, 'XTick', 1:2:maxsize);
% ax=gca;
% ax.XAxis.TickLabels=hrslabel;
% xtickangle(45)
% set(gcf, 'PaperPositionMode','manual','PaperUnits','inches','PaperPosition',[0 0 3 2])
% savefig(gcf,['nucAkt shaded' ' ' varname])
% print(['nucAkt shaded' ' ' varname],'-dpng','-r300')
% hold off
% %%
% clearvars -except a varname k maxtimes
close all
end