% this code generates a biaxial svm classifier
% please load the median data from the boxplots
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
  ind = ~isnan(B_w_ERK(2,:));
  B_w_ERK=B_w_ERK(:,ind)
  B_w_Akt=B_w_Akt(:,ind)
  
  save (['B_W_ERK_SORT'],'B_w_ERK')
  save (['B_W_AKT_SORT'],'B_w_Akt')
  
  X=[];
  y=[];
  classdata=vertcat(B_w_ERK(2,:),B_w_Akt(2,:),B_w_Akt(4,:))';
%%
numOfCells=40; % please specify the number of cells to use. here we used the max of the smaller population
classdata_divlogic=classdata(:,3)==1;
classdata_nddivlogic=classdata(:,3)==0;
classdata_div=classdata(classdata_divlogic,:);
classdata_ndiv=classdata(classdata_nddivlogic,:);
random_cells_div=[];random_cells_ndiv=[]; random_cells=[];
random_cells_div = randi([1 length(classdata_div)],1,numOfCells)';
random_cells_ndiv = randi([1 length(classdata_ndiv)],1,numOfCells)';
for i=1:length(random_cells_div)
    classdata_pics_div(i,:)=classdata_div(random_cells_div(i),:);
    classdata_pics_ndiv(i,:)=classdata_ndiv(random_cells_ndiv(i),:);
end

%%
figure
scatter(classdata_pics_ndiv(:,1),classdata_pics_ndiv(:,2),2,'MarkerFaceColor','r','MarkerEdgeColor','r',...
    'MarkerFaceAlpha',.4,'MarkerEdgeAlpha',.4)
hold on
scatter(classdata_pics_div(:,1),classdata_pics_div(:,2),2,'MarkerFaceColor','b','MarkerEdgeColor','b',...
    'MarkerFaceAlpha',.4,'MarkerEdgeAlpha',.4)
xlim([.5 1.3]);
ylim([.6 1.3]);
box off
legend off
hold off