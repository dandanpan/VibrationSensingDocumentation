
clear all;
clc;
close all;

tmpdata = importdata('22-52.txt');

[L n] = size(tmpdata);
all_data = [];
for ii=1:L
    tmp_list = tmpdata(ii);
    data_char = char(tmp_list);
    data_double = regexp(data_char,'data:','split');
    data_dd = data_double(2);
    real_data = regexp(char(data_dd),' ','split');
    
    [m n ] = size(real_data);
    if n ~= 602
        print('Err');
        break
    end
    real_data = real_data(3:n);
    ttmp_data = str2num(char(real_data))';
    all_data = [all_data, ttmp_data];
end
plot(all_data);
    
    