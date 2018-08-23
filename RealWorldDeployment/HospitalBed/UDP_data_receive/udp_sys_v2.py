import socket
import types
import time
import datetime
import thread
import os
import decode_data
import copy


PORT = 5000    #udp protocol port
ServerIp = '192.168.1.193'
FILEPATH = './activity_demo/'  #data saved path


server_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

server_address = (ServerIp, PORT)

server_socket.bind(server_address)

def all_receive_data(sensor_ip_list):
    time_tag = get_time_tag()
    old_min = time_tag[14:16]
    file_date = time_tag[0:14]
 
    all_data  = []
    
    for ii in range(len(sensor_ip_list)):
        all_data.append([])  #initial data list
        all_data[ii] = ''
    while True:
#    for ii in range(data_time*50/3): # each package have 600 data,sample rate is 10000,so each second it have 50/3 packages
        receive_data, client_address = server_socket.recvfrom(2048)
        data_ip = str(client_address[0])
#        print len(receive_data)
        if len(receive_data) < 100:
            re_message = decode_data.decode_config_message(receive_data)        
            if re_message in 'Sp':
                print("%s are stoped!"%data_ip)
                continue 
        if data_ip in sensor_ip_list:
            data_location_num = sensor_ip_list.index(data_ip)
        else:
            print ('%s sensor still upload data!'%data_ip)
            continue

        time_tag = get_time_tag()
        new_min = time_tag[14:16]
        if len(receive_data) < 600 :
            print("111")
            continue

#        print time_tag 
#        print len(receive_data)
        tmpdata = decode_data.decode_data(receive_data)
        # print(type(tmpdata))
        all_data[data_location_num] = all_data[data_location_num] + time_tag + tmpdata +'\n'
        if new_min == old_min:
            continue 
        else:
            filename = file_date + old_min + '.txt'
            old_min = new_min
            file_date = time_tag[0:14]
            writ_data = copy.deepcopy(all_data)
            thread.start_new_thread(save_file,(sensor_ip_list,filename,writ_data))
       
            for ii in range(len(sensor_ip_list)):
                all_data[ii] = ''
        #break 
        #print receive_data

def receive_data(sensor_ip, target_str):
    
    flag = False
    start_time = time.time()
    while True:

    	receive_data, client_address = server_socket.recvfrom(1024)
        real_data = decode_data.decode_config_message(receive_data)        
    #	print ('%s and message is %s'%(str(client_address[0]), real_data))
            
    	if (cmp(str(client_address[0]), sensor_ip)== 0) and target_str in real_data:
    #    print ('%s and message is %s'%(client_address, real_data))
            flag = True
            break
        now_time = time.time()
        if now_time - start_time > 1:
            break

    return flag

def send_data(sensor_ip, data_str):

    sensor_address = (sensor_ip, PORT)    
    server_socket.sendto(data_str.encode(),sensor_address)

def save_file(sensor_ip_list, filename, data_list):
    
    date = filename.split('_')[0]
    for count in range( len(sensor_ip_list)):
        if os.path.exists(FILEPATH + sensor_ip_list[count] +'/'+ date +'/') == False:
            os.makedirs(FILEPATH + sensor_ip_list[count] + '/'+ date)
        complete_filename = FILEPATH + sensor_ip_list[count] +'/' + date +'/' +filename
        print complete_filename
        datafile = open(complete_filename,'wb')
        datafile.write(data_list[count])
        datafile.close()

def get_time_tag():

    timenow = datetime.datetime.now()
    filename = str(timenow)
    filename = filename.replace(' ','_')
    filename = filename.replace(':','-')
    return filename


def sensor_config_start(sensor_ip, GAIN, data_time):

    ZERO = chr(0)+chr(0)
    RATE = 10000
    state = 0
   
    reset_com = 'r' + ZERO
    test_com ='t' + ZERO
    send_data(sensor_ip, reset_com)
    send_data(sensor_ip, test_com)
    if receive_data(sensor_ip, 'T'):
#        print 'test success'
        state = 1
    else:
        print ('%s test err'%sensor_ip)
    
    config_com = 'c' + chr(0) +chr(0) + chr(4)+chr(0) +chr(16) + chr(39)+chr(GAIN) +chr(0)
    send_data(sensor_ip, config_com)
    if receive_data(sensor_ip, 'Co'):
#        print 'config success'
        state = state + 1
    else:
        print ('%s config fail'%sensor_ip)
    
    start_com  = 's' + ZERO + chr(1)+chr(0) + 't'
    if state == 2:
        send_data(sensor_ip, start_com)
        if receive_data(sensor_ip ,'St'): # it means it start to update data
            print("%s start upload data!"%sensor_ip)
#            all_receive_data(data_time)
        else:
            print( "%s can not start"%sensor_ip)
            
def sensor_stop(sensor_ip_list):

    stop_com  = 's' + chr(0)+chr(0)+ chr(1)+chr(0) + 'p'
    for ii in sensor_ip_list:
        send_data(ii, stop_com)
#print ("%s stoped"%ii)
 
def my_receive(): 
    global GAIN
    GAIN  = 60
    data_time = 80 #seconds
    
    sensor_ip_gate ='192.168.1.'
    
    sensor_ip_list =[]
    
    tmp ="""
    start_ip = 232
    sensor_number = 1
    for count in range(sensor_number):
    tmp_sensor_ip = start_ip + count
    sensor_ip = sensor_ip_gate + str(tmp_sensor_ip)
        sensor_ip_list.append(sensor_ip)
"""
    sensor_ip_list.append('192.168.1.231')
    sensor_ip_list.append('192.168.1.233')
    sensor_ip_list.append('192.168.1.236')
    sensor_ip_list.append('192.168.1.237')
    sensor_ip_list.append('192.168.1.239')
#  sensor_ip_list.append('192.168.1.233')
#   sensor_ip_list.append('192.168.1.238')
#   sensor_ip_list.append('192.168.1.239')
    
    
    
    print ("\n*****config information***** \nGain =  %d , record time = %d seconds \nstarted sensor are : %s \n**************************\n" % (GAIN, data_time, str(sensor_ip_list)))

    for ii in sensor_ip_list:

        sensor_config_start(ii, GAIN,data_time)

    start_time = get_time_tag()
    thread.start_new_thread(all_receive_data,(sensor_ip_list,))
    if data_time ==0:

        time.sleep(data_time)
        sensor_stop(sensor_ip_list)
    else:
        while True:
	    time.sleep(10)
    
    time.sleep(2)

    server_socket.close() 
    finish_time = get_time_tag()
    print start_time
    print finish_time


if __name__ == "__main__":
    
    my_receive()
