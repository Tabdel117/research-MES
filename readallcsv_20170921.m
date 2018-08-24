clc
clear

%{
%��ȡ��������
file=dir('E:\JasonPC\Study\GridLAB-D\03-tool\PowerMatcher\����Դ�Ż�\�����������ݣ�282����\*.csv');
period = 60/15; %�Ż������Ƕ��ٷ��ӣ��޸ķ�ĸ

count = 0; %count<n��ֻ������Чվ��
% loadname={'initial','initial'};

for n=1:length(file)
    %     temp=dlmread(['E:\new\',file(n).name],' ',0,1);
    %     eval([file(n).name(1:end-4),'=temp;'])
    
    %��csv�ļ�
    fid = fopen(['E:\JasonPC\Study\GridLAB-D\03-tool\PowerMatcher\����Դ�Ż�\�����������ݣ�282����\',file(n).name]);
    %��ȡ��ͷ ���ݷ���Ϊcell���� ���ø�ʽtitle{1}
    title = textscan(fid, '%s %s %s %s %s',1,'delimiter', ',');
    %��ȡ���� ����Ϊcell����
    data = textscan(fid, '%s %s %s %s %f','delimiter', ','); %d32��������s���ַ�����f�Ǹ���
    fclose(fid);
    
    power = data{1,5};
    if mod(length(power),(24*period))==0 && ~isempty(power) && min(power)>=0
        count = count + 1;
        loadName{count} = file(n).name;
        
        con = length(power) / (24*period);
        if con == 1
            loadValue(:,count) = power;
        else
            loadValue(1:(24*period) , count) = zeros(24*period , 1);
            for i = 1:length(power)
                loadValue(ceil(i/con) ,count) = loadValue(ceil(i/con) ,count) + power(i)/con;
            end
        end
        
        % ������߸��ɡ���͸������ڵ�ʱ��
        [peakPower, peakTime] = max( loadValue(:,count) );
%         maxPowerList(count,1) = maxPower;
        list_peakTime(count, 1) = (peakTime-1)/period;
%         if maxTimeList(count, 1) >= 8 && maxTimeList(count, 1) < 12 || maxTimeList(count, 1) >= 17 && maxTimeList(count, 1) < 21 || maxTimeList(count, 1) >= 0 && maxTimeList(count, 1) < 8
%             maxFlagList(count, 1) = 2;
%         else
%             maxFlagList(count, 1) = 1;
%         end
        [valleyPower, valleyTime] = min( loadValue(:,count) );
        list_valleyTime(count, 1) = (valleyTime-1)/period;
        
        
        % �����ʣ�ƽ����������߸��ɵı��ʡ�
        avgPower = sum( loadValue(:,count) ) / length( loadValue(:,count) );
        list_avgRate(count, 1) = avgPower / peakPower;
                
        % ��С�����ʣ���������͸�������߸��ɵı��ʡ�
        list_valleyRate(count, 1) = valleyPower / peakPower;
        
        % ��Ȳ��߸�������͸���֮�
        % ��Ȳ��ʣ���Ȳ�����߸��ɵı��ʡ�
        list_diffRate(count, 1) = (peakPower - valleyPower) / peakPower;
        
        %ѡȡ�з�Ȳ�ĵ縺��
        %Ҫ����߸����ڷ�ʱ����͸����ڹ�ʱ��������������
%         if ( list_peakTime(count, 1) >= 8 && list_peakTime(count, 1) < 12 || list_peakTime(count, 1) >= 17 && list_peakTime(count, 1) < 21 )...
%                 && ( list_valleyTime(count, 1) >= 0 && list_valleyTime(count, 1) < 8 )...
%                 && ( list_valleyRate(count, 1) >= 0.4 && list_valleyRate(count, 1) <= 0.6 )
%             list_flag(count, 1) = 11;
%         else
%             list_flag(count, 1) = 0;        
%         end
        
        %ѡȡ��Ȳ��С���ȸ���
        %Ҫ����߸����ڷ�ʱ����͸����ڹ�ʱ��������������
        if ( list_peakTime(count, 1) >= 8 && list_peakTime(count, 1) < 12 || list_peakTime(count, 1) >= 17 && list_peakTime(count, 1) < 21 )...
                && ( list_valleyTime(count, 1) >= 0 && list_valleyTime(count, 1) < 8 )...
                && ( list_valleyRate(count, 1) >= 0.8 )
            list_flag(count, 1) = 11;
        else
            list_flag(count, 1) = 0;        
        end
        
    else
        disp([file(n).name,' ����������'])
    end
    
    
end

% ֮ǰ���1h���������
% save tmp1.mat loadName
% save tmp2.mat loadValue
%20171229 ��Ϊ�洢30min����
% save data_loadName_30min.mat loadName
% save data_loadValue_30min.mat loadValue
%20180201 ��Ϊ�洢15min����
save data_loadName_15min.mat loadName
save data_loadValue_15min.mat loadValue
%}


%��ȡ��������Դ������
file=dir('E:\JasonPC\Study\GridLAB-D\03-tool\PowerMatcher\Data\����_����-����ת������\�����Ŷ�_����-����ת������\Penn_State_PA_result\*.txt');
period = 60 / 15; %�Ż������Ƕ��ٷ��ӣ��޸ķ�ĸ

count = 0; %count<n��ֻ������Чվ��
% loadname={'initial','initial'};

for n=1:length(file)
    %     temp=dlmread(['E:\new\',file(n).name],' ',0,1);
    %     eval([file(n).name(1:end-4),'=temp;'])
    
    %��csv�ļ�
    fid = fopen(['E:\JasonPC\Study\GridLAB-D\03-tool\PowerMatcher\Data\����_����-����ת������\�����Ŷ�_����-����ת������\Penn_State_PA_result\',file(n).name]);
    %��ȡ��ͷ ���ݷ���Ϊcell���� ���ø�ʽtitle{1}
    title = textscan(fid, '%s %s %s %s %s %s %s %s',1,'delimiter', '\t');
    %��ȡ���� ����Ϊcell����
    data = textscan(fid, '%s %s %f %f %f %f %f %f','delimiter', '\t'); %d32��������s���ַ�����f�Ǹ���
    fclose(fid);
    
    solar = data{1,6};
    wind = data{1,5};
    
    
    
    if mod(length(solar),(24*period))==0 && ~isempty(solar) && min(solar)>=0 && max(solar)<2e5 ... %����ʹ��max����
        && mod(length(wind),(24*period))==0 && ~isempty(wind) && min(wind)>=0
    
        count = count + 1;
        renewableName{count} = file(n).name;
        
        con = length(solar) / (24*period);
        if con == 1
            solarValue(:,count) = solar;
        else
            solarValue(1:(24*period) , count) = zeros(24*period , 1);
            for i = 1:length(solar)
                solarValue(ceil(i/con) ,count) = solarValue(ceil(i/con) ,count) + solar(i)/con;
            end
        end
        
     
        con = length(wind) / (24*period);
        if con == 1
            windValue(:,count) = wind;
        else
            windValue(1:(24*period) , count) = zeros(24*period , 1);
            for i = 1:length(wind)
                windValue(ceil(i/con) ,count) = windValue(ceil(i/con) ,count) + wind(i)/con;
            end
        end

    else
        disp([file(n).name,' �����÷����������'])
    end

end

% ֮ǰ���1h���������
% save renewableName.mat renewableName
% save solarValue.mat solarValue
% save windValue.mat windValue
%20171229 ��Ϊ�洢30min����
% save renewableName_30min.mat renewableName
% save solarValue_30min.mat solarValue
% save windValue_30min.mat windValue
%20180201 ��Ϊ�洢15min����
save renewableName_15min.mat renewableName
save solarValue_15min.mat solarValue
save windValue_15min.mat windValue