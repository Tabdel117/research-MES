% Ԥ��ҵ��
% 20180219 ɾ����seedNumber����
% ���ı�׼��ֿ�

%{
function [Le_result, Lh_result] = predict(number, time) % EH�ı�ţ��ڼ�Сʱ��Ԥ�⣬time=0����ǰ��1-24������
    switch number
        case 1
            Le_base = [115
                105
                102
                103
                105
                110
                120
                125
                122
                116
                115
                110
                116
                119
                120
                128
                129
                130
                132
                136
                130
                120
                110
                108]; %��ǰԤ�⸺��
            
            Lh_base = [110
                109
                108
                107
                106
                105
                106
                107
                108
                107
                106
                105
                103
                102
                102
                104
                106
                110
                111
                113
                115
                114
                112
                110].*1;
        otherwise
            Le_base = zeros(24,1);
            Lh_base = zeros(24,1);
    end
    
    if time == 0
        Le_result = Le_base;
        Lh_result = Lh_base;
    else
        Le_error = randn([(24+1-time),1])*1; %����
        Lh_error = randn([(24+1-time),1])*1; %����
        if time ~= 1
            Le_result(1,:)=[]; %����
            Lh_result(1,:)=[]; %����
        end
        Le_result = Le_result + Le_error;
        Lh_result = Lh_result + Lh_error;
    end

end
%}

function [Le_result, Lh_result, solarP_result, windP_result] = predict(Le, Lh, solarP, windP, t_current, dev_L, dev_PV, dev_WT, solarP_rate, windP_rate) % t=1-24�������ڣ�û����ǰ
%     global period

    %rand ���ɾ��ȷֲ���α����� �ֲ��ڣ�0~1��֮��
    %randn ���ɱ�׼��̬�ֲ���α����� ����ֵΪ0������Ϊ1��
%     randn('seed', t_current);
    
    %�硢�ȸ���
%     Le_error = zeros(24*period,1);
%     Lh_error = zeros(24*period,1);
%     Le_error(t_current:24*period) = randn([(24*period-t_current+1),1]) .* Le(t_current:24*period) * dev_L; %Ԥ�����
%     Lh_error(t_current:24*period) = randn([(24*period-t_current+1),1]) .* Lh(t_current:24*period) * dev_L;
%     Le_result = Le + Le_error; %����
%     Lh_result = Lh + Lh_error;
    %��Ϊֻ�Ƶ�ǰʱ�̵�Ԥ���������ۼƵ�������Ƶ���ظ�Ԥ��Ҳ����ѧ
    Le_error = randn() * Le(t_current) * dev_L; %Ԥ�����
    Lh_error = randn() * Lh(t_current) * dev_L;
    Le_result = Le;
    Lh_result = Lh;
    Le_result(t_current) = Le_result(t_current) + Le_error; %����
    Lh_result(t_current) = Lh_result(t_current) + Lh_error;
    
    %�硢��
    %�м���͸��ɲ�һ��
    %һ�ǣ���������㣬��ôһ�����㣬û��Ԥ�����
    %���ǣ��硢��ӽ����ʱ�򣬲�Ҫ�����Ϊ����
%     solarP_error = zeros(24*period,1);
%     windP_error = zeros(24*period,1);
%     solarP_error(t_current:24*period) = randn([(24*period-t_current+1),1]) .* solarP(t_current:24*period) * dev_RES; %Ԥ�����
%     windP_error(t_current:24*period) = randn([(24*period-t_current+1),1]) .* windP(t_current:24*period) * dev_RES;
%     %����
%     for i = t_current : 24*period
%         if solarP(i) == 0
%             solarP_error(i) = 0;
%         end
%         if solarP(i) + solarP_error(i) < 0
%             solarP_error(i) = - solarP(i);
%         end
%         if windP(i) == 0
%             windP_error(i) = 0;
%         end
%         if windP(i) + windP_error(i) < 0
%             windP_error(i) = - windP(i);
%         end
%     end   
%     solarP_result = solarP + solarP_error; %����
%     windP_result = windP + windP_error;
    %��Ϊֻ�Ƶ�ǰʱ�̵�Ԥ���������ۼƵ�������Ƶ���ظ�Ԥ��Ҳ����ѧ
    solarP_error = randn() * solarP(t_current) * dev_PV; %Ԥ����solarP(t_current)=0��ʱ����ȻΪ��
    windP_error = randn() * windP(t_current) * dev_WT; %Ԥ�����
    
    solarP_result = solarP;
    windP_result = windP;
    
    solarP_result(t_current) = solarP_result(t_current) + solarP_error; %����
    if solarP_result(t_current) < 0
        solarP_result(t_current) = 0;
    elseif solarP_result(t_current) > solarP_rate
        solarP_result(t_current) = solarP_rate;
    end
    
    windP_result(t_current) = windP_result(t_current) + windP_error;
    if windP_result(t_current) < 0
        windP_result(t_current) = 0;
    elseif windP_result(t_current) > windP_rate
        windP_result(t_current) = windP_rate;
    end

end
