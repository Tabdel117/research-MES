
clc;clear;
global caseType couldExport
caseType = 2;
couldExport = 1;
para_init;
off_grid = 0; % 0��ʾ�������У�1��ʾIES1����
clear eleLimit1  gasLimit1  EH1_Le  EH1_Lh  EH1_solarP...
    EH1_windP  CHP1_para  Boiler1_para  ES1_para  HS1_para ...
    EH1_Le_jing EH1_solarP_rate EH1_windP_rate EH1_Le_drP_rate EH1_Le_drP_total EH1_Lh_drP_rate EH1_Lh_drP_total
clear eleLimit2  gasLimit2  EH2_Le  EH2_Lh  EH2_solarP...
    EH2_windP  CHP2_para  Boiler2_para  ES2_para  HS2_para...
    EH2_Le_jing EH2_solarP_rate EH2_windP_rate EH2_Le_drP_rate EH2_Le_drP_total EH2_Lh_drP_rate EH2_Lh_drP_total
clear eleLimit3  gasLimit3  EH3_Le  EH3_Lh  EH3_solarP...
    EH3_windP  CHP3_para  Boiler3_para  ES3_para  HS3_para...
    EH3_Le_jing EH3_solarP_rate EH3_windP_rate EH3_Le_drP_rate EH3_Le_drP_total EH3_Lh_drP_rate EH3_Lh_drP_total
clear Le_max Lh_max dev_L  dev_PV  dev_WT  singleLimit solar_max wind_max

%��ǰ�Ż�
priceArray = elePrice;

%ȫʱ��һ������⣨���ݶȷ���
% time = 1;
% all_temporal;
priceArray_record = zeros( 24 * period , 3);%��һ��Ϊ��ǰԤ�⣬�ڶ���Ϊʵ��
%��ʱ�����
isGrad = 1;%1-���ݶȷ� 0-���ַ�
isDA = 1;
all_temporal;

%�����Ż�
%ȫʱ�ι������
% for time = 1 : 24 * period
%     all_temporal;
% end
%��ʱ�ι������
isGrad = 0;%1-���ݶȷ� 0-���ַ�
isDA = 0;
single_temporal;
isCentral = 0;
main_handle_171013_v2