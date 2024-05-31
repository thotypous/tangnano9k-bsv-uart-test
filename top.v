module top(CLK,
           RST_N,
           rs232_SIN,
           rs232_SOUT,
           flashClk,
           flashMiso,
           flashMosi,
           flashCs,
           LED);

    input  CLK;
    input  RST_N;
    input  rs232_SIN;
    output rs232_SOUT;
    output flashClk;
    input  flashMiso;
    output flashMosi;
    output flashCs;
    output [5 : 0] LED;
    wire   CLK_PLL;

    pll pll0(
        .clock_in(CLK),
        .clock_out(CLK_PLL)
    );

    mkUartTest real_top(
        .CLK(CLK_PLL),
        .RST_N(RST_N),
        .rs232_SIN(rs232_SIN),
        .rs232_SOUT(rs232_SOUT),
        .flashClk(flashClk),
        .flashMiso(flashMiso),
        .flashMosi(flashMosi),
        .flashCs(flashCs),
        .LED(LED)
    );

endmodule
