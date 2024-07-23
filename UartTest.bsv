import RS232::*;
import GetPut::*;
import BUtils::*;
import FIFOF::*;
import Vector::*;

interface UartTest;
    interface RS232 rs232;
    (* always_ready, prefix="", result="LED" *)
    method Bit#(6) led;
endinterface

(* synthesize *)
module mkUartTest(UartTest);
    UART#(16) uart <- mkUART(8, NONE, STOP_1, 1);

    Reg#(LBit#(48600000)) espera <- mkReg(0);
    Reg#(Bit#(6)) counter[2] <- mkCReg(2, 0);
    Reg#(Bit#(6)) pwm_counter <- mkRegU;
    FIFOF#(Bit#(8)) remaining_byte <- mkFIFOF;
    FIFOF#(void) remaining_space <- mkFIFOF;

    (* descending_urgency = "espaco, segundo_digito, pisca" *)
    rule pisca;
        if (espera == 48600000) begin
            espera <= 0;
            counter[0] <= counter[0] + 1;
            uart.rx.put('h30 + extend(counter[0] / 10));
            remaining_byte.enq('h30 + extend(counter[0] % 10));
        end else begin
            espera <= espera + 1;
        end
    endrule

    rule segundo_digito;
        uart.rx.put(remaining_byte.first);
        remaining_byte.deq;
        remaining_space.enq(?);
    endrule

    rule espaco;
        remaining_space.deq;
        uart.rx.put('h20);
    endrule

    Reg#(Bit#(6)) new_counter <- mkReg(0);
    Reg#(Bit#(1)) in_state <- mkReg(0);

    rule discard_input;
        let b <- uart.tx.get;
        let next_new_counter = new_counter*10 + truncate(b - 'h30);
        in_state <= ~in_state;
        if (in_state == 1) begin
            counter[1] <= next_new_counter;
            next_new_counter = 0;
        end
        new_counter <= next_new_counter;
    endrule

    rule inc_pwm_counter;
        pwm_counter <= pwm_counter + 1;
    endrule
    
    let pwm_on = pwm_counter > counter[0];
    Vector#(6, Bool) led_vec = replicate(pwm_on);

    interface rs232 = uart.rs232;
    method led = pack(led_vec);
endmodule
