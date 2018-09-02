    % ����ʽ�Ż�������

    EH1_Le_final = [210.301397758191;230.823676166166;214.108947989989;209.606808045361;196.528718871749;200.527716727458;171.826840261211;215.434468674951;351.421093302298;385.510286550270;408.046130985166;351.424185163977;253.314128307174;312.468981661435;382.019387090551;393.974804830332;395.631704530858;295.363396526140;294.358987619370;322.389351836491;303.152990891480;218.531577322458;250.288679710111;228.503601958543;];
    EH1_Lh_final = [575.110768433430;566.343928391538;565.561753170696;558.747459140154;559.049250924452;577.664251332143;573.490976377669;576.759582520053;594.808837746766;572.100185998495;584.937565437560;613.915598291639;591.218527787315;605.178488236794;616.083673626242;630.747911468568;643.183145122572;653.889166802478;643.201515608216;606.371220233789;632.736788941651;644.504932902377;600.004163684607;575.254226710805;];

    EH2_Le_final = [410.408897758191;465.816176166166;452.198947989989;420.799308045361;403.801218871749;369.110216727458;332.471840261211;328.449468674951;451.846093302298;567.285286550270;578.236130985166;550.179185163977;440.811628307173;505.541481661435;530.489387090552;491.007304830332;494.156704530858;568.975896526140;543.006487619370;559.366851836491;499.457990891480;512.581577322458;494.963679710112;398.756101958543;];
    EH2_Lh_final = [576.424768433430;587.953928391538;602.429753170696;595.615959140154;588.405250924452;562.561751332143;567.056976377669;601.085082520053;639.772837746766;645.834185998495;635.211065437560;629.742598291639;618.848027787315;641.226488236794;624.429173626242;643.937911468568;627.137145122572;620.676666802478;612.978515608216;597.720720233789;595.010788941651;620.424432902377;583.820163684607;582.032226710805;];

    [EH1_f, EH1_ub, EH1_lb, EH1_Aeq, EH1_beq, EH1_A, EH1_b, EH1_A_eleLimit_total] = OptMatrix(eleLimit1, gasLimit1, EH1_Le_final, EH1_Lh_final, CHP1_para, Boiler1_para, ES1_para, HS1_para, elePrice, gasPrice);
    % [x,fval,exitflag,output,lambda] = linprog(EH1_f, EH1_A, EH1_b, EH1_Aeq, EH1_beq, EH1_lb, EH1_ub) % ��һ����ʽ�Ż�����
    [EH2_f, EH2_ub, EH2_lb, EH2_Aeq, EH2_beq, EH2_A, EH2_b, EH2_A_eleLimit_total] = OptMatrix(eleLimit2, gasLimit2, EH2_Le_final, EH2_Lh_final, CHP2_para, Boiler2_para, ES2_para, HS2_para, elePrice, gasPrice);
    % [x,fval,exitflag,output,lambda] = linprog(EH2_f, EH2_A, EH2_b, EH2_Aeq, EH2_beq, EH2_lb, EH2_ub) % ��һ����ʽ�Ż�����

    time = 24; %��ʱ���
    number = 3;
    var = time * 7;
    totalVar = time * 7 * number; %�ܱ�����
    %��1,2,3��time�ǹ�������CHP����������¯����������4-7��time�Ǵ��硢���ȵķš��书��

    f = [EH1_f; EH2_f];
    ub = [EH1_ub; EH2_ub];
    lb = [EH1_lb; EH2_lb];
    Aeq = [EH1_Aeq, zeros(2,var); zeros(2,var), EH2_Aeq];
    beq = [EH1_beq; EH2_beq];

    % ���Ӷ���Լ��
    % A = [EH1_A, zeros(var,var); zeros(var,var), EH2_A];
    % b = [EH1_b; EH2_b];

    % ��Ҫ��������һ�����������ϡ�����Լ��
    A1 = [EH1_A, zeros(var,var); zeros(var,var)  EH2_A];
    b1 = [EH1_b; EH2_b];
    A2 = [EH1_A_eleLimit_total, EH2_A_eleLimit_total];
    b2 = ones(time, 1) .* eleLimit_total(1);
    b2_sale = ones(time, 1) .* eleLimit_total(2);
    A = [A1; A2; -A2];
    b = [b1; b2; -b2_sale];

    [x,fval,exitflag,output,lambda] = linprog(f,A,b,Aeq,beq,lb,ub)

    x(1:24) + x(24*7+1:24*8)

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
