module Conv_WeightSelector (
    input rst_b,
    input clk,
    input [4:0] cnt_in,  
    input en,
    output wire [0:77*8-1] select_weight  // Fetch one convolution kernel at a time, 77 8bit data items
);

    wire [4:0] ADR;
    assign ADR = cnt_in;

    // Instantiate 8 SRAMs
    wire [0: 77-1] Q[0: 7];  // Readout signal

    // 77*32 Instantiate 8 simultaneously, fetch and concatenate
    asdrlspkb1p64x16cm2sw0_conv_weight conv_weight0 (
        .Q(Q[0]),
        .ADR(ADR),
        .D(77'b0),
        .WE(1'b0),
        .ME(en),
        .CLK(clk),
        .TEST1(1'b0),
        .RM(4'b0000),
        .RME(1'b0)
    );
    asdrlspkb1p64x16cm2sw0_conv_weight #(.INIT_FILE("samples/Conv_Weight_arranged_1.txt")) conv_weight1 (
        .Q(Q[1]),
        .ADR(ADR),
        .D(77'b0),
        .WE(1'b0),
        .ME(en),
        .CLK(clk),
        .TEST1(1'b0),
        .RM(4'b0000),
        .RME(1'b0)
    );
    asdrlspkb1p64x16cm2sw0_conv_weight #(.INIT_FILE("samples/Conv_Weight_arranged_2.txt")) conv_weight2 (
        .Q(Q[2]),
        .ADR(ADR),
        .D(77'b0),
        .WE(1'b0),
        .ME(en),
        .CLK(clk),
        .TEST1(1'b0),
        .RM(4'b0000),
        .RME(1'b0)
    );
    asdrlspkb1p64x16cm2sw0_conv_weight #(.INIT_FILE("samples/Conv_Weight_arranged_3.txt")) conv_weight3 (
        .Q(Q[3]),
        .ADR(ADR),
        .D(77'b0),
        .WE(1'b0),
        .ME(en),
        .CLK(clk),
        .TEST1(1'b0),
        .RM(4'b0000),
        .RME(1'b0)
    );
    asdrlspkb1p64x16cm2sw0_conv_weight #(.INIT_FILE("samples/Conv_Weight_arranged_4.txt")) conv_weight4 (
        .Q(Q[4]),
        .ADR(ADR),
        .D(77'b0),
        .WE(1'b0),
        .ME(en),
        .CLK(clk),
        .TEST1(1'b0),
        .RM(4'b0000),
        .RME(1'b0)
    );
    asdrlspkb1p64x16cm2sw0_conv_weight #(.INIT_FILE("samples/Conv_Weight_arranged_5.txt")) conv_weight5 (
        .Q(Q[5]),
        .ADR(ADR),
        .D(77'b0),
        .WE(1'b0),
        .ME(en),
        .CLK(clk),
        .TEST1(1'b0),
        .RM(4'b0000),
        .RME(1'b0)
    );
    asdrlspkb1p64x16cm2sw0_conv_weight #(.INIT_FILE("samples/Conv_Weight_arranged_6.txt")) conv_weight6 (
        .Q(Q[6]),
        .ADR(ADR),
        .D(77'b0),
        .WE(1'b0),
        .ME(en),
        .CLK(clk),
        .TEST1(1'b0),
        .RM(4'b0000),
        .RME(1'b0)
    );
    asdrlspkb1p64x16cm2sw0_conv_weight #(.INIT_FILE("samples/Conv_Weight_arranged_7.txt")) conv_weight7 (
        .Q(Q[7]),
        .ADR(ADR),
        .D(77'b0),
        .WE(1'b0),
        .ME(en),
        .CLK(clk),
        .TEST1(1'b0),
        .RM(4'b0000),
        .RME(1'b0)
    );

    // 8 77bit SRAMs
    assign select_weight[77*0 :77*1-1] = Q[0];
    assign select_weight[77*1 :77*2-1] = Q[1];
    assign select_weight[77*2 :77*3-1] = Q[2];
    assign select_weight[77*3 :77*4-1] = Q[3];
    assign select_weight[77*4 :77*5-1] = Q[4];
    assign select_weight[77*5 :77*6-1] = Q[5];
    assign select_weight[77*6 :77*7-1] = Q[6];
    assign select_weight[77*7 :77*8-1] = Q[7];

endmodule
