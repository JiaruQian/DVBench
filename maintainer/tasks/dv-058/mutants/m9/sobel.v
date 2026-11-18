`timescale 1ns / 1ps
// Module:      sobel.v
// Description: Multi-pixel Sobel edge detection filter. Converts input to
//              greyscale before the line buffer to reduce memory usage to one
//              window_generator instance. Computes horizontal (Gx) and vertical
//              (Gy) gradients using standard Sobel kernels. Gradient magnitude
//              approximated as |Gx|+|Gy| to avoid hardware square root.
//              Three modes selectable via btn_mode: full magnitude, Gx only,
//              Gy only.
// Author:      5529114
// Date:        April 2026
module sobel #
(
    parameter DATA_WIDTH  = 24,
    parameter IMAGE_WIDTH = 1920,
    parameter DEBOUNCE_LIMIT = 22'd2500000
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
     * Button input to cycle mode
     */
    input  wire                  btn_mode,
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
    // This way line buffer stores greyscale values saving memory
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
    // Sobel kernels
    //
    // Gx:              Gy:
    // -1   0   1       -1  -2  -1
    // -2   0   2        0   0   0
    // -1   0   1        1   2   1
    //
    // Max value of Gx or Gy = 4*255 = 1020 fits in 11-bit signed
    // -------------------------------------------------------------------------
    wire signed [10:0] Gx, Gy;

    assign Gx = (-$signed({1'b0, p00}) + $signed({1'b0, p02}))
              + ((-$signed({1'b0, p10}) + $signed({1'b0, p12})) <<< 1)
              + (-$signed({1'b0, p20}) + $signed({1'b0, p22}));

    assign Gy = (-$signed({1'b0, p00}) - ($signed({1'b0, p01}) <<< 1) - $signed({1'b0, p02}))
              + ($signed({1'b0, p20}) + ($signed({1'b0, p21}) <<< 1) + $signed({1'b0, p22}));

    // -------------------------------------------------------------------------
    // Absolute values using sign bit
    // -------------------------------------------------------------------------
    wire [10:0] Gx_abs, Gy_abs;
    assign Gx_abs = Gx[10] ? (~Gx + 1'b1) : Gx;
    assign Gy_abs = Gy[10] ? (~Gy + 1'b1) : Gy;

    // -------------------------------------------------------------------------
    // Magnitude = |Gx| + |Gy|
    // Max = 1020 + 1020 = 2040 fits in 12 bits
    // -------------------------------------------------------------------------
    wire [11:0] magnitude;
    assign magnitude = Gx_abs + Gy_abs;

    // -------------------------------------------------------------------------
    // Mode register and button debounce
    // Mode 0 = full magnitude (|Gx| + |Gy|)
    // Mode 1 = Gx only (horizontal edges)
    // Mode 2 = Gy only (vertical edges)
    // -------------------------------------------------------------------------
    reg [1:0]  mode;
    reg [21:0] debounce_cnt;
    reg        btn_prev;

    always @(posedge clk) begin
        if (!n_rst) begin
            mode         <= 2'd0;
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
                    if (mode == 2'd2)
                        mode <= 2'd0;
                    else
                        mode <= mode + 1;
                end
                btn_prev <= btn_mode;
            end
        end
    end

    // -------------------------------------------------------------------------
    // Output selection based on mode
    // -------------------------------------------------------------------------
    reg [7:0] edge_out;
    always @(*) begin
        case(mode)
            2'd0: edge_out = (magnitude > 12'd255) ? 8'd255 : magnitude[7:0];
            2'd1: edge_out = (Gx_abs > 11'd255)   ? 8'd255 : Gx_abs[7:0];
            2'd2: edge_out = (Gy_abs > 11'd255)    ? 8'd255 : Gy_abs[7:0];
            default: edge_out = (magnitude > 12'd255) ? 8'd255 : magnitude[7:0];
        endcase
    end

    // -------------------------------------------------------------------------
    // Register outputs
    // Use timing signals from line buffer (already pipeline delayed)
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if (!n_rst) begin
            o_vid_data  <= 0;
            o_vid_hsync <= 0;
            o_vid_vsync <= 0;
            o_vid_VDE   <= 0;
        end
        else begin
            o_vid_data  <= {edge_out, edge_out, edge_out};
            o_vid_hsync <= i_vid_hsync;
            o_vid_vsync <= i_vid_vsync;
            o_vid_VDE   <= i_vid_VDE;
        end
    end

endmodule
