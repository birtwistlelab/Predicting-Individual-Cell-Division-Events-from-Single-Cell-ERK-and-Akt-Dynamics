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
    %%
Folder   = pwd;
FileList = dir(fullfile(Folder, '**', 'joined_1hr *'));
expression = '(joined_1hr)  | \w*';
startTP=1; % set these to the start and stop time before GF stim
stopTP=12;
for k=1:length(FileList)
well_extract = regexp(FileList(k).name, expression, 'match');
    baseFileName = FileList(k).name;
    fullFileName = [FileList(k).folder,'/',baseFileName]
 fprintf(1, 'Now reading %s\n', fullFileName);
    fileID = load(fullFileName, '-mat');
    dataset1{1,k} = fileID.joined_1hr;
dataset1{2,k}=well_extract;
end

% timepoints to plot
% 15min 8hr 12hr and 24hr
interval1=[1 7];
interval2=[8 20];
interval3=[21 50];
alltimes=vertcat(interval1,interval2,interval3);
% extracting data
for p=1:size(dataset1,2)
    dataholder=dataset1{1,p};
    for z=1:length(dataholder)
        for a=1:length(alltimes)
            if height(dataholder{1,z})>=alltimes(a)
    valueholderERK(z,a)=mean(dataholder{1,z}.ERKRatio(alltimes);
    valueholderAkt(z,a)=dataholder{1,z}.AktRatio(alltimes(a));
            else continue
            end
            end
    end
dataset1{3,p}=valueholderERK;
dataset1{4,p}=valueholderAkt;
end

% concat the data
for p=1:size(dataset1,2)
 names(p)=str2num(dataset1{2,p}{1,1}(2))
end
for p=1:size(dataset1,2)
 namecheck(p)=str2num(dataset1{2,p}{1,1}(2))
end
names=unique(names);
for z=1:length(names)
     inds=namecheck==names(z);
      cat_data_ERK{z}=vertcat(dataset1{3,inds});
            cat_data_Akt{z}=vertcat(dataset1{4,inds});

end
% going throught the catted data

for p=1:length(cat_data_ERK)
    for z=1:length(alltimes)
        holder=cat_data_ERK{1,p}(:,z);
        holder(holder==0) = NaN;
        ERK_timecourse_median(z,p)=median(holder,'omitnan')
        ERK_timecourse_dev(z,p)=std(holder,'omitnan')
    end
end

for p=1:length(cat_data_Akt)
    for z=1:length(alltimes)
        holder=cat_data_Akt{1,p}(:,z);
        holder(holder==0) = NaN;
        Akt_timecourse_median(z,p)=median(holder,'omitnan')
        Akt_timecourse_dev(z,p)=std(holder,'omitnan')
    end
end

% getting the var as a function of time for different doses

% extract all data for a dose








% All data needs to be nan padded
for j=1:length(dataset1)
    for p=1:length(dataset1{1,j})
        sizeofdata=height(dataset1{1,j}{1,p});
        padsizes=maxnumofTPs-sizeofdata;
        tempERK=padarray(dataset1{1,j}{1,p}.ERKRatio,padsizes, nan, 'post');
        tempAkt=padarray(dataset1{1,j}{1,p}.AktRatio,padsizes, nan, 'post');
    dataset1{1,j}{3,p}=tempERK;
    dataset1{1,j}{4,p}=tempAkt;

    end
end


% grab the first ands every n time point acros all cells
timeholder=cell(1,length(dataset1));
for t=1:maxnumofTPs
for j=1:length(dataset1)
    for p=1:length(dataset1{1,j})
        timeholder{1,j}(t,p)=dataset1{1,j}{3,p}(t); % ERK
                timeholder{2,j}(t,p)=dataset1{1,j}{4,p}(t); % Akt;

    end
    end
end
% horizontally concatinate data from same dosesz
% 
for z=1:length(names)
     inds=namecheck==names(z);
      cat_data_timeholderERK{z}=horzcat(timeholder{1,inds});
      cat_data_timeholderAkt{z}=horzcat(timeholder{2,inds});

end

% getting the varience 
for i=1:length(cat_data_timeholderERK)
   
cat_data_timeholderERK{2,i}=var(cat_data_timeholderERK{1,i},0,2,'omitnan');    
cat_data_timeholderAkt{2,i}=var(cat_data_timeholderAkt{1,i},0,2,'omitnan');    

end
%%
figure
for i=1:length(cat_data_timeholderERK)
plot(cat_data_timeholderERK{2, i}, 'LineWidth',2  )
hold on
end
gcf; box off
% ylim([0 1.1])
xlabel('Dose')
ylabel('Var ERK KTR')
legend('mock','1xEGFINS','1:10','1:100','1:1k','1:10k','1:100k')

%%
figure
for i=1:length(cat_data_timeholderAkt)
plot(cat_data_timeholderAkt{2, i}, 'LineWidth',2  )
hold on
end
gcf; box off
% xlim([0 200])
xlabel('Dose')
ylabel('Var Akt KTR')
legend('mock','1xEGFINS','1:10','1:100','1:1k','1:10k','1:100k')
%% making plots
Linepropscolors={'k','r','g','b'}
colors=colormap(lines);
figure
for z=1:length(alltimes)
shadedErrorBar([],ERK_timecourse_median(z,:),ERK_timecourse_dev(z,:),'lineProps',{'Color',colors(z,:),'markerfacecolor',colors(z,:)})
end
gcf; box off
% ylim([0 1.1])
xlabel('Dose')
ylabel('Median KTR')
title('ERK')
legend('start','15 min','8hrs','12hrs','24hrs')
% set(gcf, 'PaperPositionMode','manual','PaperUnits','inches','PaperPosition',[0 0 3 2])
savefig(gcf,'ERK dose response timecourse')
print(['ERK dose response timecourse'],'-dpng','-r300')



figure
for z=1:length(alltimes)
shadedErrorBar([],Akt_timecourse_median(z,:),Akt_timecourse_dev(z,:),'lineProps',{'Color',colors(z,:),'markerfacecolor',colors(z,:)})
hold on
end
gcf; box off
ylim([0.85 1.1])
gcf; box off
ylim([0 1.1])
xlabel('Dose')
ylabel('Median KTR')
title('Akt')
legend('15 min','8hrs','12hrs','24hrs')
savefig(gcf,'Akt dose response timecourse')
print(['Akt dose response timecourse'],'-dpng','-r300')
%% percent max
% if a cell was saturated, then it would stay at max level of activity for 
% the enitre time course, and would show very little change 

normalized_plots_1hr={};
for ii=1:length(dataset1);
    for jj=1:length(dataset1{1,ii});
        min_ERK(1,ii)=max(dataset1{1,ii}{1,jj}.NUCIntensity_MeanIntensity_erk(startTP)); 
        min_Akt(1,ii)=max(dataset1{1,ii}{1,jj}.NUCIntensity_MeanIntensity_akt(startTP)); 
         
      
dataset1{1,ii}{5,jj}=table;
        
        dataset1{1,ii}{5,jj}.ERKNorm_Nuc=dataset1{1,ii}{1,jj}.NUCIntensity_MeanIntensity_erk(:)./min_ERK(1,ii);
        dataset1{1,ii}{5,jj}.AktNorm_Nuc=dataset1{1,ii}{1,jj}.NUCIntensity_MeanIntensity_akt(:)./min_Akt(1,ii);

    end
end