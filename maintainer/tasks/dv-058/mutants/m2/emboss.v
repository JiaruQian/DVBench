`timescale 1ns / 1ps
// Module:      emboss.v
// Description: Multi-pixel emboss filter. Converts input to greyscale before
//              the line buffer to reduce memory usage to one window_generator
//              instance. Applies a directional difference kernel with a 128
//              bias to centre output around mid-grey. Flat regions appear grey,
//              edges appear lighter or darker depending on orientation.
//              Output clamped to [0, 255].
// Author:      5529114
// Date:        April 2026

module emboss #
(
    parameter DATA_WIDTH  = 24,
    parameter IMAGE_WIDTH = 1920
)
(
    input  wire                  clk,
    input  wire                  n_rst,
    /*
     * Pixel inputs
     */
    input  wire [DATA_WIDTH-1:0] i_vid_data,
    input  wire                  i_vid_hsync,
    input  wire                  i_vid_vsync,
    input  wire                  i_vid_VDE,
    /*
     * Pixel output
     */
    output reg  [DATA_WIDTH-1:0] o_vid_data,
    output reg                   o_vid_hsync,
    output reg                   o_vid_vsync,
    output reg                   o_vid_VDE
);

    // -------------------------------------------------------------------------
    // Convert input pixel to greyscale before line buffer
    // Same approach as sobel - store greyscale in line buffer
    // -------------------------------------------------------------------------
    wire [7:0] r_in, g_in, b_in;
    assign {r_in, g_in, b_in} = i_vid_data;

    wire [15:0] grey_calc;
    assign grey_calc = (r_in * 8'd77) + (g_in * 8'd150) + (b_in * 8'd29);

    wire [7:0] grey;
    assign grey = grey_calc[15:8];

    // -------------------------------------------------------------------------
    // 3x3 window pixel outputs (greyscale only)
    // -------------------------------------------------------------------------
    wire [7:0] p00, p01, p02;
    wire [7:0] p10, p11, p12;
    wire [7:0] p20, p21, p22;

    // -------------------------------------------------------------------------
    // Single window generator for greyscale channel
    // -------------------------------------------------------------------------
    window_generator #(
        .DATA_WIDTH(8),
        .LINE_WIDTH(IMAGE_WIDTH)
    ) wg (
        .clk     (clk),
        .n_rst   (n_rst),
        .en      (i_vid_VDE),
        .pixel_in(grey),
        .p00(p00), .p01(p01), .p02(p02),
        .p10(p10), .p11(p11), .p12(p12),
        .p20(p20), .p21(p21), .p22(p22)
    );

    // -------------------------------------------------------------------------
    // Emboss kernel:
    //
    // -2  -1   0
    // -1   1   1   + 128 bias
    //  0   1   2
    //
    // Flat areas output ~128 (mid grey)
    // Bright edges facing top-left output > 128 (light)
    // Bright edges facing bottom-right output < 128 (shadow)
    //
    // Range: min = -1020 + 128 = -892
    //        max =  1275 + 128 = 1403
    // Use 12-bit signed to handle this range
    // -------------------------------------------------------------------------
    wire signed [11:0] emboss_sum;

    assign emboss_sum =
        (-12'sd2 * $signed({1'b0, p00})) +
        (-12'sd1 * $signed({1'b0, p01})) +
        ( 12'sd0 * $signed({1'b0, p02})) +
        (-12'sd1 * $signed({1'b0, p10})) +
        ( 12'sd1 * $signed({1'b0, p11})) +
        ( 12'sd1 * $signed({1'b0, p12})) +
        ( 12'sd0 * $signed({1'b0, p20})) +
        ( 12'sd1 * $signed({1'b0, p21})) +
        ( 12'sd2 * $signed({1'b0, p22})) +
        12'sd128;

    // -------------------------------------------------------------------------
    // Clamp output to 0-255
    // -------------------------------------------------------------------------
    wire [7:0] emboss_out;

    assign emboss_out = emboss_sum[11] ? 8'h00 :
                        (emboss_sum > 12'sd255) ? 8'hFF :
                        emboss_sum[7:0];

    // -------------------------------------------------------------------------
    // Register outputs
    // Output as greyscale - same value on all three channels
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (!n_rst) begin
            o_vid_data  <= 0;
            o_vid_hsync <= 0;
            o_vid_vsync <= 0;
            o_vid_VDE   <= 0;
        end
        else begin
            o_vid_data  <= {emboss_out, emboss_out, emboss_out};
            o_vid_hsync <= i_vid_hsync;
            o_vid_vsync <= i_vid_vsync;
            o_vid_VDE   <= i_vid_VDE;
        end
    end

endmodule
