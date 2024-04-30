 * Tang Nano 9k's FTDI emulation seems to set baud rate only when requested twice (?!)

 * Even though we asked for a single stop bit, it seems to work reliably only if we ask for 2 stop bits from software side, e.g. `picocom -b 115200 -p 2 -y n /dev/ttyUSB1` or `screen /dev/ttyUSB1 115200,cs8,-parenb,cstopb`
