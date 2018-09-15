%��ʱ�ε��Ż����⣬��all_temporal�Ƚ�
global minMarketPrice maxMarketPrice period
ee = 1e-2; %0.0001 0.0003
iterativeStep = 5e-6; %0.00001 0.0001
iterationTimes = zeros(24*period, 2); %��¼��������
maxIteration = 3000; %����������
gridClearDemand = zeros(24*period,1);
if isDA 
   EH1.predict(0);
   EH2.predict(0);
   EH3.predict(0);
   priceArray_record(:,1) = elePrice;
end
if isGrad == 1%���ݶȷ����
    for pt =  1 : 24 * period
        if isDA ~= 0
            EH1.predict(pt);
            EH2.predict(pt);
            EH3.predict(pt);
        end
         % ��ͼ۸�һ�㶼��������ڹ���
        priceArray(pt) = minMarketPrice;
        [x,~,~,~,~] = EH1.handlePrice(priceArray, gasPrice1, pt);
        clearDemand_minPrice_EH1 = x(1);
        [x,~,~,~,~] = EH2.handlePrice(priceArray, gasPrice1, pt);
        clearDemand_minPrice_EH2 = x(1);
        [x,~,~,~,~] = EH3.handlePrice(priceArray, gasPrice1, pt);
        clearDemand_minPrice_EH3 = x(1);
        clearDemand_minPrice_grid = Grid1.handlePrice(priceArray(pt), pt);
        clearDemand_minPrice = [clearDemand_minPrice_grid; clearDemand_minPrice_EH1; clearDemand_minPrice_EH2; clearDemand_minPrice_EH3]; % ����Ϊ��������Ϊ��
        
        % ��߼۸�һ�㶼�ǹ�����������
        priceArray(pt) = maxMarketPrice;
        [x,~,~,~,~] = EH1.handlePrice(priceArray, gasPrice1, pt);
        clearDemand_maxPrice_EH1 = x(1);
        [x,~,~,~,~] = EH2.handlePrice(priceArray, gasPrice1, pt);
        clearDemand_maxPrice_EH2 = x(1);
        [x,~,~,~,~] = EH3.handlePrice(priceArray, gasPrice1, pt);
        clearDemand_maxPrice_EH3 = x(1);
        clearDemand_maxPrice_grid = Grid1.handlePrice(priceArray(pt), pt);
        clearDemand_maxPrice = [clearDemand_maxPrice_grid; clearDemand_maxPrice_EH1; clearDemand_maxPrice_EH2; clearDemand_maxPrice_EH3]; % ����Ϊ��������Ϊ��
        
        iterationNumber = 2;
        if sum(clearDemand_minPrice) * sum(clearDemand_maxPrice) <= 0 % ˵�����������������ڣ����������⣬һ�ǵ������Ƿ�ֱ�ӽ����������������㲻Ψһ��ô��
            % �г�����õ�����۸񣬲�����Ԥ��������
            [priceArray(pt), clearDemand] = iterativeClear(minMarketPrice, maxMarketPrice, clearDemand_minPrice, clearDemand_maxPrice, ee, priceArray, gasPrice1, gasPrice3, pt);
        else
            disp('Clearing point is not in the given interval.')
        end
        
        number = 1;
        lamda_old = -10;
        lamda_new = 0.0; %ȡ��ʼֵ����Ԥ����û��ƫ��
        lamda_record = zeros(maxIteration+1, 1);
        lamda_record(number) = lamda_new;
        
        lamda_avg_old = lamda_old;
        lamda_avg_new = lamda_new;
        lamda_avg_record = zeros(maxIteration+1, 1);
        lamda_avg_record(number) = lamda_avg_new;
        
        clearDemand_record = zeros(maxIteration+1, 1);
        
        
        %���ǰ�����μ۸��ƫ��̫���򷵻ص�1��
        while number<=2 || abs(lamda_avg_new - lamda_avg_old) > ee || sum(clearDemand_new) * sum(clearDemand_old) > 1e-4  %1e-6, ����ֱ��ȡ0
            % ��һ����������Ϊ��ʹlamda�����󣬹���Ҳ��ƽ�⣬������Ҫȡһ��һ�������㣬�������
            % && || ��ǰһ��Ϊ�����һ���Ͳ�������
            % Ҫ�����ٵ������Σ�number=1��2��
            if number > maxIteration
                if isDA
                    break;
                else
                    error('��������������');
                end
            end
            
            %��ǰ�۸��µĳ���
            priceArray(pt) = elePrice(pt) + lamda_new;
            [x,~,~,~,~] = EH1.handlePrice(priceArray, gasPrice1, pt);
            clearDemand_EH1_new = x(1);
            [x,~,~,~,~] = EH2.handlePrice(priceArray, gasPrice1, pt);
            clearDemand_EH2_new = x(1);
            [x,~,~,~,~] = EH3.handlePrice(priceArray, gasPrice1, pt);
            clearDemand_EH3_new = x(1);
            
            % clearDemand_grid_new = Grid1.handlePrice(priceArray(pt), pt);
            
            f1 = - lamda_new;
            lb1 = eleLimit_total(2);
            ub1 = eleLimit_total(1);
            [clearDemand_grid_new, value1, flag1]  = linprog(f1, [], [], [], [], lb1, ub1);
            
            % �洢�ϵ�clearDemand�������µ�clearDemand������¼
            if number>1
                clearDemand_old = clearDemand_new; % number=2ʱ�ż�¼��һ��
            end
            clearDemand_new = [-clearDemand_grid_new; clearDemand_EH1_new; clearDemand_EH2_new; clearDemand_EH3_new]; % ����Ϊ��������Ϊ��
            clearDemand_record(number) = sum(clearDemand_new);
            
            % �洢�ϵ�lamda�������µ�lamda��ͨ���ݶȷ���������¼
            lamda_old = lamda_new;
            % lamda_new = max(0, lamda_old + sum(clearDemand) * iterativeStep);
            lamda_new = lamda_old + sum(clearDemand_new) * iterativeStep;
            number = number + 1;
            lamda_record(number) = lamda_new;
            
            % �洢�ϵ�ƽ��ֵ�������µ�ƽ��ֵ������¼
            lamda_avg_old = lamda_avg_new;
            % ϵ��bb����ֵռƽ��ֵ�ı���
            bb = 1/number; % ����һ��ƽ��ֵ��ʵ�ʾ��� = (lamda_avg_old * (number-1) + lamda_new * 1) / number;
            % bb = 0.5; % ����������Ȩƽ����������ֵ�����˽����������
            lamda_avg_new = lamda_avg_old * (1-bb) + lamda_new * bb;
            lamda_avg_record(number) = lamda_avg_new;
            
            % lamdaArrayAvg_new = sum(lamdaArray) / length(lamdaArray); %����һ
            % lamda_avg_new = 1 / length(lamda_record) * lamda_record(number) + (length(lamda_record)-1) / length(lamda_record) * lamda_avg_old; %������
        end
        
        % ����ֹͣ����
        iterationTimes(pt,1) = number - 1;
        % �õ������ۣ��������ԣ����ݵ���������εĽ�������µĳ���۸�ͳ��幦��
        if sum(clearDemand_new) * sum(clearDemand_old) <= 0
            if lamda_record(number-1) == lamda_record(number-2) %��ֹ���ļ���ʽ�ķ�ĸΪ��
                clearLamda = lamda_record(number-1);
            elseif clearDemand_record(number-1) == clearDemand_record(number-2) %��ֹ���ļ���ʽ�ķ�ĸΪ��
                clearLamda = (lamda_record(number-1) + lamda_record(number-2)) / 2;
            else
                slope = (clearDemand_record(number-1) - clearDemand_record(number-2)) / (lamda_record(number-1) - lamda_record(number-2));
                clearLamda = lamda_record(number-2) + (0 - clearDemand_record(number-2)) / slope;
            end
        else % ֵ��[0��1e-4]֮�䣬��ô��û�������
            clearLamda = (lamda_record(number-1) + lamda_record(number-2)) / 2;
        end
        
        clearDemand = zeros(length(clearDemand_new) ,1);
        for i=1:length(clearDemand_new)
            if lamda_record(number-1) == lamda_record(number-2)
                clearDemand(i) = clearDemand_new(i);
            else
                slope = (clearDemand_new(i) - clearDemand_old(i)) / (lamda_record(number-1) - lamda_record(number-2));
                clearDemand(i) = clearDemand_new(i) + (clearLamda - lamda_record(number-1)) * slope;
            end
        end
        
        % ���ڳ����ۿ����ɸ�
        %             if clearPrice < minMarketPrice || clearPrice > maxMarketPrice
        %                 error('�����۳�������Χ')
        %             end
        
        % ���ݵõ��ĳ���۸��Լ����幦�ʣ�EH����һ���Ż����Ը�������״̬
        priceArray(pt) = elePrice(pt) + clearLamda;
        gridClearDemand(pt) = clearDemand(1);
        EH1.conditionHandlePrice_2(priceArray, gasPrice1, pt, clearDemand(2));
        EH2.conditionHandlePrice_2(priceArray, gasPrice1, pt, clearDemand(3));
        EH3.conditionHandlePrice_2(priceArray, gasPrice1, pt, clearDemand(4));
        
    end
    
else    %���ַ����
    for pt =  1 : 24*period
        % ��ͼ۸�һ�㶼��������ڹ���
        priceArray(pt) = minMarketPrice;
        [x,~,~,~,~] = EH1.handlePrice(priceArray, gasPrice1, pt);
        clearDemand_minPrice_EH1 = x(1);
        [x,~,~,~,~] = EH2.handlePrice(priceArray, gasPrice1, pt);
        clearDemand_minPrice_EH2 = x(1);
        [x,~,~,~,~] = EH3.handlePrice(priceArray, gasPrice1, pt);
        clearDemand_minPrice_EH3 = x(1);
        clearDemand_minPrice_grid = Grid1.handlePrice(priceArray(pt), pt);
        clearDemand_minPrice = [clearDemand_minPrice_grid; clearDemand_minPrice_EH1; clearDemand_minPrice_EH2; clearDemand_minPrice_EH3]; % ����Ϊ��������Ϊ��
        
        % ��߼۸�һ�㶼�ǹ�����������
        priceArray(pt) = maxMarketPrice;
        [x,~,~,~,~] = EH1.handlePrice(priceArray, gasPrice1, pt);
        clearDemand_maxPrice_EH1 = x(1);
        [x,~,~,~,~] = EH2.handlePrice(priceArray, gasPrice1, pt);
        clearDemand_maxPrice_EH2 = x(1);
        [x,~,~,~,~] = EH3.handlePrice(priceArray, gasPrice1, pt);
        clearDemand_maxPrice_EH3 = x(1);
        clearDemand_maxPrice_grid = Grid1.handlePrice(priceArray(pt), pt);
        clearDemand_maxPrice = [clearDemand_maxPrice_grid; clearDemand_maxPrice_EH1; clearDemand_maxPrice_EH2; clearDemand_maxPrice_EH3]; % ����Ϊ��������Ϊ��
        
        iterationNumber = 2;
        if sum(clearDemand_minPrice) * sum(clearDemand_maxPrice) <= 0 % ˵�����������������ڣ����������⣬һ�ǵ������Ƿ�ֱ�ӽ����������������㲻Ψһ��ô��
            % �г�����õ�����۸񣬲�����Ԥ��������
            [priceArray(pt), clearDemand] = iterativeClear(minMarketPrice, maxMarketPrice, clearDemand_minPrice, clearDemand_maxPrice, ee, priceArray, gasPrice1, gasPrice3, pt);
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
end
[result_Ele(:,1), result_CHP_G(:,1), result_Boiler_G(:,1), result_ES_discharge(:,1), result_ES_charge(:,1), result_HS_discharge(:,1), result_HS_charge(:,1), result_ES_SOC(:,1), result_HS_SOC(:,1), EH1_Le, EH1_Lh, EH1_solarP, EH1_windP, EH1_Edr, EH1_Hdr] = EH1.getResult;
[result_Ele(:,2), result_CHP_G(:,2), result_Boiler_G(:,2), result_ES_discharge(:,2), result_ES_charge(:,2), result_HS_discharge(:,2), result_HS_charge(:,2), result_ES_SOC(:,2), result_HS_SOC(:,2), EH2_Le, EH2_Lh, EH2_solarP, EH2_windP, EH2_Edr, EH2_Hdr] = EH2.getResult;
[result_Ele(:,3), result_CHP_G(:,3), result_Boiler_G(:,3), result_ES_discharge(:,3), result_ES_charge(:,3), result_HS_discharge(:,3), result_HS_charge(:,3), result_ES_SOC(:,3), result_HS_SOC(:,3), EH3_Le, EH3_Lh, EH3_solarP, EH3_windP, EH3_Edr, EH3_Hdr] = EH3.getResult;
if isDA 
    priceArray_record(:,2) = priceArray;
else
    priceArray_record(:,3) = priceArray;
end