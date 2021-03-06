% 集中式滚动优化
% clc;clear;
global period caseType
caseType = 2;
isCollaborate = 2;
para_init;
temporal = 24* period;
isCentral = 1;
for pt = 1: temporal
    EH1.predict(pt);
    EH2.predict(pt);
    EH3.predict(pt);
    [EH1_f, EH1_ub, EH1_lb, EH1_Aeq, EH1_beq, EH1_A, EH1_b, EH1_A_eleLimit_total ] = EH1.OptMatrix(gasPrice1, pt);
    [EH2_f, EH2_ub, EH2_lb, EH2_Aeq, EH2_beq, EH2_A, EH2_b, EH2_A_eleLimit_total ] = EH2.OptMatrix(gasPrice1, pt);
    [EH3_f, EH3_ub, EH3_lb, EH3_Aeq, EH3_beq, EH3_A, EH3_b, EH3_A_eleLimit_total ] = EH3.OptMatrix(gasPrice1, pt);
    time = 24 * period - pt + 1; %总时间段
    number = IESNUMBER;
    var = time * 10;
    totalVar = time * 10 * number; %总变量数
    
    f = [EH1_f; EH2_f; EH3_f];
    ub = [EH1_ub; EH2_ub; EH3_ub];
    lb = [EH1_lb; EH2_lb; EH3_lb];
    
    Aeq = blkdiag(EH1_Aeq, EH2_Aeq, EH3_Aeq);
    beq = [EH1_beq; EH2_beq; EH3_beq];
 
    A1 = blkdiag(EH1_A, EH2_A, EH3_A);
    b1 = [EH1_b; EH2_b; EH3_b];
    
    % 需要额外增加一个购电量的上、下限约束
    A2 = [EH1_A_eleLimit_total, EH2_A_eleLimit_total, EH3_A_eleLimit_total];
    b2 = ones(time, 1) .* eleLimit_total(1) + EH_res_total(pt : end);
    b2_sale = ones(time, 1) .* eleLimit_total(2) + EH_res_total(pt : end);
   
    A = [A1; A2; -A2];
    b = [b1; b2; -b2_sale];

    [x,fval,exitflag,output,lambda] = linprog(f,A,b,Aeq,beq,lb,ub);
    
    for IES_no = 1 : IESNUMBER
        eval(['EH',num2str(IES_no),'.update_central(x, pt, IES_no);']);
    end
end
[result_Ele(:,1), result_CHP_G(:,1), result_Boiler_G(:,1), result_eBoiler_E(:,1), result_ES_discharge(:,1), result_ES_charge(:,1), result_HS_discharge(:,1), result_HS_charge(:,1), result_ES_SOC(:,1), result_HS_SOC(:,1), result_EH_Le(:, 1), result_EH_Lh(:,1), result_EH_solarP(:,1), result_EH_windP(:,1), result_EH_Edr(:,1), result_EH_Hdr(:,1)] = EH1.getResult;
[result_Ele(:,2), result_CHP_G(:,2), result_Boiler_G(:,2), result_eBoiler_E(:,2), result_ES_discharge(:,2), result_ES_charge(:,2), result_HS_discharge(:,2), result_HS_charge(:,2), result_ES_SOC(:,2), result_HS_SOC(:,2), result_EH_Le(:, 2), result_EH_Lh(:,2), result_EH_solarP(:,2), result_EH_windP(:,2), result_EH_Edr(:,2), result_EH_Hdr(:,2)] = EH2.getResult;
[result_Ele(:,3), result_CHP_G(:,3), result_Boiler_G(:,3), result_eBoiler_E(:,3), result_ES_discharge(:,3), result_ES_charge(:,3), result_HS_discharge(:,3), result_HS_charge(:,3), result_ES_SOC(:,3), result_HS_SOC(:,3), result_EH_Le(:, 3), result_EH_Lh(:,3), result_EH_solarP(:,3), result_EH_windP(:,3), result_EH_Edr(:,3), result_EH_Hdr(:,3)] = EH3.getResult;

save('data/central.mat');