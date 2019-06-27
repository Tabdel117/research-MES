%��ʱ�ε��Ż����⣬��all_temporal�Ƚ�
global minMarketPrice maxMarketPrice period IESNUMBER elePrice  minimumPower
ee = 1e-2; %0.0001 0.0003
iterativeStep = 1e-5; %0.00001 0.0001
iterationTimes = zeros(24*period, 2); %��¼��������
maxIteration = 3000; %����������
gridClearDemand = zeros(24*period,1);
dflag = 0; % �Ƿ��ͼ
for pt =  1 : 24 * period
     if isDA == 0
        EH1.predict(pt);
        EH2.predict(pt);
        EH3.predict(pt);
     end 
     if dflag == 1
        [demand,price] = IESdemand_curve(priceArray, pt);
        figure;
        hold on;
        for ies_no = 1 : IESNUMBER
            plot(price,demand(ies_no,:),'LineWidth',1.5);
        end
        plot(price,sum(demand),'LineWidth',1.5);
        xlabel('���')
%             legend('IES1','IES2','IES3','��')
        title([pt ,'ʱ��Ͷ������']);
        ylabel('����')
     end

    % ��ͼ۸�һ�㶼��������ڹ���
    priceArray(pt) = minMarketPrice;
    [x,~,~,~,~] = EH1.handlePrice(priceArray, gasPrice1, pt);
    clearDemand_minPrice_EH1 = x(1);
    [x,~,~,~,~] = EH2.handlePrice(priceArray, gasPrice1, pt);
    clearDemand_minPrice_EH2 = x(1);
    [x,~,~,~,~] = EH3.handlePrice(priceArray, gasPrice1, pt);
    clearDemand_minPrice_EH3 = x(1);
    if priceArray(pt) ==  elePrice(pt)
        clearDemand_minPrice_grid = clearDemand_minPrice_EH1 + clearDemand_minPrice_EH2 + clearDemand_minPrice_EH3;
        if clearDemand_minPrice_grid > eleLimit_total(1)
            clearDemand_minPrice_grid = eleLimit_total(1);
        end
        if clearDemand_minPrice_grid < minimumPower
            clearDemand_minPrice_grid = minimumPower;
        end
    elseif  priceArray(pt)>  elePrice(pt)
        clearDemand_minPrice_grid =eleLimit_total(1);
    else
        clearDemand_minPrice_grid =minimumPower;
    end
    clearDemand_minPrice = [-clearDemand_minPrice_grid; clearDemand_minPrice_EH1; clearDemand_minPrice_EH2; clearDemand_minPrice_EH3]; % ����Ϊ��������Ϊ��

    % ��߼۸�һ�㶼�ǹ�����������
    priceArray(pt) = maxMarketPrice;
    [x,~,~,~,~] = EH1.handlePrice(priceArray, gasPrice1, pt);
    clearDemand_maxPrice_EH1 = x(1);
    [x,~,~,~,~] = EH2.handlePrice(priceArray, gasPrice1, pt);
    clearDemand_maxPrice_EH2 = x(1);
    [x,~,~,~,~] = EH3.handlePrice(priceArray, gasPrice1, pt);
    clearDemand_maxPrice_EH3 = x(1);
    if priceArray(pt) ==  elePrice(pt)
        clearDemand_maxPrice_grid = clearDemand_maxPrice_EH1 + clearDemand_maxPrice_EH2 + clearDemand_maxPrice_EH3;
        if clearDemand_maxPrice_grid > eleLimit_total(1)
            clearDemand_maxPrice_grid = eleLimit_total(1);
        end
        if clearDemand_maxPrice_grid < minimumPower
            clearDemand_maxPrice_grid = minimumPower;
        end
    elseif  priceArray(pt )>  elePrice(pt)
            clearDemand_maxPrice_grid =eleLimit_total(1);
    else
            clearDemand_maxPrice_grid =minimumPower;
    end
    clearDemand_maxPrice = [-clearDemand_maxPrice_grid; clearDemand_maxPrice_EH1; clearDemand_maxPrice_EH2; clearDemand_maxPrice_EH3]; % ����Ϊ��������Ϊ��

    iterationNumber = 2;
    if sum(clearDemand_minPrice) * sum(clearDemand_maxPrice) <= 0 % ˵�����������������ڣ����������⣬һ�ǵ������Ƿ�ֱ�ӽ����������������㲻Ψһ��ô��
        % �г�����õ�����۸񣬲�����Ԥ��������
        [priceArray(pt), clearDemand] = iterativeClear(minMarketPrice, maxMarketPrice, clearDemand_minPrice, clearDemand_maxPrice, ee, priceArray, gasPrice1, pt);
    else
        disp('Clearing point is not in the given interval.')
    end
    iterationTimes(pt,1) = iterationNumber;

    % �õ�����۸�󣬻�Ҫ��ȷ���幦�ʣ�EH��������״̬��������ʱ���ܱ�֤�����幦��֮��Ϊ�㣿
    gridClearDemand(pt) = clearDemand(1);
    EH1.conditionHandlePrice_2(priceArray, gasPrice1, pt, clearDemand(2));
    EH2.conditionHandlePrice_2(priceArray, gasPrice1, pt, clearDemand(3));
    EH3.conditionHandlePrice_2(priceArray, gasPrice1, pt, clearDemand(4));

end
[result_Ele(:,1), result_CHP_G(:,1), result_Boiler_G(:,1), result_ES_discharge(:,1), result_ES_charge(:,1), result_HS_discharge(:,1), result_HS_charge(:,1), result_ES_SOC(:,1), result_HS_SOC(:,1), result_EH_Le(:, 1), result_EH_Lh(:,1), result_EH_solarP(:,1), result_EH_windP(:,1), result_EH_Edr(:,1), result_EH_Hdr(:,1)] = EH1.getResult;
[result_Ele(:,2), result_CHP_G(:,2), result_Boiler_G(:,2), result_ES_discharge(:,2), result_ES_charge(:,2), result_HS_discharge(:,2), result_HS_charge(:,2), result_ES_SOC(:,2), result_HS_SOC(:,2), result_EH_Le(:, 2), result_EH_Lh(:,2), result_EH_solarP(:,2), result_EH_windP(:,2), result_EH_Edr(:,2), result_EH_Hdr(:,2)] = EH2.getResult;
[result_Ele(:,3), result_CHP_G(:,3), result_Boiler_G(:,3), result_ES_discharge(:,3), result_ES_charge(:,3), result_HS_discharge(:,3), result_HS_charge(:,3), result_ES_SOC(:,3), result_HS_SOC(:,3), result_EH_Le(:, 3), result_EH_Lh(:,3), result_EH_solarP(:,3), result_EH_windP(:,3), result_EH_Edr(:,3), result_EH_Hdr(:,3)] = EH3.getResult;

priceArray_record(:,3) = priceArray;