function shape_classification_save_results_selected_clusters(data)
answer = inputdlg({'Show Scale Bar (0 or 1):','Pixel Size (nm):'},'Input',[1 50],{'0','116'});
if isempty(answer)~=1
    show_scale_bar = str2double(answer{1});
    pixel_size = str2double(answer{2});
    
    classes = data.classes;    
    for i = 1:size(classes,1)
        colors{i} = unique(cell2mat(classes{i,4}));
    end
    colors = unique(vertcat(colors{:}));
    c_map = colormap(jet);
    c_map = interp1(1:256,c_map,linspace(1,256,max(colors)));
    
    path = uigetdir();
    if path~=0
        for p=1:size(classes,1)
            save_selected_clusters(classes(p,:),path,p,c_map,show_scale_bar,pixel_size)
        end
    end
end
end

function save_selected_clusters(data,path,class_number,c_map,show_scale_bar,pixel_size)
classes = data{1,1};
group = data{1,4};

f = figure();
set(gcf,'name','clusters in node','NumberTitle','off','color','w','units','normalized','position',[0.1 0.1 0.7 0.4],'InvertHardcopy', 'off')
try
    index = randperm(length(classes),10);
catch
    index = 1:length(classes);
end
m = 0;

for i=1:length(index)
    m = m+1;
    subplot(2,5,m)
    data_to_plot = classes{index(i)};
    data_to_plot = data_to_plot*(pixel_size);
    [~,data_to_plot] = pca(data_to_plot);    
    scatter(data_to_plot(:,1),data_to_plot(:,2),1,c_map(group{i},:),'filled')    
    if show_scale_bar
        data_to_plot_size_x = round((max(data_to_plot(:,1))-min(data_to_plot(:,1)))/10)*5;
        data_to_plot_size_y = data_to_plot_size_x/7;
        rectangle('Position',[min(data_to_plot(:,1)) max(data_to_plot(:,2)) data_to_plot_size_x data_to_plot_size_y],'facecolor','w')
        text(min(data_to_plot(:,1)),max(data_to_plot(:,2)),num2str(data_to_plot_size_x))
    end
    title(['mass = ',num2str(size(data_to_plot,1))],'interpreter','latex','fontsize',12)
    axis equal
    axis off
    set(gca,'color','w')
end
if length(classes)>10
    subplot(2,5,3)
    title(['number of clusters: ',num2str(length(classes))],'interpreter','latex','fontsize',12)
end
print(gcf,fullfile(path,[num2str(class_number),'.jpg']),'-dpng','-r300'); 
close(f)
end