`timescale 1ns / 1ps
// Module:      window_generator.v
// Description: Generates a 3x3 pixel neighbourhood window for a single colour
//              channel. Uses two chained line_buffer instances to access pixels
//              from the current line, one line ago, and two lines ago. Three
//              horizontal shift registers per row provide the complete p00-p22
//              pixel window required by convolution-based filters.
// Author:      5529114
// Date:        April 2026

module window_generator #
(
    parameter DATA_WIDTH = 8,    // bits per pixel channel
    parameter LINE_WIDTH = 1920  // pixels per line
)
(
    input  wire                  clk,
    input  wire                  n_rst,
    input  wire                  en,         // enable - tied to i_vid_VDE
    input  wire [DATA_WIDTH-1:0] pixel_in,   // current pixel channel input
    
    // 3x3 window pixel outputs
    output reg  [DATA_WIDTH-1:0] p00, p01, p02,  // row 0 - 2 lines ago
    output reg  [DATA_WIDTH-1:0] p10, p11, p12,  // row 1 - 1 line ago
    output reg  [DATA_WIDTH-1:0] p20, p21, p22   // row 2 - current line
);

    // Line buffer outputs
    wire [DATA_WIDTH-1:0] lb1_out;  // 1 line ago
    wire [DATA_WIDTH-1:0] lb2_out;  // 2 lines ago
    
    // First line buffer - delays by one line
    line_buffer #(
        .DATA_WIDTH(DATA_WIDTH),
        .LINE_WIDTH(LINE_WIDTH)
    ) lb1 (
        .clk      (clk),
        .n_rst    (n_rst),
        .en       (en),
        .pixel_in (pixel_in),
        .pixel_out(lb1_out)
    );
    
    // Second line buffer - chained from lb1, delays by another line
    // lb2 input = lb1 output (1 line ago)
    // lb2 output = 2 lines ago
    line_buffer #(
        .DATA_WIDTH(DATA_WIDTH),
        .LINE_WIDTH(LINE_WIDTH)
    ) lb2 (
        .clk      (clk),
        .n_rst    (n_rst),
        .en       (en),
        .pixel_in (lb1_out),
        .pixel_out(lb2_out)
    );
    
    // Shift registers to build horizontal neighbourhood
    // Each row needs 3 consecutive pixels (p_2, p_1, p_0)
    // New pixel shifts in from right, oldest shifts out from left
    always @ (posedge clk) begin
        if(!n_rst) begin
            // Reset all window pixels to 0
            p00 <= 0; p01 <= 0; p02 <= 0;
            p10 <= 0; p11 <= 0; p12 <= 0;
            p20 <= 0; p21 <= 0; p22 <= 0;
        end
        else if(en) begin
            // Row 2 - current line (newest pixels)
            p22 <= pixel_in;
            p21 <= p22;
            p20 <= p21;
            
            // Row 1 - 1 line ago
            p12 <= lb1_out;
            p11 <= p12;
            p10 <= p11;
            
            // Row 0 - 2 lines ago (oldest pixels)
            p02 <= lb2_out;
            p01 <= p02;
            p00 <= p01;
        end
    end

endmodule