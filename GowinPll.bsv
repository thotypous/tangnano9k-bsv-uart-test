import Clocks::*;

typedef struct {
    String fclkin;
    Integer idiv_sel;
    Integer fbdiv_sel;
    Integer odiv_sel;
} GowinClockGenParams deriving (Bits, Eq);

interface GowinClockGen;
    interface Clock clkout;
    (* always_ready *)
    method Bool locked;
endinterface

import "BVI" rPLL =
module vMkrPLL#(GowinClockGenParams params)(GowinClockGen);
    default_clock inclk(CLKIN);
    default_reset no_reset;

    parameter FCLKIN = params.fclkin;
    parameter IDIV_SEL = params.idiv_sel;
    parameter FBDIV_SEL = params.fbdiv_sel;
    parameter ODIV_SEL = params.odiv_sel;

    input_reset rst(RESET) clocked_by(no_clock) <- invertCurrentReset;
    input_reset rst_p(RESET_P) clocked_by(no_clock) <- invertCurrentReset;

    port CLKFB = 1'b0;
    port FBDSEL = 6'b0;
    port IDSEL = 6'b0;
    port ODSEL = 6'b0;
    port PSDA = 4'b0;
    port DUTYDA = 4'b0;
    port FDLY = 4'b0;

    output_clock clkout(CLKOUT);

    method LOCK locked() clocked_by(no_clock) reset_by(no_reset);

    schedule (locked) CF (locked);
endmodule

module mkGowinClockGen#(GowinClockGenParams params)(GowinClockGen);
    (* hide *)
    let _m <- vMkrPLL(params);
    return _m;
endmodule
