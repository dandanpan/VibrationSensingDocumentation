from struct import *
import types
def decode_data(bin_data):
    head_info = bin_data[0:17]  # 17 bytes are head info
    #print head_info
    #print len(head_info)
    if len(head_info) == 17:
        head = unpack('<cHHIIHH',head_info)
        # print head
        data = bin_data[17::]
        # print len(data)
        real_data = unpack('<600H',data)
        # print type(head)
        # print type(real_data)
        return str(head) + str(real_data)
    else:
        return '000'


def decode_config_message(bin_data):
    data_len = len(bin_data)
    real_data = ''

    if data_len == 5: # t or m
        real_data = unpack('<cHH', bin_data) # make sure 'H' is correct
	return real_data[0]
    else:
        if data_len == 6: #config or start/stop
            real_data = unpack('<cHHc', bin_data)
            return real_data[0] + real_data[3]
        else:
            return 'errmessage'	


if __name__  == "__main__":
    filename = '2018-01-15_16-30-00.644228.txt'
    f = open(filename,'rb')
    bin_data = f.read()
    print len(bin_data)
    f.close()
    decode_data(bin_data)

