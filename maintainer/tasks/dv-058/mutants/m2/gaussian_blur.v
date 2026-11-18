`timescale 1ns / 1ps
// Module:      gaussian_blur.v
// Description: Multi-pixel Gaussian blur filter. Applies a configurable 3x3
//              weighted averaging kernel independently to each RGB channel
//              using three window_generator instances. Three blur modes
//              (light/medium/heavy) are selectable at runtime via btn_mode
//              with hardware debouncing. Uses 16-bit intermediate wires to
//              prevent overflow.
// Author:      5529114
// Date:        April 2026

module gaussian_blur #
(
    parameter DATA_WIDTH  = 24,
    parameter IMAGE_WIDTH = 1920,
    parameter DEBOUNCE_LIMIT = 22'd2500000
)
(
    input  wire                  clk,
    input  wire                  n_rst,
    /*
     * Button input to cycle blur mode
     */
    input  wire                  btn_mode,
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
    output reg                   o_vid_VDE,
    /*
     * Current blur mode output (for top level LED control)
     */
    output wire [1:0]            o_blur_mode
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
    // Blur mode register and button debounce
    // Mode 0 = light blur
    // Mode 1 = medium blur (default)
    // Mode 2 = heavy blur
    // -------------------------------------------------------------------------
    reg [1:0]  blur_mode;
    reg [21:0] debounce_cnt;
    reg        btn_prev;

    assign o_blur_mode = blur_mode;

    always @(posedge clk) begin
        if (!n_rst) begin
            blur_mode    <= 2'd1;
            debounce_cnt <= 0;
            btn_prev     <= 0;
        end
        else begin
            if (debounce_cnt < DEBOUNCE_LIMIT) begin
                debounce_cnt <= debounce_cnt + 1;
            end
            else begin
                debounce_cnt <= 0;
                if (btn_mode && !btn_prev) begin
                    if (blur_mode == 2'd2)
                        blur_mode <= 2'd0;
                    else
                        blur_mode <= blur_mode + 1;
                end
                btn_prev <= btn_mode;
            end
        end
    end

    // -------------------------------------------------------------------------
    // Kernel coefficients based on blur mode
    //
    // Mode 0 - Light blur:        Mode 1 - Medium blur:    Mode 2 - Heavy blur:
    // 1  1  1                     1  2  1                  1  3  1
    // 1  2  1  / 10               2  4  2  / 16            3  9  3  / 25
    // 1  1  1                     1  2  1                  1  3  1
    // -------------------------------------------------------------------------
    reg [3:0] k_corner, k_edge, k_centre;
    reg [4:0] k_divisor;

    always @(*) begin
        case(blur_mode)
            2'd0: begin
                k_corner  = 4'd1;
                k_edge    = 4'd1;
                k_centre  = 4'd2;
                k_divisor = 5'd10;
            end
            2'd1: begin
                k_corner  = 4'd1;
                k_edge    = 4'd2;
                k_centre  = 4'd4;
                k_divisor = 5'd16;
            end
            2'd2: begin
                k_corner  = 4'd1;
                k_edge    = 4'd3;
                k_centre  = 4'd9;
                k_divisor = 5'd25;
            end
            default: begin
                k_corner  = 4'd1;
                k_edge    = 4'd2;
                k_centre  = 4'd4;
                k_divisor = 5'd16;
            end
        endcase
    end

    // -------------------------------------------------------------------------
    // Apply kernel to each channel separately
    // Use 16-bit intermediates to avoid overflow
    // max value = (4*255*1) + (4*255*3) + (255*9) = 255*25 = 6375 fits in 16bit
    // -------------------------------------------------------------------------
    wire [15:0] r_sum, g_sum, b_sum;

    assign r_sum = (k_corner * r00) + (k_edge   * r01) + (k_corner * r02) +
                   (k_edge   * r10) + (k_centre  * r11) + (k_edge   * r12) +
                   (k_corner * r20) + (k_edge   * r21) + (k_corner * r22);

    assign g_sum = (k_corner * g00) + (k_edge   * g01) + (k_corner * g02) +
                   (k_edge   * g10) + (k_centre  * g11) + (k_edge   * g12) +
                   (k_corner * g20) + (k_edge   * g21) + (k_corner * g22);

    assign b_sum = (k_corner * b00) + (k_edge   * b01) + (k_corner * b02) +
                   (k_edge   * b10) + (k_centre  * b11) + (k_edge   * b12) +
                   (k_corner * b20) + (k_edge   * b21) + (k_corner * b22);

    // -------------------------------------------------------------------------
    // Divide by kernel sum to normalise
    // Using division here for clarity - Vivado will synthesise this
    // -------------------------------------------------------------------------
    wire [7:0] r_out, g_out, b_out;
    assign r_out = r_sum / k_divisor;
    assign g_out = g_sum / k_divisor;
    assign b_out = b_sum / k_divisor;

    // -------------------------------------------------------------------------
    // Register outputs
    // Use timing signals from line buffer output (already delayed)
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
