# Environment

Use `bluespec-git`, `bluespec-contrib-git`, `yosys-git` and `nextpnr-git` from [Chaotic AUR](https://aur.chaotic.cx), or [docker-fpga-builder](https://github.com/thotypous/docker-fpga-builder).

# Programming data to external flash

```
echo "hello world" > test.txt
openFPGALoader -b tangnano9k --external-flash test.txt
```

# Running

```
make load
```

# Caveats

USB UART in Tang Nano 9k is an emulated FTDI which seems to be a little buggy.

The only way I found to reliably set the baud rate was a combination of GNU screen and picocom. Right after loading the bitfile to board, run:

```
screen /dev/ttyUSB1 3000000,cs8,-parenb,cstopb
```

Then close GNU screen by typing `Ctrl+a k y`.

After that, run picocom:

```
picocom -b 3000000 -d 8 -p 1 -y n /dev/ttyUSB1
```

Then close picocom by typing `Ctrl+A Ctrl+X`.

Finally, run hexdump and have fun:

```
hexdump -C /dev/ttyUSB1
```
