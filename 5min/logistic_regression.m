w2s = 107;
 w2e = 485;

%  w2s = 107;
%  w2e = 365;

% old data
%  w2s = 40;
%  w2e = 166;
% combine both non and dividing cells
% all_data={};
B_w_ERK = {}; % ERK is row 6
B_w_Akt = {}; % Akt is row 7
% all_data=horzcat(all_div_cells,all_non_div);

for i = 1:length(all_data)
    B_w_ERK{2, i} = median(all_data{6, i}(w2s:w2e),'omitnan'); %81
    B_w_Akt{2, i} = median(all_data{7, i}(w2s:w2e),'omitnan'); %81
end


B_w_ERK=cell2mat(B_w_ERK);
B_w_Akt=cell2mat(B_w_Akt);
div_status=cell2mat(all_data(3,:));
B_w_ERK(4,:)=div_status;
B_w_Akt(4,:)=div_status;

%%
% svm data prep
 % remove nans please and sort the data 1-transpose data sort to rid
  % the nans and then sorting again
  ind = ~isnan(B_w_ERK(1,:));
  B_w_ERK=B_w_ERK(:,ind)
  B_w_Akt=B_w_Akt(:,ind)
  all_data=all_data(:,ind);
  save (['B_W_ERK_SORT'],'B_w_ERK')
  save (['B_W_AKT_SORT'],'B_w_Akt')
  
  X=[];
  y=[];
  classdata=vertcat(B_w_ERK(1,:),B_w_Akt(1,:),cell2mat(all_data(3,:)))';
inds=classdata(:,3)==1;
  classdata_div=classdata(inds,:);
classdata_nodiv=classdata(~inds,:);
  a=length(all_div_cells);
b=length(all_non_div);
logic_test=min([a,b]);
%% Generating the training set
totalCells=size(classdata,1);
numDiv=size(classdata_div,1);
numNoDiv=size(classdata_nodiv,1);
trainDivSize=floor(numDiv*1);
trainNODiv=floor(numNoDiv*1);
divcat=ones(1,trainDivSize)
nodivcat=zeros(1,trainNODiv)
 random_cells_div = randperm(length(classdata_div),trainDivSize)';
random_cells_ndiv = randperm(length(classdata_nodiv),trainNODiv)';
data_div=classdata_div(random_cells_div,:);
data_nodiv=classdata_nodiv(random_cells_ndiv,:);
trainingset=(vertcat(data_div,data_nodiv));
inds=1:length(classdata_div);
indstokeep1=setdiff(inds,random_cells_div);
inds=1:length(classdata_nodiv);
indstokeep2=setdiff(inds,random_cells_ndiv);
classdata_divtest=classdata_div(indstokeep1,:);
classdata_nodivtest=classdata_nodiv(indstokeep2,:);
testset=vertcat(classdata_divtest,classdata_nodivtest);


%% now make the model
X=[]; y=[];
X(:,1)=trainingset(:,1);X(:,2)=trainingset(:,2);
y=logical(trainingset(:,3));



mdl = fitglm(X,y,'Distribution','binomial','link','logit');
mdl2 = stepwiseglm(X,y,'constant','Distribution','binomial','Upper','linear')
scores = mdl.Fitted.Probability;
[Xlogit,Ylogit,Tlogit,AUClogit] = perfcurve(y,scores,1);

% to report the mdl coefficients use
fitInfo=mdl.Coefficients

plot(Xlogit,Ylogit,'k')
ax=gca;
ax.LineWidth=1;
ax.FontSize=10;
box(ax,'off')
set(gcf, 'PaperPositionMode','manual','PaperUnits','inches','PaperPosition',[0 0 3.5 2]);
savefig(gcf,'roc')
gcf
print('roc','-dpng','-r300')

save('fitInfo','fitInfo','mdl','mdl2','Xlogit','Ylogit','Tlogit','AUClogit')

