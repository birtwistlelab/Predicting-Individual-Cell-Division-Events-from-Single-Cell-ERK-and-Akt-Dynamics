% this code generates a biaxial svm classifier
% please load the median data from the boxplots
% load B_w_ERK
% load B_w_Akt
% load all_div_cells
% load all_non_div

B_w_ERK=cell2mat(B_w_ERK);
B_w_Akt=cell2mat(B_w_Akt);


all_data=horzcat(all_div_cells,all_non_div);
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

  a=length(all_div_cells);
b=length(all_non_div);
logic_test=min([a,b]);
%%

Xsvm={};Ysvm={};AUCsvm={};

numOfCells=34; % please specify the number of cells to use. here we used the max of the smaller population
classdata_divlogic=classdata(:,3)==1;
classdata_nddivlogic=classdata(:,3)==0;
classdata_div=classdata(classdata_divlogic,:);
classdata_ndiv=classdata(classdata_nddivlogic,:);
random_cells_div=[];random_cells_ndiv=[]; random_cells=[];

for p=1:10
for i=1:numOfCells
    random_cells_div = randperm( length(classdata_div),numOfCells)';
random_cells_ndiv = randperm(length(classdata_ndiv),numOfCells)';
    classdata_pics_div{p}(i,:)=classdata_div(random_cells_div(i),:);
    classdata_pics_ndiv{p}(i,:)=classdata_ndiv(random_cells_ndiv(i),:);
end
classdata_pics=vertcat(classdata_pics_div{p},classdata_pics_ndiv{p});
%x is the data, y is the response X(1:50,1:2)
X=[]; y=[];
X(:,1)=classdata_pics(:,1);X(:,2)=classdata_pics(:,2);
y=classdata_pics(:,3);
score_svm=[];scores=[];
SVMModel = fitcsvm(X,y);
%[label,score] = predict(trainedModel1,X);
% using this link https://www.mathworks.com/matlabcentral/answers/260523-how-to-draw-the-roc-curve-for-svm-knn-naive-bayes-classifiers
SVMModel = fitPosterior(SVMModel);
[~,score_svm] = resubPredict(SVMModel);
[label,scores] = resubPredict(SVMModel);
%Predicted class scores or posterior probabilities, returned as a numeric matrix of size n-by-K. n is the number of observations (rows) in the training data X, and K is the number of classes (in mdl.ClassNames). score(i,j) is the posterior probability that observation i in X is of class j in mdl.ClassNames. See Posterior Probability.
% [Xsvm,Ysvm,AUCsvm] = perfcurve(y,score_svm(:,SVMModel.ClassNames),'true'); 
% [X,Y,T,AUC] = perfcurve(resp,scores,1);
% first column contains the negative class scores and the second column contains the positive class scores for the corresponding observations.
[Xsvm{p},Ysvm{p},AUCsvm{p}] = perfcurve(y,score_svm(:,2),1);
figure
plot(Xsvm{p},Ysvm{p},'k')
box off
AUCsvm{p}=trapz(Xsvm{p},Ysvm{p});
end
save(['svm.mat'],'Xsvm','Ysvm','AUCsvm','classdata_pics_div','classdata_pics_ndiv')
AUCsvm=cell2mat(AUCsvm);
%% lets plot the best possible svm
bestsvm=max(AUCsvm)
ind=find(bestsvm==AUCsvm);
%%auc   
figure
plot(Xsvm{ind},Ysvm{ind},'k')
box off

gcf;
savefig('AUCPlot')
%%
figure
scatter(classdata_pics_ndiv{ind}(:,1),classdata_pics_ndiv{ind}(:,2),20,'MarkerFaceColor','r','MarkerEdgeColor','r',...
    'MarkerFaceAlpha',.4,'MarkerEdgeAlpha',.4)
hold on
scatter(classdata_pics_div{ind}(:,1),classdata_pics_div{ind}(:,2),20,'MarkerFaceColor','b','MarkerEdgeColor','b',...
    'MarkerFaceAlpha',.4,'MarkerEdgeAlpha',.4)
xlim([0.8 1.1]);
ylim([0.8 1.1]);
box off
legend off
hold on
% 
xt = linspace(0.8,1.1);
yt = linspace(0.8,1.1);
[XX,YY] = meshgrid(xt,yt);
% here we generate the hyperplane
pred = [XX(:),YY(:)];
p = predict(SVMModel,pred);
% gscatter(pred(:,1),pred(:,2),p)
f = @(xt) -(xt*SVMModel.Beta(1) + SVMModel.Bias)/SVMModel.Beta(2);
yt = f(yt);
hold on
plot(xt,yt,'k--','LineWidth',2,'DisplayName','Boundary')
hold off

gcf;
print(['svm'],'-dpng','-r300');
savefig(['svm']);
