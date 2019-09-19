close all

% ������
% 20180309 v3 ���¸Ļ�1Сʱ�������ٽ�һ���Ӵ�Ԥ�������ı�׼��ֿ������ݸ�������ʵ

global period off_grid EH1 EH2 EH3 Grid1 IESNUMBER eleLimit_total caseType feedInPrice %feed-in tariff���úܴ��ǹص�
period = 60 / 60; % ��ĸ��ʱ����

load '../tmp1.mat'
load '../tmp2.mat'
load '../renewableName.mat'
load '../solarValue.mat'
load '../windValue.mat'
load '../singleWindValue.mat'
load '../singleLoadValue.mat'
load '../gridPriceRecord'

Le_max = [1.2 , 1.5 , 3] * 1000;
Lh_max = [1.5 , 1.8 , 4] * 1000;
Le_dr_rate = [0, 0.2, 0];
Lh_dr_rate = [0, 0, 0];
solar_max = [0 , 0.6 , 0.6, 0.3] * 1000;
wind_max = [0.6 , 0, 0, 0.4] * 1000;
% IES1 ������
EH1_Le = loadPower(:,1) - 0.4; 
EH1_Lh = circshift(loadValue(:,112),9);
EH1_solarP = solarValue(:,3) ; 
EH1_windP = windPower(3,:)'; 
EH1_Le_flag = zeros(24, 1); EH1_Le_flag(1:3) = ones(3, 1);  EH1_Le_flag(16:23) = ones(8,1);
EH1_Lh_flag = zeros(24, 1); EH1_Lh_flag(1:3) = ones(3, 1);  EH1_Lh_flag(16:23) = ones(8,1);

% IES2 סլ�������ȸ��ɰ���ͣ����ϸߣ��ȵ��൱����Դ�ḻ��
EH2_Le = loadPower(:,3) - 0.4;
EH2_Lh = circshift(loadValue(:, 113), 9); 
EH2_solarP = solarValue(:,1) ;
EH2_windP = windPower(1,:)';
EH2_Le_flag = zeros(24, 1); EH2_Le_flag(1:6) = ones(6,1);  EH2_Le_flag(20:24) = ones(5,1);
EH2_Lh_flag = zeros(24, 1); % ��ҵ��û�п�ƽ���ȸ���


% IES3 �����������ȸ��ɰ���ߣ����Ϻܵͣ��ȵ��൱�������շ壬������
EH3_Le = loadValue(:,88) -1000 ; % ��Ӧ127�Ź�˾ %/8
EH3_Lh = loadValue(:,91) ; % ��Ӧ130�Ź�˾ %/6
EH3_Le_flag = zeros(24, 1); EH3_Le_flag(9:20) = ones(12,1); 
EH3_Lh_flag = zeros(24, 1); EH1_Lh_flag(1:3) = ones(3, 1);  EH3_Lh_flag(16:23) = ones(8,1);

EH3_solarP = solarValue(:,27) ;
EH3_windP = windPower(2,:)';

% ����ϵͳ�Ŀ�������Դ
EH_windP_total = windPower(2,:)'; 
EH_solarP_total = solarValue(:,30);
EH_res_total = EH_windP_total / max(EH_windP_total) * wind_max(4) + EH_solarP_total / max(EH_solarP_total) * solar_max(4);
%CHP�Ĳ���
CHP1_para = [0.30, 0.42, Lh_max(1), 0.1, 0.5]; % CHP_GE_eff_in, CHP_GH_eff_in, CHP_Prate_in, CHP_Pmin_Rate_in, CHP_ramp_rate
CHP2_para = [0.35, 0.45, 0, 0, 1];
CHP3_para = [0.28, 0.56, Lh_max(3), 0.1, 0.5];


%���¯
eBoiler1_para = [0.98; 0; 0; 0.5]; % eBoiler_eff_in, eBoiler_Prate_in, eBoiler_Prate_min, eBoiler_Prate_ramp
eBoiler2_para = [0.98; Le_max(2) * 0.7; 0; 1];
eBoiler3_para = [0.98; 0; 0; 0.5];

%ȼ����¯
Boiler1_para = [0.90; 0]; % Boiler_eff_in, Boiler_Prate_in
Boiler2_para = [0.90; Lh_max(2) * 0.9];
Boiler3_para = [0.90; 0];

%�索�ܺ��ȴ���

% HS_totalC_in, HS_maxSOC_in, HS_minSOC_in, HS_currentSOC_in, HS_targetSOC_in, HS_chargeTime, HS_eff_in
ES1_para = [1600, 0.85, 0.1, 0.2, 0.2, 3, 0.95];
ES2_para = [1500, 0.85, 0.1, 0.2, 0.2, 4, 0.95];
ES3_para = [1400, 0.85, 0.1, 0.2, 0.2, 3, 0.95];
HS1_para = [1200, 0.9, 0.1, 0.6, 0.6, 4, 0.9];
HS2_para = [1200, 0.9, 0.1, 0.6, 0.6, 4, 0.9];
HS3_para = [1400, 0.9, 0.1, 0.5, 0.5, 4, 0.9];

IESNUMBER = 3; % IES����

for IES_no = 1 : IESNUMBER
    eval(['EH',num2str(IES_no),'_Le = EH',num2str(IES_no),'_Le / max(EH',num2str(IES_no),'_Le) * Le_max(IES_no) * (1 -Le_dr_rate(IES_no));']);
    eval(['EH',num2str(IES_no),'_Lh = EH',num2str(IES_no),'_Lh / max(EH',num2str(IES_no),'_Lh) * Lh_max(IES_no) * (1 -Lh_dr_rate(IES_no));']);
    eval(['EH',num2str(IES_no),'_solarP = EH',num2str(IES_no),'_solarP / max(EH',num2str(IES_no),'_solarP) * solar_max(IES_no);']);
    eval(['EH',num2str(IES_no),'_windP = EH',num2str(IES_no),'_windP / max(EH',num2str(IES_no),'_windP) * wind_max(IES_no);']);
    eval(['EH',num2str(IES_no),'_solarP_rate = solar_max(IES_no);']);
    eval(['EH',num2str(IES_no),'_windP_rate = wind_max(IES_no);']);
end
res_total = sum(EH1_solarP + EH1_windP + EH2_solarP + EH2_windP + EH3_solarP + EH3_windP + EH_res_total);
% ��Ҫ��ͼ���жϾ����ɣ�����������

EH1_Le_jing = EH1_Le-EH1_solarP-EH1_windP;
EH2_Le_jing = EH2_Le-EH2_solarP-EH2_windP;
EH3_Le_jing = EH3_Le-EH3_solarP-EH3_windP;

%{
        for IES_no = 1 : IESNUMBER
            subplot(3,2,IES_no * 2 - 1);hold on
            eval(['plot(EH', num2str(IES_no) , '_Le)']);
            eval(['plot(EH',num2str(IES_no) , '_Lh)']);
            eval(['plot(EH',num2str(IES_no) , '_Le_jing)']);
            legend('�縺��','�ȸ���','���縺��');
            subplot(3,2, IES_no * 2);hold on
            eval(['plot(EH', num2str(IES_no), '_Le_jing/0.35-EH', num2str(IES_no),'_Lh/0.45);']);
        end
%}
clear loadName loadValue renewableName solarValue windValue


global minMarketPrice maxMarketPrice priceNumbers step

minMarketPrice = 0.2;
maxMarketPrice = 1;
step = 0.1; %ֻ���ڵ��γ����ʱ���õõ�
priceNumbers = (maxMarketPrice - minMarketPrice)/step + 1; %һ��Ͷ�������ĳ��ȣ������������� + 1 = ����
marketInfo = [minMarketPrice; maxMarketPrice; step; priceNumbers];
feedInPrice = 100;
% ��������
global elePrice
%��ʱ���
%{
        elePrice = ones(24*period,1) .* 0.6268;
        elePrice(0+1 : 8*period) = ones(8*period,1) .* 0.3089;
        elePrice(8*period+1 : 12*period) = ones(4*period,1) .* 1.0447;
        elePrice(17*period+1 : 21*period) = ones(4*period,1) .* 1.0447;
%}
%ʵʱ���
elePrice = gridPriceRecord( 49 : 49 + 24 - 1)';
elePrice = (elePrice - min(elePrice) ) / (max(elePrice) - min(elePrice)) * 0.8 + 0.2 ;
clear gridPriceRecord

% ��������
global gasPrice1 gasPrice3  % ����Ҫȫ�ֱ�����
gasPrice1 = 0.334; % 3.3Ԫÿ�����׻�����ֵ
gasPrice3 = 0.284; % 2.8Ԫÿ�����׻�����ֵ
gasLimit1 = 1e6; %��ʱ�����ǻ�����Ȼ��
gasLimit2 = 1e6;
gasLimit3 = 1e6;

% ���ɺͷ��Ԥ�����
dev_L = 3/100; %�ٷ��� 1
dev_PV = 10/100; %5
dev_WT = 15/100;
% seedNumber = 0;
% rand ���ɾ��ȷֲ���α����� �ֲ��ڣ�0~1��֮��
% randn ���ɱ�׼��̬�ֲ���α����� ����ֵΪ0����׼��Ϊ1�������Ե�ϵ���Ǳ�׼����Ƿ����
randn('seed', 10);

%��
%��IES��ʱ������ƽ�Ƹ��ɹ���
EH1_Le_drP_rate = Le_max(1) * Le_dr_rate(1);
EH2_Le_drP_rate = Le_max(2) * Le_dr_rate(2);
EH3_Le_drP_rate = Le_max(3) * Le_dr_rate(3);
%��IES�ܿ�ƽ�Ƹ��ɵ���
EH1_Le_drP_total = EH1_Le_drP_rate * 4;
EH2_Le_drP_total = EH2_Le_drP_rate * 4;
EH3_Le_drP_total = EH3_Le_drP_rate * 4;
%��ƽ�Ƹ���ʱ��
%��
%��IES��ʱ������ƽ�Ƹ��ɹ���
EH1_Lh_drP_rate = Lh_max(1) * Lh_dr_rate(1);
EH2_Lh_drP_rate = Lh_max(2) * Lh_dr_rate(2);
EH3_Lh_drP_rate = Lh_max(3) * Lh_dr_rate(3);
%��IES�ܿ�ƽ�Ƹ��ɵ���
EH1_Lh_drP_total = EH1_Lh_drP_rate * 4;
EH2_Lh_drP_total = EH2_Lh_drP_rate * 4;
EH3_Lh_drP_total = EH3_Lh_drP_rate * 4;

singleLimit = Le_max * 1.5;
% totalLimit = 1.2 * mean(EH1_Le_jing) + mean(EH2_Le_jing) + mean(EH3_Le_jing)+...
%     (EH1_Le_drP_total +EH1_Le_drP_total + EH1_Le_drP_total )/(24 * period) ;
reverseRate = 4;
% ֧��: �¼����ϼ����硢�۵�Լ�����ټ�һ��������5-7%
eleLimit1 = [singleLimit(1), -singleLimit(1), 1];
eleLimit2 = [singleLimit(2), -singleLimit(2), 1];
eleLimit3 = [singleLimit(3), -singleLimit(3), 1];
if isCollaborate == 1
%     eleLimit_total = [sum(singleLimit)/4, 0];
    eleLimit_total = [2250, 0];
elseif isCollaborate == 2
    eleLimit_total = [2250, -2250];
else
    eleLimit_total = [sum(singleLimit), -sum(singleLimit)] * 10;
end
% ����
Grid1 = Grid_171118(eleLimit_total);
% EH������ʵ����
EH1 = EH_local_170828_v3(eleLimit1, gasLimit1, EH1_Le, EH1_Lh, EH1_solarP, EH1_windP, CHP1_para, Boiler1_para, eBoiler1_para,...
    ES1_para, HS1_para, dev_L, dev_PV, dev_WT, EH1_solarP_rate, EH1_windP_rate, ...
    EH1_Le_drP_rate, EH1_Le_drP_total, EH1_Lh_drP_rate, EH1_Lh_drP_total, EH1_Le_flag, EH1_Lh_flag);
EH2 = EH_local_170828_v3(eleLimit2, gasLimit2, EH2_Le, EH2_Lh, EH2_solarP, EH2_windP, CHP2_para, Boiler2_para, eBoiler2_para,...
    ES2_para, HS2_para, dev_L, dev_PV, dev_WT, EH2_solarP_rate, EH2_windP_rate,...
    EH2_Le_drP_rate, EH2_Le_drP_total, EH2_Lh_drP_rate, EH2_Lh_drP_total, EH2_Le_flag, EH2_Lh_flag);
EH3 = EH_local_170828_v3(eleLimit3, gasLimit3, EH3_Le, EH3_Lh, EH3_solarP, EH3_windP, CHP3_para, Boiler3_para, eBoiler3_para,...
    ES3_para, HS3_para, dev_L, dev_PV, dev_WT, EH3_solarP_rate, EH3_windP_rate,...
    EH3_Le_drP_rate, EH3_Le_drP_total, EH3_Lh_drP_rate, EH3_Lh_drP_total, EH3_Le_flag, EH3_Lh_flag);

