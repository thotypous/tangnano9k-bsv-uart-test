import UART::*;
import GetPut::*;

interface UartTest;
    (* prefix="" *)
    interface UartRxWires uart_rx_wires;
    (* prefix="" *)
    interface UartTxWires uart_tx_wires;
    (* always_ready, prefix="", result="LED" *)
    method Bit#(6) led;
endinterface

(* synthesize *)
module mkUartTest(UartTest);
    UartRx uart_rx <- mkUartRx;
    UartTx uart_tx <- mkUartTx;

    Reg#(Bit#(6)) led_reg <- mkReg(0);

    rule do_stuff;
        let b <- uart_rx.rx.get;
        uart_tx.tx.put(b); // echo
        led_reg <= led_reg+1;
    endrule

    interface uart_rx_wires = uart_rx.wires;
    interface uart_tx_wires = uart_tx.wires;
    method led = ~led_reg;
endmodule
