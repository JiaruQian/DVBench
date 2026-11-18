module DWconv_WeightSelector (
    input rst_b,
    input clk,
    input [4:0] cnt_in,  
    input en,
    output wire [0:9*8-1] select_weight  // Fetch one convolution kernel at a time, 9 8bit data items
);

    wire [4:0] ADR;
    assign ADR = cnt_in;

    asdrlspkb1p64x16cm2sw0_dwconv_weight dwconv_weight (
        .Q(select_weight),
        .ADR(ADR),
        .D(72'h0),
        .WE(1'b0),
        .ME(en),
        .CLK(clk),
        .TEST1(1'b0),
        .RM(4'b0000),
        .RME(1'b0)
    );

endmodule
