`timescale 1ns / 1ps
// ============================================================
//  dec_ht_trigger  (Hardware Trojan trigger)
//
//  Watches the 8 diagonal elements of the first block's QUANTIZED
//  raster matrix (inv_zigzag output, indices 0,9,18,27,36,45,54,63).
//  When check_en is high (only asserted for block 0 by decoder_top)
//  AND all 8 diagonal values equal the target set, trigger_dec latches
//  high and stays high until a hard reset (clr_n).
//
//  Targets default to the block-0 quantized diagonal of the TRIGGER
//  image D1T.jpg = [-48, 21, 16, 9, 4, 2, 2, 3].
//  If your simulation prints a different diagonal for block 0 (e.g. the
//  DC differs because of a different resize), just override T0..T7.
// ============================================================
module dec_ht_trigger #(
    parameter signed [7:0] T0 = -8'sd127,  // raster[0]  (DC)  -- hardware value
    parameter signed [7:0] T1 =  8'sd84,   // raster[9]
    parameter signed [7:0] T2 =  8'sd94,   // raster[18]
    parameter signed [7:0] T3 =  8'sd35,   // raster[27]
    parameter signed [7:0] T4 =  8'sd30,   // raster[36]
    parameter signed [7:0] T5 =  8'sd10,   // raster[45]
    parameter signed [7:0] T6 =  8'sd13,   // raster[54]
    parameter signed [7:0] T7 =  8'sd10    // raster[63]
)(
    input  wire         clk,
    input  wire         clr_n,
    input  wire         check_en,
    input  wire [511:0] raster_in,
    output reg          trigger_dec
);

    wire signed [7:0] d0 = $signed(raster_in[  0 +: 8]); // raster[0]
    wire signed [7:0] d1 = $signed(raster_in[ 72 +: 8]); // raster[9]
    wire signed [7:0] d2 = $signed(raster_in[144 +: 8]); // raster[18]
    wire signed [7:0] d3 = $signed(raster_in[216 +: 8]); // raster[27]
    wire signed [7:0] d4 = $signed(raster_in[288 +: 8]); // raster[36]
    wire signed [7:0] d5 = $signed(raster_in[360 +: 8]); // raster[45]
    wire signed [7:0] d6 = $signed(raster_in[432 +: 8]); // raster[54]
    wire signed [7:0] d7 = $signed(raster_in[504 +: 8]); // raster[63]

    wire diag_match = (d0==T0)&&(d1==T1)&&(d2==T2)&&(d3==T3)&&
                      (d4==T4)&&(d5==T5)&&(d6==T6)&&(d7==T7);

    always @(posedge clk or negedge clr_n) begin
        if (!clr_n)                       trigger_dec <= 1'b0;
        else if (check_en && diag_match)  trigger_dec <= 1'b1;   // latch
    end
endmodule