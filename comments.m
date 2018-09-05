
    % ����ʽ�Ż������� 24*period ��
    %{
    % ��ʼSOC
    result_ES_SOC(1,1) = ES1_para(4);
    result_ES_SOC(1,2) = ES2_para(4);
    result_ES_SOC(1,3) = ES3_para(4);

    result_HS_SOC(1,1) = HS1_para(4);
    result_HS_SOC(1,2) = HS2_para(4);
    result_HS_SOC(1,3) = HS3_para(4);

    for t_current = 1:24*period
        % ����Ԥ��
        [EH1_Le, EH1_Lh, EH1_solarP, EH1_windP] = predict(EH1_Le, EH1_Lh, EH1_solarP, EH1_windP, t_current, dev_L, dev_PV, dev_WT, EH1_solarP_rate, EH1_windP_rate);
        [EH2_Le, EH2_Lh, EH2_solarP, EH2_windP] = predict(EH2_Le, EH2_Lh, EH2_solarP, EH2_windP, t_current, dev_L, dev_PV, dev_WT, EH2_solarP_rate, EH2_windP_rate);
        [EH3_Le, EH3_Lh, EH3_solarP, EH3_windP] = predict(EH3_Le, EH3_Lh, EH3_solarP, EH3_windP, t_current, dev_L, dev_PV, dev_WT, EH3_solarP_rate, EH3_windP_rate);
        % ���µ��SOC
        ES1_para(4) = result_ES_SOC(t_current, 1);
        ES2_para(4) = result_ES_SOC(t_current, 2);
        ES3_para(4) = result_ES_SOC(t_current, 3);

        HS1_para(4) = result_HS_SOC(t_current, 1);
        HS2_para(4) = result_HS_SOC(t_current, 2);
        HS3_para(4) = result_HS_SOC(t_current, 3);

        [EH1_f, EH1_ub, EH1_lb, EH1_A, EH1_b, EH1_A_eleLimit_total] = OptMatrix_rolling_20171010(eleLimit1, gasLimit1, EH1_Le, EH1_Lh, CHP1_para, Boiler1_para, ES1_para, HS1_para, gasPrice1, EH1_windP, EH1_solarP, t_current);
        [EH2_f, EH2_ub, EH2_lb, EH2_A, EH2_b, EH2_A_eleLimit_total] = OptMatrix_rolling_20171010(eleLimit2, gasLimit2, EH2_Le, EH2_Lh, CHP2_para, Boiler2_para, ES2_para, HS2_para, gasPrice1, EH2_windP, EH2_solarP, t_current);
        [EH3_f, EH3_ub, EH3_lb, EH3_A, EH3_b, EH3_A_eleLimit_total] = OptMatrix_rolling_20171010(eleLimit3, gasLimit3, EH3_Le, EH3_Lh, CHP3_para, Boiler3_para, ES3_para, HS3_para, gasPrice3, EH3_windP, EH3_solarP, t_current);


        time = 24*period - t_current + 1; %��ʱ���
        var = time * 7;
        %��1,2,3��time�ǹ�������CHP����������¯����������4-7��time�Ǵ��硢���ȵķš��书��

        f = [EH1_f; EH2_f; EH3_f];
        ub = [EH1_ub; EH2_ub; EH3_ub];
        lb = [EH1_lb; EH2_lb; EH3_lb];

        % ��ǰ�汾û�е�ʽԼ���ˣ����ǲ���ʽԼ��
        A1 = [EH1_A, zeros(var+2,var), zeros(var+2,var);
              zeros(var+2,var), EH2_A, zeros(var+2,var);
              zeros(var+2,var), zeros(var+2,var), EH3_A;];
        b1 = [EH1_b; EH2_b; EH3_b];

        % �����Ӷ���Լ��
    %     A = A1;
    %     b = b1;

        % ��Ҫ��������һ���������ߵĹ��������ϡ�����Լ��
        A2 = [EH1_A_eleLimit_total, EH2_A_eleLimit_total, EH3_A_eleLimit_total];
        b2 = ones(time, 1) .* eleLimit_total(1);
        b2_sale = ones(time, 1) .* eleLimit_total(2);
        A = [A1; A2; -A2];
        b = [b1; b2; -b2_sale];

        [x,fval,exitflag,output,lambda] = linprog(f,A,b,[],[],lb,ub);
        if exitflag~=1
            error(['����ʽ�Ż�ʧ�ܣ�ʱ����',num2str(t_current)])
        end

        %�������ߵĹ�����Լ���Ƿ�����
        % x(1:24) + x(24*7+1:24*8)

        %��¼���
        for i=1 : IESnumber
            % ִֻ�е�ǰ���ڵĽ��
            result_Ele(t_current, i) = x(1 + var*(i-1), 1);
            result_CHP_G(t_current, i) = x(time+1 + var*(i-1), 1);
            result_Boiler_G(t_current, i) = x(time*2+1 + var*(i-1), 1);
            result_ES_discharge(t_current, i) = x(time*3+1 + var*(i-1), 1);
            result_ES_charge(t_current, i) = x(time*4+1 + var*(i-1), 1);
            result_HS_discharge(t_current, i) = x(time*5+1 + var*(i-1), 1);
            result_HS_charge(t_current, i) = x(time*6+1 + var*(i-1), 1);
        end
        %���´���״̬
        result_ES_SOC(t_current+1, 1) = result_ES_SOC(t_current, 1) - result_ES_discharge(t_current, 1) / ES1_para(7) / ES1_para(1) + result_ES_charge(t_current, 1) * ES1_para(7) / ES1_para(1);
        result_ES_SOC(t_current+1, 2) = result_ES_SOC(t_current, 2) - result_ES_discharge(t_current, 2) / ES2_para(7) / ES2_para(1) + result_ES_charge(t_current, 2) * ES2_para(7) / ES2_para(1);
        result_ES_SOC(t_current+1, 3) = result_ES_SOC(t_current, 3) - result_ES_discharge(t_current, 3) / ES3_para(7) / ES3_para(1) + result_ES_charge(t_current, 3) * ES3_para(7) / ES3_para(1);

        result_HS_SOC(t_current+1, 1) = result_HS_SOC(t_current, 1) - result_HS_discharge(t_current, 1) / HS1_para(7) / HS1_para(1) + result_HS_charge(t_current, 1) * HS1_para(7) / HS1_para(1);
        result_HS_SOC(t_current+1, 2) = result_HS_SOC(t_current, 2) - result_HS_discharge(t_current, 2) / HS2_para(7) / HS2_para(1) + result_HS_charge(t_current, 2) * HS2_para(7) / HS2_para(1);
        result_HS_SOC(t_current+1, 3) = result_HS_SOC(t_current, 3) - result_HS_discharge(t_current, 3) / HS3_para(7) / HS3_para(1) + result_HS_charge(t_current, 3) * HS3_para(7) / HS3_para(1);
    end
    % ����
    gridClearDemand = - sum(result_Ele,2); %1��ʾ������ͣ�2��ʾ�������
    %}

    %���γ���
    %{
    priceArray = elePrice; %����ʷ���ݵõ�����ǰԤ����
    priceArray_record = zeros(24*period,2); %��¼��ǰ�����ڵĳ���۸�

    % off_grid = 0; % 0��ʾ�������У�1��ʾIES1����
    t_realtime = zeros(24*period,3); %��¼ÿ�������Ż������ʱ��

    for t_current = 1:24*period
        disp(['t_current is ',num2str(t_current)]);

        if t_current == 1 %�������ǰ�Ż�
            tic
            EH1.predict(0);
            EH2.predict(0);
            EH3.predict(0);
            for pt = t_current : 1 : 24*period
                %Ͷ��
                gridDemand = Grid1.zGenerate(elePrice(pt)); % �ڵ�ǰ�Ż������ڲ���
                EH1Demand = EH1.curveGenerate(priceArray, gasPrice1, pt);
                EH2Demand = EH2.curveGenerate(priceArray, gasPrice1, pt);
                EH3Demand = EH3.curveGenerate(priceArray, gasPrice3, pt);
                %�ۺ�
                demand_sum = gridDemand + EH1Demand + EH2Demand + EH3Demand;
                %����
                priceArray(pt) = clearing(demand_sum, 0); %�г�����õ�����۸񣬲�����Ԥ��������
                %��Ӧ����۸�
                Grid1.getClearDemand(priceArray(pt), pt);
                EH1.conditionHandlePrice(priceArray, gasPrice1, pt); %EH�յ�����۸񣬱������Ż�һ�Σ���������״̬
                EH2.conditionHandlePrice(priceArray, gasPrice1, pt);
                EH3.conditionHandlePrice(priceArray, gasPrice3, pt);
            end

            priceArray_record(:,1) = priceArray; %��¼��ǰ����۸�
            t_dayahead = toc; %��¼��ǰ�Ż��������ʱ�䣨���ʱ�䲻׼ȷ����Ϊ3��IESʵ����Ӧ���м��㣬���Ǵ��У�

            % ��ǰ�Ż��Ľ��
            gridClearDemand = Grid1.getResult;
            [result_Ele(:,1), result_CHP_G(:,1), result_Boiler_G(:,1), result_ES_discharge(:,1), result_ES_charge(:,1), result_HS_discharge(:,1), result_HS_charge(:,1), result_ES_SOC(:,1), result_HS_SOC(:,1), EH1_Le, EH1_Lh, EH1_solarP, EH1_windP] = EH1.getResult;
            [result_Ele(:,2), result_CHP_G(:,2), result_Boiler_G(:,2), result_ES_discharge(:,2), result_ES_charge(:,2), result_HS_discharge(:,2), result_HS_charge(:,2), result_ES_SOC(:,2), result_HS_SOC(:,2), EH2_Le, EH2_Lh, EH2_solarP, EH2_windP] = EH2.getResult;
            [result_Ele(:,3), result_CHP_G(:,3), result_Boiler_G(:,3), result_ES_discharge(:,3), result_ES_charge(:,3), result_HS_discharge(:,3), result_HS_charge(:,3), result_ES_SOC(:,3), result_HS_SOC(:,3), EH3_Le, EH3_Lh, EH3_solarP, EH3_windP] = EH3.getResult;
        end



        % �����Ż�����Ϊ�������С���������
    %     if off_grid == 0 % ��������
            EH1.predict(t_current);
            EH2.predict(t_current);
            EH3.predict(t_current);
            %Ͷ��
            gridDemand = Grid1.zGenerate(elePrice(t_current)); % �ڵ�ǰ�Ż������ڲ���
            tic
            EH1Demand = EH1.curveGenerate(priceArray, gasPrice1, t_current);
            t_realtime(t_current,1) = toc;
            tic
            EH2Demand = EH2.curveGenerate(priceArray, gasPrice1, t_current);
            t_realtime(t_current,2) = toc;
            tic
            EH3Demand = EH3.curveGenerate(priceArray, gasPrice3, t_current);
            t_realtime(t_current,3) = toc;
            %�ۺ�
            demand_sum = gridDemand + EH1Demand + EH2Demand + EH3Demand;
            %����
            priceArray(t_current) = clearing(demand_sum, 0); %����Ϊʵ�ʵ��
            %��Ӧ����۸�
            Grid1.getClearDemand(priceArray(t_current), t_current);
            EH1.conditionHandlePrice(priceArray, gasPrice1, t_current);
            EH2.conditionHandlePrice(priceArray, gasPrice1, t_current);
            EH3.conditionHandlePrice(priceArray, gasPrice3, t_current);

    %     else % IES1����
    %     end
    end
    priceArray_record(:,2) = priceArray; %��¼���ڳ���۸�

    % �����Ż��Ľ��
    gridClearDemand = Grid1.getResult;
    [result_Ele(:,1), result_CHP_G(:,1), result_Boiler_G(:,1), result_ES_discharge(:,1), result_ES_charge(:,1), result_HS_discharge(:,1), result_HS_charge(:,1), result_ES_SOC(:,1), result_HS_SOC(:,1), EH1_Le, EH1_Lh, EH1_solarP, EH1_windP] = EH1.getResult;
    [result_Ele(:,2), result_CHP_G(:,2), result_Boiler_G(:,2), result_ES_discharge(:,2), result_ES_charge(:,2), result_HS_discharge(:,2), result_HS_charge(:,2), result_ES_SOC(:,2), result_HS_SOC(:,2), EH2_Le, EH2_Lh, EH2_solarP, EH2_windP] = EH2.getResult;
    [result_Ele(:,3), result_CHP_G(:,3), result_Boiler_G(:,3), result_ES_discharge(:,3), result_ES_charge(:,3), result_HS_discharge(:,3), result_HS_charge(:,3), result_ES_SOC(:,3), result_HS_SOC(:,3), EH3_Le, EH3_Lh, EH3_solarP, EH3_windP] = EH3.getResult;
    % test���ݶ�����handle������

    %}
