import RS232::*;
import GetPut::*;
import Connectable::*;
import SPIFlash::*;

interface UartTest;
    interface RS232 rs232;
    (* prefix="" *)
    interface SPIFlashPins flash;
    (* always_ready, result="LED" *)
    method Bit#(6) led;
endinterface

(* synthesize *)
module mkUartTest(UartTest);
    UART#(16) uart <- mkUART(8, NONE, STOP_1, 1);
    SPIFlash spiflash <- mkSPIFlash;

    Reg#(Bit#(6)) led_reg <- mkReg(0);

    rule discard_input;
        let _ <- uart.tx.get;
    endrule

    mkConnection(spiflash.out, uart.rx);

    interface rs232 = uart.rs232;
    interface flash = spiflash.pins;
    method led = ~led_reg;
endmodule
