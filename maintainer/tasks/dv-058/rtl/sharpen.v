`timescale 1ns / 1ps
// Module:      sharpen.v
// Description: Multi-pixel sharpening filter. Applies a Laplacian-based 3x3
//              kernel (centre weight 5, cardinal neighbours -1) to each RGB
//              channel independently using three window_generator instances.
//              Uses 12-bit signed arithmetic to handle negative intermediate
//              values. Output is clamped to [0, 255].
// Author:      5529114
// Date:        April 2026

module sharpen #
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
    // Extract RGB channels from input pixel
    // -------------------------------------------------------------------------
    wire [7:0] red, green, blue;
    assign {red, green, blue} = i_vid_data;

    // -------------------------------------------------------------------------
    // 3x3 window pixel outputs for each channel
    // -------------------------------------------------------------------------
    wire [7:0] r00, g00, b00, r01, g01, b01, r02, g02, b02;
    wire [7:0] r10, g10, b10, r11, g11, b11, r12, g12, b12;
    wire [7:0] r20, g20, b20, r21, g21, b21, r22, g22, b22;

    // -------------------------------------------------------------------------
    // Window generators - one per RGB channel
    // -------------------------------------------------------------------------
    window_generator #(
        .DATA_WIDTH(8),
        .LINE_WIDTH(IMAGE_WIDTH)
    ) wg_red (
        .clk     (clk),
        .n_rst   (n_rst),
        .en      (i_vid_VDE),
        .pixel_in(red),
        .p00(r00), .p01(r01), .p02(r02),
        .p10(r10), .p11(r11), .p12(r12),
        .p20(r20), .p21(r21), .p22(r22)
    );

    window_generator #(
        .DATA_WIDTH(8),
        .LINE_WIDTH(IMAGE_WIDTH)
    ) wg_green (
        .clk     (clk),
        .n_rst   (n_rst),
        .en      (i_vid_VDE),
        .pixel_in(green),
        .p00(g00), .p01(g01), .p02(g02),
        .p10(g10), .p11(g11), .p12(g12),
        .p20(g20), .p21(g21), .p22(g22)
    );

    window_generator #(
        .DATA_WIDTH(8),
        .LINE_WIDTH(IMAGE_WIDTH)
    ) wg_blue (
        .clk     (clk),
        .n_rst   (n_rst),
        .en      (i_vid_VDE),
        .pixel_in(blue),
        .p00(b00), .p01(b01), .p02(b02),
        .p10(b10), .p11(b11), .p12(b12),
        .p20(b20), .p21(b21), .p22(b22)
    );

    // -------------------------------------------------------------------------
    // Sharpen kernel:
    //  0  -1   0
    // -1   5  -1   sum = 1, no division needed
    //  0  -1   0
    //
    // Applied per channel as signed arithmetic
    // Result = 5*centre - top - left - right - bottom
    // Use 10-bit signed to handle negative intermediate values
    // Range: min = 5*0 - 4*255 = -1020
    //        max = 5*255 - 4*0 = 1275
    // Both fit in 11-bit signed (-1024 to 1023 is 11-bit, need 12-bit)
    // Use 12-bit signed to be safe
    // -------------------------------------------------------------------------
    wire signed [11:0] r_sum, g_sum, b_sum;

    assign r_sum = (12'sd5 * $signed({1'b0, r11})) -
                   $signed({1'b0, r01}) -
                   $signed({1'b0, r10}) -
                   $signed({1'b0, r12}) -
                   $signed({1'b0, r21});

    assign g_sum = (12'sd5 * $signed({1'b0, g11})) -
                   $signed({1'b0, g01}) -
                   $signed({1'b0, g10}) -
                   $signed({1'b0, g12}) -
                   $signed({1'b0, g21});

    assign b_sum = (12'sd5 * $signed({1'b0, b11})) -
                   $signed({1'b0, b01}) -
                   $signed({1'b0, b10}) -
                   $signed({1'b0, b12}) -
                   $signed({1'b0, b21});
                   
    // -------------------------------------------------------------------------
    // Clamp output to 0-255
    // If negative clamp to 0, if > 255 clamp to 255
    // -------------------------------------------------------------------------
    wire [7:0] r_out, g_out, b_out;

    assign r_out = r_sum[11] ? 8'h00 :
                   (r_sum > 12'sd255) ? 8'hFF : r_sum[7:0];

    assign g_out = g_sum[11] ? 8'h00 :
                   (g_sum > 12'sd255) ? 8'hFF : g_sum[7:0];

    assign b_out = b_sum[11] ? 8'h00 :
                   (b_sum > 12'sd255) ? 8'hFF : b_sum[7:0];

    // -------------------------------------------------------------------------
    // Register outputs
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (!n_rst) begin
            o_vid_data  <= 0;
            o_vid_hsync <= 0;
            o_vid_vsync <= 0;
            o_vid_VDE   <= 0;
        end
        else begin
            o_vid_data  <= {r_out, g_out, b_out};
            o_vid_hsync <= i_vid_hsync;
            o_vid_vsync <= i_vid_vsync;
            o_vid_VDE   <= i_vid_VDE;
        end
    end

endmodule
