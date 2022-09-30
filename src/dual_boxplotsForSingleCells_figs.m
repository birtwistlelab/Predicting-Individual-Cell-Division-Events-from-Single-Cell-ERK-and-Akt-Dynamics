% for this to work load the data exported from boxplots_figs.m code
% BP with both erk and akt side by side
%1.	ERK div (1), ERK non-dividing (2), Akt div(3), Akt non-dividing (4)

% navigate to the ERK directory
% \Demo\singleReporter\9\ERK\high
uiopen('.mat')
div_values_ERK = horzcat(all_div_cells,all_non_div);
div_values_ERK = cell2mat(div_values_ERK(3,:))
inds=div_values_ERK==0;
div_values_ERK(inds)=2;
% \Demo\singleReporter\9\Akt\high

uiopen('.mat')
div_values_akt = horzcat(all_div_cells,all_non_div);
div_values_akt = cell2mat(div_values_akt(3,:))
inds=div_values_akt==1;
div_values_akt(inds)=3;

inds=div_values_akt==0;
div_values_akt(inds)=4;

B_w=horzcat(B_w_ERK,B_w_akt);
dual_div_values=horzcat(div_values_ERK,div_values_akt);
save (['dual_div_values'],'dual_div_values')
%%
for i=1:3
    figure
    zz=cell2mat(B_w(i,:))
    bb=notBoxPlot(zz,dual_div_values,'markMedian',true)
    for p =1:4
    bb(p).med.Color=[1 0 0];
    bb(p).mu.Visible='off';
    bb(p).med.LineStyle='-';
    bb(p).med.LineWidth=2;
    bb(p).data.Marker='.'
    bb(p).data.Color=[0 0 0]
    bb(p).data.MarkerFaceColor=[0 0 0]
    bb(p).sdPtch.FaceColor=[1 1 1]
    bb(p).sdPtch.EdgeColor=[0 0 0]
    bb(p).sdPtch.LineWidth=2;
    bb(p).semPtch.FaceColor=[1 1 1]
    bb(p).semPtch.EdgeColor=[1 1 1]
    bb(p).semPtch.Visible='off'
    bb(p).data.MarkerSize=3;
    end   
    fig=gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 3 2];
    xlim([.5 4.5])
    ylim([.4 1.6])
    savefig(gcf,strcat('median_w_all', '_', num2str(i)))
    print(strcat('median_w_all', '_', num2str(i)),'-dpng','-r300')
end
