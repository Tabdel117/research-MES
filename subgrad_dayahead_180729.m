%�ô��ݶȷ������ǰ�Ż�����
global period elePrice;
priceArray = elePrice; %����ʷ���ݵõ�Ԥ���� %Ҳ�����ڵ����ļ۸����
priceArray_record = zeros(24*period,2); %һ����ǰ��һ��ʵʱ
ee = 0.01; %0.0001 0.0003
iterativeStep = 0.0001; %0.00001 0.0001
iterationTimes = zeros(24*period, 2); %��¼��������
maxIteration = 3000; %����������

demand_sum = zeros(priceNumbers, 1);
gridClearDemand = zeros(24*period,1);

off_grid = 0; % 0��ʾ�������У�1��ʾIES1����
t_realtime = zeros(24*period,3);

number = 1;
lamda_old = -10 * ones(24 * period , 1);
lamda_new = zeros(24 * period , 1); %ȡ��ʼֵ����Ԥ����û��ƫ��
lamda_record = zeros(24 * period , maxIteration + 1);
lamda_record(: , number) = lamda_new;

clearDemand_record = zeros( 24 * period, maxIteration + 1);


%���ǰ�����μ۸��ƫ��̫���򷵻ص�1��
while number <= 2 | max(abs(lamda_new - lamda_old)) > ee |max(abs(clearDemand_new))>1%| max(abs(clearDemand_new - clearDemand_old)) > 1e-4 %1e-6, ����ֱ��ȡ0
    % ��һ����������Ϊ��ʹlamda�����󣬹���Ҳ��ƽ�⣬������Ҫȡһ��һ�������㣬�������
    % && || ��ǰһ��Ϊ�����һ���Ͳ�������
    % Ҫ�����ٵ������Σ�number=1��2��
    
    if number > maxIteration
        error('��������������');
    end
    if number > 1% number=2ʱ�ż�¼��һ��
        clearDemand_old = clearDemand_new;
    end
    %��ǰ�۸��µĳ���
    priceArray = elePrice + lamda_new;
    [x,~,~,~,~] = EH1.handlePrice(priceArray, gasPrice1, 1);
    clearDemand_EH1_new = x(1: 24* period);
    [x,~,~,~,~] = EH2.handlePrice(priceArray, gasPrice1, 1);
    clearDemand_EH2_new = x(1: 24* period);
    [x,~,~,~,~] = EH3.handlePrice(priceArray, gasPrice3, 1);
    clearDemand_EH3_new = x(1: 24* period);
    
    f1 = - lamda_new;
    lb1 = eleLimit_total(2) * ones( 24 * period , 1);
    ub1 = eleLimit_total(1) * ones( 24 * period , 1);
    clearDemand_grid_new=zeros(24 * period ,1);
    for i = 1: 24 * period
        if abs(lamda_new(i)) < 1e-4            
             clearDemand_grid_new(i) = clearDemand_EH1_new(i) + clearDemand_EH2_new(i) + clearDemand_EH3_new(i);
             if clearDemand_grid_new(i) > eleLimit_total(1)
                 clearDemand_grid_new(i) = eleLimit_total(1);
             end
             if clearDemand_grid_new(i) < eleLimit_total(2)
                 clearDemand_grid_new(i) = eleLimit_total(2);
             end
        elseif lamda_new(i) >0
            clearDemand_grid_new(i) =eleLimit_total(1);
        elseif lamda_new(i) < 0
            clearDemand_grid_new(i) =eleLimit_total(2);
        end
            
            
    end
%     [clearDemand_grid_new, value1, flag1]  = linprog(f1, [], [], [], [], lb1, ub1);
    
    clearDemand_new = [-clearDemand_grid_new , clearDemand_EH1_new , clearDemand_EH2_new , clearDemand_EH3_new] ;
    clearDemand_record(: , number) = sum(clearDemand_new')' ;
    
    % �洢�ϵ�lamda�������µ�lamda��ͨ���ݶȷ���������¼
    lamda_old = lamda_new;
    %                 lamda_new = max(0, lamda_old + sum(clearDemand) * iterativeStep);
    lamda_new = lamda_old +  clearDemand_record(: , number) * iterativeStep;
    number = number + 1;
    lamda_record(: , number) = lamda_new;
    
end
clearLamda = zeros( 24 * period , 1);

% �õ������ۣ��������ԣ����ݵ���������εĽ�������µĳ���۸�ͳ��幦��
for pt= 1: 24 * period
    clearDemand_new_pt = clearDemand_record(pt , number-1);
    clearDemand_old_pt = clearDemand_record(pt , number-2);
    if clearDemand_new_pt * clearDemand_old_pt <= 0
        if lamda_new(pt) == lamda_old(pt) %��ֹ���ļ���ʽ�ķ�ĸΪ��
            clearLamda(pt) = lamda_new(pt);
        elseif clearDemand_new_pt == clearDemand_old_pt %��ֹ���ļ���ʽ�ķ�ĸΪ��
            clearLamda(pt) = (lamda_new(pt) + lamda_old(pt)) / 2;
        else
            slope = (clearDemand_new_pt - clearDemand_old_pt) / (lamda_new(pt) - lamda_old(pt));
            clearLamda(pt) =  lamda_old(pt) + (0 - clearDemand_old_pt) / slope;
        end
    else % ֵ��[0��1e-4]֮�䣬��ô��û�������
        clearLamda(pt)= (lamda_new(pt) + lamda_old(pt)) / 2;
    end
    [lr , lc ] = size(clearDemand_new);
    clearDemand = zeros( 24 * period , lc);%4�зֱ���grid, EH1,2,3�ĳ��幦��
    for i=1:lc
        if lamda_new(pt) == lamda_old(pt)
            clearDemand(pt,i) = clearDemand_new(pt ,i);
        else
            slope = (clearDemand_new(pt,i) - clearDemand_old(pt,i)) / (lamda_new(i)- lamda_old(i));
            clearDemand(pt,i) = clearDemand_new(pt,i) + (clearLamda(pt) - lamda_new(pt)) * slope;
        end
    end
end



% ���ڳ����ۿ����ɸ�
%             if clearPrice < minMarketPrice || clearPrice > maxMarketPrice
%                 error('�����۳�������Χ')
%             end

% ���ݵõ��ĳ���۸��Լ����幦�ʣ�EH����һ���Ż����Ը�������״̬
priceArray = elePrice + clearLamda;
gridClearDemand = clearDemand(:,1);
EH1.conditionHandlePrice_DA(priceArray, gasPrice1, 1, clearDemand(:,2));
EH2.conditionHandlePrice_DA(priceArray, gasPrice1, 1, clearDemand(:,3));
EH3.conditionHandlePrice_DA(priceArray, gasPrice3, 1, clearDemand(:,4));
clearDemand_grid_all=clearDemand_grid_new';
disp(['��ǰȫʱ�μ����Ż��ɱ���']);
priceArray_pre_all=priceArray;

priceArray_record(:,1) = priceArray;
% t_dayahead = toc; %���ʱ�䲻׼ȷ����Ϊ3��IESӦ���ǲ��м����

% ��ǰ�Ż��Ľ��
[result_Ele(:,1), result_CHP_G(:,1), result_Boiler_G(:,1), result_ES_discharge(:,1), result_ES_charge(:,1), result_HS_discharge(:,1), result_HS_charge(:,1), result_ES_SOC(:,1), result_HS_SOC(:,1), EH1_Le, EH1_Lh, EH1_solarP, EH1_windP] = EH1.getResult;
[result_Ele(:,2), result_CHP_G(:,2), result_Boiler_G(:,2), result_ES_discharge(:,2), result_ES_charge(:,2), result_HS_discharge(:,2), result_HS_charge(:,2), result_ES_SOC(:,2), result_HS_SOC(:,2), EH2_Le, EH2_Lh, EH2_solarP, EH2_windP] = EH2.getResult;
[result_Ele(:,3), result_CHP_G(:,3), result_Boiler_G(:,3), result_ES_discharge(:,3), result_ES_charge(:,3), result_HS_discharge(:,3), result_HS_charge(:,3), result_ES_SOC(:,3), result_HS_SOC(:,3), EH3_Le, EH3_Lh, EH3_solarP, EH3_windP] = EH3.getResult;
