% clc
% clear

%����Э���Ż�
%��Դ��Ŧ�ı��ؼ���ʽ�Ż�����
%2017.8.22 ver1.0
%2017.8.28 ver1.1 �硢�ȹ���ƽ���Ϊ����Լ�������ӹ������͵�Լ����BUGΪ���������ӯ��Ļ����Ȼ��ֳ��ַ�
%2017.8.28 ver2.0 ��Ϊclass
%2018.1.10 ver3.0 market��Ϣ����ȫ�ֱ������Դ��ܵ��ֳ��ַŲ��õ�Ч�������Ż�������ʱ������Ϊ15min

% f2=[-13;-23];
% A2=[5,15; 4,4; 35,20;];
% b2=[480,160,1190];
% lb=[0;0];
% [x,fval,exitflag,output,lambda] = linprog(f2,A2,b2,[],[],lb,[])



classdef EH_local_170828_v3 < handle
    properties %�������ʼֵ
        %�������������Դ
        Le;
        Lh;
        solarP;
        solarP_rate;
        windP;
        windP_rate;
        dev_L; %�ٷ���
        dev_PV;
        dev_WT;
        
        %CHP�Ĳ���
        CHP_GE_eff;
        CHP_GH_eff;
        CHP_G_max;
        CHP_G_min;
        
        %��¯
        Boiler_eff;
        Boiler_G_max;
        % Boiler_G_min = 0;
        
        %�����ߵ罻����������Լ��
        Ele_max;
        Ele_min;
        Ele_eff;
        Gas_max;
        % Gas_min = 0;
        
        %�索��
        ES_totalC;
        ES_maxSOC;
        ES_minSOC;
        % ES_currentC; %��ʱ��仯��
        ES_targetSOC;
        ES_Pmax;
        ES_eff;
        
        %�ȴ���
        HS_totalC;
        HS_maxSOC;
        HS_minSOC;
        % HS_currentC; %��ʱ��仯��
        HS_targetSOC;
        HS_Hmax;
        HS_eff;
        
        %Ͷ��
        demand_curve;
        
        %�����Ż����
        ES_SOC;
        HS_SOC;
        result_Ele;
        result_CHP_G;
        result_Boiler_G;
        result_ES_discharge;
        result_ES_charge;
        result_HS_discharge;
        result_HS_charge;
    end
    
    methods
        
        function obj = EH_local_170828_v3(eleLimit, gasLimit, Le_base, Lh_base, solar_base, wind_base, CHP_para, Boiler_para, ES_para, HS_para, dev_load, dev_solar, dev_wind, solar_rate, wind_rate)
            
            global priceNumbers period
            
            %�����ߵ罻����������Լ��
            obj.Ele_max = eleLimit(1);
            obj.Ele_min = eleLimit(2);
            obj.Ele_eff = eleLimit(3); %����Ч�ʣ�����·�����������
            obj.Gas_max = gasLimit; %�����������ĺ�
            % Gas_min = 0;
            
            %�������������Դ
            obj.Le = Le_base; %base����ǰ������Ԥ������
            obj.Lh = Lh_base;
            obj.solarP = solar_base;
            obj.solarP_rate = solar_rate;
            obj.windP = wind_base;
            obj.windP_rate = wind_rate;
            obj.dev_L = dev_load; %�ٷ���
            obj.dev_PV = dev_solar;
            obj.dev_WT = dev_wind;
            
            %CHP�Ĳ���
            obj.CHP_GE_eff = CHP_para(1);
            obj.CHP_GH_eff = CHP_para(2);
            obj.CHP_G_max = CHP_para(3) / obj.CHP_GE_eff; %�ɶ�繦�ʵõ��������
            obj.CHP_G_min = CHP_para(4) * obj.CHP_G_max;
            
            %��¯
            obj.Boiler_eff = Boiler_para(1);
            obj.Boiler_G_max = Boiler_para(2) / obj.Boiler_eff;  %10
            % Boiler_G_min = 0;
            
            %�索�ܺ��ȴ���
            obj.ES_totalC = ES_para(1);
            obj.ES_maxSOC = ES_para(2);
            obj.ES_minSOC = ES_para(3);
            obj.ES_targetSOC = ES_para(5);
            obj.ES_Pmax = obj.ES_totalC / ES_para(6);
            obj.ES_eff = ES_para(7);
            
            obj.HS_totalC = HS_para(1);
            obj.HS_maxSOC = HS_para(2);
            obj.HS_minSOC = HS_para(3);
            obj.HS_targetSOC = HS_para(5);
            obj.HS_Hmax = obj.HS_totalC / HS_para(6);
            obj.HS_eff = HS_para(7);
            
            % Ͷ��
            obj.demand_curve = zeros(priceNumbers, 1); %��ʼ��Ͷ������
            
            %�����Ż����
            obj.ES_SOC = zeros(24*period+1,1);
            obj.ES_SOC(1) = ES_para(4);
            obj.HS_SOC = zeros(24*period+1,1);
            obj.HS_SOC(1) = HS_para(4);
            obj.result_Ele = zeros(24*period,1);
            obj.result_CHP_G = zeros(24*period,1);
            obj.result_Boiler_G = zeros(24*period,1);
            obj.result_ES_discharge = zeros(24*period,1);
            obj.result_ES_charge = zeros(24*period,1);
            obj.result_HS_discharge = zeros(24*period,1);
            obj.result_HS_charge = zeros(24*period,1);
        end
        
        % ��������Դ�븺�ɵ�Ԥ��ҵ��һ��Ԥ��25�Σ���ǰһ�Σ�����ÿСʱһ��
        function predict(obj, t_current) % �ڼ�Сʱ��Ԥ�⣬time=0����ǰ��1-24������
            %             global period
            if t_current ~= 0
                %rand ���ɾ��ȷֲ���α����� �ֲ��ڣ�0~1��֮��
                %randn ���ɱ�׼��̬�ֲ���α����� ����ֵΪ0������Ϊ1��
                %                 randn('seed', t_current);
                
                %�硢�ȸ���
                %                 Le_error = zeros(24*period,1);
                %                 Lh_error = zeros(24*period,1);
                %                 Le_error(t_current:24*period) = randn([(24*period-t_current+1),1]) .* obj.Le(t_current:24*period) * obj.dev_L; %Ԥ�����
                %                 Lh_error(t_current:24*period) = randn([(24*period-t_current+1),1]) .* obj.Lh(t_current:24*period) * obj.dev_L;
                %                 obj.Le = obj.Le + Le_error; %����
                %                 obj.Lh = obj.Lh + Lh_error;
                %��Ϊֻ�Ƶ�ǰʱ�̵�Ԥ���������ۼƵ�������Ƶ���ظ�Ԥ��Ҳ����ѧ
                Le_error = randn() * obj.Le(t_current) * obj.dev_L; %Ԥ�����
                Lh_error = randn() * obj.Lh(t_current) * obj.dev_L;
                obj.Le(t_current) = obj.Le(t_current) + Le_error; %����
                obj.Lh(t_current) = obj.Lh(t_current) + Lh_error;
                
                %�硢��
                %�м���͸��ɲ�һ��
                %һ�ǣ���������㣬��ôһ�����㣬û��Ԥ�����
                %���ǣ��硢��ӽ����ʱ�򣬲�Ҫ�����Ϊ����
                %                 solarP_error = zeros(24*period,1);
                %                 windP_error = zeros(24*period,1);
                %                 solarP_error(t_current:24*period) = randn([(24*period-t_current+1),1]) .* obj.solarP(t_current:24*period) * obj.dev_RES; %Ԥ�����
                %                 windP_error(t_current:24*period) = randn([(24*period-t_current+1),1]) .* obj.windP(t_current:24*period) * obj.dev_RES;
                %                 %����
                %                 for i = t_current : 24*period
                %                     if obj.solarP(i) == 0
                %                         solarP_error(i) = 0;
                %                     end
                %                     if obj.solarP(i) + solarP_error(i) < 0
                %                         solarP_error(i) = - obj.solarP(i);
                %                     end
                %                     if obj.windP(i) == 0
                %                         windP_error(i) = 0;
                %                     end
                %                     if obj.windP(i) + windP_error(i) < 0
                %                         windP_error(i) = - obj.windP(i);
                %                     end
                %                 end
                %                 obj.solarP = obj.solarP + solarP_error; %����
                %                 obj.windP = obj.windP + windP_error;
                %��Ϊֻ�Ƶ�ǰʱ�̵�Ԥ���������ۼƵ�������Ƶ���ظ�Ԥ��Ҳ����ѧ
                solarP_error = randn() * obj.solarP(t_current) * obj.dev_PV; %Ԥ����solarP(t_current)=0��ʱ����ȻΪ��
                windP_error = randn() * obj.windP(t_current) * obj.dev_WT; %Ԥ�����
                
                obj.solarP(t_current) = obj.solarP(t_current) + solarP_error; %����
                if obj.solarP(t_current) < 0
                    obj.solarP(t_current) = 0;
                elseif obj.solarP(t_current) > obj.solarP_rate
                    obj.solarP(t_current) = obj.solarP_rate;
                end
                
                obj.windP(t_current) = obj.windP(t_current) + windP_error;
                if obj.windP(t_current) < 0
                    obj.windP(t_current) = 0;
                elseif obj.windP(t_current) > obj.windP_rate
                    obj.windP(t_current) = obj.windP_rate;
                end
            else
                %��ǰԤ��ֵ����baseֵ
            end
        end
        
        
        
        %ͨ����ν����Ż�������Ͷ�꺯��
        function demand_curve_result = curveGenerate(obj, Eprice, Gprice, t_current) %���յ�ۡ����ۡ���ǰʱ��
            % predict(obj, t_current); %���±��صĸ���Ԥ��
            global minMarketPrice step priceNumbers
            
            for i = 1: 1 : priceNumbers
                Eprice(t_current) = minMarketPrice + (i-1) * step;
                [x,~,~,~,~] = localOptimal(obj, Eprice, Gprice, t_current, 9e9); % conditionEle = 9e9
                obj.demand_curve(i) = x(1);
            end
            
            demand_curve_result = obj.demand_curve;
        end
        
        
        %�����г�����۸��������Ż�����������״̬
        function [x,fval,exitflag,output,lambda] = handlePrice(obj, Eprice, Gprice, t_current) %�����x����t_current��Խ��Խ��
            global period
            
            [x,fval,exitflag,output,lambda] = localOptimal(obj, Eprice, Gprice, t_current, 9e9); % conditionEle = 9e9
            time = 24*period - t_current + 1; %��ʱ���
            
            % ִֻ�е�ǰ���ڵĽ��
            obj.result_Ele(t_current) = x(1);
            obj.result_CHP_G(t_current) = x(time+1);
            obj.result_Boiler_G(t_current) = x(time*2+1);
            obj.result_ES_discharge(t_current) = x(time*3+1);
            obj.result_ES_charge(t_current) = x(time*4+1);
            obj.result_HS_discharge(t_current) = x(time*5+1);
            obj.result_HS_charge(t_current) = x(time*6+1);
            
            %���´���״̬
            obj.ES_SOC(t_current+1) = obj.ES_SOC(t_current) - obj.result_ES_discharge(t_current) / obj.ES_eff / obj.ES_totalC + obj.result_ES_charge(t_current) * obj.ES_eff / obj.ES_totalC;
            obj.HS_SOC(t_current+1) = obj.HS_SOC(t_current) - obj.result_HS_discharge(t_current) / obj.HS_eff / obj.HS_totalC + obj.result_HS_charge(t_current) * obj.HS_eff / obj.HS_totalC;
        end
        
        
        % ����TC���γ���
        %�����г�����۸񣬰�Ͷ�����ߵõ����幦�ʣ��ڱ��ֳ��幦�ʲ��������£�������Ż�
        function [x,fval,exitflag,output,lambda] = conditionHandlePrice(obj, Eprice, Gprice, t_current) %�����x����t_current��Խ��Խ��
            global period
            conditionEle = getClearDemand(obj.demand_curve, Eprice(t_current));
            
            [x,fval,exitflag,output,lambda] = localOptimal(obj, Eprice, Gprice, t_current, conditionEle);
            time = 24*period - t_current + 1; %��ʱ���
            
            % ִֻ�е�ǰ���ڵĽ��
            obj.result_Ele(t_current) = x(1);
            obj.result_CHP_G(t_current) = x(time+1);
            obj.result_Boiler_G(t_current) = x(time*2+1);
            obj.result_ES_discharge(t_current) = x(time*3+1);
            obj.result_ES_charge(t_current) = x(time*4+1);
            obj.result_HS_discharge(t_current) = x(time*5+1);
            obj.result_HS_charge(t_current) = x(time*6+1);
            
            %���´���״̬
            obj.ES_SOC(t_current+1) = obj.ES_SOC(t_current) - obj.result_ES_discharge(t_current) / obj.ES_eff / obj.ES_totalC + obj.result_ES_charge(t_current) * obj.ES_eff / obj.ES_totalC;
            obj.HS_SOC(t_current+1) = obj.HS_SOC(t_current) - obj.result_HS_discharge(t_current) / obj.HS_eff / obj.HS_totalC + obj.result_HS_charge(t_current) * obj.HS_eff / obj.HS_totalC;
        end
        
        
        % ����TC�������� ���ַ�
        % �����г�����۸񡢳��幦�ʣ��ڱ��ֳ��幦�ʲ��������£�������Ż�
        function [x,fval,exitflag,output,lambda] = conditionHandlePrice_2(obj, Eprice, Gprice, t_current, clearDemand) %�����x����t_current��Խ��Խ��
            global period
            conditionEle = clearDemand;
            
            [x,fval,exitflag,output,lambda] = localOptimal(obj, Eprice, Gprice, t_current, conditionEle);
            time = 24*period - t_current + 1; %��ʱ���
            
            % ִֻ�е�ǰ���ڵĽ��
            obj.result_Ele(t_current) = x(1);
            obj.result_CHP_G(t_current) = x(time+1);
            obj.result_Boiler_G(t_current) = x(time*2+1);
            obj.result_ES_discharge(t_current) = x(time*3+1);
            obj.result_ES_charge(t_current) = x(time*4+1);
            obj.result_HS_discharge(t_current) = x(time*5+1);
            obj.result_HS_charge(t_current) = x(time*6+1);
            
            %���´���״̬
            obj.ES_SOC(t_current+1) = obj.ES_SOC(t_current) - obj.result_ES_discharge(t_current) / obj.ES_eff / obj.ES_totalC + obj.result_ES_charge(t_current) * obj.ES_eff / obj.ES_totalC;
            obj.HS_SOC(t_current+1) = obj.HS_SOC(t_current) - obj.result_HS_discharge(t_current) / obj.HS_eff / obj.HS_totalC + obj.result_HS_charge(t_current) * obj.HS_eff / obj.HS_totalC;
        end
        
        
        
        function [x,fval,exitflag,output,lambda] = conditionHandlePrice_DA(obj, Eprice, Gprice, t_current, clearDemand) %�����x����t_current��Խ��Խ��
            global period
            conditionEle = clearDemand;
            
            [x,fval,exitflag,output,lambda] = localOptimal(obj, Eprice, Gprice, t_current, conditionEle);
            time = 24*period - t_current + 1; %��ʱ���
            for pt = t_current: 24 * period
            % ִֻ�е�ǰ���ڵĽ��
            obj.result_Ele(pt) = x(1 + pt - t_current);
            obj.result_CHP_G(pt) = x(time + 1 + pt - t_current);
            obj.result_Boiler_G(pt) = x(time*2 + 1 + pt - t_current);
            obj.result_ES_discharge(pt) = x(time*3 + 1 + pt - t_current);
            obj.result_ES_charge(pt) = x(time*4 + 1 + pt - t_current);
            obj.result_HS_discharge(pt) = x(time*5 + 1 + pt - t_current);
            obj.result_HS_charge(pt) = x(time*6 + 1 + pt - t_current);
            
            %���´���״̬
            obj.ES_SOC(pt+1) = obj.ES_SOC(pt) - obj.result_ES_discharge(pt) / obj.ES_eff / obj.ES_totalC + obj.result_ES_charge(pt) * obj.ES_eff / obj.ES_totalC;
            obj.HS_SOC(pt+1) = obj.HS_SOC(pt) - obj.result_HS_discharge(pt) / obj.HS_eff / obj.HS_totalC + obj.result_HS_charge(pt) * obj.HS_eff / obj.HS_totalC;
        
            end
        end
        % ����Ż����
        function [Ele, G_CHP, G_Boiler, ES_discharge, ES_charge, HS_discharge, HS_charge, ES_SOC, HS_SOC, Le, Lh, solarP, windP] = getResult(obj)
            Ele = obj.result_Ele;
            G_CHP = obj.result_CHP_G;
            G_Boiler = obj.result_Boiler_G;
            ES_discharge = obj.result_ES_discharge;
            ES_charge = obj.result_ES_charge;
            HS_discharge = obj.result_HS_discharge;
            HS_charge = obj.result_HS_charge;
            ES_SOC = obj.ES_SOC;
            HS_SOC = obj.HS_SOC;
            % ͬʱ���ƫ�ƺ�ĸ������������Դ
            Le = obj.Le;
            Lh = obj.Lh;
            solarP = obj.solarP;
            windP = obj.windP;
        end
        
        
        
        % �����Ż����
        function [result_balance_P, result_balance_H, result_check_ES, result_check_HS] = testResult(obj)
            %�硢�ȹ���ƽ���Բ��ԣ�����Ҫ����������
            result_balance_P = obj.result_Ele + obj.CHP_GE_eff.*obj.result_CHP_G + obj.result_ES_discharge - obj.result_ES_charge - obj.Le + obj.windP + obj.solarP;
            result_balance_H = obj.CHP_GH_eff.*obj.result_CHP_G + obj.Boiler_eff.*obj.result_Boiler_G + obj.result_HS_discharge - obj.result_HS_charge - obj.Lh;
            %�䡢�Ź���������һ������
            result_check_ES = obj.result_ES_discharge .* obj.result_ES_charge;
            result_check_HS = obj.result_HS_discharge .* obj.result_HS_charge; %��һ��С���⣬��Ϊ�ȹ��ڳ�ԣ
        end
        
        
        % �����Ż�
        function [x,fval,exitflag,output,lambda] = localOptimal(obj, Eprice, Gprice, t_current, conditionEle)
            %�����������Ҫ��obj������ᱨ��too many input arguments
            
            %��conditionEle<9e9ʱ����ʾ�ڸ����ĵ�ǰʱ�̵Ĺ������£������Ż�
            %����ǰʱ�̵Ĺ���������Сֵ�����ֵ���趨Ϊ����ֵ
            
            global period
            time = 24*period - t_current + 1; %��ʱ���
            var = time * 7; %�ܱ�����
            %��1,2,3��time�ǹ�������CHP����������¯����������4-7��time�Ǵ��硢���ȵķš��书��
            
            
            
            %��һ����ϵ��f �Ǹ�������
            f = zeros(var, 1);
            for i = 1 : time
                % f(i, 1) = Eprice(i); %Eprice��size����t_current�仯��
                f(i, 1) = Eprice(t_current + i - 1); %Eprice��size���䣬����ȡ����ֵ
                f(time+i, 1) = Gprice;
                f(time*2+i, 1) = Gprice;
            end
            
            %����������
            ub = zeros(var, 1);
            lb = zeros(var, 1);
            for i = 1 : time
                ub(i, 1) = obj.Ele_max;
                ub(time+i, 1) = obj.CHP_G_max;
                ub(time*2+i, 1) = obj.Boiler_G_max;
                ub(time*3+i, 1) = obj.ES_Pmax;
                ub(time*4+i, 1) = obj.ES_Pmax;
                ub(time*5+i, 1) = obj.HS_Hmax;
                ub(time*6+i, 1) = obj.HS_Hmax;
            end
            for i = 1 : time
                lb(i, 1) = obj.Ele_min;
                lb(time+i, 1) = obj.CHP_G_min;
                %                     lb(time*2+i, 1) = 0;
                %                     lb(time*3+i, 1) = 0;
                %                     lb(time*4+i, 1) = 0;
                %                     lb(time*5+i, 1) = 0;
                %                     lb(time*6+i, 1) = 0;
            end
            if length(conditionEle)>1
                ub(1:length(conditionEle),1) = conditionEle;
                lb(1:length(conditionEle),1) = conditionEle;
            else
                if conditionEle < 9e9
                    ub(1,1) = conditionEle;
                    lb(1,1) = conditionEle;
                end
            end
            
            
            
            %��ʽԼ���������硢��ƽ��Լ�����������󣬸�Ϊ����ʽ�����硢�ȴ���ƽ����Լ������Ϊ����ʽԼ������
            %�硢��ƽ��Լ��
            Aeq_Ebus = zeros(time, var);
            Aeq_Hbus = zeros(time, var);
            %beq_Ebus = - obj.Le;
            %beq_Hbus = - obj.Lh;
            beq_Ebus = - obj.Le(t_current : 24*period) + obj.windP(t_current : 24*period) + obj.solarP(t_current : 24*period); %Le��size���䣬����ȡ����ֵ
            beq_Hbus = - obj.Lh(t_current : 24*period); %Lh��size���䣬����ȡ����ֵ
            for i=1:time
                Aeq_Ebus(i,i) = - obj.Ele_eff; %������
                Aeq_Ebus(i,time+i) = - obj.CHP_GE_eff;
                Aeq_Ebus(i,time*3+i) = - 1; %�ŵ�
                Aeq_Ebus(i,time*4+i) = 1; %���
            end
            for i=1:time
                Aeq_Hbus(i,time+i) = - obj.CHP_GH_eff;
                Aeq_Hbus(i,time*2+i) = - obj.Boiler_eff;
                Aeq_Hbus(i,time*5+i) = - 1; %����
                Aeq_Hbus(i,time*6+i) = 1; %����
            end
            
            
            %�硢�ȴ���ƽ����Լ��
            Aeq_ES = zeros(1, var);
            beq_ES = - (obj.ES_targetSOC - obj.ES_SOC(t_current)) * obj.ES_totalC;
            for i=1:time
                Aeq_ES(1, time*3+i) = 1/obj.ES_eff; %�ŵ�
                Aeq_ES(1, time*4+i) = - 1*obj.ES_eff; %���
            end
            Aeq_HS = zeros(1, var);
            beq_HS = - (obj.HS_targetSOC - obj.HS_SOC(t_current)) * obj.HS_totalC;
            for i=1:time
                Aeq_HS(1, time*5+i) = 1/obj.HS_eff; %����
                Aeq_HS(1, time*6+i) = - 1*obj.HS_eff; %����
            end
            
            
            
            %����ʽԼ��������SOCԼ�����������͵�Լ������������Լ����
            %SOCԼ�� A1�����ޣ�A2������
            A1_Esoc = zeros(time, var);
            A2_Esoc = zeros(time, var);
            b1_Esoc = ones(time,1) * (obj.ES_maxSOC - obj.ES_SOC(t_current)) * obj.ES_totalC;
            b2_Esoc = ones(time,1) * (obj.ES_SOC(t_current) - obj.ES_minSOC) * obj.ES_totalC;
            for i=1:time
                for j=1 : i
                    A1_Esoc(i, time*3+j) = -1/obj.ES_eff; %�ŵ�
                    A1_Esoc(i, time*4+j) = 1*obj.ES_eff; %���
                end
            end
            for i=1:time
                for j=1 : i
                    A2_Esoc(i, time*3+j) = 1/obj.ES_eff; %�ŵ�
                    A2_Esoc(i, time*4+j) = -1*obj.ES_eff; %���
                end
            end
            
            A1_Hsoc = zeros(time, var);
            A2_Hsoc = zeros(time, var);
            b1_Hsoc = ones(time,1) * (obj.HS_maxSOC - obj.HS_SOC(t_current)) * obj.HS_totalC;
            b2_Hsoc = ones(time,1) * (obj.HS_SOC(t_current) - obj.HS_minSOC) * obj.HS_totalC;
            for i=1:time
                for j=1 : i
                    A1_Hsoc(i, time*5+j) = -1/obj.HS_eff; %����
                    A1_Hsoc(i, time*6+j) = 1*obj.HS_eff; %����
                end
            end
            for i=1:time
                for j=1 : i
                    A2_Hsoc(i, time*5+j) = 1/obj.HS_eff; %����
                    A2_Hsoc(i, time*6+j) = -1*obj.HS_eff; %����
                end
            end
            
            %�������͵�Լ��
            A_Gmax = zeros(time, var);
            b_Gmax = ones(time,1) .* obj.Gas_max;
            for i=1:time
                A_Gmax(i, time+i) = 1;
                A_Gmax(i, time*2+i) = 1;
            end
            
            
            
            %������������Լ��
            %��ʽԼ���������硢��ƽ��Լ������Ϊ����ʽ�����硢�ȴ���ƽ����Լ������Ϊ����ʽ��
            %����ʽԼ��������SOCԼ�����������͵�Լ������������Լ����
            Aeq=[];
            beq=[];
            A=[Aeq_Ebus; Aeq_Hbus;   Aeq_ES; Aeq_HS;    A1_Esoc; A2_Esoc; A1_Hsoc; A2_Hsoc;  A_Gmax];
            b=[beq_Ebus; beq_Hbus;   beq_ES; beq_HS;    b1_Esoc; b2_Esoc; b1_Hsoc; b2_Hsoc;  b_Gmax];
            
            %             %fmincon��Ҫ�г�һ����ʼ���н�
            %             x0 = zeros(var,1);
            %             for i = 1 : time
            %                 x0(i) = min(-beq_Ebus(i), obj.Ele_max); % ��������������·����
            %                 x0(time+i) = (-beq_Ebus(i) - x0(i)) / obj.CHP_GE_eff; % CHP�������������ĵ���CHP����˳�㷢��
            %                 x0(time*2+i) = max(-beq_Hbus(i) - x0(time+i)*obj.CHP_GH_eff , 0) / obj.Boiler_eff; % boiler�����������������ɹ�¯��
            %             %     x0(time*3+i, 1) = 0;
            %             %     x0(time*4+i, 1) = 0;
            %             %     x0(time*5+i, 1) = 0;
            %             %     x0(time*6+i, 1) = 0;
            %             end
            
            
            [x,fval,exitflag,output,lambda] = linprog(f,A,b,Aeq,beq,lb,ub);
            
            %             options = optimoptions('fmincon','MaxFunEvals',1000000);
            %             [x,fval,exitflag,output,lambda] = fmincon('myfun_1', x0, A, b, Aeq, beq, lb, ub, 'mycon', options);
            
            if exitflag ~= 1
                %                 error('û�п��н�')
            end
            
        end
        
    end
    
end

