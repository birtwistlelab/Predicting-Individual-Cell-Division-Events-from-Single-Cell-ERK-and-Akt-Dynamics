sizes=[];
 maxsize=590
 padsizes=[];
 
for i=1:size(all_div_cells,2)
    sizes(i)=length(all_div_cells{5,i}.ERKRatio);
end
maxsize=590
padsizes=maxsize-sizes;
for i=1:size(all_div_cells,2)
   all_div_cells{6,i}=padarray(all_div_cells{5,i}.ERKRatio,padsizes(i),nan,'post');
      all_div_cells{7,i}=padarray(all_div_cells{5,i}.AktRatio,padsizes(i),nan,'post');

end

% ND
sizes=[];
maxsizeND=590
padsizes=[];
for i=1:size(all_non_div,2)
    sizes(i)=length(all_non_div{1,i}.ERKRatio);
 end
maxsizeND=590
padsizes=maxsizeND-sizes;
for i=1:size(all_non_div,2)
     all_non_div{6,i}=padarray(all_non_div{1,i}.ERKRatio,padsizes(i),nan,'post');
          all_non_div{7,i}=padarray(all_non_div{1,i}.AktRatio,padsizes(i),nan,'post');

end
%%
% med_div_ERK and Akt
valueholder_ERK=[];
valueholder_Akt=[];
med_DIV=[];
for ii=1:maxsize
    for i=1:size(all_div_cells,2)
        valueholder_ERK(i)=all_div_cells{6,i}(ii);
                valueholder_Akt(i)=all_div_cells{7,i}(ii);

    end
med_DIV_ERK(ii)=nanmedian(valueholder_ERK) ;
med_DIV_Akt(ii)=nanmedian(valueholder_Akt) ;

end

% med_noDIV=[];
valueholdernd_ERK=[];
valueholdernd_Akt=[];

med_NODIV=[];
for ii=1:maxsizeND
    for i=1:size(all_non_div,2)
        valueholdernd_ERK(i)=all_non_div{6,i}(ii);
                valueholdernd_Akt(i)=all_non_div{7,i}(ii);

    end
med_NODIV_ERK(ii)=nanmedian(valueholdernd_ERK) ;
med_NODIV_Akt(ii)=nanmedian(valueholdernd_Akt) ;

end

%% plotting the data and making hte fgs\
  %% ERK-6
    figure

    for i = 1:size(all_div_cells,2)
        plot(all_div_cells{6, i},'Color',[0 0 .8 .3])
        hold on
    end

    for i = 1:size(all_non_div,2)
        plot(all_non_div{6, i},'Color',[.8 0 0 .2])
        hold on
    end

    plot(med_DIV_ERK, 'linewidth', 3, 'Color', [0 0 .5 .8]) % for alpha= 0 to 1 the lines will be more clear
    plot(med_NODIV_ERK, 'linewidth', 3, 'Color', [.5 0 0 .8]) % for alpha= 0 to 1 the lines will be more clear
    ylim([0.8 1.1])

   
    ax = gca;
    set(gca, 'XTick', tickPos);

    ax.XAxis.TickLabels = hrslabel;
    xtickangle(45)
    set(gca, 'linewidth', 1)
    set(gca, 'FontSize', 6)
    % title(position)
    ax = gca
    box(ax, 'off')
    set(gcf, 'PaperPositionMode', 'manual', 'PaperUnits', 'inches', 'PaperPosition', [0 0 3 2])
    savefig(gcf, 'ERK_Div_nd')
    print([ ' ERK_Div_nd'], '-dpng', '-r300')
    %% Akt-7
    figure

    for i = 1:size(all_div_cells,2)
        plot(all_div_cells{7, i}, 'Color',[0 0 .8 .3])
        hold on
    end

    for i = 1:size(all_non_div,2)
        plot(all_non_div{7, i}, 'Color',[.8 0 0 .2])
        hold on
    end

    plot(med_DIV_Akt, 'linewidth', 3, 'Color', [0 0 .5 .8]) % for alpha= 0 to 1 the lines will be more clear
    plot(med_NODIV_Akt, 'linewidth', 3, 'Color', [.5 0 0 .8]) % for alpha= 0 to 1 the lines will be more clear
    ylim([0.8 1.1])


    ax = gca;
    set(gca, 'XTick', tickPos);

    ax.XAxis.TickLabels = hrslabel;
    xtickangle(45)

    set(gca, 'linewidth', 1)
    set(gca, 'FontSize', 6)
    % title(position)
    ax = gca
    box(ax, 'off')
    set(gcf, 'PaperPositionMode', 'manual', 'PaperUnits', 'inches', 'PaperPosition', [0 0 3 2])
    savefig(gcf,'Akt_Div_nd')
    print('Akt_Div_nd', '-dpng', '-r300')

