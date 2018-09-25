close all
% ���ݴ���
global period

%--------------------------------------���ɺͿ�������Դ������--------------------------------------

figure(1)
optNumber=24;
t=1:1:24*period;
w=1.2;

% EH1_Le(24*period+1) = EH1_Le(24*period);
% EH1_Lh(24*period+1) = EH1_Lh(24*period);
% EH1_solarP(24*period+1) = EH1_solarP(24*period);
% EH1_windP(24*period+1) = EH1_windP(24*period);
% EH2_Le(24*period+1) = EH2_Le(24*period);
% EH2_Lh(24*period+1) = EH2_Lh(24*period);
% EH2_solarP(24*period+1) = EH2_solarP(24*period);
% EH2_windP(24*period+1) = EH2_windP(24*period);
% EH3_Le(24*period+1) = EH3_Le(24*period);
% EH3_Lh(24*period+1) = EH3_Lh(24*period);
% EH3_solarP(24*period+1) = EH3_solarP(24*period);
% EH3_windP(24*period+1) = EH3_windP(24*period);


for IES_no = 1 : 3
    eval(['EH_Le_base = EH',num2str(IES_no),'_Le;']);
    eval(['EH_Lh_base = EH',num2str(IES_no),'_Lh;']);
    eval(['EH_solarP = EH',num2str(IES_no),'_solarP;']);
    eval(['EH_windP = EH',num2str(IES_no),'_windP;']);
    eval(['EH_Le = EH_Le_base + EH',num2str(IES_no),'_Edr;']);
    eval(['EH_Lh = EH_Lh_base + EH',num2str(IES_no),'_Hdr;']);
    subplot(3 , 2 , (IES_no - 1) * 2 + 1 )
    hold on;
    stairs(t,EH_Le_base/1000,'Color','b','LineStyle','-.','LineWidth',w) %plot
    stairs(t,EH_Le/1000,'Color','b','LineStyle','-','LineWidth',w) %plot
    stairs(t,EH_Lh_base/1000,'Color','r','LineStyle','-.','LineWidth',w)
    stairs(t,EH_Lh/1000,'Color','r','LineStyle','-','LineWidth',w)
    xlim([0,24*period])
    ylim([0,max(max(EH_Le),max(EH_Lh))/1000]);
    set(gca,'XTick',0:(24*period/4):24*period, 'XTickLabel',{'0:00','6:00','12:00','18:00','24:00'})
    ylabel('��������(MW)')
    legend('�����縺��','�ܵ縺��','�����ȸ���','���ȸ���','Location','northoutside','Orientation','horizontal')
    % ylabel('load / kW')
    % xlabel('time / h')
    % legend('Le','Lh','Location','northoutside','Orientation','horizontal')
    % xlabel('ʱ��(h)')
    subplot(3,2,(IES_no - 1) * 2 + 2 )
    hold on
    stairs(t,EH_solarP/1000,'Color','r','LineStyle','-','LineWidth',w)
    stairs(t,EH_windP/1000,'Color','b','LineStyle','--','LineWidth',w)
    xlim([0,24*period])
    set(gca,'XTick',0:(24*period/4):24*period, 'XTickLabel',{'0:00','6:00','12:00','18:00','24:00'})
    % ylabel('RES power / kW')
    % xlabel('time / h')
    % legend('PV','WT','Location','northoutside','Orientation','horizontal')
    ylabel('���繦��(MW)')
    legend('���','���','Location','northoutside','Orientation','horizontal')
end
set(gcf,'Position',[0 0 800 500]);


%--------------------------------------���ݴ���--------------------------------------
result_Gas = result_CHP_G + result_Boiler_G;
for IES_no = 1 : 3
    eval(['result_Ele_loss(:,IES_no) = result_Ele(:,IES_no) .* EH',num2str(IES_no),'.Ele_eff;']); % eleLimit(3)��������
    eval(['result_CHP_power(:,IES_no) = result_CHP_G(:,IES_no) .* EH',num2str(IES_no),'.CHP_GE_eff; ']);
    eval(['result_CHP_heat(:,IES_no) = result_CHP_G(:,IES_no) .* EH',num2str(IES_no),'.CHP_GH_eff; ']);
    eval(['result_Boiler_heat(:,IES_no) = result_Boiler_G(:,IES_no) .* EH',num2str(IES_no),'.Boiler_eff;']);
end
%--------------------------------------�����Ż����--------------------------------------
ee = 1e-3;

% �����ܵ����䡢�ŵ繦�ʺܴ�ʱ��1000 * 1e-3 Ҳ��Խ�ߣ����Ӧ����ǰ��1e-3��Ϊ0
result_ES_discharge(result_ES_discharge < ee) = 0;
result_ES_charge(result_ES_charge < ee) = 0;
result_HS_discharge(result_HS_discharge < ee) = 0;
result_HS_charge(result_HS_charge < ee) = 0;

% for IES_no = 1 : 3
%     %�硢�ȹ���ƽ���Բ��ԣ�����Ҫ����������
%     eval(['result_balance_P(:,IES_no) = result_Ele_loss(:,IES_no) + result_CHP_power(:,IES_no) + result_ES_discharge(:,IES_no) - result_ES_charge(:,IES_no) - EH',num2str(IES_no),'_Le - EH',num2str(IES_no),'_Edr + EH',num2str(IES_no),'_windP + EH',num2str(IES_no),'_solarP;']);
%     eval(['result_balance_H(:,IES_no) = result_CHP_heat(:,IES_no) + result_Boiler_heat(:,IES_no) + result_HS_discharge(:,IES_no) - result_HS_charge(:,IES_no) - EH',num2str(IES_no),'_Lh - EH', num2str(IES_no),'_Hdr;']);
%     %�䡢�Ź���������һ������
%     result_check_ES(:,IES_no) = result_ES_discharge(:,IES_no) .* result_ES_charge(:,IES_no);
%     result_check_HS(:,IES_no) = result_HS_discharge(:,IES_no) .* result_HS_charge(:,IES_no); %��һ��С���⣬��Ϊ�ȹ��ڳ�ԣ
%     % 20180129 �Գ�ŵ�˻�Լ������˼��
%     if max(result_check_ES(:,IES_no)) > 0
%         fprintf('EH%d�索����Ҫ����',IES_no);
%         for i=1:length(result_check_ES(:,IES_no))
%             if result_check_ES(i,IES_no)> 0
%                 if result_balance_P(i,IES_no) < ee % ������ͬʱ���У�����û�ж���ĵ磬����������
%                      fprintf('EH%d�索�ܽ�������� !!! ʱ����%d',IES_no,i);
%                 else % �Գ��ͬʱ�ĳ�������������SOC���䣬��ŵ繦�ʱ���һ�����㣬��ֵ�б仯
%                     deltaSOC = result_ES_SOC(i+1,IES_no) - result_ES_SOC(i,IES_no);
%                     if deltaSOC > 0 % ��ʾ���
%                         eval(['result_ES_charge(i,IES_no) = deltaSOC * EH',num2str(IES_no),'.ES_totalC / EH',num2str(IES_no),'.ES_eff;']); % ��������������Ч��
%                         result_ES_discharge(i,IES_no) = 0;
%                     else % ��ʾ�ŵ�
%                         result_ES_charge(i,IES_no) = 0;
%                         eval(['result_ES_discharge(i,IES_no) = - deltaSOC * EH',num2str(IES_no),'.ES_totalC * EH',num2str(IES_no),'.ES_eff;']); % ��������������Ч��;
%                     end
%                 end
%             end
%         end
%         % ������������¼���
%         eval(['result_balance_P(:,IES_no) = result_Ele_loss(:,IES_no) + result_CHP_power(:,IES_no) + result_ES_discharge(:,IES_no) - result_ES_charge(:,IES_no) - EH',num2str(IES_no),'_Le -EH', num2str(IES_no),'_Edr + EH',num2str(IES_no),'_windP + EH',num2str(IES_no),'_solarP;']);
%         result_check_ES(:,IES_no) = result_ES_discharge(:,IES_no) .* result_ES_charge(:,IES_no);
%     end
%     if max(result_check_HS(:,IES_no)) > 0
%         fprintf('EH%d�ȴ�����Ҫ����',IES_no);
%         for i=1:length(result_check_HS(:,IES_no))
%             if result_check_HS(i,IES_no) > 0
%                 if result_balance_H(i,IES_no) < ee % ������ͬʱ���У�����û�ж���ĵ磬����������
%                      fprintf('EH%d�ȴ��ܽ�������� !!! ʱ����%d',IES_no,i);
%                 else % �Գ��ͬʱ�ĳ�������������SOC���䣬��ŵ繦�ʱ���һ�����㣬��ֵ�б仯
%                     deltaSOC = result_HS_SOC(i+1,IES_no) - result_HS_SOC(i,IES_no);
%                     if deltaSOC > 0 % ��ʾ���
%                         eval(['result_HS_charge(i,IES_no) = deltaSOC * EH',num2str(IES_no),'.HS_totalC / EH',num2str(IES_no),'.HS_eff; ']);% ��������������Ч��
%                         result_HS_discharge(i,IES_no) = 0;
%                     else % ��ʾ�ŵ�
%                         result_HS_charge(i,IES_no) = 0;
%                         eval(['result_HS_discharge(i,IES_no) = - deltaSOC * EH',num2str(IES_no),'.HS_totalC * EH',num2str(IES_no),'.HS_eff;']); % ��������������Ч��;
%                     end
%                 end
%             end
%         end
%         % ������������¼���
%         eval(['result_balance_H(:,IES_no) = result_CHP_heat(:,IES_no) + result_Boiler_heat(:,IES_no) + result_HS_discharge(:,IES_no) - result_HS_charge(:,IES_no) - EH',num2str(IES_no),'_Lh-EH', num2str(IES_no),'_Hdr;']);
%         result_check_HS(:,IES_no) = result_HS_discharge(:,IES_no) .* result_HS_charge(:,IES_no);
%     end
%     
%     
% end

%������ߵ�ƽ���ԣ���������ߵĹ����Ƿ�Խ��

%�����ܵĹ��繦�ʺ��ܵĹ�������(�鿴�Ƿ�Խ��)
% totalE = result_Ele(:,1) + result_Ele(:,2) + result_Ele(:,3);
% totalGas = EH1_G_CHP + EH1_G_Boiler + EH2_G_CHP + EH2_G_Boiler

%}
% ����
%�����ܳɱ� �����ۼ���
totalCost1 = ( sum(result_Ele(:,1) .* elePrice) + sum(result_Gas(:,1) .* gasPrice1) ) / period;
totalCost2 = ( sum(result_Ele(:,2) .* elePrice) + sum(result_Gas(:,2) .* gasPrice1) ) / period;
totalCost3 = ( sum(result_Ele(:,3) .* elePrice) + sum(result_Gas(:,3) .* gasPrice1) ) / period;

disp(['IES1�ܳɱ�Ϊ ',num2str(totalCost1),' Ԫ'])
disp(['IES2�ܳɱ�Ϊ ',num2str(totalCost2),' Ԫ'])
disp(['IES3�ܳɱ�Ϊ ',num2str(totalCost3),' Ԫ'])
disp(['�ܳɱ�Ϊ ',num2str(totalCost1 + totalCost2 + totalCost3),' Ԫ'])

%�����������
% waste_power1 = sum(result_balance_P(:,1)) / sum(EH1_solarP + EH1_windP) * 100; % ���ӷ�ĸ��period������
% waste_power2 = sum(result_balance_P(:,2)) / sum(EH2_solarP + EH2_windP) * 100;
% waste_power3 = sum(result_balance_P(:,3)) / sum(EH3_solarP + EH3_windP) * 100;
% disp(['IES1�������Ϊ ',num2str(waste_power1),' %'])
% disp(['IES2�������Ϊ ',num2str(waste_power2),' %'])
% disp(['IES3�������Ϊ ',num2str(waste_power3),' %'])
% 
% %�������˷���
% waste_heat1 = sum(result_balance_H(:,1)) / sum(EH1_Lh) * 100; % ���ӷ�ĸ��period������
% waste_heat2 = sum(result_balance_H(:,2)) / sum(EH2_Lh) * 100;
% waste_heat3 = sum(result_balance_H(:,3)) / sum(EH3_Lh) * 100;
% disp(['IES1���˷���Ϊ ',num2str(waste_heat1),' %'])
% disp(['IES2���˷���Ϊ ',num2str(waste_heat2),' %'])
% disp(['IES3���˷���Ϊ ',num2str(waste_heat3),' %'])

% %�����������
% times_dayahead = sum(iterationTimes(:,1)) / length(iterationTimes(:,1));
% times_inday = sum(iterationTimes(:,2)) / length(iterationTimes(:,2));
% disp(['��ǰ�Ż�ƽ������ ',num2str(times_dayahead)])
% disp(['�����Ż�ƽ������ ',num2str(times_inday)])

% --------------------------------------��ͼ--------------------------------------
t1 = 1:1:24*period;
t2 = 0:1:24*period;
optNumber = 24;
w=1.2;

w=1.5;
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

%--------------------��������---------------------
if isCentral == 0
    c4_clearingPrice = priceArray;
    c4_gridClearDemand = - sum(result_Ele , 2);
else
    c4_clearingPrice = elePrice;
    c4_gridClearDemand = - sum(result_Ele , 2);
end
figure
hold on
[AX,H1,H2] = plotyy(t1, -c4_gridClearDemand/1000, t1, [c4_clearingPrice, elePrice], 'bar', 'plot');
H1(1).EdgeColor = dodgerblue;
H1(1).FaceColor = dodgerblue;
set(H2(1),'Color',firebrick, 'LineStyle','-','LineWidth',1.5, 'Marker', '.', 'MarkerSize', 13)
set(H2(2),'Color',darkblue, 'LineStyle','-','LineWidth',1.5, 'Marker', '.', 'MarkerSize', 13)

set(get(AX(1),'Ylabel'),'String','���߹��繦��(MW)')
set(get(AX(2),'Ylabel'),'String','���(Ԫ/kWh)')
% xlabel('ʱ��(h)')
set(AX(1),'xlim',[0,24*period+1])
set(AX(2),'xlim',[0,24*period+1])
set(gca,'XTick',0:(24*period/4):24*period, 'XTickLabel',{'0:00','6:00','12:00','18:00','24:00'})
set(AX(2),'XTick',[],'XTickLabel',[])

H3 = stairs(t2, ones(24*period+1, 1) .* eleLimit_total, 'Color',gray,'LineStyle','--','LineWidth',1);
stairs(t2, ones(24*period+1, 1) * eleLimit_total / reverseRate, 'Color',gray,'LineStyle','--','LineWidth',1);

H10 = legend([H1,H2(1),H2(2),H3(1)],'���߹���','���ص��','�������','���߹���Լ��');
set(H10,'Box','off');
set(gcf,'Position',[0 0 400 200]);

%--------------------�Ż����2---------------------
result_Ele_loss_positive = result_Ele_loss;
result_Ele_loss_positive(result_Ele_loss_positive<0) = 0;
result_Ele_loss_negtive = result_Ele_loss;
result_Ele_loss_negtive(result_Ele_loss_negtive>0) = 0;

stackedbar = @(x, A) bar(x, A, 'stacked');
prettyline = @(x, y) plot(x, y, 'Color',firebrick, 'LineStyle','-','LineWidth',1.5, 'Marker', '.', 'MarkerSize', 13);

figure
for IES_no = 1 : IESNUMBER
    subplot(3,1,IES_no)
    hold on
    eval(['bar_positive = [result_Ele_loss_positive(:,IES_no), result_CHP_power(:,IES_no), EH', num2str(IES_no),'_solarP + EH', num2str(IES_no), '_windP, result_ES_discharge(:,IES_no)] ./ 1000;']);
    bar_negtive = [result_Ele_loss_negtive(:,IES_no), -result_ES_charge(:,IES_no)] ./1000;
    eval(['Egen = (result_Ele_loss(:,IES_no) + result_CHP_power(:,IES_no) + EH', num2str(IES_no),'_solarP + EH', num2str(IES_no),'_windP + result_ES_discharge(:,IES_no) - result_ES_charge(:,IES_no)) ./1000 ;']);
    eval(['Eload = (EH', num2str(IES_no),'_Le + EH', num2str(IES_no),'_Edr) ./1000;']);
    eval(['Eload_base = EH', num2str(IES_no),'_Le ./1000;']);

    [AX,H1,H2] = plotyy(t1, bar_positive, t2,result_ES_SOC(:,IES_no),stackedbar,prettyline);
    H1(1).EdgeColor = dodgerblue;
    H1(1).FaceColor = H1(1).EdgeColor;
    H1(2).EdgeColor = yellowgreen;
    H1(2).FaceColor = H1(2).EdgeColor;
    H1(3).EdgeColor = gold;
    H1(3).FaceColor = H1(3).EdgeColor;
    H1(4).EdgeColor = indianred;
    H1(4).FaceColor = H1(4).EdgeColor;
    
    H3 = bar(bar_negtive,'stacked');
    H3(1).EdgeColor = H1(1).EdgeColor;
    H3(1).FaceColor = H3(1).EdgeColor;
    H3(2).EdgeColor = H1(4).EdgeColor;
    H3(2).FaceColor = H3(2).EdgeColor;
    H4 = plot(t1,[Eload_base, Eload]);
    
    set(H4(1),'Color','black', 'LineStyle','-.','LineWidth',1.5, 'Marker', '.', 'MarkerSize', 13);
    set(H4(2),'Color','black', 'LineStyle','-','LineWidth',1.5, 'Marker', '.', 'MarkerSize', 13);
    
    set(get(AX(1),'Ylabel'),'String','�繦��(MW)')
    set(get(AX(2),'Ylabel'),'String','SOC')
    xlabel(sprintf('IES%d',IES_no))
    set(AX(1),'xlim',[0,24*period+1])
    set(AX(2),'xlim',[0,24*period+1])
    set(gca,'XTick',0:(24*period/4):24*period, 'XTickLabel',{'0:00','6:00','12:00','18:00','24:00'}) % 0:(optNumber/4):optNumber)
    set(AX(2),'XTick',[],'XTickLabel',[])
    set(AX(1),'ylim',[-1,2.5])
    set(AX(1),'YTick',-1:0.5:2.5)
    set(AX(2),'ylim',[0,1])
    set(AX(2),'YTick',0.1:0.2:1)
    
    H10 = legend([H1(1),H1(2),H1(3),H1(4),H2,H4(1),H4(2)], '֧�߹���','CHP','��������Դ','ESS�ŵ�','�索��SOC','�ܻ���','�ܸ���','Location','northoutside','Orientation','horizontal');
    set(H10,'Box','off');
    set(gcf,'Position',[0 0 550 500]);
    
end
%%%%%%%%%%%%%%
figure
for IES_no = 1 : IESNUMBER
    subplot(3,1,IES_no)
    hold on
    bar_positive = [result_CHP_heat(:,IES_no), result_Boiler_heat(:,IES_no), result_HS_discharge(:,IES_no)] ./1000;
    bar_negtive = -result_HS_charge(:,IES_no) ./1000;
    Hgen = (result_CHP_heat(:,IES_no) + result_Boiler_heat(:,IES_no) + result_HS_discharge(:,IES_no) - result_HS_charge(:,IES_no)) ./1000;
    eval(['Hload = (EH', num2str(IES_no),'.Lh_real + EH', num2str(IES_no),'_Hdr) ./1000;']);
    eval(['Hload_base = EH', num2str(IES_no),'.Lh_real ./1000;']);
    [AX,H1,H2] = plotyy(t1, bar_positive, t2,result_HS_SOC(:,IES_no),stackedbar,prettyline);
    H1(1).EdgeColor = yellowgreen;
    H1(1).FaceColor = H1(1).EdgeColor;
    H1(2).EdgeColor = gold;
    H1(2).FaceColor = H1(2).EdgeColor;
    H1(3).EdgeColor = indianred;
    H1(3).FaceColor = H1(3).EdgeColor;
    H3 = bar(bar_negtive,'stacked');
    H3(1).EdgeColor = H1(3).EdgeColor;
    H3(1).FaceColor = H3(1).EdgeColor;
    
    H4 = plot(t1,[Hload_base, Hload]);
    set(H4(1),'Color','black', 'LineStyle','-.','LineWidth',1.5, 'Marker', '.', 'MarkerSize', 13);
    set(H4(2),'Color','black', 'LineStyle','-','LineWidth',1.5, 'Marker', '.', 'MarkerSize', 13);
  
    set(get(AX(1),'Ylabel'),'String','�ȹ���(MW)')
    set(get(AX(2),'Ylabel'),'String','SOC')
    xlabel(sprintf('IES%d',IES_no))
    set(AX(1),'xlim',[0,24*period+1])
    set(AX(2),'xlim',[0,24*period+1])
    set(gca,'XTick',0:(24*period/4):24*period, 'XTickLabel',{'0:00','6:00','12:00','18:00','24:00'})
    set(AX(2),'XTick',[],'XTickLabel',[])
    set(AX(1),'ylim',[-1,2])
    set(AX(1),'YTick',-1:0.5:2)
    set(AX(2),'ylim',[0,1])
    set(AX(2),'YTick',0.1:0.2:1)
    
    H10 = legend([H1(1),H1(2),H1(3),H2,H4(1),H4(2)], 'CHP','GF','ThSS�ŵ�','�ȴ���SOC','�ܻ���','�ܸ���','Location','northoutside','Orientation','horizontal');
    set(H10,'Box','off');
    set(gcf,'Position',[0 0 500 500]);
end

% IES���õ� ����
% �磺CHP���索�ܣ������ߣ�
% �ȣ�CHP����¯���ȴ���
%--------------------------------------������չ--------------------------------------
% result_Ele_loss(24*period+1, :) = result_Ele_loss(24*period, :);
% result_CHP_power(24*period+1, :) = result_CHP_power(24*period, :);
% result_CHP_heat(24*period+1, :) = result_CHP_heat(24*period, :);
% result_Boiler_heat(24*period+1, :) = result_Boiler_heat(24*period, :);

%{
figure(4)
subplot(2,1,1)
hold on
[AX,H1,H2] = plotyy(t2, result_Ele_loss(:,1), t2, result_ES_SOC(:,1),'stairs','plot');
stairs(t2, result_CHP_power(:,1), 'Color','r','LineStyle','--','LineWidth',w);
% legend('lateral','CHP','EESS','Location','northoutside','Orientation','horizontal')
legend('֧�߽�������','CHP�繦��','ESS SOC','Location','northoutside','Orientation','horizontal')
set(H1,'Color','b','LineStyle',':','LineWidth',w)
set(H2,'Color',[101, 147, 74]./255,'LineWidth',w)
% set(get(AX(1),'Ylabel'),'String','electricity power / kW')
set(get(AX(1),'Ylabel'),'String','�繦��(kW)')
set(get(AX(2),'Ylabel'),'String','SOC')
% xlabel('time / h')
% text(1,1,'(c)֧��2')
set(AX(1),'xlim',[0,24*period])
set(AX(2),'xlim',[0,24*period])
set(gca,'XTick',0:(24*period/4):24*period, 'XTickLabel',0:(optNumber/4):optNumber)
set(AX(2),'XTick',[],'XTickLabel',[])
set(AX(1),'ylim',[-100,650])
set(AX(1),'YTick',-100:150:650)
set(AX(2),'ylim',[0,1])
set(AX(2),'YTick',0:0.2:1)

subplot(2,1,2)
hold on
[AX,H1,H2] = plotyy(t2, result_Boiler_heat(:,1), t2, result_HS_SOC(:,1),'stairs','plot');
stairs(t2, result_CHP_heat(:,1), 'Color','r','LineStyle','--','LineWidth',w)
legend('GF�ȹ���','CHP�ȹ���','ThSS SOC','Location','northoutside','Orientation','horizontal')
set(H1,'Color','b','LineStyle',':','LineWidth',w)
set(H2,'Color',[101, 147, 74]./255,'LineWidth',w)
% set(get(AX(1),'Ylabel'),'String','thermal power / kW')
set(get(AX(1),'Ylabel'),'String','�ȹ���(kW)')
set(get(AX(2),'Ylabel'),'String','SOC')
% xlabel('time / h')
xlabel('ʱ��(h)')
% text(1,1,'(c)֧��2')
set(AX(1),'xlim',[0,24*period])
set(AX(2),'xlim',[0,24*period])
set(gca,'XTick',0:(24*period/4):24*period, 'XTickLabel',0:(optNumber/4):optNumber)
set(AX(2),'XTick',[],'XTickLabel',[])
set(AX(1),'ylim',[0,750])
set(AX(1),'YTick',0:150:750)
set(AX(2),'ylim',[0,1])
set(AX(2),'YTick',0:0.2:1)

set(gcf,'Position',[0 0 400 300]);

figure(5)

subplot(2,1,1)
hold on
[AX,H1,H2] = plotyy(t2, result_Ele_loss(:,2), t2, result_ES_SOC(:,2),'stairs','plot');
stairs(t2, result_CHP_power(:,2), 'Color','r','LineStyle','--','LineWidth',w);
% legend('lateral','CHP','EESS','Location','northoutside','Orientation','horizontal')
legend('֧�߽�������','CHP�繦��','ESS SOC','Location','northoutside','Orientation','horizontal')
set(H1,'Color','b','LineStyle',':','LineWidth',w)
set(H2,'Color',[101, 147, 74]./255,'LineWidth',w)
% set(get(AX(1),'Ylabel'),'String','electricity power / kW')
set(get(AX(1),'Ylabel'),'String','�繦��(kW)')
set(get(AX(2),'Ylabel'),'String','SOC')
% xlabel('ʱ��')
% text(1,1,'(c)֧��2')
set(AX(1),'xlim',[0,24*period])
set(AX(2),'xlim',[0,24*period])
set(gca,'XTick',0:(24*period/4):24*period, 'XTickLabel',0:(optNumber/4):optNumber)
set(AX(2),'XTick',[],'XTickLabel',[])
set(AX(1),'ylim',[-100,400])
set(AX(1),'YTick',-100:100:400)
set(AX(2),'ylim',[0,1])
set(AX(2),'YTick',0:0.2:1)

subplot(2,1,2)
hold on
[AX,H1,H2] = plotyy(t2, result_Boiler_heat(:,2), t2, result_HS_SOC(:,2),'stairs','plot');
stairs(t2, result_CHP_heat(:,2), 'Color','r','LineStyle','--','LineWidth',w)
legend('GF�ȹ���','CHP�ȹ���','ThSS SOC','Location','northoutside','Orientation','horizontal')
set(H1,'Color','b','LineStyle',':','LineWidth',w)
set(H2,'Color',[101, 147, 74]./255,'LineWidth',w)
% set(get(AX(1),'Ylabel'),'String','thermal power / kW')
set(get(AX(1),'Ylabel'),'String','�ȹ���(kW)')
set(get(AX(2),'Ylabel'),'String','SOC')
% xlabel('time / h')
xlabel('ʱ��(h)')
% text(1,1,'(c)֧��2')
set(AX(1),'xlim',[0,24*period])
set(AX(2),'xlim',[0,24*period])
set(gca,'XTick',0:(24*period/4):24*period, 'XTickLabel',0:(optNumber/4):optNumber)
set(AX(2),'XTick',[],'XTickLabel',[])
set(AX(1),'ylim',[0,400])
set(AX(1),'YTick',0:80:400)
set(AX(2),'ylim',[0,1])
set(AX(2),'YTick',0:0.2:1)


set(gcf,'Position',[0 0 400 300]);



figure(6)

subplot(2,1,1)
hold on
[AX,H1,H2] = plotyy(t2, result_Ele_loss(:,3), t2, result_ES_SOC(:,3),'stairs','plot');
stairs(t2, result_CHP_power(:,3), 'Color','r','LineStyle','--','LineWidth',w);
% legend('lateral','CHP','EESS','Location','northoutside','Orientation','horizontal')
legend('֧�߽�������','CHP�繦��','ESS SOC','Location','northoutside','Orientation','horizontal')
set(H1,'Color','b','LineStyle',':','LineWidth',w)
set(H2,'Color',[101, 147, 74]./255,'LineWidth',w)
% set(get(AX(1),'Ylabel'),'String','electricity power / kW')
set(get(AX(1),'Ylabel'),'String','�繦��(kW)')
set(get(AX(2),'Ylabel'),'String','SOC')
% xlabel('ʱ��')
% text(1,1,'(c)֧��2')
set(AX(1),'xlim',[0,24*period])
set(AX(2),'xlim',[0,24*period])
set(gca,'XTick',0:(24*period/4):24*period, 'XTickLabel',0:(optNumber/4):optNumber)
set(AX(2),'XTick',[],'XTickLabel',[])
set(AX(1),'ylim',[-60,240])
set(AX(1),'YTick',-60:60:240)
set(AX(2),'ylim',[0,1])
set(AX(2),'YTick',0:0.2:1)

subplot(2,1,2)
hold on
[AX,H1,H2] = plotyy(t2, result_Boiler_heat(:,3), t2, result_HS_SOC(:,3),'stairs','plot');
stairs(t2, result_CHP_heat(:,3), 'Color','r','LineStyle','--','LineWidth',w)
legend('GF�ȹ���','CHP�ȹ���','ThSS SOC','Location','northoutside','Orientation','horizontal')
set(H1,'Color','b','LineStyle',':','LineWidth',w)
set(H2,'Color',[101, 147, 74]./255,'LineWidth',w)
% set(get(AX(1),'Ylabel'),'String','thermal power / kW')
set(get(AX(1),'Ylabel'),'String','�ȹ���(kW)')
set(get(AX(2),'Ylabel'),'String','SOC')
% xlabel('time / h')
xlabel('ʱ��(h)')
% text(1,1,'(c)֧��2')
set(AX(1),'xlim',[0,24*period])
set(AX(2),'xlim',[0,24*period])
set(gca,'XTick',0:(24*period/4):24*period, 'XTickLabel',0:(optNumber/4):optNumber)
set(AX(2),'XTick',[],'XTickLabel',[])
set(AX(1),'ylim',[0,400])
set(AX(1),'YTick',0:80:400)
set(AX(2),'ylim',[0,1])
set(AX(2),'YTick',0:0.2:1)


set(gcf,'Position',[0 0 400 300]);
%}

% -------ֻ��¼�������еĳ�����---------
%{
elePrice(24*period+1, :) = elePrice(24*period, :);
priceArray_record(24*period+1, :) = priceArray_record(24*period, :);

figure(8)
w=1.2;

hold on
stairs(t2, elePrice, 'Color','b','LineStyle','--','LineWidth',w);
stairs(t2, priceArray_record(:,1), 'Color','r','LineStyle','-','LineWidth',w);
stairs(t2, priceArray_record(:,2), 'Color','k','LineStyle',':','LineWidth',w);

% legend('utility price','day-ahead clearing price','real-time clearing price','real-time clearing price��IES3 isolated��')
legend('�������','��ǰ������','���ڳ�����')
axis([0 24*period 0.2 1.2])
set(gca,'XTick',0:(24*period/4):24*period, 'XTickLabel',0:(optNumber/4):optNumber)
% xlabel('time / h')
xlabel('ʱ��(h)')
% ylabel('price / yuan/kWh')
ylabel('���(Ԫ/kWh)')
% set(gca,'FontSize',14) % �������ִ�С��ͬʱӰ���������ע��ͼ��������ȡ�
% set(get(gca,'XLabel'),'FontSize',14);
% set(get(gca,'YLabel'),'FontSize',14);
set(gcf,'Position',[0 0 400 200]);
set(gca,'Fontname','Monospaced');
%}


% -------ͬʱ��¼�������к�ͻȻ����ʱ�ĳ�����---------
%{
priceArray_normal = [0.370008142338676;0.385717522693708;0.363534521676111;0.368375205528558;0.353264238197299;0.353915728172134;0.437959326413856;0.392929250442548;1.03292467099294;0.561401875187474;0.537300862415980;0.544080498984673;0.535957976900646;0.546204794157670;0.540864819374419;0.544925848460731;0.555158632619513;0.542910592622054;0.553443592092666;0.561598149278862;0.713071708347918;0.585047037404080;0.593975061642661;0.578366550751511;0.578366550751511];
elePrice(25,:) = elePrice(24,:);
priceArray_record(25,:) = priceArray_record(24,:);
priceArray_normal(25,:) = priceArray_normal(24,:);

figure(7)
w=1.2;

hold on
stairs(t2, elePrice, 'Color','k','LineStyle',':','LineWidth',w);
stairs(t2, priceArray_record(:,1), 'Color','b','LineStyle','-.','LineWidth',w);
stairs(t2, priceArray_normal, 'Color',[101, 147, 74]./255,'LineStyle','-','LineWidth',w);
stairs(t2, priceArray_record(:,2), 'Color','r','LineStyle','--','LineWidth',w);

% legend('utility price','day-ahead clearing price','real-time clearing price','real-time clearing price��IES3 isolated��')
legend('�������','��ǰ������','���ڳ�����','IES��������������ڳ�����')
axis([0 24 0.2 1.5])
set(gca,'XTick',0:(optNumber/4):optNumber)
% xlabel('time / h')
xlabel('ʱ��(h)')
% ylabel('price / yuan/kWh')
ylabel('���(Ԫ/kWh)')
% set(gca,'FontSize',14) % �������ִ�С��ͬʱӰ���������ע��ͼ��������ȡ�
% set(get(gca,'XLabel'),'FontSize',14);
% set(get(gca,'YLabel'),'FontSize',14);
set(gcf,'Position',[0 0 400 300]);
%}