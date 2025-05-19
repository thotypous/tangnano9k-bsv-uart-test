module top(CLK,
		  RST_N,
		  rx,
		  tx,
		  LED);

    input  CLK;
    input  RST_N;
    input  rx;
    output tx;
    output [5 : 0] LED;
    wire   CLK_UART;

    pll pll_0(
        .clock_in(CLK),
        .clock_out(CLK_UART),
    );

    mkUartTest real_top(
        .CLK(CLK_UART),
        .RST_N(RST_N),
        .rx(rx),
        .tx(tx),
        .LED(LED)
    );

endmodule
