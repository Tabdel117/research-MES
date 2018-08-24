classdef Grid_171118 < handle
    properties %�������ʼֵ
        %��������
        eleLimit_forward; % �������΢��Ⱥ��磬����
        eleLimit_reverse; % ���ͣ�����        
        %Ͷ��
        demand_curve;
        %�����Ż����
        result_demand;
    end
    
    methods
        function obj = Grid_171118(eleLimit_total) %��ʼ������
            global priceNumbers period
            % ��������
            obj.eleLimit_forward = eleLimit_total(1); % �������΢��Ⱥ���
            obj.eleLimit_reverse = eleLimit_total(2); % ����
            % Ͷ��
            obj.demand_curve = zeros(priceNumbers, 1); %��ʼ��Ͷ������
            %�����Ż����
            obj.result_demand = zeros(24*period,1);
        end
        
            
        function gridDemand = zGenerate(obj, elePrice_current)
            global minMarketPrice priceNumbers step
            
            for i = 1 : priceNumbers
                pricePoint = minMarketPrice + (i-1) * step;
                
                if pricePoint <= elePrice_current
                    obj.demand_curve(i) = - obj.eleLimit_reverse; % ��۽ϵͣ��������磬�൱�ڱ��ظ���
                else
                    obj.demand_curve(i) = - obj.eleLimit_forward; % ��۽ϸߣ��������磬�൱�ڱ��ص�Դ
                end
            end
            gridDemand = obj.demand_curve;
        end
        
        
        function clearDemand = getClearDemand(obj, clearPrice, t_current)
            global minMarketPrice step
            
            p = (clearPrice - minMarketPrice) / step + 1;
            p1 = floor((clearPrice - minMarketPrice) / step) + 1;
            p2 = ceil((clearPrice - minMarketPrice) / step) + 1;
            
            if p1 ~= p2
                slope = (obj.demand_curve(p2) - obj.demand_curve(p1)) / (p2 - p1);
                clearDemand = slope * (p - p1) + obj.demand_curve(p1);
            else
                clearDemand = obj.demand_curve(p1);
            end
            
            obj.result_demand(t_current) = clearDemand;
        end
        
        
        function gridDemand = handlePrice(obj, Eprice, t_current)
            global elePrice
            if Eprice <= elePrice(t_current)
                gridDemand = - obj.eleLimit_reverse; % ��۽ϵͣ��������磬�൱�ڱ��ظ���
            else
                gridDemand = - obj.eleLimit_forward; % ��۽ϸߣ��������磬�൱�ڱ��ص�Դ
            end
        end
                
        
        
         % ����Ż����
        function demandRecord = getResult(obj)
            demandRecord = obj.result_demand;
        end
        
        
    end
end