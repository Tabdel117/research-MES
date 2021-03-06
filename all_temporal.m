%全时段的优化问题，与single_temporal比较
%次梯度法求解
% 用于日前预测或日内作为对比
global EH1 EH2 EH3 elePrice period couldExport minimumPower
delta_lambda_max = 1e-4;
maxIteration = 3000; %最大迭代次数
iterativeStep = 1;
ee = 0.001;
if couldExport == 1
    minimumPower = eleLimit_total(2);
else
    minimumPower = 0;
end
if isDA
    EH1.predict(0);
    EH2.predict(0);
    EH3.predict(0);
    priceArray_record(:,1) = elePrice;
    prePrice = elePrice;
    temporal = 1;
    st = 1;
else
    temporal =  24* period;
    st = time;
end
for pt = st : temporal
    if isDA == 0
        EH1.predict(pt);
        EH2.predict(pt);
        EH3.predict(pt);
    end
    number = 1; k = 1;
    lamda_old = -10 * ones(24 * period - pt + 1, 1);
    lamda_new = zeros(24 * period - pt + 1, 1); %取初始值：对预测电价没有偏差
    lamda_record = zeros(24 * period - pt + 1 , maxIteration + 1);
    lamda_record(: , number) = lamda_new;
    max_balance=zeros (1 , maxIteration + 1);
    %如果前后两次价格的偏差太大，则返回第1步
    while number <= 2 || max(abs(balanceDemand)) > 100
        % max(abs(lamda_new - lamda_old)) > ee || %| max(abs(clearDemand_new - clearDemand_old)) > 1e-4 %1e-6, 不能直接取0
        % 后一个条件是因为即使lamda收敛后，供需也不平衡，所以需要取一正一负两个点，来求零点
        % && || 的前一个为否，则后一个就不计算了
        % 要求至少迭代两次（number=1，2）
        
        %             if number > maxIteration
        %                 error('超出最大迭代次数');
        %             end
        if number > 1% number=2时才记录第一次
            clearDemand_old = clearDemand_new;
        end
        
        
        [x1,f1,~,~,~] = EH1.handlePrice(priceArray, gasPrice1, pt);
        clearDemand_EH1_new = x1(1: 24 * period - pt + 1);
        [x2,f2,~,~,~] = EH2.handlePrice(priceArray, gasPrice1, pt);
        clearDemand_EH2_new = x2(1: 24 * period - pt + 1);
        [x3,f3,~,~,~] = EH3.handlePrice(priceArray, gasPrice1, pt);
        clearDemand_EH3_new = x3(1: 24 * period - pt + 1);

        clearDemand_grid_new=zeros(24 * period - pt + 1 ,1);
        for i = 1: 24 * period - pt + 1
            if lamda_new(i) == 0 
                clearDemand_grid_new(i) = clearDemand_EH1_new(i) + clearDemand_EH2_new(i) + clearDemand_EH3_new(i) - EH_res_total(pt + i - 1);
                if clearDemand_grid_new(i) > eleLimit_total(1)
                    clearDemand_grid_new(i) = eleLimit_total(1);
                end
                if clearDemand_grid_new(i) < minimumPower
                    clearDemand_grid_new(i) = minimumPower;
                end
            elseif lamda_new(i) > 0
                clearDemand_grid_new(i) = eleLimit_total(1);
            else
                clearDemand_grid_new(i) = minimumPower;
            end
        end
 
        clearDemand_new = [-clearDemand_grid_new, clearDemand_EH1_new , clearDemand_EH2_new , clearDemand_EH3_new, - EH_res_total] ;
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
        %当前价格下的出力
        priceArray(pt : 24* period) = prePrice(pt : 24* period) + lamda_new;
        priceArray(priceArray>maxMarketPrice) =maxMarketPrice;
        priceArray(priceArray<minMarketPrice) =minMarketPrice;
    end
    
    
    % 根据得到的出清价格以及出清功率，EH进行一次优化，以更新自身状态
    if isDA == 0
        gridClearDemand(pt) = clearDemand_new(1,1);
        EH1.conditionHandlePrice_2(priceArray, gasPrice1, pt, clearDemand_new(:,2));
        EH2.conditionHandlePrice_2(priceArray, gasPrice1, pt, clearDemand_new(:,3));
        EH3.conditionHandlePrice_2(priceArray, gasPrice3, pt, clearDemand_new(:,4));
    end
    prePrice = priceArray;
end
% 日前优化的结果
if isDA
    priceArray_record(:,2) = priceArray;
else
    priceArray_record(:,3) = priceArray;
end
isCentral =0;
