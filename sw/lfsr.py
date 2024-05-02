import struct

with open('reference_data.bin', 'wb') as f:
    feed = 0x8016
    r = 1
    for i in range(1<<18):
        f.write(struct.pack('<H', r))
        if (r & 1) == 1:
            r = (r >> 1) ^ feed
        else:
            r = r >> 1
