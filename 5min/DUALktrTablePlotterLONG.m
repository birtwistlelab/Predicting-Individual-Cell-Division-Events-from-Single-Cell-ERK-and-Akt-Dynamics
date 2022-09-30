load a
% load maxtime_198

%%
startTP=1; % set these to the start and stop time before GF stim
stopTP=12;

for k=1:length(a) % a is the export from batchreader
    %% Parsing out the important data, and adding Cyto:Nuc
    % this script will plot the KTR dynamics over time
    maxnumofTPs=590; % this needs to be specified
    time_interval=5; % this is in minutes
    timefraction=time_interval/60;
    total_time_min=maxnumofTPs*time_interval; % in minutes
    total_time_hrs=total_time_min/60;
    timechart=[1:1:maxnumofTPs;0:time_interval:total_time_min-1];
    hrs=timechart(2,:)/60;
    timechart=vertcat(timechart,hrs);
    timechart=timechart';
    hrsplot=[0:2:48 49];
    [LogArray,Loc]=ismember(hrsplot,timechart(:,3));
    tickPos=Loc;
    hrslabel={};
    for i=1:length(hrsplot)
        hrslabel{i}=num2str(hrsplot(i));
    end
    
    vars = {'ImageImageNumber', 'CytoplasmObjectNumber', 'ImageMetadata_Column', 'ImageMetadata_ROI', 'ImageMetadata_time', 'CytoplasmIntensity_IntegratedIntensity_DNA', 'CytoplasmIntensity_IntegratedIntensity_akt', 'CytoplasmIntensity_IntegratedIntensity_erk', 'CytoplasmIntensity_MeanIntensity_DNA', 'CytoplasmIntensity_MeanIntensity_akt', 'CytoplasmIntensity_MeanIntensity_erk', 'CytoplasmIntensity_MedianIntensity_DNA', 'CytoplasmIntensity_MedianIntensity_akt', 'CytoplasmIntensity_MedianIntensity_erk', 'CytoplasmIntensity_StdIntensity_DNA', 'CytoplasmIntensity_StdIntensity_akt', 'CytoplasmIntensity_StdIntensity_erk', 'CytoplasmNumber_Object_Number', 'NUCIntensity_IntegratedIntensity_DNA', 'NUCIntensity_IntegratedIntensity_akt', 'NUCIntensity_IntegratedIntensity_erk', 'NUCIntensity_MeanIntensity_DNA', 'NUCIntensity_MeanIntensity_akt', 'NUCIntensity_MeanIntensity_erk', 'NUCIntensity_MedianIntensity_DNA', 'NUCIntensity_MedianIntensity_akt', 'NUCIntensity_MedianIntensity_erk', 'NUCIntensity_StdIntensity_DNA', 'NUCIntensity_StdIntensity_akt', 'NUCIntensity_StdIntensity_erk', 'NUCNumber_Object_Number', 'NUCTrackObjects_Displacement_20', 'NUCTrackObjects_DistanceTraveled_20', 'NUCTrackObjects_FinalAge_20', 'NUCTrackObjects_IntegratedDistance_20', 'NUCTrackObjects_Label_20', 'NUCTrackObjects_Lifetime_20', 'NUCTrackObjects_Linearity_20', 'NUCTrackObjects_ParentImageNumber_20', 'NUCTrackObjects_ParentObjectNumber_20', 'NUCTrackObjects_TrajectoryX_20', 'NUCTrackObjects_TrajectoryY_20'};
    CellComputations1hr=a{1,k}(:,vars);
    CellComputations1hr.ERKRatio=(CellComputations1hr.CytoplasmIntensity_MeanIntensity_erk)./(CellComputations1hr.NUCIntensity_MeanIntensity_erk);
    CellComputations1hr.AktRatio=(CellComputations1hr.CytoplasmIntensity_MeanIntensity_akt)./(CellComputations1hr.NUCIntensity_MeanIntensity_akt);
    fields=unique(a{k}.ImageMetadata_ROI);
    for i=1:length(fields)
        rows1hr=CellComputations1hr.ImageMetadata_ROI==fields(i);
        byfielddata1hr{i}=CellComputations1hr(rows1hr,:);
    end
    
    for i=1:length(byfielddata1hr)
        rowsdeempty(1,i)=~isempty(byfielddata1hr{1,i});
    end
    byfielddata1hr=byfielddata1hr(rowsdeempty);
    realfields=[];
    for i=1:length(byfielddata1hr)
        realfields(1,i)=byfielddata1hr{1,i}.ImageMetadata_ROI(1);
    end
    fields=realfields;
    wellname=num2str(unique(a{k}.ImageMetadata_Column));
    varname=strcat(wellname,'_',num2str(a{k}.ImageMetadata_ROI(1)));
    save (['byfielddata1hr',' ',varname],'byfielddata1hr')
    save (['CellComputations1hr',' ',varname],'CellComputations1hr')
    % save(['fields',' ',varname],'fields')
    %% Life time suggested cells
    % Here's where you'll get a list of cell tracks sorted by life time, maybe
    % you'll think about using one of em
    
    Lifetime=CellComputations1hr(:,vars);
    colzz={'NUCTrackObjects_Label_20','ImageMetadata_ROI'};
    for i=1:length(fields)
        rows1hr=Lifetime.ImageMetadata_ROI==fields(i);
        byLIFEdata1hr{i}=CellComputations1hr(rows1hr,:);
        j=max((byLIFEdata1hr{i}.NUCTrackObjects_FinalAge_20));
        rowsMaxLife1hr=byLIFEdata1hr{i}.NUCTrackObjects_FinalAge_20==j;
        HighbyLIFEdata1hr{i}=byLIFEdata1hr{i}(rowsMaxLife1hr,:);
        SuggestedCells1hr{i}=HighbyLIFEdata1hr{i}(:,colzz);
        SuggestedCells1hr{i}=sortrows(SuggestedCells1hr{i},1);
    end
    colzz={'NUCTrackObjects_Label_20','ImageMetadata_ROI'};
    for ii=1:length(fields)
        rows=byLIFEdata1hr{ii}.ImageImageNumber==byLIFEdata1hr{ii}.ImageImageNumber(1); % cells at tp 1
        atleast1hr{ii}=byLIFEdata1hr{ii}(rows,colzz);
        atleast1hr{ii}=sortrows(atleast1hr{ii},1);
    end
    
    cellsToPlot1hr={};
    cellsToPlot1hr=atleast1hr;
    %% table with all of the cells from each field you wanted
    counter=1;
    vars = {'ImageImageNumber', 'CytoplasmObjectNumber', 'ImageMetadata_Column', 'ImageMetadata_ROI','ERKRatio','AktRatio', 'ImageMetadata_time', 'CytoplasmIntensity_IntegratedIntensity_DNA', 'CytoplasmIntensity_IntegratedIntensity_akt', 'CytoplasmIntensity_IntegratedIntensity_erk', 'CytoplasmIntensity_MeanIntensity_DNA', 'CytoplasmIntensity_MeanIntensity_akt', 'CytoplasmIntensity_MeanIntensity_erk', 'CytoplasmIntensity_MedianIntensity_DNA', 'CytoplasmIntensity_MedianIntensity_akt', 'CytoplasmIntensity_MedianIntensity_erk', 'CytoplasmIntensity_StdIntensity_DNA', 'CytoplasmIntensity_StdIntensity_akt', 'CytoplasmIntensity_StdIntensity_erk', 'CytoplasmNumber_Object_Number', 'NUCIntensity_IntegratedIntensity_DNA', 'NUCIntensity_IntegratedIntensity_akt', 'NUCIntensity_IntegratedIntensity_erk', 'NUCIntensity_MeanIntensity_DNA', 'NUCIntensity_MeanIntensity_akt', 'NUCIntensity_MeanIntensity_erk', 'NUCIntensity_MedianIntensity_DNA', 'NUCIntensity_MedianIntensity_akt', 'NUCIntensity_MedianIntensity_erk', 'NUCIntensity_StdIntensity_DNA', 'NUCIntensity_StdIntensity_akt', 'NUCIntensity_StdIntensity_erk', 'NUCNumber_Object_Number', 'NUCTrackObjects_Displacement_20', 'NUCTrackObjects_DistanceTraveled_20', 'NUCTrackObjects_FinalAge_20', 'NUCTrackObjects_IntegratedDistance_20', 'NUCTrackObjects_Label_20', 'NUCTrackObjects_Lifetime_20', 'NUCTrackObjects_Linearity_20', 'NUCTrackObjects_ParentImageNumber_20', 'NUCTrackObjects_ParentObjectNumber_20', 'NUCTrackObjects_TrajectoryX_20', 'NUCTrackObjects_TrajectoryY_20'};
    
    for j=1:length(fields)
        
        for jj=1:height(cellsToPlot1hr{j}(:,1))
            rows=byfielddata1hr{j}.NUCTrackObjects_Label_20==table2array(cellsToPlot1hr{j}(jj,1)); %
            joined_1hr{counter}=[byfielddata1hr{j}(rows,vars)];
            counter=counter+1;
        end
    end
    
    for lmnop=1:length(joined_1hr)
        if height(joined_1hr{1,lmnop})<=120 % time filter
            joined_1hr{1,lmnop}=[];
        else
            if median(joined_1hr{1,lmnop}.ERKRatio(startTP:stopTP))>1.2
                joined_1hr{1,lmnop}=[];
            else
                if sum(joined_1hr{1,lmnop}.ERKRatio(stopTP+1:end)>1.5)>0
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
   parfor j=1:length(joined_1hr)
        Zerk=normalize(joined_1hr{1,j}.ERKRatio,'range');
        Zakt=normalize(joined_1hr{1,j}.AktRatio,'range');
        joined_1hr{1,j}.ERKRatioZ=Zerk;
        joined_1hr{1,j}.AktRatioZ=Zakt;
        
    end
%% plotting Individual cells
    % figure;
    stringCell={};
    stringField={};
    cellLabels={};
    for m=1:length(joined_1hr)
        stringCell{m}=num2str(joined_1hr{1,m}.NUCTrackObjects_Label_20(startTP),'cell %-d ');
        stringField{m}=num2str(joined_1hr{1,m}.ImageMetadata_ROI(startTP),' field %-d');
        cellLabels{m}=[stringCell{m} ' ' stringField{m}];
    end
    
    legendCell = (cellLabels);
    % legend(legendCell)
    joined_1hr(2,:)=cellLabels;
    save (['joined_1hr',' ',varname],'joined_1hr')
%% Normalization 1hr
normalized_plots_1hr={};
for ii=1:length(joined_1hr);
    for jj=1:length(joined_1hr{1,ii}.ERKRatio);
        CellNormConst_1hr_ERK(1,ii)=median(joined_1hr{1,ii}.ERKRatio(startTP:stopTP)); 
        CellNormConst_1hr_Akt(1,ii)=median(joined_1hr{1,ii}.AktRatio(startTP:stopTP)); 
        normalized_plots_1hr{ii}=joined_1hr{1,ii};
        normalized_plots_1hr{ii}.ERKNorm=joined_1hr{1,ii}.ERKRatio./CellNormConst_1hr_ERK(1,ii);
        normalized_plots_1hr{ii}.AktNorm=joined_1hr{1,ii}.AktRatio./CellNormConst_1hr_Akt(1,ii);
    end
end
save (['normalized_plots_1hr',' ',varname],'normalized_plots_1hr')
%% plotting dynamics, be sure to pick what you want to plot

for m=1:length(joined_1hr)
whatToPlot{m}=joined_1hr{1,m}.ERKRatio;
end
nameofparameter='ERK KTR ratio';
ktrplots(nameofparameter,whatToPlot,varname,hrslabel,cellLabels,tickPos)

for m=1:length(joined_1hr)
whatToPlot{m}=joined_1hr{1,m}.AktRatio;
end
nameofparameter='Akt KTR ratio';
ktrplots(nameofparameter,whatToPlot,varname,hrslabel,cellLabels,tickPos)

% nuclear values
for m=1:length(joined_1hr)
whatToPlot{m}=joined_1hr{1,m}.NUCIntensity_MeanIntensity_akt;
end
nameofparameter='Akt nuclear KTR';
ktrplots(nameofparameter,whatToPlot,varname,hrslabel,cellLabels,tickPos)

for m=1:length(joined_1hr)
whatToPlot{m}=joined_1hr{1,m}.NUCIntensity_MeanIntensity_erk;
end
nameofparameter='ERK nuclear KTR';
ktrplots(nameofparameter,whatToPlot,varname,hrslabel,cellLabels,tickPos)

% Z score normalized values
for m=1:length(joined_1hr)
whatToPlot{m}=joined_1hr{1,m}.ERKRatioZ;
end
nameofparameter='ERK KTR ratio Zscore';
ktrplots(nameofparameter,whatToPlot,varname,hrslabel,cellLabels,tickPos)

for m=1:length(joined_1hr)
whatToPlot{m}=joined_1hr{1,m}.AktRatioZ;
end
nameofparameter='Akt KTR ratio Zscore';
ktrplots(nameofparameter,whatToPlot,varname,hrslabel,cellLabels,tickPos)
%%  KTR subplots 5x5
hrsplot=[0:12:48];
[LogArray,Loc]=ismember(hrsplot,timechart(:,3));
tickPos=Loc;
hrslabel={};
for i=1:length(hrsplot)
    hrslabel{i}=num2str(hrsplot(i));
end



figure;
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
                    times=1:length(joined_1hr{1,counters(j)}.ImageMetadata_time(1:end));
              plot(times,joined_1hr{1,counters(j)}.ERKRatioZ,'r','LineWidth',1,'MarkerSize',1, 'MarkerEdgeColor','r'); hold on
                            plot(times,joined_1hr{1,counters(j)}.AktRatioZ,'g','LineWidth',1,'MarkerSize',1, 'MarkerEdgeColor','r');
hold off
box off
ylim([0 1.1])
xlim([0 590])
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

clearvars -except a varname k maxtimes startTP stopTP
close all
end