import RS232::*;
import GetPut::*;
import FIFOF::*;
import Connectable::*;
import Clocks::*;

interface UartTest;
    interface RS232 rs232;
    interface Reset rs232_rst;
    (* always_ready, prefix="", result="LED" *)
    method Bit#(6) led;
    (* always_ready, always_enabled, prefix="" *)
    method Action put_eth_rx(Bit#(1) eth_rx);
    (* always_ready, prefix="", result="DBG" *)
    method Bit#(1) dbg;
endinterface

(* synthesize *)
module mkUartTest#(Clock clk_uart)(UartTest);
    Reset rst_uart <- mkAsyncResetFromCR(2, clk_uart);
    UART#(16) uart <- mkUART(8, NONE, STOP_1, 1, clocked_by clk_uart, reset_by rst_uart);
    SyncFIFOIfc#(Bit#(8)) fifo_uart <- mkSyncFIFOFromCC(2, clk_uart);
    mkConnection(toGet(fifo_uart), uart.rx);

    //FIFOF#(Bit#(8)) buffer <- mkGSizedFIFOF(True, False, 1600);
    //mkConnection(toGet(buffer), toPut(fifo_uart));

    Reg#(Bit#(6)) led_reg <- mkReg(0);

    rule discard;
        let b <- uart.tx.get;
    endrule

    interface rs232 = uart.rs232;
    interface rs232_rst = rst_uart;
    method led = ~led_reg;
    method Action put_eth_rx(Bit#(1) eth_rx);
        led_reg <= (led_reg << 1) | extend(eth_rx);
        //buffer.enq({eth_rx, eth_rx, led_reg});
    endmethod
    method dbg = led_reg[0];
endmodule
