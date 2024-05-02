BOARD=tangnano9k
FAMILY=GW1N-9C
DEVICE=GW1NR-LV9QN88PC6/I5

all: uart.fs

mkUartTest.v: UartTest.bsv
	bsc -p +:%/Libraries/FPGA/Misc/ -u -verilog UartTest.bsv

# Synthesis
uart.json: top.v mkUartTest.v
	yosys -p "read_verilog /opt/bluespec/lib/Verilog/SizedFIFO.v; read_verilog /opt/bluespec/lib/Verilog/Counter.v; read_verilog mkUartTest.v; read_verilog pll.v; read_verilog top.v; synth_gowin -top top -json uart.json"

# Place and Route
uart_pnr.json: uart.json
	nextpnr-himbaechel --json uart.json --write uart_pnr.json --freq 27 --device ${DEVICE} --vopt family=${FAMILY} --vopt cst=${BOARD}.cst

# Generate Bitstream
uart.fs: uart_pnr.json
	gowin_pack -d ${FAMILY} -o uart.fs uart_pnr.json

# Program Board
load: uart.fs
	openFPGALoader -b ${BOARD} uart.fs

# Cleanup build artifacts
clean:
	rm mkUartTest.v uart.fs

.PHONY: load clean
.INTERMEDIATE: uart_pnr.json uart.json
