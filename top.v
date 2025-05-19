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

    mkUartTest real_top(
        .CLK(CLK),
        .RST_N(RST_N),
        .rx(rx),
        .tx(tx),
        .LED(LED)
    );

endmodule
