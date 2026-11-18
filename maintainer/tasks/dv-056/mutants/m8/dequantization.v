`timescale 1ns / 1ps
// PURPOSE: Multiply each quantized coefficient by Q(i,j)
//          to recover approximate DCT coefficients
// INPUT:  quant_in  [511:0]  - 64 × 8-bit quantized values
//         dequant_start      - pulse to start
// OUTPUT: dct_approx[1023:0] - 64 × 16-bit dequantized values
//         dequant_done       - pulse when complete

module dequantization (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         dequant_start,
    input  wire [511:0] quant_in,

    output reg [1023:0] dct_approx,
    output reg          dequant_done
);

    reg [7:0] Q_table [0:63];
    initial begin
        Q_table[ 0]=8'd16; Q_table[ 1]=8'd11; Q_table[ 2]=8'd10;
        Q_table[ 3]=8'd16; Q_table[ 4]=8'd24; Q_table[ 5]=8'd40;
        Q_table[ 6]=8'd51; Q_table[ 7]=8'd61;
        Q_table[ 8]=8'd12; Q_table[ 9]=8'd12; Q_table[10]=8'd14;
        Q_table[11]=8'd19; Q_table[12]=8'd26; Q_table[13]=8'd58;
        Q_table[14]=8'd60; Q_table[15]=8'd55;
        Q_table[16]=8'd14; Q_table[17]=8'd13; Q_table[18]=8'd16;
        Q_table[19]=8'd24; Q_table[20]=8'd40; Q_table[21]=8'd57;
        Q_table[22]=8'd69; Q_table[23]=8'd56;
        Q_table[24]=8'd14; Q_table[25]=8'd17; Q_table[26]=8'd22;
        Q_table[27]=8'd29; Q_table[28]=8'd51; Q_table[29]=8'd87;
        Q_table[30]=8'd80; Q_table[31]=8'd62;
        Q_table[32]=8'd18; Q_table[33]=8'd22; Q_table[34]=8'd37;
        Q_table[35]=8'd56; Q_table[36]=8'd68; Q_table[37]=8'd109;
        Q_table[38]=8'd103;Q_table[39]=8'd77;
        Q_table[40]=8'd24; Q_table[41]=8'd35; Q_table[42]=8'd55;
        Q_table[43]=8'd64; Q_table[44]=8'd81; Q_table[45]=8'd104;
        Q_table[46]=8'd113;Q_table[47]=8'd92;
        Q_table[48]=8'd49; Q_table[49]=8'd64; Q_table[50]=8'd78;
        Q_table[51]=8'd87; Q_table[52]=8'd103;Q_table[53]=8'd121;
        Q_table[54]=8'd120;Q_table[55]=8'd101;
        Q_table[56]=8'd72; Q_table[57]=8'd92; Q_table[58]=8'd95;
        Q_table[59]=8'd98; Q_table[60]=8'd112;Q_table[61]=8'd100;
        Q_table[62]=8'd103;Q_table[63]=8'd99;
    end

    reg [5:0] coeff_idx;
    reg       processing;

    wire signed [7:0]  curr_quant;
    wire        [7:0]  curr_Q;
    wire signed [15:0] result;

    assign curr_quant = $signed(quant_in[coeff_idx*8 +: 8]);
    assign curr_Q     = Q_table[coeff_idx];

    assign result = curr_quant * $signed({1'b0, curr_Q});

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            coeff_idx    <= 6'd0;
            processing   <= 1'b0;
            dequant_done <= 1'b0;
            dct_approx   <= 1024'd0;
        end
        else begin
            dequant_done <= 1'b0;

            if (dequant_start) begin
                processing <= 1'b1;
                coeff_idx  <= 6'd0;
            end

            if (processing) begin
                dct_approx[coeff_idx*16 +: 16] <= result;

                if (coeff_idx == 6'd63) begin
                    processing   <= 1'b0;
                    dequant_done <= 1'b1;
                end
                else
                    coeff_idx <= coeff_idx + 6'd1;
            end
        end
    end

endmodule