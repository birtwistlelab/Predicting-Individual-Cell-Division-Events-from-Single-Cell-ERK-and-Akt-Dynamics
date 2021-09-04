% for this to work load the data exported from boxplots_figs.m code
% BP with both erk and akt side by side
%1.	ERK div (1), ERK non-dividing (2), Akt div(3), Akt non-dividing (4)
load B_w_ERK
B_w_ERK = B_w

load B_w_Akt
B_w_akt = B_w

load all_div_cells_ERK
load all_non_div_ERK
div_values_ERK = horzcat(all_div_cells,all_non_div);
div_values_ERK = cell2mat(div_values_ERK(3,:))
inds=div_values_ERK==0;
div_values_ERK(inds)=2;

load all_div_cells_Akt
load all_non_div_Akt
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
    bb(1).med.Color=[1 0 0];
    bb(1).mu.Visible='off';
    bb(1).med.LineStyle='-';
    bb(1).med.LineWidth=2;
    bb(1).data.Marker='.'
    bb(1).data.Color=[0 0 0]
    bb(1).data.MarkerFaceColor=[0 0 0]
    bb(1).sdPtch.FaceColor=[1 1 1]
    bb(1).sdPtch.EdgeColor=[0 0 0]
    bb(1).sdPtch.LineWidth=2;
    bb(1).semPtch.FaceColor=[1 1 1]
    bb(1).semPtch.EdgeColor=[1 1 1]
    bb(1).semPtch.Visible='off'
    bb(1).data.MarkerSize=3;
    bb(2).data.MarkerSize=3;
    bb(2).med.Color=[1 0 0];
    bb(2).mu.Visible='off';
    bb(2).med.LineStyle='-';
    bb(2).med.LineWidth=2;
    bb(2).data.Marker='.'
    bb(2).data.Color=[0 0 0]
    bb(2).data.MarkerFaceColor=[0 0 0]
    bb(2).sdPtch.FaceColor=[1 1 1]
    bb(2).sdPtch.EdgeColor=[0 0 0]
    bb(2).sdPtch.LineWidth=2;
    bb(2).semPtch.FaceColor=[1 1 1]
    bb(2).semPtch.EdgeColor=[1 1 1]
    bb(2).semPtch.Visible='off'
    bb(3).data.MarkerSize=3;
    bb(3).med.Color=[0 0.8 0];
    bb(3).mu.Visible='off';
    bb(3).med.LineStyle='-';
    bb(3).med.LineWidth=2;
    bb(3).data.Marker='.'
    bb(3).data.Color=[0 0 0]
    bb(3).data.MarkerFaceColor=[0 0 0]
    bb(3).sdPtch.FaceColor=[1 1 1]
    bb(3).sdPtch.EdgeColor=[0 0 0]
    bb(3).sdPtch.LineWidth=2;
    bb(3).semPtch.FaceColor=[1 1 1]
    bb(3).semPtch.EdgeColor=[1 1 1]
    bb(3).semPtch.Visible='off'
    bb(2).data.MarkerSize=3
    bb(4).data.MarkerSize=3
    bb(4).med.Color=[0 0.8 0];
    bb(4).mu.Visible='off';
    bb(4).med.LineStyle='-';
    bb(4).med.LineWidth=2;
    bb(4).data.Marker='.'
    bb(4).data.Color=[0 0 0]
    bb(4).data.MarkerFaceColor=[0 0 0]
    bb(4).sdPtch.FaceColor=[1 1 1]
    bb(4).sdPtch.EdgeColor=[0 0 0]
    bb(4).sdPtch.LineWidth=2;
    bb(4).semPtch.FaceColor=[1 1 1]
    bb(4).semPtch.EdgeColor=[1 1 1]
    bb(4).semPtch.Visible='off'
    
    fig=gcf;
    fig.PaperUnits = 'inches';
    fig.PaperPosition = [0 0 3 2];
    xlim([.5 4.5])
    ylim([.4 1.6])
    savefig(gcf,strcat('median_w_all', '_', num2str(i)))
    print(strcat('median_w_all', '_', num2str(i)),'-dpng','-r300')
end

close all
