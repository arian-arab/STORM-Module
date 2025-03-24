function loc_list_montage(data,map,scatter_num,scatter_size,c_lim)
if length(data)>6
    msgbox('Number of files selected should be less than or equal to 3')
else    
    figure()
    set(gcf,'name','Montage Plot','NumberTitle','off','color',[0.1 0.1 0.1],'units','normalized','position',[0.15 0.2 0.7 0.6]);
        
    subplot = @(m,n,p) subtightplot (m, n, p, [0 0], [0 0], [0 0]);     
    data_down_sampled = cell(length(data),1);
    for i = 1:length(data)        
        data_down_sampled{i} = loc_list_down_sample(data{i},scatter_num);
        subplot(1,length(data),i)        
        %scatter(data_down_sampled{i}.x_data,data_down_sampled{i}.y_data,scatter_size,'g','filled','MarkerFaceAlpha',0.2);

        scatter(data_down_sampled{i}.x_data,data_down_sampled{i}.y_data,scatter_size,data_down_sampled{i}.area,'filled','MarkerFaceAlpha',0.2);
        set(gca,'color',[0.1 0.1 0.],'colormap',map,'ColorScale','log')
        pbaspect([1 1 1])        
        axis equal
        box on
        axis off 
        %caxis(c_lim); 
    end    
    
    uimenu('Text','Save Image High Quality','ForegroundColor','b','CallBack',@save_image);
    uimenu('Text','Add Scale Bar','ForegroundColor','b','CallBack',@add_scale_bar); 
    uimenu('Text','Show ColorBar','ForegroundColor','b','CallBack',@show_colorbar); 
end

    function save_image(~,~,~)
        get_capture_from_figure()
    end

    function add_scale_bar(~,~,~)
         loc_list_add_scale_bar(data_down_sampled)
    end

    function show_colorbar(~,~,~)
        subplot = @(m,n,p) subtightplot (m, n, p, [0 0], [0 0], [0 0]);
        for k = 1:length(data)
            subplot(1,length(data_down_sampled),k)            
            h = colorbar;            
            h.TickLabelInterpreter = 'latex';
            h.FontSize = 14;
            h.Color = 'w';            
        end
    end
end