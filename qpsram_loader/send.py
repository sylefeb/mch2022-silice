import serial
import time
import sys
import os
import glob

if len(sys.argv) != 3:
  print("send.py <port> <file>")
  sys.exit()

ser = serial.Serial(sys.argv[1],115200)

f = open(sys.argv[2],"rb")
packet = bytearray()
packet.append(0xAA) # start tag
ser.write(packet)

while True:
  b = f.read(1)
  if not b:
    break
  ser.write(b)

ser.close()
