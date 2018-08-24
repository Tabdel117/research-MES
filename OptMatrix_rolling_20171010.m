% clc
% clear

%����Э���Ż�
%��Դ��Ŧ�ı��ؼ���ʽ�Ż�����
%��������������γ�����Ҫ�ľ���

%20171010 �ӿ�������Դ����Ϊ�����Ż�
%20180110 ����ƽ����Լ����Ϊ����ʽԼ����������û�е�ʽԼ����
%20180129 ���ӹ���Ч�ʣ�����·�����������Ele_eff������period

function [f, ub, lb, A, b, A_eleLimit_total] = OptMatrix_rolling_20171010(eleLimit, gasLimit, Le, Lh, CHP_para, Boiler_para, ES_para, HS_para, Gprice, windP, solarP, t_current)
global period elePrice

%�����ߵ罻����������Լ��
Ele_max = eleLimit(1);
Ele_min = eleLimit(2);
Ele_eff = eleLimit(3); %����Ч�ʣ�����·�����������
Gas_max = gasLimit; %�����������ĺ�
% Gas_min = 0;

%CHP�Ĳ���
CHP_GE_eff = CHP_para(1);
CHP_GH_eff = CHP_para(2);
CHP_G_max = CHP_para(3) / CHP_GE_eff; %�ɶ�繦�ʵõ��������
CHP_G_min = CHP_para(4) * CHP_G_max;

%��¯
Boiler_eff = Boiler_para(1);
Boiler_G_max = Boiler_para(2) / Boiler_eff;  %10
% Boiler_G_min = 0;

%�索�ܺ��ȴ���
ES_totalC = ES_para(1);
ES_maxSOC = ES_para(2);
ES_minSOC = ES_para(3);
ES_currentSOC = ES_para(4);
ES_targetSOC = ES_para(5);
ES_Pmax = ES_totalC / ES_para(6);
ES_eff = ES_para(7);

HS_totalC = HS_para(1);
HS_maxSOC = HS_para(2);
HS_minSOC = HS_para(3);
HS_currentSOC = HS_para(4);
HS_targetSOC = HS_para(5);
HS_Hmax = HS_totalC / HS_para(6);
HS_eff = HS_para(7);



time = 24*period - t_current + 1; %��ʱ���
var = time * 7; %�ܱ�����
%��1,2,3��time�ǹ�������CHP����������¯����������4-7��time�Ǵ��硢���ȵķš��书��



%��һ����ϵ��f �Ǹ�������
f = zeros(var, 1);
for i = 1 : time
    % f(i, 1) = elePrice(i);
    f(i, 1) = elePrice(t_current + i - 1); %elePrice��size���䣬����ȡ����ֵ
    f(time+i, 1) = Gprice;
    f(time*2+i, 1) = Gprice;
end

%����������
ub = zeros(var, 1);
lb = zeros(var, 1);
for i = 1 : time
    ub(i, 1) = Ele_max;
    ub(time+i, 1) = CHP_G_max;
    ub(time*2+i, 1) = Boiler_G_max;
    ub(time*3+i, 1) = ES_Pmax;
    ub(time*4+i, 1) = ES_Pmax;
    ub(time*5+i, 1) = HS_Hmax;
    ub(time*6+i, 1) = HS_Hmax;
end
for i = 1 : time
    lb(i, 1) = Ele_min;
    lb(time+i, 1) = CHP_G_min;
    %     lb(time*2+i, 1) = 0;
    %     lb(time*3+i, 1) = 0;
    %     lb(time*4+i, 1) = 0;
    %     lb(time*5+i, 1) = 0;
    %     lb(time*6+i, 1) = 0;
end



%��ʽԼ����������


%����ʽԼ������������ƽ����Լ��������ƽ��Լ�����������󣩣�SOCԼ�����������͵�Լ������������Լ����
%�硢�ȴ���ƽ����Լ������Ϊ����ʽԼ�� ��ֹʱ��ֵ>Ŀ��ֵ �� -��ֹʱ��ֵ<-Ŀ��ֵ��
Aeq_ES = zeros(1, var);
beq_ES = - (ES_targetSOC - ES_currentSOC) * ES_totalC;
for i=1:time
    Aeq_ES(1, time*3+i) = 1/ES_eff; %�ŵ�
    Aeq_ES(1, time*4+i) = - 1*ES_eff; %���
end
Aeq_HS = zeros(1, var);
beq_HS = - (HS_targetSOC - HS_currentSOC) * HS_totalC;
for i=1:time
    Aeq_HS(1, time*5+i) = 1/HS_eff; %����
    Aeq_HS(1, time*6+i) = - 1*HS_eff; %����
end

%�硢��ƽ��Լ��
Aeq_Ebus = zeros(time, var);
Aeq_Hbus = zeros(time, var);
% beq_Ebus = - Le;
% beq_Hbus = - Lh;
beq_Ebus = - Le(t_current : 24*period) + windP(t_current : 24*period) + solarP(t_current : 24*period); %Le��size���䣬����ȡ����ֵ
beq_Hbus = - Lh(t_current : 24*period); %Lh��size���䣬����ȡ����ֵ 

for i=1:time
    Aeq_Ebus(i,i) = - Ele_eff;
    Aeq_Ebus(i,time+i) = - CHP_GE_eff;
    Aeq_Ebus(i,time*3+i) = - 1; %�ŵ�
    Aeq_Ebus(i,time*4+i) = 1; %���
end
for i=1:time
    Aeq_Hbus(i,time+i) = - CHP_GH_eff;
    Aeq_Hbus(i,time*2+i) = - Boiler_eff;
    Aeq_Hbus(i,time*5+i) = - 1; %����
    Aeq_Hbus(i,time*6+i) = 1; %����
end

%SOCԼ�� A1�����ޣ�A2������
A1_Esoc = zeros(time, var);
A2_Esoc = zeros(time, var);
b1_Esoc = ones(time,1) * (ES_maxSOC - ES_currentSOC) * ES_totalC;
b2_Esoc = ones(time,1) * (ES_currentSOC - ES_minSOC) * ES_totalC;
for i=1:time
    for j=1 : i
        A1_Esoc(i, time*3+j) = -1/ES_eff; %�ŵ�
        A1_Esoc(i, time*4+j) = 1*ES_eff; %���
    end
end
for i=1:time
    for j=1 : i
        A2_Esoc(i, time*3+j) = 1/ES_eff; %�ŵ�
        A2_Esoc(i, time*4+j) = -1*ES_eff; %���
    end
end

A1_Hsoc = zeros(time, var);
A2_Hsoc = zeros(time, var);
b1_Hsoc = ones(time,1) * (HS_maxSOC - HS_currentSOC) * HS_totalC;
b2_Hsoc = ones(time,1) * (HS_currentSOC - HS_minSOC) * HS_totalC;
for i=1:time
    for j=1 : i
        A1_Hsoc(i, time*5+j) = -1/HS_eff; %����
        A1_Hsoc(i, time*6+j) = 1*HS_eff; %����
    end
end
for i=1:time
    for j=1 : i
        A2_Hsoc(i, time*5+j) = 1/HS_eff; %����
        A2_Hsoc(i, time*6+j) = -1*HS_eff; %����
    end
end

%�������͵�Լ��
A_Gmax = zeros(time, var);
b_Gmax = ones(time,1) .* Gas_max;
for i=1:time
    A_Gmax(i, time+i) = 1;
    A_Gmax(i, time*2+i) = 1;
end



%������������Լ��
%����ʽԼ������������ƽ����Լ��������ƽ��Լ����SOCԼ�����������͵�Լ������������Լ����
A=[Aeq_Ebus; Aeq_Hbus;   Aeq_ES; Aeq_HS;   A1_Esoc; A2_Esoc; A1_Hsoc; A2_Hsoc; A_Gmax];
b=[beq_Ebus; beq_Hbus;   beq_ES; beq_HS;   b1_Esoc; b2_Esoc; b1_Hsoc; b2_Hsoc; b_Gmax];


% ��Ҫ��������һ�����������ϡ�����Լ��
A_eleLimit_total = zeros(time, var);
for i=1:time
    A_eleLimit_total(i, i) = 1;
end

end




