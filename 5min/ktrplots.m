function ktrplots(nameofparameter,whatToPlot,varname,hrslabel,cellLabels,tickPos)
figure
for z=1:length(whatToPlot)    
        plot(whatToPlot{z},'LineWidth',1,'MarkerSize',3, 'MarkerEdgeColor','r')
    hold on
end
gcf;
legendCell = cellLabels;
legend(legendCell)
title([nameofparameter,' ' varname]);
xlabel('Time (Hrs)');
ylabel('KTR nuc Fluorescence A.U');
 set(gca, 'XTick', tickPos);
        ax=gca;
        ax.XAxis.TickLabels=hrslabel;
        xtickangle(45)

box off
set(gcf, 'PaperPositionMode','manual','PaperUnits','inches','PaperPosition',[10 10 10 10])
savefig(gcf,[nameofparameter ' ' varname])
print([nameofparameter ' ' varname],'-dpng','-r300')
hold off


end