function [ deccolor ] = ColorHex( hexcolor )
%UNTITLED3 �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
deccolor(1)=hex2dec(hexcolor(1:2));
deccolor(2)=hex2dec(hexcolor(3:4));
deccolor(3)=hex2dec(hexcolor(5:6));

end

