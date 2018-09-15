function [clearPrice, clearDemand] = iterativeClear(price_min, price_max, clearDemand_minPrice, clearDemand_maxPrice, ee, priceArray, gasPrice1, gasPrice3, t_current)

    global Grid1 EH1 EH2 EH3 minMarketPrice maxMarketPrice iterationNumber
    
    price_medium = (price_min + price_max)/2;
    
    priceArray(t_current) = price_medium;
    [x,~,~,~,~] = EH1.handlePrice(priceArray, gasPrice1, t_current);
    clearDemand_medium_EH1 = x(1);
    [x,~,~,~,~] = EH2.handlePrice(priceArray, gasPrice1, t_current);
    clearDemand_medium_EH2 = x(1);
    [x,~,~,~,~] = EH3.handlePrice(priceArray, gasPrice1, t_current);
    clearDemand_medium_EH3 = x(1);
%     clearDemand_medium_grid = Grid1.getClearDemand(priceArray(t_current), t_current);
    clearDemand_medium_grid = Grid1.handlePrice(priceArray(t_current), t_current);
    clearDemand_mediumPrice = [clearDemand_medium_grid; clearDemand_medium_EH1; clearDemand_medium_EH2; clearDemand_medium_EH3]; %����Ϊ��������Ϊ��
    
    iterationNumber = iterationNumber + 1;
    
    if sum(clearDemand_mediumPrice) * sum(clearDemand_minPrice) <= 0 % ˵���������ǰ�������
        distance = price_medium - price_min;
        if distance>ee
            % price_max = price_medium;
            [clearPrice, clearDemand] = iterativeClear(price_min, price_medium, clearDemand_minPrice, clearDemand_mediumPrice, ee, priceArray, gasPrice1, gasPrice3, t_current);
        else
            % ����һ���������ַ��Ľ�������ǲ��ܱ�֤����ƽ��
            % clearPrice = (price_min + price_medium)/2; % ֹͣ����
            
            % ���������������ԣ������۸�ͳ��幦��
            if sum(clearDemand_minPrice) == sum(clearDemand_mediumPrice)
                clearPrice = (price_min + price_medium)/2;
            else
                slope = (sum(clearDemand_minPrice) - sum(clearDemand_mediumPrice)) / (price_min - price_medium);
                clearPrice = price_min + (0 - sum(clearDemand_minPrice)) / slope;
            end
            
            if clearPrice < minMarketPrice || clearPrice > maxMarketPrice
                error('�����۳�������Χ')
            end
            
            clearDemand = zeros(length(clearDemand_minPrice) ,1);
            for i=1:length(clearDemand_minPrice)
                slope = (clearDemand_minPrice(i) - clearDemand_mediumPrice(i)) / (price_min - price_medium);
                clearDemand(i) = clearDemand_minPrice(i) + (clearPrice - price_min) * slope;
            end
            
        end
    else % ˵��������ں�������
        distance = price_max - price_medium;
        if distance>ee
            % price_min = price_medium;
            [clearPrice, clearDemand] = iterativeClear(price_medium, price_max, clearDemand_mediumPrice, clearDemand_maxPrice, ee, priceArray, gasPrice1, gasPrice3, t_current);
        else
            % ����һ���������ַ��Ľ�������ǲ��ܱ�֤����ƽ��
            % clearPrice = (price_medium + price_max)/2; % ֹͣ����            
            
            % ���������������ԣ������۸�ͳ��幦��
            if sum(clearDemand_mediumPrice) == sum(clearDemand_maxPrice)
                clearPrice = (price_medium + price_max)/2;
            else
                slope = (sum(clearDemand_mediumPrice) - sum(clearDemand_maxPrice)) / (price_medium - price_max);
                clearPrice = price_medium + (0 - sum(clearDemand_mediumPrice)) / slope;
            end
            
            if clearPrice < minMarketPrice || clearPrice > maxMarketPrice
                error('�����۳�������Χ')
            end
            
            clearDemand = zeros(length(clearDemand_mediumPrice) ,1);
            for i=1:length(clearDemand_mediumPrice)
                slope = (clearDemand_mediumPrice(i) - clearDemand_maxPrice(i)) / (price_medium - price_max);
                clearDemand(i) = clearDemand_mediumPrice(i) + (clearPrice - price_medium) * slope;
            end
            
        end
    end
   
end