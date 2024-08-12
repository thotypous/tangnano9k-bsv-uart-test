import RS232::*;
import GetPut::*;
import FIFOF::*;
import Connectable::*;
import Clocks::*;
import BUtils::*;

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

    Reg#(LBit#(TMul#(1600, 8))) trigger_left <- mkReg(0);
    let is_trigged = trigger_left != 0;

    Reg#(Bit#(1)) prev <- mkReg(0);
    Reg#(Bit#(16)) how_long <- mkReg(0);
    Reg#(Bit#(6)) strikes <- mkReg(0);

    Reg#(Bit#(6)) led_reg <- mkReg(0);

    rule discard;
        let b <- uart.tx.get;
    endrule

    method Action put_eth_rx(Bit#(1) eth_rx);
        led_reg <= (led_reg << 1) | extend(eth_rx);

        prev <= eth_rx;
        if (is_trigged) begin
            trigger_left <= trigger_left - 1;
            how_long <= 0;
            strikes <= 0;
        end else begin
            if (eth_rx == prev) begin
                how_long <= how_long + 1;
            end else begin
                how_long <= 0;
                if (how_long == 7 || how_long == 8 || how_long == 9) begin
                    strikes <= strikes + 1;

                    if (strikes == 3) begin
                        trigger_left <= 1600*8;
                    end
                end else begin
                    strikes <= 0;
                end
            end
        end
    endmethod
    interface rs232 = uart.rs232;
    interface rs232_rst = rst_uart;
    method led = ~led_reg;
    method dbg = is_trigged ? 1 : 0;
endmodule
