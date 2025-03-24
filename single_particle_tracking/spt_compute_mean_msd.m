function spt_compute_mean_msd(data)
f = waitbar(0,'calculating mean msd');
for i=1:length(data)
    mean_msd{1} = calculate_mean_msd(data{i}.msd);
    data_to_send{i}.msd = mean_msd;
    data_to_send{i}.name = [data{i}.name,'_mean_msd'];
    data_to_send{i}.tracks{1} = data{i}.tracks{1};
    data_to_send{i}.type = 'spt';
    waitbar(1,f,'calculating mean msd')
    clear mean_msd
end
close(f)
spt_plot(data_to_send);
spt_plot_mean_msd(data_to_send)
end

function mean_msd_to_send = calculate_mean_msd(data)
for i=1:length(data)
    delays{i} = data{i}(:,1);
    msds{i} = data{i}(:,2);   
end
delays = vertcat(delays{:});
msds = vertcat(msds{:});

delays_unique = unique(delays);
for i=1:length(delays_unique)
    wanted = msds(delays == delays_unique(i));    
    mean_msd(i) = mean(wanted);    
    std_msd(i) = var(wanted); 
    I(i) = length(wanted);
    clear wanted
end
mean_msd_to_send(:,1) = delays_unique;
mean_msd_to_send(:,2) = mean_msd';
mean_msd_to_send(:,3) = sqrt(std_msd');
mean_msd_to_send(:,4) = sqrt(I');
end

function spt_plot_mean_msd(data)
figure()
set(gcf,'name','mean_msd_plot','NumberTitle','off','color','w','menubar','none','toolbar','figure')

if length(data)>1
    slider_step_one=[1/(length(data)-1),1];
    slider_one = uicontrol('style','slider','units','normalized','position',[0,0,0.04,1],'value',1,'min',1,'max',length(data),'sliderstep',slider_step_one,'Callback',{@sld_one_callback});
end
slider_one_value=1;
input_data = data{slider_one_value}.msd;
input_data = input_data{1};
name = data{slider_one_value}.name;
msd_plot_mean_msd_inside(input_data,name)

diff_coeff = uimenu('Text','Find Diffusion Coefficient');
uimenu(diff_coeff,'Text','Find Diffusion Coefficient (Parabolic Fit)','ForegroundColor','k','CallBack',@diff_coeff_parabolic_callback);
uimenu(diff_coeff,'Text','Find Diffusion Coefficient (Linear Fit)','ForegroundColor','k','CallBack',@diff_coeff_linear_callback);

    function sld_one_callback(~,~,~)
        slider_one_value = round(slider_one.Value);
        input_data = data{slider_one_value}.msd;
        input_data = input_data{1};
        name = data{slider_one_value}.name;
        msd_plot_mean_msd_inside(input_data,name)
    end

    function msd_plot_mean_msd_inside(data,name)
        ax = gca; cla(ax)
        x = data(:,1);
        y = data(:,2);
        curve1 = data(:,2)+data(:,3);
        curve2 = data(:,2)-data(:,3);
        hold on
        plot(x, curve1, 'r', 'LineWidth', 2);
        plot(x, curve2, 'b', 'LineWidth', 2);
        x2 = [x; flipud(x)];
        inBetween = [curve1; flipud(curve2)];
        fill(x2, inBetween,'b','facealpha',0.2);
        plot(x,y,'k','LineWidth',2)
        errorbar(x,y,data(:,3)./data(:,4),'b')
        set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex','box','on')
        axtoolbar(gca,{'zoomin','zoomout','restoreview'});
        xlim([min(x) max(x)])
        title(regexprep(name,'_',' '),'interpreter','latex','fontsize',14)
        xlabel('Delays (s)','interpreter','latex','FontSize',14)
        ylabel('MSD ($um^2/s$)','interpreter','latex','FontSize',14)
    end

    function diff_coeff_parabolic_callback(~,~,~)
        input_values = inputdlg({'percentage of data to fit:'},'',1,{'25'});
        if isempty(input_values)==1
            return
        else
            percentage=str2double(input_values{1});            
            x = input_data(:, 1);
            y = input_data(:,2);
            std_msd = input_data(:,3);
            std_msd(1) = std_msd(2);
            
            size_data = length(x);
            x_fit = x(1:floor((size_data*percentage)/100));
            y_fit = y(1:floor((size_data*percentage)/100));
            std_msd_fit = std_msd(1:floor((size_data*percentage)/100));
            
            ft = fittype('a*x + c*x^2');
            [fo, gof] = fit(x_fit, y_fit, ft, 'Weights', 1./(std_msd_fit), 'StartPoint', [0 0]);
            
            Dfit = fo.a / 4;
            
            ci = confint(fo);
            Dci = ci(:,1) / 4;
            
            hold on
            plot(x_fit,y_fit,'k','linewidth',2)
            plot(x_fit,fo.a*x_fit+fo.c*(x_fit.^2),'g','linewidth',2);
            set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex','box','on')
            xlim([min(x_fit) max(x_fit)])
            title({regexprep(name,'_',' '),['$R^2 = $',num2str(gof.rsquare)],['Diffusion Coefficient = ',num2str(Dfit)]},'interpreter','latex','fontsize',14)
            xlabel('Delays (s)','interpreter','latex','FontSize',14)
            ylabel('MSD ($um^2/s$)','interpreter','latex','FontSize',14) 
        end
    end

    function diff_coeff_linear_callback(~,~,~)
        input_values = inputdlg({'percentage of data to fit:'},'',1,{'25'});
        if isempty(input_values)==1
            return
        else
            percentage=str2double(input_values{1});            
            x = input_data(:, 1);
            y = input_data(:,2);
            std_msd = input_data(:,3);
            std_msd(1) = std_msd(2);
            
            size_data = length(x);
            x_fit = x(1:floor((size_data*percentage)/100));
            y_fit = y(1:floor((size_data*percentage)/100));
            std_msd_fit = std_msd(1:floor((size_data*percentage)/100));
            
            ft = fittype('a*x + b');
            [fo, gof] = fit(x_fit, y_fit, ft, 'Weights', 1./std_msd_fit, 'StartPoint', [0 0]);
            
            Dfit = fo.a / 4;
            
            ci = confint(fo);
            Dci = ci(:,1) / 4;
                        
            hold on
            plot(x_fit,y_fit,'k','linewidth',2)
            plot(x_fit,fo.a*x_fit+fo.b,'g','linewidth',2);
            set(gca,'TickLength',[0.02 0.02],'FontName','TimesNewRoman','FontSize',12,'TickLabelInterpreter','latex','box','on')
            xlim([min(x_fit) max(x_fit)])
            title({regexprep(name,'_',' '),['$R^2 = $',num2str(gof.rsquare)],['Diffusion Coefficient = ',num2str(Dfit)]},'interpreter','latex','fontsize',14)
            xlabel('Delays (s)','interpreter','latex','FontSize',14)
            ylabel('MSD ($um^2/s$)','interpreter','latex','FontSize',14) 
        end
    end
end