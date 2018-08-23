# system test
import sys
import string
import time
#import serial
import thread
import Queue
import os.path

fileNum = 1
DATA_FOLDER = './'
inputStr = DATA_FOLDER + 'DATA_1.TXT'

while os.path.isfile(inputStr):
    try:
        inputStr = DATA_FOLDER + 'DATA_' + str(fileNum) + '.txt'
        outStr1 = DATA_FOLDER + str(fileNum) + '-1.txt'
        outStr2 = DATA_FOLDER + str(fileNum) + '-2.txt'
        outStr3 = DATA_FOLDER + str(fileNum) + '-3.txt'
        f = open(inputStr,'rb')
        f1 = open(outStr1,'w')
        f2 = open(outStr2,'w')
        f3 = open(outStr3,'w')

        data = f.read(8)
        count = 0
        while data:
            if ord(data[0]) == 255 and ord(data[7]) == 254:
                number1 = ord(data[1]) + ord(data[2]) * 256
                f1.write(str(number1) + '\n')
                number2 = ord(data[3]) + ord(data[4]) * 256
                f2.write(str(number2) + '\n')
                number3 = ord(data[5]) + ord(data[6]) * 256
                f3.write(str(number3) + '\n')
            elif ord(data[0]) == 255 and ord(data[7]) == 255:
                data = f.read(8)
                timestamp = ord(data[0])+ord(data[1])*256+ord(data[2])*(256^2)+ord(data[3])*(256^3)+ord(data[4])*(256^4)+ord(data[5])*(256^5)+ord(data[6])*(256^6)+ord(data[7])*(256^7)
                f1.write(str(timestamp) + '\n')
                f2.write(str(timestamp) + '\n')
                f3.write(str(timestamp) + '\n')
                data = f.read(8)
            data = f.read(8)
        fileNum = fileNum + 1
    finally:
        f.close()
        f1.close()
        f2.close()
        f3.close()