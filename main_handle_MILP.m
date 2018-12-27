close all
% ���ݴ���
global period caseType
%--------------------��ɫ����---------------------
orange = [1 0.65 0];
gold = [1 0.843 0];
gray = [0.5 0.5 0.5];

olivedrab = [0.41961 0.55686 0.13725];
yellowgreen = [0.60392 0.80392 0.19608];

firebrick = [0.69804 0.13333 0.13333];
tomato = [1 0.38824 0.27843];
brown = [0.80392 0.2 0.2];
maroon = [0.6902 0.18824 0.37647];

royalblue = [0.2549 0.41176 0.88235];
royalblue_dark = [0.15294 0.25098 0.5451];
darkblue =[0 0 0.5451];
dodgerblue = [0.11765 0.56471 1];

indianred = [1 0.41 0.42];
chocolate3 = [0.804 0.4 0.113];
tan2 = [0.93  0.60 0.286];

c1 = ColorHex('0D56A6');
c2 = ColorHex('41DB00');
c3 = ColorHex('A63C00');
%--------------------------------------���ɺͿ�������Դ������--------------------------------------
if caseType ~=32
    figure(1)
    optNumber=24;
    t=1:1:24*period;
    w=1.2;
    
    for IES_no = 1 : 3
        t_1 = 0 : 24;
        for isMILP = 0 : 1
            EH_Le_base = result_EH_Le(:, IES_no + isMILP * IESNUMBER);
            EH_Lh_base = result_EH_Lh(:, IES_no + isMILP * IESNUMBER);
            EH_solarP = result_EH_solarP(:, IES_no + isMILP * IESNUMBER);
            EH_windP = result_EH_windP(:, IES_no + isMILP * IESNUMBER);
            EH_Le = EH_Le_base + result_EH_Edr(:, IES_no + isMILP * IESNUMBER);
            EH_Lh = EH_Lh_base + result_EH_Hdr(:, IES_no + isMILP * IESNUMBER);
            subplot(3 , 2 , (IES_no - 1) * 2 + 1 );
            hold on;
            stairs(t_1, appendStairArray(EH_Le_base) / 1000, 'Color', firebrick + 0.2 * isMILP, 'LineStyle', '-.', 'LineWidth', w)
            stairs(t_1, appendStairArray(EH_Le) / 1000, 'Color', firebrick + 0.2 * isMILP, 'LineStyle', '-', 'LineWidth', w)
            stairs(t_1, appendStairArray(EH_Lh_base) / 1000, 'Color', gray + 0.2 * isMILP, 'LineStyle', '-.', 'LineWidth',w)
            stairs(t_1, appendStairArray(EH_Lh) / 1000, 'Color', gray + 0.2 * isMILP, 'LineStyle', '-', 'LineWidth',w)
            xlim([0, 24 * period])
            ylim([0, max(max(EH_Le), max(EH_Lh)) / 1000]);
            xticks(0 : (24 * period / 4) : 24 * period);
            xticklabels({ '0:00', '6:00', '12:00', '18:00', '24:00' });
            xlabel(sprintf('IES%d', IES_no))
            ylabel('Load(MW)')
            if IES_no == 1
                H1 = legend('base electric load','total electric load','base thermal load','total thermal load',...
                    'Location','northoutside','Orientation','horizontal');
                set(H1,'Box','off');
            end
            
        end
        subplot(3,2,(IES_no - 1) * 2 + 2)
        hold on
        stairs(t_1, appendStairArray(EH_solarP) / 1000, 'Color', 'b', 'LineStyle', '-', 'LineWidth', w);
        stairs(t_1, appendStairArray(EH_windP) / 1000, 'Color', 'b' , 'LineStyle', '--', 'LineWidth', w);      
        xlim([0, 24*period]);
        xticks(0 : (24 * period /4) : 24 * period);
        xticklabels({'0:00','6:00','12:00','18:00','24:00'});
        xlabel(sprintf('IES%d', IES_no))
        ylabel('power(MW)')
        if IES_no == 1
            le = legend('PV','wind','Location','northoutside','Orientation','horizontal');
            set(le,'Box','off');
        end
        
    end
    set(gcf,'Position',[0 0 800 500]);
    
    
    %--------------------------------------���ݴ���--------------------------------------
    result_Gas = result_CHP_G + result_Boiler_G;
    for IES_no = 1 : 6
        ies_no = mod(IES_no - 1, 3) + 1; 
        eval(['result_Ele_loss(:,IES_no) = result_Ele(:,IES_no) .* EH',num2str(ies_no),'.Ele_eff;']); % eleLimit(3)��������
        eval(['result_CHP_power(:,IES_no) = result_CHP_G(:,IES_no) .* EH',num2str(ies_no),'.CHP_GE_eff; ']);
        eval(['result_CHP_heat(:,IES_no) = result_CHP_G(:,IES_no) .* EH',num2str(ies_no),'.CHP_GH_eff; ']);
        eval(['result_Boiler_heat(:,IES_no) = result_Boiler_G(:,IES_no) .* EH',num2str(ies_no),'.Boiler_eff;']);
    end
    %--------------------------------------�����Ż����--------------------------------------
    ee = 1e-3;
    
    % �����ܵ����䡢�ŵ繦�ʺܴ�ʱ��1000 * 1e-3 Ҳ��Խ�ߣ����Ӧ����ǰ��1e-3��Ϊ0
    result_ES_discharge(result_ES_discharge < ee) = 0;
    result_ES_charge(result_ES_charge < ee) = 0;
    result_HS_discharge(result_HS_discharge < ee) = 0;
    result_HS_charge(result_HS_charge < ee) = 0;
    
    % ����
    %�����ܳɱ� �����ۼ���
    totalCost_p2 = (result_Ele(:, 1: 3)' *  elePrice + sum(result_Gas(:, 1: 3))' * gasPrice1) / period;
    totalCost_p1 = (result_Ele(:, 4: 6)' *  elePrice + sum(result_Gas(:, 4: 6))' * gasPrice1) / period;
    sum(totalCost_p2)
    sum(totalCost_p1)
    % --------------------------------------��ͼ--------------------------------------    totalCost_p1 = (result_Ele(:, 1: 3)' *  elePrice + sum(result_Gas(:, 1: 3))' * gasPrice1) / period;

    t1 = 1 : 1 : 24 * period;
    t2 = 0 : 1 : 24 * period;
    optNumber = 24;
    w=1.5;
    
    %--------------------��������---------------------
    
    clearingPrice = elePrice;
    gridClearDemandP2 = - sum(result_Ele(:, 1 : 3), 2);%LP
    gridClearDemandP1 = - sum(result_Ele(:, 4 : 6), 2);%MILP

    figure;
    hold on;
    yyaxis left;
    H1 = bar(t1, -[gridClearDemandP2, gridClearDemandP1] / 1000);
    
    H1(1).EdgeColor = dodgerblue;
    H1(1).FaceColor = H1(1).EdgeColor;
    H1(2).EdgeColor = yellowgreen;
    H1(2).FaceColor = H1(2).EdgeColor;
    
    H3 = stairs(t2, ones(24*period+1, 1) .* eleLimit_total(1)/1000, 'Color',gray,'LineStyle','--','LineWidth',1);
    H4 = stairs(t2, ones(24*period+1, 1) * eleLimit_total(2)/1000, 'Color',gray,'LineStyle','--','LineWidth',1);
    ylabel('transformer power(MW)');
    uplimit= ceil(eleLimit_total(1) / 1000 * 1.1);
    lowerlimit=ceil(-eleLimit_total(2) / 1000 * 1.1);
    ylim([-lowerlimit, uplimit]);
    yticks(-lowerlimit : 1 : uplimit);
    
    yyaxis right;
    H2 = plot(t1, [clearingPrice, elePrice]);
    le = legend([H1(1),H1(2), H2(1),H2(2),H3(1)],...
        'transformer power(LP)','transformer power(MILP)','hourly clearing price','utility price','power limits');...
    set(le,'Box','off');
    set(H2(1),'Color',firebrick, 'LineStyle','-','LineWidth',1.5, 'Marker', '.', 'MarkerSize', 13)
    set(H2(2),'Color',darkblue, 'LineStyle','-','LineWidth',1.5, 'Marker', '.', 'MarkerSize', 13)
    ylabel('electricity price(yuan/kWh)');
    ylim([0.1, 1.2]);
    yticks(0.1 : 0.3 : 1.2);
    %xlabel('ʱ��(h)')
    xlim([0, 24 * period + 1]);
    xticks(0 : (24*period/4):24*period);
    xticklabels({'0:00','6:00','12:00','18:00','24:00'});
    set(gcf,'Position',[0 0 400 200]);
    
    %--------------------�Ż����2---------------------
    result_Ele_loss_positive = result_Ele_loss;
    result_Ele_loss_positive(result_Ele_loss_positive<0) = 0;
    result_Ele_loss_negtive = result_Ele_loss;
    result_Ele_loss_negtive(result_Ele_loss_negtive>0) = 0;
    
    stackedbar = @(x, A) bar(x, A, 'stacked');
    prettyline = @(x, y) plot(x, y, 'Color',firebrick, 'LineStyle','-','LineWidth',1.5, 'Marker', '.', 'MarkerSize', 13);
    
    figure
    fig = 1;
    for IES_no = 1 : 3
        subplot(3, 1, fig)
        hold on
        clear bar_positive bar_negative
        for isMILP = 0 : 1
            ies_no = IES_no + IESNUMBER * isMILP;
            bar_positive(1 + 24 * isMILP : 24 * (isMILP + 1), :) = [result_Ele_loss_positive(:,ies_no), result_CHP_power(:,ies_no), ...
                result_EH_solarP(:, ies_no) + result_EH_windP(:, ies_no), result_ES_discharge(:,ies_no)] ./ 1000;
            bar_negative(1 + 24 * isMILP : 24 * (isMILP + 1), :) = [result_Ele_loss_negtive(:,ies_no), -result_ES_charge(:,ies_no)] ./1000;
            Egen(:, 1 + isMILP) = (result_Ele_loss(:,ies_no) + result_CHP_power(:,ies_no) + result_EH_solarP(:, ies_no) + result_EH_windP(:, ies_no)...
                + result_ES_discharge(:,ies_no) - result_ES_charge(:,ies_no)) ./1000 ;
            Eload(:, 1 + isMILP) = (result_EH_Le(:, ies_no) + result_EH_Edr(:, ies_no)) ./1000;
            Eload_base(:, 1 + isMILP) = result_EH_Le(:, ies_no) ./1000;
        end
        bar_positive = merge(bar_positive(1 : 24, :), bar_positive(25 : 48, :));
        bar_negative = merge(bar_negative(1 : 24, :), bar_negative(25 : 48, :));

        yyaxis left;
        t_merge = 0.5 : 0.5: 24;
        H1 = stackedbar(t_merge, bar_positive);
        H1(1).EdgeColor = dodgerblue;
        H1(1).FaceColor = H1(1).EdgeColor;
        H1(2).EdgeColor = yellowgreen;
        H1(2).FaceColor = H1(2).EdgeColor;
        H1(3).EdgeColor = gold;
        H1(3).FaceColor = H1(3).EdgeColor;
        H1(4).EdgeColor = indianred;
        H1(4).FaceColor = H1(4).EdgeColor;
        
        H3 = stackedbar(t_merge, bar_negative);
        H3(1).EdgeColor = H1(1).EdgeColor;
        H3(1).FaceColor = H3(1).EdgeColor;
        H3(2).EdgeColor = H1(4).EdgeColor;
        H3(2).FaceColor = H3(2).EdgeColor;
        
        H4 = plot(t1 - 0.25, [Eload_base, Eload]);
        
        set(H4(1), 'Color', 'black', 'LineStyle', '-.', 'LineWidth', 1.5, 'Marker', '.', 'MarkerSize', 13);
        set(H4(2), 'Color', 'black', 'LineStyle', '-.', 'LineWidth', 1.5, 'Marker', 'd', 'MarkerSize', 13);
        set(H4(3), 'Color', 'black', 'LineStyle', '-', 'LineWidth', 1.5, 'Marker', '.', 'MarkerSize', 13);
        set(H4(4), 'Color', 'black', 'LineStyle', '-', 'LineWidth', 1.5, 'Marker', 'd', 'MarkerSize', 13);

        ylabel('electric power(MW)');
        ylim([-1,2.5]);
        yticks(-1:0.5:2.5);
        
        yyaxis right;
        
        H2 = plot(t2 - 0.25, [result_ES_SOC( : , IES_no), result_ES_SOC(:, IES_no + 3)]);
        set(H2(1), 'Color',firebrick, 'LineStyle','-','LineWidth',1.5, 'Marker', '.', 'MarkerSize', 13);
        set(H2(2), 'Color',firebrick, 'LineStyle','-','LineWidth',1.5, 'Marker', 'd', 'MarkerSize', 13);

        ylabel('SOC');
        ylim([0,1]);
        yticks(0.1:0.2:1);
        
        xlabel(sprintf('IES%d', IES_no));
        xlim([0, 24 * period + 1]);
        xticks(0:(24 * period / 4) : 24 * period);
        xticklabels({ '0:00','6:00','12:00','18:00','24:00' });
        
        if IES_no == 2
            le = legend([H1(1), H1(2), H1(3), H1(4), H2(1), H4(1), H4(3)],...
                'transformer','CHP','renewable energies','EES','SOC of EES','base electric load','total electric load',...
                'Location','northoutside','Orientation','horizontal');
            set(le, 'Box', 'off');
        end
        set(gcf,'Position',[0 0 550 500]);
        fig = fig + 1;
    end
    %%%%%%%%%%%%%%
    
    figure
    fig = 1;
    for IES_no = 1 : 3
        subplot(3, 1, fig)
        hold on
        clear bar_positive bar_negative
        for isMILP = 0 : 1
        ies_no = IES_no + IESNUMBER * isMILP;
        bar_positive(1 + 24 * isMILP : 24 * (isMILP + 1), :) = [result_CHP_heat(:,ies_no), result_Boiler_heat(:,ies_no), result_HS_discharge(:,ies_no)] ./1000;
        bar_negative(1 + 24 * isMILP : 24 * (isMILP + 1), :) = -result_HS_charge(:,ies_no) ./1000;
        Hgen(:, 1 + isMILP) = (result_CHP_heat(:,ies_no) + result_Boiler_heat(:,ies_no) + result_HS_discharge(:,ies_no)...
            - result_HS_charge(:,ies_no)) ./1000;
        Hload(:, 1 + isMILP) = (result_EH_Lh(:, ies_no) + result_EH_Hdr(:, ies_no)) ./1000;
        Hload_base(:, 1 + isMILP) = result_EH_Lh(:, ies_no) ./1000;
        end
        bar_positive = merge(bar_positive(1 : 24, :), bar_positive(25 : 48, :));
        bar_negative = merge(bar_negative(1 : 24, :), bar_negative(25 : 48, :));

        yyaxis left;
        H1 = stackedbar(t_merge, bar_positive);
        H1(1).EdgeColor = yellowgreen;
        H1(1).FaceColor = H1(1).EdgeColor;
        H1(2).EdgeColor = gold;
        H1(2).FaceColor = H1(2).EdgeColor;
        H1(3).EdgeColor = indianred;
        H1(3).FaceColor = H1(3).EdgeColor;
        
        H3 = stackedbar(t_merge, bar_negative);
        H3(1).EdgeColor = H1(3).EdgeColor;
        H3(1).FaceColor = H3(1).EdgeColor;
        
        H4 = plot(t1 - 0.25,[Hload_base, Hload]);
        set(H4(1), 'Color', 'black', 'LineStyle', '-.', 'LineWidth', 1.5, 'Marker', '.', 'MarkerSize', 13);
        set(H4(2), 'Color', 'black', 'LineStyle', '-.', 'LineWidth', 1.5, 'Marker', 'd', 'MarkerSize', 13);
        set(H4(3), 'Color', 'black', 'LineStyle', '-', 'LineWidth', 1.5, 'Marker', '.', 'MarkerSize', 13);
        set(H4(4), 'Color', 'black', 'LineStyle', '-', 'LineWidth', 1.5, 'Marker', 'd', 'MarkerSize', 13);        
        ylabel('thermal power(MW)');
        ylim([-1, 2]);
        yticks(-1 : 0.5 : 2);
        
        yyaxis right;
        H2 = plot(t2 - 0.35,[result_HS_SOC(:,IES_no), result_HS_SOC(:, IES_no + 3)]);
        set(H2(1), 'Color',firebrick, 'LineStyle','-','LineWidth',1.5, 'Marker', '.', 'MarkerSize', 13);
        set(H2(2), 'Color',firebrick, 'LineStyle','-','LineWidth',1.5, 'Marker', 'd', 'MarkerSize', 13);

        ylabel('SOC');
        ylim([0,1]);
        yticks(0.1:0.2:1);
        
        xlabel(sprintf('IES%d',IES_no));
        xlim([0, 24 * period + 1]);
        xticks(0 : (24 * period / 4) : 24 * period);
        xticklabels({'0:00','6:00','12:00','18:00','24:00'});
        
        if IES_no == 1
            le = legend([H1(1),H1(2),H1(3),H2(1),H4(1),H4(3)],...
                'CHP','GF','TES','SOC of TES','base thermal load','total thermal load',...
                'Location','northoutside','Orientation','horizontal');
            set(le,'Box','off');
        end
        set(gcf,'Position',[0 0 500 500]);
        fig = fig + 1;
    end
end

function [result] = merge(arr1, arr2)
[row, col] = size(arr1);
result = zeros(row * 2, col); 
    for i = 1 : row
        result(2 * i - 1, :) = arr1(i, :);
        result(2 * i, :) = arr2(i, :);
    end
end