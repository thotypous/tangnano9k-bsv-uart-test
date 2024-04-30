import RS232::*;
import GetPut::*;
import GowinPll::*;
import Clocks::*;

interface UartTest;
    interface RS232 rs232;
    (* always_ready, prefix="", result="LED" *)
    method Bit#(6) led;

    interface Clock unused_clock;
    interface Reset unused_reset;
endinterface

(* synthesize *)

module mkUartTest(UartTest);
    /* Target-Device:                GW1NR-9 C6/I5
     * Given input frequency:        27.000 MHz
     * Requested output frequency:   65.536 MHz
     * Achieved output frequency:    65.571 MHz
     */
    GowinClockGen clkgen <- mkGowinClockGen(GowinClockGenParams {
        fclkin: "27",
        idiv_sel: 6,
        fbdiv_sel: 16,
        odiv_sel: 8
    });

    Reset new_reset <- mkAsyncResetFromCR(3, clkgen.clkout);

    // 65.571 MHz / 16 / 36  == 113839  ~ 115200
    // 65.571 MHz / 16 / 427 ==   9598  ~   9600
    UART#(16) uart <- mkUART(8, NONE, STOP_1, 427, clocked_by clkgen.clkout, reset_by new_reset);

    Reg#(Bit#(6)) led_reg <- mkReg(0, clocked_by clkgen.clkout, reset_by new_reset);

    rule do_stuff;
        let b <- uart.tx.get;
        uart.rx.put(b); // echo
        led_reg <= truncate(b);
    endrule

    interface rs232 = uart.rs232;
    method led = led_reg;

    interface unused_clock = clkgen.clkout;
    interface unused_reset = new_reset;
endmodule
