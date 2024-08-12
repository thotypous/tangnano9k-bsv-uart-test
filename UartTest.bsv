import RS232::*;
import GetPut::*;
import FIFOF::*;
import Connectable::*;
import Clocks::*;
import BUtils::*;
import PAClib::*;
import Vector::*;

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

    FIFOF#(Bit#(8)) buffer <- mkSizedFIFOF(1600);
    mkConnection(toGet(buffer), toPut(fifo_uart));

    FIFOF#(Bit#(1)) deser_fifo <- mkGFIFOF(True, False);
    PipeOut#(Bit#(8)) deser_pipe <- mkCompose(
        mkCompose(
            mkCompose(mkFn_to_Pipe(vecBind), mkUnfunnel(True)),
            mkFn_to_Pipe(pack)),
        mkFn_to_Pipe(reverseBits),
        f_FIFOF_to_PipeOut(deser_fifo));
    mkConnection(toGet(deser_pipe), toPut(buffer));

    Reg#(LBit#(TMul#(1600, 8))) trigger_left <- mkReg(0);
    let is_trigged = trigger_left != 0;

    Reg#(Bit#(1)) prev <- mkReg(0);
    Reg#(Bit#(16)) how_long <- mkReg(0);
    Reg#(Bit#(6)) strikes <- mkReg(0);
    Reg#(Bool) first_trigger <- mkReg(True);

    Reg#(Bit#(6)) led_reg <- mkReg(0);

    rule discard;
        let b <- uart.tx.get;
    endrule

    method Action put_eth_rx(Bit#(1) eth_rx);
        led_reg <= is_trigged ? 1 : 0;

        prev <= eth_rx;
        if (is_trigged) begin
            if (first_trigger)
                deser_fifo.enq(eth_rx);

            if (trigger_left == 1)
                first_trigger <= False;

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

function a vecUnbind(Vector#(1,a) vec) = vec[0];

function Vector#(1,a) vecBind(a value) = cons(value, nil);
