import RS232::*;
import GetPut::*;
import Clocks::*;

interface UartTest;
    interface RS232 rs232;
    (* always_ready, prefix="", result="LED" *)
    method Bit#(6) led;
endinterface

(* synthesize *)
module mkUartTest(UartTest);
    UART#(16) uart <- mkUART(8, NONE, STOP_1, 1);

    Reg#(Bit#(6)) led_reg <- mkReg(0);

    rule do_stuff;
        let b <- uart.tx.get;
        uart.rx.put(b); // echo
        led_reg <= truncate(b);
    endrule

    interface rs232 = uart.rs232;
    method led = led_reg;
endmodule
