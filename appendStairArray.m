function [ result ] = appendStairArray(array)%Ϊstairs��ͼ�������������һ��
    [row, col] = size(array);
    if row == 1 %������
        result = [array, array(end)];
    elseif col == 1 %������
        result = [array; array(end)];
    else %����
        result = [array; array(end, :)];
    end
end