import serial
import os

BAUDRATE=3000000

# open twice to work around FTDI emulator apparent bug
ser = serial.Serial('/dev/ttyUSB1', baudrate=BAUDRATE)
print(ser.read_all())
ser.close()
ser = serial.Serial('/dev/ttyUSB1', baudrate=BAUDRATE)
print(ser.read_all())
assert os.system('make -C .. load') == 0

# twice a complete 16-bit LFSR cycle
data = ser.read(1<<18)

with open('acquired_data.bin', 'wb') as f:
    f.write(data)
