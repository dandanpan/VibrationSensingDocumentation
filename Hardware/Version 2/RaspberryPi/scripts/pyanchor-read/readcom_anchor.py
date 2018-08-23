import string
import time
import serial
import thread
import Queue
import math
import struct

qr = Queue.Queue(0)
counter = 0;

def recive_data(com):
    global qr
    global counter   
    if tSerial.inWaiting() > 0:
        comdata = com.read(com.inWaiting())
    comdata = ''
    bufferSize = 512 
    while True:
	while tSerial.inWaiting()<bufferSize:
	    time.sleep(0.005)
        comdata = com.read(bufferSize)
        qr.put(item = comdata, block = False)


def write_data(test):
    global qr
    global counter
    print("alive2")
    sampleRate = 10000
    while True:
        test = 1
        while (qr.qsize() < 10):
            time.sleep(.05)
	counter = counter + 1
	#print(qr.qsize())
	if counter == 1:
            # use datatime as file name
            currentTime = time.strftime("%Y-%m-%d_%H-%M-%S",time.localtime())
            fname = currentTime + '.txt'
            # read datas from FIFO and write them into file, each file contant 60000 datas
            f = open(fname,'w')
            print('creating file : '+fname+' ...' )
	#print(qr.qsize())
	#print(time.clock())
	for i in range(qr.qsize()):
            f.write(str(qr.get(block = False)))
	#print(time.clock())
	#print(qr.qsize())
	if counter >= 500:
            f.flush()
            f.close()
	    counter = 0
            print('creating file : '+fname+' SUCCESS !' )

if __name__=='__main__':
    state = 1
    try:
        # need change the com port name #14131
        tSerial = serial.Serial('/dev/ttyACM0',115200)
    except:
        print('ERROR-- open seroial port failed !')
        state = 0
    if (state == 1):
        thread.start_new_thread(write_data,(1,))
        thread.start_new_thread(recive_data,(tSerial,))
    while True:
            time.sleep(100)
