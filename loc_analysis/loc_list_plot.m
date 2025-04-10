function loc_list_plot(data)
if isempty(data)~=1    
    fig = figure();
    set(gcf,'name','Localizations List (2D)','NumberTitle','off','color',[0.1 0.1 0.1],'units','normalized','position',[0.25 0.15 0.5 0.7],'menubar','none','toolbar','figure');
  
    defaultToolbar = findall(fig,'Type','uitoolbar');
    a = findall(defaultToolbar,'ToolTipString','New Figure');
    b = findall(defaultToolbar,'ToolTipString','Insert Legend');
    c = findall(defaultToolbar,'ToolTipString','Insert Colorbar');
    d = findall(defaultToolbar,'ToolTipString','Open Property Inspector');
    e = findall(defaultToolbar,'ToolTipString','Edit Plot');
    f = findall(defaultToolbar,'ToolTipString','Link Plot');
    g = findall(defaultToolbar,'ToolTipString','Open File');
    h = findall(defaultToolbar,'ToolTipString','Save Figure');
    i = findall(defaultToolbar,'ToolTipString','Print Figure');
    delete(a);delete(b);delete(c);delete(d);delete(e);delete(f);delete(g);delete(h);delete(i);    
    crop_pushtool = uipushtool(defaultToolbar);   
    [img,test_map] = imread(fullfile(matlabroot,'toolbox','matlab','icons','tool_rectangle.gif'));
    ptImage = ind2rgb(img,test_map);
    crop_pushtool.CData = ptImage;
    crop_pushtool.ClickedCallback = @crop;    
    
    uicontrol('style','text','units','normalized','position',[0,0.95,0.3,0.05],'string','No. of Locs:','BackgroundColor',[0.1 0.1 0.1],'FontSize',14,'ForegroundColor','w');
    scatter_num_edit = uicontrol('style','edit','units','normalized','position',[0.3,0.96,0.2,0.04],'string','50000','Callback',@scatter_num_callback,'FontSize',14,'BackgroundColor',[0.1 0.1 0.1],'ForegroundColor',[0.5 0.5 0.5]);
    scatter_num =  str2double(scatter_num_edit.String);

    uicontrol('style','text','units','normalized','position',[0.5,0.95,0.3,0.05],'string','Locs Size:','FontSize',14,'BackgroundColor',[0.1 0.1 0.1],'ForegroundColor','w');
    scatter_size_edit = uicontrol('style','edit','units','normalized','position',[0.8,0.96,0.2,0.04],'string','3','Callback',@scatter_size_callback,'FontSize',14,'BackgroundColor',[0.1 0.1 0.1],'ForegroundColor',[0.5 0.5 0.5]);
    scatter_size =  str2double(scatter_size_edit.String);
    
    if length(data)>1
        slider_step=[1/(length(data)-1),1/(length(data)-1)];
        slider = uicontrol('style','slider','units','normalized','position',[0,0,0.04,1],'value',1,'min',1,'max',length(data),'sliderstep',slider_step,'Callback',{@sld_callback});
    end
    slider_value=1;
    
    color_bar =0;
    
    if isempty(data{slider_value})~=1          
        loc_list_plot_inside(data{slider_value},slider_value,length(data),scatter_num,scatter_size,color_bar)
    end 
    
    file_menu = uimenu('Text','File');
    uimenu(file_menu,'Text','Send Data to Workspace','ForegroundColor','b','CallBack',@send_data_callback);
    uimenu(file_menu,'Text','Save Data (.png)','ForegroundColor','b','CallBack',@save_png);
    uimenu(file_menu,'Text','Save Data (.bin)','ForegroundColor','b','CallBack',@save_bin);
    
    basic_analysis_menu = uimenu('Text','Basic Analysis');    
    uimenu(basic_analysis_menu,'Text','Multiply by a Number','ForegroundColor','b','CallBack',@multiply_by_number);
    uimenu(basic_analysis_menu,'Text','Add by a Number','ForegroundColor','b','CallBack',@add_by_number);
    uimenu(basic_analysis_menu,'Text','Center Data','ForegroundColor','b','CallBack',@center_data);
    uimenu(basic_analysis_menu,'Text','Pile Data','ForegroundColor','b','CallBack',@pile_data);
    uimenu(basic_analysis_menu,'Text','Make Same Color','ForegroundColor','b','CallBack',@make_same_color);
    uimenu(basic_analysis_menu,'Text','Put in Different Channel','ForegroundColor','b','CallBack',@show_in_channel);
    uimenu(basic_analysis_menu,'Text','Flip Image Left-Right','ForegroundColor','b','CallBack',@flip_lr);
    uimenu(basic_analysis_menu,'Text','Flip Image Up-Down','ForegroundColor','b','CallBack',@flip_ud);
    uimenu(basic_analysis_menu,'Text','Down Sample Data','ForegroundColor','b','CallBack',@down_sample);
    
    basic_analysis_menu = uimenu('Text','Density Map');  
    uimenu(basic_analysis_menu,'Text','Voronoi-Area Density Map','ForegroundColor','b','CallBack',@voronoi_density_map);  
    uimenu(basic_analysis_menu,'Text','1/mean(KNN-distance)','ForegroundColor','b','CallBack',@knn_density_map);    
    
    image_segmentation = uimenu('Text','Image Segmentation');    
    %uimenu(image_segmentation,'Text','Gravitational Clustering','ForegroundColor','b','CallBack',@gravitational_clustering);
    %uimenu(image_segmentation,'Text','Distance Clustering','ForegroundColor','b','CallBack',@distance_clustering);
    uimenu(image_segmentation,'Text','Remove Noise','ForegroundColor','b','CallBack',@remove_noise);
    uimenu(image_segmentation,'Text','k-Means','ForegroundColor','b','CallBack',@k_means)
    uimenu(image_segmentation,'Text','DBSCAN','ForegroundColor','b','CallBack',@dbscan_regular)
    uimenu(image_segmentation,'Text','DBSCAN (elbow method)','ForegroundColor','b','CallBack',@dbscan_elbow)
    uimenu(image_segmentation,'Text','Voronoi Segmentation','ForegroundColor','b','CallBack',@voronoi_segmentation)
    uimenu(image_segmentation,'Text','Determine Voronoi Area Threshold (Monte-Carlo Simulation)','ForegroundColor','b','CallBack',@monte_carlo);
     
    clustering_analysis = uimenu('Text','Clustering');
    uimenu(clustering_analysis,'Text','Total Clusters Area','ForegroundColor','k','CallBack',@total_clusters_area);    
    uimenu(clustering_analysis,'Text','Total Number of Clusters','ForegroundColor','k','CallBack',@clusters_count_clusters);
    uimenu(clustering_analysis,'Text','Clusters Data Table (Area, No of Locs)','ForegroundColor','k','CallBack',@clusters_data_table_short);    
    uimenu(clustering_analysis,'Text','Clusters Data Table (All)','ForegroundColor','k','CallBack',@clusters_data_table);    
    uimenu(clustering_analysis,'Text','Clusters Area Histogram','ForegroundColor','k','CallBack',@clusters_area_histogram);
    uimenu(clustering_analysis,'Text','Clusters No. of Locs. Histogram','ForegroundColor','k','CallBack',@clusters_no_of_locs_histogram);
    uimenu(clustering_analysis,'Text','Clusters Locs/Area (Density) Histogram','ForegroundColor','k','CallBack',@clusters_density_histogram);
    uimenu(clustering_analysis,'Text','Clusters Normalized Density Histogram','ForegroundColor','k','CallBack',@clusters_norm_density_histogram);
    uimenu(clustering_analysis,'Text','Scatter Clusters No. of Locs vs Area','ForegroundColor','b','CallBack',@scatter_clusters_no_of_locs_area);   
    uimenu(clustering_analysis,'Text','Filter Clusters Random Selection','ForegroundColor','r','CallBack',@clusters_filter_random_selection) 
    uimenu(clustering_analysis,'Text','Filter Clusters (Number of Locs)','ForegroundColor','r','CallBack',@clusters_filter_no_of_locs)
    uimenu(clustering_analysis,'Text','Filter Clusters (Area)','ForegroundColor','r','CallBack',@clusters_filter_area)
    uimenu(clustering_analysis,'Text','Filter Clusters (Aspect Ratio)','ForegroundColor','r','CallBack',@clusters_filter_aspect_ratio)
    uimenu(clustering_analysis,'Text','Clusters Remove Outliers','ForegroundColor','k','CallBack',@clusters_remove_outliers)
    uimenu(clustering_analysis,'Text','Extract Clusters','ForegroundColor','b','CallBack',@extract_clusters)    
    uimenu(clustering_analysis,'Text','Extract Features for Shape Classification','ForegroundColor','b','CallBack',@extract_features)

    colormap_menu = uimenu('Text','Colormap');   
    uimenu(colormap_menu,'Text','Change Colormap Limits','ForegroundColor','b','CallBack',@change_colormap_limits);
    uimenu(colormap_menu,'Text','Auto Colormap Limits','ForegroundColor','b','CallBack',@auto_colormap_limits);
    uimenu(colormap_menu,'Text','Lines','ForegroundColor','b','CallBack',@lines_map);
    uimenu(colormap_menu,'Text','Colorcube','ForegroundColor','b','CallBack',@colorcube_map);
    uimenu(colormap_menu,'Text','Prism','ForegroundColor','b','CallBack',@prism_map);
    uimenu(colormap_menu,'Text','Jet','ForegroundColor','b','CallBack',@jet_map);
    uimenu(colormap_menu,'Text','HSV','ForegroundColor','b','CallBack',@hsv_map);
    uimenu(colormap_menu,'Text','Hot','ForegroundColor','b','CallBack',@hot_map);
    uimenu(colormap_menu,'Text','Parula','ForegroundColor','b','CallBack',@parula_map);
    show_colorbar_menu = uimenu(colormap_menu,'Text','Show Colorbar','ForegroundColor','b','CallBack',@show_colorbar,'Checked','off');
    
    plot_menu = uimenu('Text','Plot Functions');   
    uimenu(plot_menu,'Text','Montage','ForegroundColor','b','CallBack',@montage);
    uimenu(plot_menu,'Text','Plot in Two Channel','ForegroundColor','b','CallBack',@two_channel);
    uimenu(plot_menu,'Text','Plot in Three Channel','ForegroundColor','b','CallBack',@three_channel);
    uimenu(plot_menu,'Text','Voronoi Plot','ForegroundColor','b','CallBack',@voronoi_plot);    
    
    roi_menu = uimenu('Text','ROI');   
    uimenu(roi_menu,'Text','ROI Selection','ForegroundColor','b','CallBack',@roi);
    uimenu(roi_menu,'Text','ROI Selection Module','ForegroundColor','b','CallBack',@roi_module);
    
    %plot_random_menu = uimenu('Text','Plot Random');   
    %uimenu(plot_random_menu,'Text','Plot Clusters Random','ForegroundColor','b','CallBack',@plot_random);
end

    function scatter_num_callback(~,~,~)
        scatter_num =  str2double(scatter_num_edit.String);
        scatter_size =  str2double(scatter_size_edit.String);
        if isempty(data{slider_value})~=1
            loc_list_plot_inside(data{slider_value},slider_value,length(data),scatter_num,scatter_size,color_bar)
        end
    end

    function scatter_size_callback(~,~,~)
        scatter_num =  str2double(scatter_num_edit.String);
        scatter_size =  str2double(scatter_size_edit.String);
        if isempty(data{slider_value})~=1
            loc_list_plot_inside(data{slider_value},slider_value,length(data),scatter_num,scatter_size,color_bar)
        end
    end

    function sld_callback(~,~,~)
        slider_value = round(slider.Value);
        if isempty(data{slider_value})~=1
            loc_list_plot_inside(data{slider_value},slider_value,length(data),scatter_num,scatter_size,color_bar)
        end
    end

    function send_data_callback(~,~,~)
        send_data_to_workspace(data)
    end

    function save_png(~,~,~)
        global map
        c_lim = caxis(gca);
        loc_list_save_png(data,map,c_lim);
    end

    function save_bin(~,~,~)
        loc_list_save_bin(data)
    end

    function crop(~,~,~)
        loc_list_crop(data);        
    end

    function roi(~,~,~)
        loc_list_roi(data);  
    end

    function roi_module(~,~,~)
        global map
        loc_list_roi_module(data,scatter_num,scatter_size,map);  
    end

%     function plot_random(~,~,~)        
%         loc_list_plot_random(data);
%     end

    function multiply_by_number(~,~,~)
        loc_list_multiply_by_number(data);
    end

    function add_by_number(~,~,~)
        loc_list_add_by_number(data);
    end

    function center_data(~,~,~)
        loc_list_center_data(data);
    end

    function pile_data(~,~,~)
        loc_list_pile_data(data);
     end

    function make_same_color(~,~,~)
        loc_list_make_same_color(data);
    end

    function show_in_channel(~,~,~)
        loc_list_show_in_channels(data);
    end

    function flip_lr(~,~,~)
        loc_list_flip_lr(data);        
    end

    function flip_ud(~,~,~)
        loc_list_flip_ud(data);
    end    

    function down_sample(~,~,~)
        loc_list_down_sample_data(data);
    end

    function voronoi_density_map(~,~,~)
        loc_list_voronoi_density_map(data);        
    end

    function knn_density_map(~,~,~)
        loc_list_knn_density_map(data);        
    end    

%     function gravitational_clustering(~,~,~)
%         data_bundle = loc_list_gravitational_clustering(data);
%         loc_list_plot(data_bundle)        
%     end
% 
%     function distance_clustering(~,~,~)
%         loc_list_distance_clustering(data);         
%     end

    function remove_noise(~,~,~)
        loc_list_remove_noise(data);
    end

    function k_means(~,~,~)
        loc_list_k_means(data);
    end

    function dbscan_regular(~,~,~)
        loc_list_dbscan_regular(data);
    end

    function dbscan_elbow(~,~,~)
        loc_list_dbscan_elbow(data);
    end

    function voronoi_segmentation(~,~,~)
        loc_list_voronoi_segmentation(data);
    end

    function monte_carlo(~,~,~)
        [data_clustered,data_not_clustered] = loc_list_voronoi_monte_carlo(data);
        loc_list_plot(data_clustered)
        loc_list_plot(data_not_clustered)
    end

    function total_clusters_area(~,~,~)
        loc_list_clusters_total_clusters_area(data);
    end

    function clusters_count_clusters(~,~,~)
        loc_list_clusters_count_clusters(data);
    end

    function clusters_data_table(~,~,~)
        loc_list_clusters_data_table(data);
    end

    function clusters_data_table_short(~,~,~)
        loc_list_clusters_data_table_short(data);
    end

    function clusters_area_histogram(~,~,~)
        loc_list_clusters_area_histogram(data);
    end

    function clusters_no_of_locs_histogram(~,~,~)
        loc_list_clusters_no_of_locs_histogram(data);
    end

    function clusters_density_histogram(~,~,~)
        loc_list_clusters_density_histogram(data);
    end

    function clusters_norm_density_histogram(~,~,~)
        loc_list_clusters_norm_density_histogram(data);
    end

    function scatter_clusters_no_of_locs_area(~,~,~)
        loc_list_clusters_scatter_no_of_locs_area(data);        
    end

    function clusters_filter_no_of_locs(~,~,~)
        loc_list_clusters_filter_no_of_locs(data);
    end

    function clusters_filter_random_selection(~,~,~)
        loc_list_clusters_filter_random_selection(data);
    end

    function clusters_filter_area(~,~,~)
        loc_list_clusters_filter_area(data);
    end

    function clusters_filter_aspect_ratio(~,~,~)
        loc_list_clusters_filter_aspect_ratio(data);
    end

    function clusters_remove_outliers(~,~,~)
        loc_list_clusters_remove_outliers_updated(data);
    end

    function extract_clusters(~,~,~)
        loc_list_extract_clusters(data);
    end

    function extract_features(~,~,~)
        loc_list_extract_features(data);
    end

    function change_colormap_limits(~,~,~)
        loc_list_change_colormap_limits();
    end

    function auto_colormap_limits(~,~,~)
        caxis('auto')
    end

    function lines_map(~,~,~)
        global map
        map = colormap(lines);
        loc_list_plot_inside(data{slider_value},slider_value,length(data),scatter_num,scatter_size,color_bar)
    end

    function colorcube_map(~,~,~)
        global map
        map = colormap(colorcube);
        loc_list_plot_inside(data{slider_value},slider_value,length(data),scatter_num,scatter_size,color_bar)
    end

    function prism_map(~,~,~)
        global map
        map = colormap(prism);
        loc_list_plot_inside(data{slider_value},slider_value,length(data),scatter_num,scatter_size,color_bar)
    end

    function jet_map(~,~,~)
        global map
        map = colormap(jet);
        loc_list_plot_inside(data{slider_value},slider_value,length(data),scatter_num,scatter_size,color_bar)
    end

    function hsv_map(~,~,~)
        global map
        map = colormap(hsv);
        loc_list_plot_inside(data{slider_value},slider_value,length(data),scatter_num,scatter_size,color_bar)
    end

    function hot_map(~,~,~)
        global map
        map = colormap(hot);
        loc_list_plot_inside(data{slider_value},slider_value,length(data),scatter_num,scatter_size,color_bar)
    end

    function parula_map(~,~,~)
        global map
        map = colormap(parula);
        loc_list_plot_inside(data{slider_value},slider_value,length(data),scatter_num,scatter_size,color_bar)
    end

    function show_colorbar(~,~,~)
        if color_bar ==0
            color_bar =1;
            loc_list_plot_inside(data{slider_value},slider_value,length(data),scatter_num,scatter_size,color_bar)
            show_colorbar_menu.Checked = 'on';
        else
            color_bar =0;
            loc_list_plot_inside(data{slider_value},slider_value,length(data),scatter_num,scatter_size,color_bar)
            show_colorbar_menu.Checked = 'off';
        end
    end

    function montage(~,~,~) 
        global map
        ax = gca;
        c_lim = ax.CLim;
        loc_list_montage(data,map,scatter_num,scatter_size,c_lim)
    end

    function two_channel(~,~,~)         
        loc_list_two_channel(data,scatter_size,scatter_num)
    end

    function three_channel(~,~,~)         
        loc_list_three_channel(data,scatter_size,scatter_num)
    end

    function voronoi_plot(~,~,~) 
        loc_list_voronoi_plot(data{slider_value})
    end
end    
    
function loc_list_plot_inside(data,n,N,scatter_num,scatter_size,color_bar)
global map
number_of_clusters = length(unique(data.area));
no_of_locs = length(data.x_data);

lim_x_original = [min(data.x_data) max(data.x_data)]';
lim_y_original = [min(data.y_data) max(data.y_data)]';

data_down_sampled = loc_list_down_sample(data,scatter_num);

if scatter_size>10
    scatter_size = 10;
end
if scatter_size<1
    scatter_size = 1;
end
ax = gca; cla(ax);

% if isfield(data, 'boundary')
%     hold on
%     for i = 1:length(data.boundary)
%         plot(data.boundary{i}(:,1),data.boundary{i}(:,2),'r')
%     end
% end

area = data_down_sampled.area;
scatter(data_down_sampled.x_data,data_down_sampled.y_data,scatter_size,area,'filled','MarkerFaceAlpha',0.2);
set(gca,'colormap',map,'color',[0.1 0.1 0.1],'TickDir', 'out','box','on','BoxStyle','full','XColor',[0.5,0.5,0.5],'YColor',[0.5,0.5,0.5],'fontsize',14,'ticklabelinterpreter','latex','ColorScale','log');
pbaspect([1 1 1])
axis equal
xlim(lim_x_original)
ylim(lim_y_original)

y_lim = get(gca,'ylim');
x_lim = get(gca,'xlim');
text(x_lim(1),y_lim(2),{'','','','',['File Name: ',regexprep(data.name,'_',' ')],['File Number: ',num2str(n),'/',num2str(N),''],['Number of Clusters: ',num2str(number_of_clusters)],['Number of Localizations: ',num2str(no_of_locs)]},'color','r')

if color_bar==1
    h = colorbar;
    h.Position = [0.9 0.1 0.02 0.8];
    h.TickLabelInterpreter = 'latex';
    h.FontSize = 14;
    h.Color = 'w';
    ylabel(h, 'Clusters Area','FontSize',14,'interpreter','latex');
end
end