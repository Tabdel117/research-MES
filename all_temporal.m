%ȫʱ�ε��Ż����⣬��single_temporal�Ƚ�
%���ݶȷ����
global EH1 EH2 EH3 elePrice period
delta_lambda_max = 1e-4;
maxIteration = 3000; %����������
iterativeStep = 1;
ee = 0.001;

if isDA
    EH1.predict(0);
    EH2.predict(0);
    EH3.predict(0);
    priceArray_record(:,1) = elePrice;
    prePrice = elePrice;
end
if isDA
    temporal = 1;
else
    temporal =  24* period;
end
for pt = 1 : temporal
    if isDA == 0
        EH1.predict(pt);
        EH2.predict(pt);
        EH3.predict(pt);
    end
    number = 1; k = 1;
    lamda_old = -10 * ones(24 * period - pt + 1, 1);
    lamda_new = zeros(24 * period - pt + 1, 1); %ȡ��ʼֵ����Ԥ����û��ƫ��
    lamda_record = zeros(24 * period - pt + 1 , maxIteration + 1);
    lamda_record(: , number) = lamda_new;
    max_balance=zeros (1 , maxIteration + 1);
    %���ǰ�����μ۸��ƫ��̫���򷵻ص�1��
    while number <= 2 || max(abs(balanceDemand)) > 100
        % max(abs(lamda_new - lamda_old)) > ee || %| max(abs(clearDemand_new - clearDemand_old)) > 1e-4 %1e-6, ����ֱ��ȡ0
        % ��һ����������Ϊ��ʹlamda�����󣬹���Ҳ��ƽ�⣬������Ҫȡһ��һ�������㣬�������
        % && || ��ǰһ��Ϊ�����һ���Ͳ�������
        % Ҫ�����ٵ������Σ�number=1��2��
        
        %             if number > maxIteration
        %                 error('��������������');
        %             end
        if number > 1% number=2ʱ�ż�¼��һ��
            clearDemand_old = clearDemand_new;
        end
        
        %��ǰ�۸��µĳ���
        priceArray(pt : 24* period) = prePrice(pt : 24* period) + lamda_new;
        [x1,f1,~,~,~] = EH1.handlePrice(priceArray, gasPrice1, pt);
        clearDemand_EH1_new = x1(1: 24 * period - pt + 1);
        [x2,f2,~,~,~] = EH2.handlePrice(priceArray, gasPrice1, pt);
        clearDemand_EH2_new = x2(1: 24 * period - pt + 1);
        [x3,f3,~,~,~] = EH3.handlePrice(priceArray, gasPrice1, pt);
        clearDemand_EH3_new = x3(1: 24 * period - pt + 1);
        
        clearDemand_grid_new=zeros(24 * period - pt + 1 ,1);
        for i = 1: 24 * period - pt + 1
            if lamda_new(i) == 0 
                clearDemand_grid_new(i) = clearDemand_EH1_new(i) + clearDemand_EH2_new(i) + clearDemand_EH3_new(i);
                if clearDemand_grid_new(i) > eleLimit_total(1)
                    clearDemand_grid_new(i) = eleLimit_total(1);
                end
                if clearDemand_grid_new(i) < eleLimit_total(2)
                    clearDemand_grid_new(i) = eleLimit_total(2);
                end
            elseif lamda_new(i) > 0
                clearDemand_grid_new(i) =eleLimit_total(1);
            else
                clearDemand_grid_new(i) =eleLimit_total(2);
            end
        end
        clearDemand_new = [-clearDemand_grid_new, clearDemand_EH1_new , clearDemand_EH2_new , clearDemand_EH3_new] ;
        phi(number) = f1 + f2 + f3 - lamda_new'* clearDemand_grid_new;
        if  number == 1
            balanceDemand = sum(clearDemand_new, 2) ;
            balanceDemand_reocrd(:,1) = balanceDemand;
            lamda_record(: , 1) = lamda_new;
            step_record(1) = step;
            price_record(:,1) = priceArray;
            delta_lambda = balanceDemand .* iterativeStep /sqrt(sum(balanceDemand.^2)) ;
            step = iterativeStep;
            lamda_old = lamda_new;
            lamda_new = lamda_old +  delta_lambda;
            number = 2;
        elseif phi(number) - phi(number-1) > -1
            balanceDemand_reocrd(:,number) = balanceDemand;
            lamda_record(: , number) = lamda_new;
            step_record(number) = step;
            price_record(:,number) = priceArray;
            balanceDemand = sum(clearDemand_new, 2) ;
            delta_lambda = balanceDemand .* iterativeStep /sqrt(sum(balanceDemand.^2)) ;
            step = iterativeStep;
            lamda_old = lamda_new;
            lamda_new = lamda_old +  delta_lambda;
            if  number> 5 && max(step_record(number-5: number))< 1e-3
                break;
            end
            number = number + 1;
            k = k + 1;
            
        else
            step = step / 2;
            delta_lambda = balanceDemand .* step /sqrt(sum(balanceDemand.^2)) ;
            lamda_new = lamda_old +  delta_lambda;
            k = k + 1;
        end
    end
    
    
    % ���ݵõ��ĳ���۸��Լ����幦�ʣ�EH����һ���Ż����Ը�������״̬
    if isDA == 0
        gridClearDemand(pt) = clearDemand_new(1,1);
        EH1.conditionHandlePrice_2(priceArray, gasPrice1, pt, clearDemand_new(:,2));
        EH2.conditionHandlePrice_2(priceArray, gasPrice1, pt, clearDemand_new(:,3));
        EH3.conditionHandlePrice_2(priceArray, gasPrice3, pt, clearDemand_new(:,4));
    end
    prePrice = priceArray;
end
% ��ǰ�Ż��Ľ��

[result_Ele(:,1), result_CHP_G(:,1), result_Boiler_G(:,1), result_ES_discharge(:,1), result_ES_charge(:,1), result_HS_discharge(:,1), result_HS_charge(:,1), result_ES_SOC(:,1), result_HS_SOC(:,1), EH1_Le, EH1_Lh, EH1_solarP, EH1_windP, EH1_Edr, EH1_Hdr] = EH1.getResult;
[result_Ele(:,2), result_CHP_G(:,2), result_Boiler_G(:,2), result_ES_discharge(:,2), result_ES_charge(:,2), result_HS_discharge(:,2), result_HS_charge(:,2), result_ES_SOC(:,2), result_HS_SOC(:,2), EH2_Le, EH2_Lh, EH2_solarP, EH2_windP, EH2_Edr, EH2_Hdr] = EH2.getResult;
[result_Ele(:,3), result_CHP_G(:,3), result_Boiler_G(:,3), result_ES_discharge(:,3), result_ES_charge(:,3), result_HS_discharge(:,3), result_HS_charge(:,3), result_ES_SOC(:,3), result_HS_SOC(:,3), EH3_Le, EH3_Lh, EH3_solarP, EH3_windP, EH3_Edr, EH3_Hdr] = EH3.getResult;
if isDA
    priceArray_record(:,2) = priceArray;
else
    priceArray_record(:,3) = priceArray;
end
isCentral =0;
