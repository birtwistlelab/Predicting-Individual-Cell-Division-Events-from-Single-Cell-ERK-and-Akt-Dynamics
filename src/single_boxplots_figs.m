w1s=14; %original time points
w1e=40;
w2s=40;
w2e=166;
w3s=98;
w3e=166;
load all_div_cells_ERK
load all_non_div_ERK
reporter_name={};
reporter_name='ERK'
median_w=strcat('median_w_',reporter_name);
rankh_name=strcat('rankh_',reporter_name);
rankp_name=strcat('rankp_',reporter_name);
rankh=[];
rankp=[];
% w1s=15; 
% w1e=41;
% w2s=41;
% w2e=167;
% w3s=99;
% w3e=167;
    
% combine both non and dividing cells
% all_data={};
B_w={};
% make sure that the data is the same size
B_w={}
sizes=[];
maxsize=[];
padsizes=[];
for i=1:length(all_div_cells)
    sizes(i)=length(all_div_cells{6,i}); % ERK IS ROW 6
end
maxsize=198;
padsizes=maxsize-sizes;
for i=1:length(all_div_cells)
    all_div_cells{6,i}=padarray(all_div_cells{6,i},padsizes(i),nan,'post');
end
all_data=horzcat(all_div_cells,all_non_div);

for i =1:length(all_data)
    B_w{1,i}=nanmedian(all_data{6,i}(w1s:w1e)); %145
end
for i =1:length(all_data)
    B_w{2,i}=nanmedian(all_data{6,i}(w2s:w2e)); %81
end
for i =1:length(all_data)
    B_w{3,i}=nanmedian(all_data{6,i}(w3s:w3e)); %41
end
save (['B_w'],'B_w') % save the data, you could also save it as B_w_ERK or B_w_akt
% depending on what single reporter data you are working with

%% making figures 
top=1.6
bottom=.4
div_values=all_data(3,:);
for i=1:3
figure
bb=notBoxPlot(cell2mat(B_w(i,:)),cell2mat(div_values),'markMedian',true)
bb(1).med.Color=[1 0 0];
bb(1).mu.Visible='off';
bb(1).med.LineStyle='-';
bb(1).med.LineWidth=2;
bb(1).data.Marker='.'
bb(1).data.MarkerSize=6
bb(1).data.Color=[0 0 0]
bb(1).data.MarkerFaceColor=[0 0 0]
bb(1).sdPtch.FaceColor=[1 1 1]
bb(1).sdPtch.EdgeColor=[0 0 0]
bb(1).sdPtch.LineWidth=2;
bb(1).semPtch.FaceColor=[1 1 1]
bb(1).semPtch.EdgeColor=[1 1 1]
bb(1).semPtch.Visible='off'
bb(2).data.MarkerSize=6
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
fig=gcf;
fig.PaperUnits = 'inches';
fig.PaperPosition = [0 0 3 2];
xlim([-.5 1.5])
ylim([bottom top])
 savefig(gcf,strcat(median_w, '_', num2str(i)))
print(strcat(median_w, '_', num2str(i)),'-dpng','-r300')
values=[];
values(1,:)=cell2mat(B_w(i,:));
values(2,:)=cell2mat(div_values);
rowd=values(2,:)==1;
rownd=values(2,:)==0;
values_div=values(1,rowd);
values_nodiv=values(1,rownd);
[rankh(i),rankp(i)]=ranksum(values_div,values_nodiv,'Tail','Right');
clear rowd rownd 
end
save (['rankh'],'rankh')
save (['rankp'],'rankp')
