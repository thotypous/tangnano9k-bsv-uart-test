# Environment

Use `bluespec-git`, `bluespec-contrib-git`, `yosys-git` and `nextpnr-git` from [Chaotic AUR](https://aur.chaotic.cx), or [docker-fpga-builder](https://github.com/thotypous/docker-fpga-builder).

# Running

```
make load
```

# Caveats

USB UART in Tang Nano 9k is an emulated FTDI which seems to be a little buggy.

The only way I found to reliably set the baud rate was by calling stty before starting picocom. Right after loading the bitfile to board, run:

```
stty -F /dev/ttyUSB1 3000000 cs8 -parenb cstopb
```

Finally, run picocom and have fun:

```
picocom -b 3000000 -d 8 -p 1 -y n /dev/ttyUSB1
```
