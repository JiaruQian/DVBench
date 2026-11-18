`timescale 1ns / 1ps
// Module:      greyscale.v
// Description: Single-pixel greyscale conversion filter. Converts 24-bit RGB
//              input to luminance using ITU-R BT.601 weighted coefficients
//              (Y = 0.299R + 0.587G + 0.114B) approximated with integer
//              arithmetic and a right shift to avoid floating-point division.
// Author:      5529114
// Date:        April 2026

module greyscale #
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
    
    // Weighted greyscale calculation
    wire [15:0] grey_calc;
    assign grey_calc = (red * 8'd77) + (green * 8'd150) + (blue * 8'd29);
    wire [7:0] grey;
    assign grey = grey_calc[15:8];
    
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
            o_vid_data <= {grey, grey, grey};
        end
    end
endmodule
