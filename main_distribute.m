clc;clear;
global caseType couldExport
caseType = 2;
couldExport = 1;
para_init;
off_grid = 0; % 0��ʾ�������У�1��ʾIES1����
priceArray = elePrice;
priceArray_record = zeros( 24 * period , 3);
% 2-stage
%��ǰ�Ż�
isDA = 1;
% ���ݶȷ�
all_temporal;

%�����Ż�
isDA = 0;
%��ʱ�ι������
% ���ַ�
single_temporal;
isCentral = 0;
main_handle_171013_v2

