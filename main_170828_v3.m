        global off_grid EH1 EH2 EH3
        para_init;
        
        off_grid = 0; % 0表示正常运行，1表示IES1离网
        clear eleLimit1  gasLimit1  EH1_Le  EH1_Lh  EH1_solarP  EH1_windP  CHP1_para  Boiler1_para  ES1_para  HS1_para EH1_Le_jing EH1_solarP_rate EH1_windP_rate EH1_Le_drP_rate EH1_Le_drP_total EH1_Lh_drP_rate EH1_Lh_drP_total
        clear eleLimit2  gasLimit2  EH2_Le  EH2_Lh  EH2_solarP  EH2_windP  CHP2_para  Boiler2_para  ES2_para  HS2_para EH2_Le_jing EH2_solarP_rate EH2_windP_rate EH2_Le_drP_rate EH2_Le_drP_total EH2_Lh_drP_rate EH2_Lh_drP_total
        clear eleLimit3  gasLimit3  EH3_Le  EH3_Lh  EH3_solarP  EH3_windP  CHP3_para  Boiler3_para  ES3_para  HS3_para EH3_Le_jing EH3_solarP_rate EH3_windP_rate EH3_Le_drP_rate EH3_Le_drP_total EH3_Lh_drP_rate EH3_Lh_drP_total
        clear Le_max Lh_max dev_L  dev_PV  dev_WT  singleLimit solar_max wind_max

        %日前优化
        priceArray = elePrice;

        %全时段一次性求解（次梯度法）
%         time = 1; 
%         all_temporal;
        priceArray_record = zeros( 24 * period , 3);%第一列为日前预测，第二列为实际
        priceArray_record(:,1) = elePrice;
        %单时段求解
        global isGrad isDA isHeatExchange %1-次梯度法 0-二分法
        isDA = 1;
        isGrad = 1;
        isHeatExchange = 1;
        single_temporal;
        
        %日内优化
        %全时段滚动求解
%         for time = 1 : 24 * period
%             all_temporal;
%         end
        %单时段滚动求解
        priceArray_record(:,2) = priceArray;
        isDA = 0;
        single_temporal;
        priceArray_record(:,3) = priceArray;
        
%         all_temporal;
        isCentral = 0;
        main_handle