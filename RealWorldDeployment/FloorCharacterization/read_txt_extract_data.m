function all_data = read_txt_extract_data(sensor, date, hour, min)
%date = '2018-04-23';
%hour = '13';
%start_min = 41;
%min_count =1;
%start_ip = 238;
%sensor_count = 10;

%bad_ip =[220,225];

ip = '192.168.1.';
dirpath = './BlueBox/'
all_data=[];

tmp_sensor = ['192.168.1.', num2str(sensor)]

file_path = strcat(dirpath,tmp_sensor ,'/',date,'/');
all_data =[];


if min <10
    strmin = strcat(int2str(0), int2str(min));
else
    strmin = int2str(min);
end
tmpfilename = strcat(file_path,date,'_', hour, '-', strmin, '.txt');
tmpdata = importdata(tmpfilename);
[a,b] = size(tmpdata);
for tmptime = 1:a
    each_data = tmpdata(tmptime);
    s_each_data = char(each_data);
    real_data = strsplit(s_each_data,'(');
    real_data = real_data(3);
    real_data = char(real_data);
    [m , n ] = size(real_data);
    real_data = real_data(1:n-1);
    data = str2num(real_data);
    [tmp, LEN] = size(data);
    if LEN ~= 600
        disp('data err, please check');
        disp(tmpfilename);
        break;
    end
    all_data = [all_data, data];
end

end