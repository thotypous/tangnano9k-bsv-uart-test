import RS232::*;
import GetPut::*;
import LFSR::*;
import Vector::*;
import PAClib::*;
import Connectable::*;

interface UartTest;
    interface RS232 rs232;
    (* always_ready, prefix="", result="LED" *)
    method Bit#(6) led;
endinterface

(* synthesize *)
module mkUartTest(UartTest);
    UART#(16) uart <- mkUART(8, NONE, STOP_1, 1);

    Reg#(Bit#(6)) led_reg <- mkReg(0);

    LFSR#(Bit#(16)) lfsr <- mkLFSR_16;
    PipeOut#(Bit#(8)) lfsr_bytes <- mkCompose(
        mkCompose(mkFn_to_Pipe(unpack), mkFunnel),
        mkFn_to_Pipe(vecUnbind),
        f_LFSR_to_PipeOut(lfsr));
    mkConnection(toGet(lfsr_bytes), uart.rx);

    rule update_led;
        let b <- uart.tx.get;
        led_reg <= truncate(b);
    endrule

    interface rs232 = uart.rs232;
    method led = led_reg;
endmodule


function PipeOut#(a) f_LFSR_to_PipeOut(LFSR#(a) ifc);
    return (interface PipeOut;
            method a first = ifc.value;
            method Action deq = ifc.next;
            method Bool notEmpty = True;
        endinterface);
endfunction

function a vecUnbind(Vector#(1,a) vec) = vec[0];
