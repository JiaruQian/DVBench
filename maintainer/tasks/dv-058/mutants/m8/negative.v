`timescale 1ns / 1ps
// Module:      negative.v
// Description: Single-pixel colour inversion filter. Produces photographic
//              negative effect by subtracting each RGB channel value from 255.
//              One clock cycle pipeline latency.
// Author:      5529114
// Date:        April 2026

module negative #
(
    parameter DATA_WIDTH = 24
)
(
    input  wire                   clk,
    input  wire                   n_rst,

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
    output reg [DATA_WIDTH-1:0] o_vid_data,
    output reg                  o_vid_hsync,
    output reg                  o_vid_vsync,
    output reg                  o_vid_VDE
);

    wire [7:0] red, green, blue;
    assign {red, green, blue} = i_vid_data;
    
    // Invert
    wire [7:0] r_neg, g_neg, b_neg;
    assign r_neg = 8'hFF - red;
    assign g_neg = 8'hFF - green;
    assign b_neg = 8'hFF - blue;
    
    always @ (posedge clk) begin
        if(!n_rst) begin
            o_vid_hsync <= 0;
            o_vid_vsync <= 0; 
            o_vid_VDE <= 0;
            o_vid_data <= 0;
        end
        else begin
            o_vid_hsync <= i_vid_hsync;
            o_vid_vsync <= i_vid_vsync; 
            o_vid_VDE <= i_vid_VDE;
            o_vid_data <= {r_neg, g_neg, b_neg};
        end
    end
endmodule
