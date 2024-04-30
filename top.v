module top(CLK,
		  RST_N,
		  rs232_SIN,
		  rs232_SOUT,
		  LED);

    input  CLK;
    input  RST_N;
    input  rs232_SIN;
    output rs232_SOUT;
    output [5 : 0] LED;

    mkUartTest real_top(
        .CLK(CLK),
        .RST_N(RST_N),
        .rs232_SIN(rs232_SIN),
        .rs232_SOUT(rs232_SOUT),
        .LED(LED)
    );

endmodule
