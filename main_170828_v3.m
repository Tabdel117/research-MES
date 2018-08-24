clear
clc
close all

% ������
% 20180309 v3 ���¸Ļ�1Сʱ�������ٽ�һ���Ӵ�Ԥ�������ı�׼��ֿ������ݸ�������ʵ

global period
period = 60 / 15; % ��ĸ��ʱ����

if period == 1
    load '../tmp1.mat' % ��177�ҹ�˾
    load '../tmp2.mat'
    load '../renewableName.mat'
    load '../solarValue.mat'
    load '../windValue.mat'
elseif period == 4 % ֻ��174�ҹ�˾��
    load data_loadValue_15min.mat
    load data_loadName_15min.mat
    load renewableName_15min.mat
    load solarValue_15min.mat
    load windValue_15min.mat
end

% IES1 ��ҵ�������ȸ��ɶ��Ƚ�ƽ�������Ըߣ��ȴ��ڵ磬������
EH1_Le = loadValue(:,94) .* 4; % ��Ӧ134�Ź�˾ %/10
EH1_Lh = loadValue(:,143) .* 8; % ��Ӧ223�Ź�˾ %/5
EH1_solarP = solarValue(:,3) ./1000 .* 50; %*1
EH1_windP = windValue(:,3)./1000 .* 30; %*2
EH1_solarP_rate = 5000;
EH1_windP_rate = 1500;
EH1_solarP(EH1_solarP>EH1_solarP_rate) = EH1_solarP_rate;
EH1_windP(EH1_windP>EH1_windP_rate) = EH1_windP_rate;

% IES2 �����������ȸ��ɰ���ߣ����Ϻܵͣ��ȵ��൱�������շ壬������
EH2_Le = loadValue(:,88) ./ 2.25; % ��Ӧ127�Ź�˾ %/8
EH2_Lh = loadValue(:,91) ./ 2.25*1.4 ; % ��Ӧ130�Ź�˾ %/6
EH2_solarP = solarValue(:,1) ./1000 .* 2; %*1
EH2_windP = windValue(:,1)./1000 .* 15; %*3
EH2_solarP_rate = 250;
EH2_windP_rate = 500;
EH2_solarP(EH2_solarP>EH2_solarP_rate) = EH2_solarP_rate;
EH2_windP(EH2_windP>EH2_windP_rate) = EH2_windP_rate;

% IES3 סլ�������ȸ��ɰ���ͣ����ϸߣ��ȵ��൱����Դ�ḻ��
if period == 1
    EH3_Le = loadValue(:,172) .* 3; % ��Ӧ273�Ź�˾ %/5
    EH3_Lh = loadValue(:,174) .* 2.5; % ��Ӧ275�Ź�˾ %/6
elseif period == 4
    EH3_Le = loadValue(:,169) ./ 5; % ��Ӧ273�Ź�˾
    EH3_Lh = loadValue(:,171) ./ 6; % ��Ӧ275�Ź�˾
end
EH3_solarP = solarValue(:,27) ./1000 .* 9; %*2
EH3_windP = windValue(:,27)./1000 .* 6; %*6
EH3_solarP_rate = 1000;
EH3_windP_rate = 300;
EH3_solarP(EH3_solarP>EH3_solarP_rate) = EH3_solarP_rate;
EH3_windP(EH3_windP>EH3_windP_rate) = EH3_windP_rate;


%{
% ��Ҫ��ͼ���жϾ����ɣ�����������
EH1_Le_jing = EH1_Le-EH1_solarP-EH1_windP;
EH2_Le_jing = EH2_Le-EH2_solarP-EH2_windP;
EH3_Le_jing = EH3_Le-EH3_solarP-EH3_windP;
figure
hold on
plot(EH1_Le)
plot(EH1_Lh,'r')
plot(EH1_Le_jing,'k')
figure
hold on
plot(EH2_Le)
plot(EH2_Lh,'r')
plot(EH2_Le_jing,'k')
figure
hold on
plot(EH3_Le)
plot(EH3_Lh,'r')
plot(EH3_Le_jing,'k')
%}
clear loadName loadValue renewableName solarValue windValue


global minMarketPrice maxMarketPrice priceNumbers step

minMarketPrice = 0;
maxMarketPrice = 1.5;
step = 0.1; %ֻ���ڵ��γ����ʱ���õõ�
priceNumbers = (maxMarketPrice - minMarketPrice)/step + 1; %һ��Ͷ�������ĳ��ȣ������������� + 1 = ����
marketInfo = [minMarketPrice; maxMarketPrice; step; priceNumbers];

% ��������
global elePrice
elePrice = ones(24*period,1) .* 0.6268;
elePrice(0+1 : 8*period) = ones(8*period,1) .* 0.3089;
elePrice(8*period+1 : 12*period) = ones(4*period,1) .* 1.0447;
elePrice(17*period+1 : 21*period) = ones(4*period,1) .* 1.0447;

singleLimit = [16000, 800, 2500]; %[16000, 800, 2500] [0 0 0] [16000, 800, 2500]./19300.*16000
totalLimit = 16000; 
reverseRate = 4;
% ֧��: �¼����ϼ����硢�۵�Լ�����ټ�һ��������5-7%
eleLimit1 = [singleLimit(1), -singleLimit(1)/reverseRate, 0.94];
eleLimit2 = [singleLimit(2), -singleLimit(2)/reverseRate, 0.94];
eleLimit3 = [singleLimit(3), -singleLimit(3)/reverseRate, 0.94];
eleLimit_total = [totalLimit, -totalLimit/reverseRate]; % ����

% ��������
% global gasPrice1 gasPrice3  % ����Ҫȫ�ֱ�����
gasPrice1 = 0.334; % 3.3Ԫÿ�����׻�����ֵ
gasPrice3 = 0.284; % 2.8Ԫÿ�����׻�����ֵ
gasLimit1 = 1e6; %��ʱ�����ǻ�����Ȼ��
gasLimit2 = 1e6;
gasLimit3 = 1e6;
% gasLimit_total = 150; %��ʱ�޷�����Ȼ������������Լ����ֻ��Ĭ���Ǹ�֧��Լ���ĺ�

%CHP�Ĳ���
CHP1_para = [0.35, 0.45, 30000, 0.4]; % CHP_GE_eff_in, CHP_GH_eff_in, CHP_Prate_in, CHP_Pmin_Rate_in
CHP2_para = [0.35, 0.45, 1500, 0.45];
CHP3_para = [0.35, 0.45, 5000, 0.45];

%��¯
Boiler1_para = [0.90; 1e5]; % Boiler_eff_in, Boiler_Prate_in
Boiler2_para = [0.90; 1e5];
Boiler3_para = [0.90; 1e5];

%�索�ܺ��ȴ���
% ES_totalC_in, ES_maxSOC_in, ES_minSOC_in, ES_currentSOC_in, ES_targetSOC_in, ES_chargeTime, ES_eff_in
% 0.096*200, 0.85, 0.15, 0.5, 0.5, 0.024*200, 0.9
ES1_para = [50000, 0.8, 0.2,      0.4, 0.4,   10, 0.9]; 
ES2_para = [3000, 0.85, 0.15,      0.4, 0.4,   10, 0.9]; 
ES3_para = [10000, 0.85, 0.15,    0.4, 0.4,   10, 0.9]; 
% HS_totalC_in, HS_maxSOC_in, HS_minSOC_in, HS_currentSOC_in, HS_targetSOC_in, HS_chargeTime, HS_eff_in
% 5*4, 0.85, 0.15, 0.5, 0.5, 1.5*4, 0.9
HS1_para = [6000, 0.9, 0.1, 0.5, 0.5, 5, 0.9];
HS2_para = [1000, 0.9, 0.1, 0.5, 0.5, 5, 0.9];
HS3_para = [6000, 0.9, 0.1, 0.5, 0.5, 5, 0.9]; 

% ���ɺͷ��Ԥ�����
dev_L = 3/100; %�ٷ��� 1
dev_PV = 10/100; %5
dev_WT = 15/100;
% seedNumber = 0;
% rand ���ɾ��ȷֲ���α����� �ֲ��ڣ�0~1��֮��
% randn ���ɱ�׼��̬�ֲ���α����� ����ֵΪ0����׼��Ϊ1�������Ե�ϵ���Ǳ�׼����Ƿ����
randn('seed', 10);

% ���ͷ����
% DG2 = DieselGenerator_171123(100, 0.001, 0.125, 0.3);


% ����ʽ�Ż�������
%{
EH1_Le_final = [210.301397758191;230.823676166166;214.108947989989;209.606808045361;196.528718871749;200.527716727458;171.826840261211;215.434468674951;351.421093302298;385.510286550270;408.046130985166;351.424185163977;253.314128307174;312.468981661435;382.019387090551;393.974804830332;395.631704530858;295.363396526140;294.358987619370;322.389351836491;303.152990891480;218.531577322458;250.288679710111;228.503601958543;];
EH1_Lh_final = [575.110768433430;566.343928391538;565.561753170696;558.747459140154;559.049250924452;577.664251332143;573.490976377669;576.759582520053;594.808837746766;572.100185998495;584.937565437560;613.915598291639;591.218527787315;605.178488236794;616.083673626242;630.747911468568;643.183145122572;653.889166802478;643.201515608216;606.371220233789;632.736788941651;644.504932902377;600.004163684607;575.254226710805;];

EH2_Le_final = [410.408897758191;465.816176166166;452.198947989989;420.799308045361;403.801218871749;369.110216727458;332.471840261211;328.449468674951;451.846093302298;567.285286550270;578.236130985166;550.179185163977;440.811628307173;505.541481661435;530.489387090552;491.007304830332;494.156704530858;568.975896526140;543.006487619370;559.366851836491;499.457990891480;512.581577322458;494.963679710112;398.756101958543;];
EH2_Lh_final = [576.424768433430;587.953928391538;602.429753170696;595.615959140154;588.405250924452;562.561751332143;567.056976377669;601.085082520053;639.772837746766;645.834185998495;635.211065437560;629.742598291639;618.848027787315;641.226488236794;624.429173626242;643.937911468568;627.137145122572;620.676666802478;612.978515608216;597.720720233789;595.010788941651;620.424432902377;583.820163684607;582.032226710805;];

[EH1_f, EH1_ub, EH1_lb, EH1_Aeq, EH1_beq, EH1_A, EH1_b, EH1_A_eleLimit_total] = OptMatrix(eleLimit1, gasLimit1, EH1_Le_final, EH1_Lh_final, CHP1_para, Boiler1_para, ES1_para, HS1_para, elePrice, gasPrice);
% [x,fval,exitflag,output,lambda] = linprog(EH1_f, EH1_A, EH1_b, EH1_Aeq, EH1_beq, EH1_lb, EH1_ub) % ��һ����ʽ�Ż�����
[EH2_f, EH2_ub, EH2_lb, EH2_Aeq, EH2_beq, EH2_A, EH2_b, EH2_A_eleLimit_total] = OptMatrix(eleLimit2, gasLimit2, EH2_Le_final, EH2_Lh_final, CHP2_para, Boiler2_para, ES2_para, HS2_para, elePrice, gasPrice);
% [x,fval,exitflag,output,lambda] = linprog(EH2_f, EH2_A, EH2_b, EH2_Aeq, EH2_beq, EH2_lb, EH2_ub) % ��һ����ʽ�Ż�����

time = 24; %��ʱ���
number = 2;
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
%}


IESnumber = 3; % IES����

% ���ڴ�������Ż����
result_ES_SOC = zeros(24*period+1,IESnumber);
result_HS_SOC = zeros(24*period+1,IESnumber);
result_Ele = zeros(24*period,IESnumber);
result_CHP_G = zeros(24*period,IESnumber);
result_Boiler_G = zeros(24*period,IESnumber);
result_ES_discharge = zeros(24*period,IESnumber);
result_ES_charge = zeros(24*period,IESnumber);
result_HS_discharge = zeros(24*period,IESnumber);
result_HS_charge = zeros(24*period,IESnumber);



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



%�ֲ�ʽ����
global Grid1 EH1 EH2 EH3
% ����
Grid1 = Grid_171118(eleLimit_total);
% EH������ʵ����
EH1 = EH_local_170828_v3(eleLimit1, gasLimit1, EH1_Le, EH1_Lh, EH1_solarP, EH1_windP, CHP1_para, Boiler1_para, ES1_para, HS1_para, dev_L, dev_PV, dev_WT, EH1_solarP_rate, EH1_windP_rate);
EH2 = EH_local_170828_v3(eleLimit2, gasLimit2, EH2_Le, EH2_Lh, EH2_solarP, EH2_windP, CHP2_para, Boiler2_para, ES2_para, HS2_para, dev_L, dev_PV, dev_WT, EH2_solarP_rate, EH2_windP_rate);
EH3 = EH_local_170828_v3(eleLimit3, gasLimit3, EH3_Le, EH3_Lh, EH3_solarP, EH3_windP, CHP3_para, Boiler3_para, ES3_para, HS3_para, dev_L, dev_PV, dev_WT, EH3_solarP_rate, EH3_windP_rate);


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




%20171117 �������壬���ַ�

priceArray = elePrice; %����ʷ���ݵõ�Ԥ���� %Ҳ�����ڵ����ļ۸����
priceArray_record = zeros(24*period,2); %һ����ǰ��һ��ʵʱ
ee = 0.01;

demand_sum = zeros(priceNumbers, 1);
gridClearDemand = zeros(24*period,1);
global iterationNumber
iterationTimes = zeros(24*period, 2); %��¼��������

global off_grid
off_grid = 0; % 0��ʾ�������У�1��ʾIES1����
t_realtime = zeros(24*period,3);
isDAsingle=0;
if isDAsingle==0
    subgrad_dayahead_180729;
end
%�ô��ݶȷ�����ǰ�Ż�����

for t_current = 1:24*period
    disp(['t_current is ',num2str(t_current)]);
    if isDAsingle==1
   
    if t_current == 1 %�������ǰ�Ż�
        tic
        % ���ɺͿ�������Դ��Ԥ��ֵû�б仯
%         EH1.predict(0);
%         EH2.predict(0);
%         EH3.predict(0);
        for pt = t_current : 1 : 24*period
            tic
%             Grid1.zGenerate(elePrice(pt)); % �ڵ�ǰ�Ż������ڲ���

            % ��ͼ۸�һ�㶼��������ڹ���
            priceArray(pt) = minMarketPrice;
            [x,~,~,~,~] = EH1.handlePrice(priceArray, gasPrice1, pt);
            clearDemand_minPrice_EH1 = x(1);
            [x,~,~,~,~] = EH2.handlePrice(priceArray, gasPrice1, pt);
            clearDemand_minPrice_EH2 = x(1);
            [x,~,~,~,~] = EH3.handlePrice(priceArray, gasPrice3, pt);
            clearDemand_minPrice_EH3 = x(1);   
            clearDemand_minPrice_grid = Grid1.handlePrice(priceArray(pt), pt);
            clearDemand_minPrice = [clearDemand_minPrice_grid; clearDemand_minPrice_EH1; clearDemand_minPrice_EH2; clearDemand_minPrice_EH3]; % ����Ϊ��������Ϊ��
            
            % ��߼۸�һ�㶼�ǹ�����������
            priceArray(pt) = maxMarketPrice;
            [x,~,~,~,~] = EH1.handlePrice(priceArray, gasPrice1, pt);
            clearDemand_maxPrice_EH1 = x(1);
            [x,~,~,~,~] = EH2.handlePrice(priceArray, gasPrice1, pt);
            clearDemand_maxPrice_EH2 = x(1);
            [x,~,~,~,~] = EH3.handlePrice(priceArray, gasPrice3, pt);
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
            EH3.conditionHandlePrice_2(priceArray, gasPrice3, pt, clearDemand(4));
            
        end
        
        priceArray_record(:,1) = priceArray;
        t_dayahead = toc; %���ʱ�䲻׼ȷ����Ϊ3��IESӦ���ǲ��м����
        
        % ��ǰ�Ż��Ľ��
        [result_Ele(:,1), result_CHP_G(:,1), result_Boiler_G(:,1), result_ES_discharge(:,1), result_ES_charge(:,1), result_HS_discharge(:,1), result_HS_charge(:,1), result_ES_SOC(:,1), result_HS_SOC(:,1), EH1_Le, EH1_Lh, EH1_solarP, EH1_windP] = EH1.getResult;
        [result_Ele(:,2), result_CHP_G(:,2), result_Boiler_G(:,2), result_ES_discharge(:,2), result_ES_charge(:,2), result_HS_discharge(:,2), result_HS_charge(:,2), result_ES_SOC(:,2), result_HS_SOC(:,2), EH2_Le, EH2_Lh, EH2_solarP, EH2_windP] = EH2.getResult;
        [result_Ele(:,3), result_CHP_G(:,3), result_Boiler_G(:,3), result_ES_discharge(:,3), result_ES_charge(:,3), result_HS_discharge(:,3), result_HS_charge(:,3), result_ES_SOC(:,3), result_HS_SOC(:,3), EH3_Le, EH3_Lh, ~, EH3_windP] = EH3.getResult;
    end
    clearDemand_grid_sin=sum(result_Ele');    
    priceArray_pre_sin=priceArray;
    end

    off_grid = 0;
    
    % �����Ż�����Ϊ�������к�EH1����   
    if t_current==11
       a=1; 
    end
    if off_grid == 0 % ��������
        EH1.predict(t_current);
        EH2.predict(t_current);
        EH3.predict(t_current);
        
%         Grid1.zGenerate(elePrice(t_current)); %�ڵ�ǰ�Ż������ڲ���
        
        % ��ͼ۸�һ�㶼��������ڹ���
        priceArray(t_current) = minMarketPrice;
        [x,~,~,~,~] = EH1.handlePrice(priceArray, gasPrice1, t_current);
        clearDemand_minPrice_EH1 = x(1);
        [x,~,~,~,~] = EH2.handlePrice(priceArray, gasPrice1, t_current);
        clearDemand_minPrice_EH2 = x(1);
        [x,~,~,~,~] = EH3.handlePrice(priceArray, gasPrice3, t_current);
        clearDemand_minPrice_EH3 = x(1);
        clearDemand_minPrice_grid = Grid1.handlePrice(priceArray(t_current), t_current);
        clearDemand_minPrice = [clearDemand_minPrice_grid; clearDemand_minPrice_EH1; clearDemand_minPrice_EH2; clearDemand_minPrice_EH3]; % ����Ϊ��������Ϊ��
            
        % ��߼۸�һ�㶼�ǹ�����������
        priceArray(t_current) = maxMarketPrice;
        [x,~,~,~,~] = EH1.handlePrice(priceArray, gasPrice1, t_current);
        clearDemand_maxPrice_EH1 = x(1);
        [x,~,~,~,~] = EH2.handlePrice(priceArray, gasPrice1, t_current);
        clearDemand_maxPrice_EH2 = x(1);
        [x,~,~,~,~] = EH3.handlePrice(priceArray, gasPrice3, t_current);
        clearDemand_maxPrice_EH3 = x(1);
        clearDemand_maxPrice_grid = Grid1.handlePrice(priceArray(t_current), t_current);
        clearDemand_maxPrice = [clearDemand_maxPrice_grid; clearDemand_maxPrice_EH1; clearDemand_maxPrice_EH2; clearDemand_maxPrice_EH3]; % ����Ϊ��������Ϊ��
            
        iterationNumber = 2;
        if sum(clearDemand_minPrice) * sum(clearDemand_maxPrice) <= 0 % ˵�����������������ڣ����������⣬һ�ǵ������Ƿ�ֱ�ӽ����������������㲻Ψһ��ô��
            %�г�����õ�����۸񣬲�����Ԥ��������
            [priceArray(t_current), clearDemand] = iterativeClear(minMarketPrice, maxMarketPrice, clearDemand_minPrice, clearDemand_maxPrice, ee, priceArray, gasPrice1, gasPrice3, t_current);
        else
            disp('Clearing point is not in the given interval.')
        end
        iterationTimes(t_current,2) = iterationNumber;
        
        % �õ�����۸�󣬻�Ҫ��ȷ���幦�ʣ�EH��������״̬��
        gridClearDemand(t_current) = clearDemand(1);
        EH1.conditionHandlePrice_2(priceArray, gasPrice1, t_current, clearDemand(2));
        EH2.conditionHandlePrice_2(priceArray, gasPrice1, t_current, clearDemand(3));
        EH3.conditionHandlePrice_2(priceArray, gasPrice3, t_current, clearDemand(4));
        
    else % IES1����
        
%         EH1.predict(t_current);
        EH2.predict(t_current);
        EH3.predict(t_current);
        
%         Grid1.zGenerate(elePrice(t_current)); %�ڵ�ǰ�Ż������ڲ���
        
        % ��ͼ۸�һ�㶼��������ڹ���
        priceArray(t_current) = minMarketPrice;
%         [x,~,~,~,~] = EH1.handlePrice(priceArray, gasPrice1, t_current);
%         clearDemand_minPrice_EH1 = x(1);
        [x,~,~,~,~] = EH2.handlePrice(priceArray, gasPrice1, t_current);
        clearDemand_minPrice_EH2 = x(1);
        [x,~,~,~,~] = EH3.handlePrice(priceArray, gasPrice3, t_current);
        clearDemand_minPrice_EH3 = x(1);
        clearDemand_minPrice_grid = Grid1.handlePrice(priceArray(t_current), t_current);
        clearDemand_minPrice = [clearDemand_minPrice_grid; clearDemand_minPrice_EH2; clearDemand_minPrice_EH3]; % ����Ϊ��������Ϊ��
            
        % ��߼۸�һ�㶼�ǹ�����������
        priceArray(t_current) = maxMarketPrice;
%         [x,~,~,~,~] = EH1.handlePrice(priceArray, gasPrice1, t_current);
%         clearDemand_maxPrice_EH1 = x(1);
        [x,~,~,~,~] = EH2.handlePrice(priceArray, gasPrice1, t_current);
        clearDemand_maxPrice_EH2 = x(1);
        [x,~,~,~,~] = EH3.handlePrice(priceArray, gasPrice3, t_current);
        clearDemand_maxPrice_EH3 = x(1);
        clearDemand_maxPrice_grid = Grid1.handlePrice(priceArray(t_current), t_current);
        clearDemand_maxPrice = [clearDemand_maxPrice_grid; clearDemand_maxPrice_EH2; clearDemand_maxPrice_EH3]; % ����Ϊ��������Ϊ��
            
        iterationNumber = 2;
        if sum(clearDemand_minPrice) * sum(clearDemand_maxPrice) <= 0 % ˵�����������������ڣ����������⣬һ�ǵ������Ƿ�ֱ�ӽ����������������㲻Ψһ��ô��
            %�г�����õ�����۸񣬲�����Ԥ��������
            [priceArray(t_current), clearDemand] = iterativeClear(minMarketPrice, maxMarketPrice, clearDemand_minPrice, clearDemand_maxPrice, ee, priceArray, gasPrice1, gasPrice3, t_current);
        else
            disp('Clearing point is not in the given interval.')
        end
        iterationTimes(t_current,2) = iterationNumber;
        
        % �õ�����۸�󣬻�Ҫ��ȷ���幦�ʣ�EH��������״̬��
        gridClearDemand(t_current) = clearDemand(1);
%         EH1.conditionHandlePrice_2(priceArray, gasPrice1, t_current, clearDemand(2));
        EH2.conditionHandlePrice_2(priceArray, gasPrice1, t_current, clearDemand(2));
        EH3.conditionHandlePrice_2(priceArray, gasPrice3, t_current, clearDemand(3));
    
    end
end
priceArray_record(:,2) = priceArray;

[result_Ele(:,1), result_CHP_G(:,1), result_Boiler_G(:,1), result_ES_discharge(:,1), result_ES_charge(:,1), result_HS_discharge(:,1), result_HS_charge(:,1), result_ES_SOC(:,1), result_HS_SOC(:,1), EH1_Le, EH1_Lh, EH1_solarP, EH1_windP] = EH1.getResult;
[result_Ele(:,2), result_CHP_G(:,2), result_Boiler_G(:,2), result_ES_discharge(:,2), result_ES_charge(:,2), result_HS_discharge(:,2), result_HS_charge(:,2), result_ES_SOC(:,2), result_HS_SOC(:,2), EH2_Le, EH2_Lh, EH2_solarP, EH2_windP] = EH2.getResult;
[result_Ele(:,3), result_CHP_G(:,3), result_Boiler_G(:,3), result_ES_discharge(:,3), result_ES_charge(:,3), result_HS_discharge(:,3), result_HS_charge(:,3), result_ES_SOC(:,3), result_HS_SOC(:,3), EH3_Le, EH3_Lh, EH3_solarP, EH3_windP] = EH3.getResult;



%�������壬�ݶȷ�
%{
priceArray = elePrice; %����ʷ���ݵõ�Ԥ���� %Ҳ�����ڵ����ļ۸����
priceArray_record = zeros(24*period,2); %һ����ǰ��һ��ʵʱ
ee = 0.01; %0.0001 0.0003
iterativeStep = 0.000001; %0.00001 0.0001
iterationTimes = zeros(24*period, 2); %��¼��������
maxIteration = 3000; %����������

demand_sum = zeros(priceNumbers, 1);
gridClearDemand = zeros(24*period,1);

off_grid = 0; % 0��ʾ�������У�1��ʾIES1����
t_realtime = zeros(24*period,3);

% ���ڲ��Եĵ��
% priceArray = [0.334979896750537;0.345365343857041;0.332393081385998;0.308531501102345;0.322635963415099;0.304882110539400;0.304515835848279;0.304153787790538;1.04508174057890;1.04470000000178;1.04470000000007;1.04470000000001;0.626800000000104;0.626800000000167;0.626800000055620;0.627101953428408;0.628016602128634;1.04470000000009;1.04512412592951;1.04574079511051;1.04623511011097;0.627798249878306;0.641181118337553;0.633909463862792];


for t_current = 1:24*period
    disp(['t_current is ',num2str(t_current)]);
    
    if t_current == 1 %�������ǰ�Ż�
        tic
%         EH1.predict(0);
%         EH2.predict(0);
%         EH3.predict(0);
        for pt = t_current : 1 : 24*period
            tic
            
%             figure(1);hold on;

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
                    error('��������������');
                end
                
                %��ǰ�۸��µĳ���
                priceArray(pt) = elePrice(pt) + lamda_new;
                [x,~,~,~,~] = EH1.handlePrice(priceArray, gasPrice1, pt);
                clearDemand_EH1_new = x(1);
                [x,~,~,~,~] = EH2.handlePrice(priceArray, gasPrice1, pt);
                clearDemand_EH2_new = x(1);
                [x,~,~,~,~] = EH3.handlePrice(priceArray, gasPrice3, pt);
                clearDemand_EH3_new = x(1);
                
%                 clearDemand_grid_new = Grid1.handlePrice(priceArray(pt), pt);

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
%                 lamda_new = max(0, lamda_old + sum(clearDemand) * iterativeStep);
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
                
%                 lamdaArrayAvg_new = sum(lamdaArray) / length(lamdaArray); %����һ
%                 lamda_avg_new = 1 / length(lamda_record) * lamda_record(number) + (length(lamda_record)-1) / length(lamda_record) * lamda_avg_old; %������                    
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
            EH3.conditionHandlePrice_2(priceArray, gasPrice3, pt, clearDemand(4));
            
        end
        
        priceArray_record(:,1) = priceArray;
        t_dayahead = toc; %���ʱ�䲻׼ȷ����Ϊ3��IESӦ���ǲ��м����
        
        % ��ǰ�Ż��Ľ��
        [result_Ele(:,1), result_CHP_G(:,1), result_Boiler_G(:,1), result_ES_discharge(:,1), result_ES_charge(:,1), result_HS_discharge(:,1), result_HS_charge(:,1), result_ES_SOC(:,1), result_HS_SOC(:,1), EH1_Le, EH1_Lh, EH1_solarP, EH1_windP] = EH1.getResult;
        [result_Ele(:,2), result_CHP_G(:,2), result_Boiler_G(:,2), result_ES_discharge(:,2), result_ES_charge(:,2), result_HS_discharge(:,2), result_HS_charge(:,2), result_ES_SOC(:,2), result_HS_SOC(:,2), EH2_Le, EH2_Lh, EH2_solarP, EH2_windP] = EH2.getResult;
        [result_Ele(:,3), result_CHP_G(:,3), result_Boiler_G(:,3), result_ES_discharge(:,3), result_ES_charge(:,3), result_HS_discharge(:,3), result_HS_charge(:,3), result_ES_SOC(:,3), result_HS_SOC(:,3), EH3_Le, EH3_Lh, EH3_solarP, EH3_windP] = EH3.getResult;
    end
    
    
    
    % �����Ż�����Ϊ�������к�EH1����   
    if off_grid == 0 % ��������
        EH1.predict(t_current);
        EH2.predict(t_current);
        EH3.predict(t_current);
        
        number = 1;
        
        lamda_old = -10;
        lamda_new = priceArray_record(t_current,1) - elePrice(t_current); %ȡ��ʼֵ��Ϊ��ǰ�Ż��ĳ���lamda����ʱû���棬��Ҫ����һ��
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
                error('��������������');
            end
            
            %��ǰ�۸��µĳ���
            priceArray(t_current) = elePrice(t_current) + lamda_new;
            [x,~,~,~,~] = EH1.handlePrice(priceArray, gasPrice1, t_current);
            clearDemand_EH1_new = x(1);
            [x,~,~,~,~] = EH2.handlePrice(priceArray, gasPrice1, t_current);
            clearDemand_EH2_new = x(1);
            [x,~,~,~,~] = EH3.handlePrice(priceArray, gasPrice3, t_current);
            clearDemand_EH3_new = x(1);
            
            f1 = - lamda_new;
            lb1 = eleLimit_total(2);
            ub1 = eleLimit_total(1);
            [clearDemand_grid_new, value1, flag1]  = linprog(f1, [], [], [], [], lb1, ub1);
            
            % �洢�ϵ�clearDemand�������µ�clearDemand������¼
            if number>1
                clearDemand_old = clearDemand_new;
            end
            clearDemand_new = [-clearDemand_grid_new; clearDemand_EH1_new; clearDemand_EH2_new; clearDemand_EH3_new]; % ����Ϊ��������Ϊ��
            clearDemand_record(number) = sum(clearDemand_new);
            
            % �洢�ϵ�lamda�������µ�lamda��ͨ���ݶȷ���������¼
            lamda_old = lamda_new;
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
        end
        
        % ����ֹͣ����
        iterationTimes(t_current,2) = number - 1;
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
        
        % ���ݵõ��ĳ���۸��Լ����幦�ʣ�EH����һ���Ż����Ը�������״̬
        priceArray(t_current) = elePrice(t_current) + clearLamda;
        gridClearDemand(t_current) = clearDemand(1);
        EH1.conditionHandlePrice_2(priceArray, gasPrice1, t_current, clearDemand(2));
        EH2.conditionHandlePrice_2(priceArray, gasPrice1, t_current, clearDemand(3));
        EH3.conditionHandlePrice_2(priceArray, gasPrice3, t_current, clearDemand(4)); 
        
    else % IES1����
    end
end
priceArray_record(:,2) = priceArray;

[result_Ele(:,1), result_CHP_G(:,1), result_Boiler_G(:,1), result_ES_discharge(:,1), result_ES_charge(:,1), result_HS_discharge(:,1), result_HS_charge(:,1), result_ES_SOC(:,1), result_HS_SOC(:,1), EH1_Le, EH1_Lh, EH1_solarP, EH1_windP] = EH1.getResult;
[result_Ele(:,2), result_CHP_G(:,2), result_Boiler_G(:,2), result_ES_discharge(:,2), result_ES_charge(:,2), result_HS_discharge(:,2), result_HS_charge(:,2), result_ES_SOC(:,2), result_HS_SOC(:,2), EH2_Le, EH2_Lh, EH2_solarP, EH2_windP] = EH2.getResult;
[result_Ele(:,3), result_CHP_G(:,3), result_Boiler_G(:,3), result_ES_discharge(:,3), result_ES_charge(:,3), result_HS_discharge(:,3), result_HS_charge(:,3), result_ES_SOC(:,3), result_HS_SOC(:,3), EH3_Le, EH3_Lh, EH3_solarP, EH3_windP] = EH3.getResult;
%}



