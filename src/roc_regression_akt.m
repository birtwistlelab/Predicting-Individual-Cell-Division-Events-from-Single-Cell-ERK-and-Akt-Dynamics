% used this link for help https://www.mathworks.com/help/stats/perfcurve.html
% point this script towards where the single reporter data is
%load the SINGLE reporter data
load all_div_cells_Akt
load all_non_div_Akt
load B_w_Akt
reportertype={};
reportertype='Akt';

all_data=horzcat(all_div_cells, all_non_div);
div_values=cell2mat(all_data(3,:));
pred=cell2mat(B_w(2,:)); % prediction window 2 of the time course
resp=div_values; % response (cell division values )
mdl = fitglm(pred,resp,'Distribution','binomial');
scores = mdl.Fitted.Probability;
[X,Y,T,AUC] = perfcurve(resp,scores,1);
plot(X,Y,'k')
ax=gca;
ax.LineWidth=1;
ax.FontSize=10;
box(ax,'off')
set(gcf, 'PaperPositionMode','manual','PaperUnits','inches','PaperPosition',[0 0 3.5 2]);
savefig(gcf,[strcat(reportertype,'roc')])
print([strcat(reportertype,'roc')],'-dpng','-r300')

save(['AUC',' ',reportertype],'AUC')
disp(AUC)

%%% random sampling can be done here 
%BW=cell2mat(B_w(2,:));
%Bw_div=BW(div_values==1);
%Bw_nd=BW(div_values==0);
%samples=70;
%random_cells = randi([0 length(Bw_div)],1,samples);
%BW_div_rand={};
%BW_nd_rand={};
%BW_div_rand=Bw_div(random_cells);
%BW_nd_rand=Bw_nd(random_cells);
%div_rand=ones(1,samples);
%nd_rand=(ones(1,samples))-1;
%BW_rand=horzcat(BW_div_rand,BW_nd_rand);
%div_values_rand=horzcat(div_rand,nd_rand);
%pred=BW_rand;
%resp=div_values_rand;
%mdl = fitglm(pred,resp,'Distribution','binomial');
%scores = mdl.Fitted.Probability;
%[X,Y,T,AUC] = perfcurve(resp,scores,1);
%plot(X,Y,'k')
%% xlabel('False positive rate') 
%% ylabel('True positive rate')
%% title('ROC for Classification by Logistic Regression')
%% ax=gca;
%% ax.LineWidth=1;
%% ax.FontSize=10;
%% box(ax,'off')
%% set(gcf, 'PaperPositionMode','manual','PaperUnits','inches','PaperPosition',[0 0 3.5 2]);
%% savefig(gcf,['ERKAktroc'])
%% print(['ERKAktroc'],'-dpng','-r300')