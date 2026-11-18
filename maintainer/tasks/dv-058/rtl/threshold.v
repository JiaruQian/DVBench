`timescale 1ns / 1ps
// Module:      threshold.v
// Description: Single-pixel binary threshold filter. Converts input to
//              greyscale then applies a configurable threshold comparison,
//              outputting white (255) or black (0). Threshold is adjustable
//              at runtime via btn_up/btn_down with 20ms hardware debouncing.
//              Default threshold is 128, step size is 5.
// Author:      5529114
// Date:        April 2026

module threshold #
(
    parameter DATA_WIDTH = 24,
    parameter DEBOUNCE_LIMIT = 22'd2500000
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
     * Button inputs
     */
    input wire                  btn_up,
    input wire                  btn_down,
    
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
    
    // 1. Convert to greyscale
    wire [15:0] grey_calc;
    assign grey_calc = (red * 8'd77) + (green * 8'd150) + (blue * 8'd29);
    wire [7:0] grey;
    assign grey = grey_calc[15:8];
    
    // Threshold register
    reg [7:0] threshold;
    
    // Debounce counter and registers
    reg [21:0] debounce_cnt;
    reg btn_up_prev, btn_down_prev;
    
    // Threshold pixel output
    wire [7:0] thresh_out;
    assign thresh_out = (grey >= threshold) ? 8'd255 : 8'd0;
    
    always @ (posedge clk) begin
        if(!n_rst) begin
            o_vid_hsync <= 0;
            o_vid_vsync <= 0; 
            o_vid_VDE <= 0;
            o_vid_data <= 0;
            threshold <= 8'd128;
            debounce_cnt <= 0;
            btn_up_prev <= 0;
            btn_down_prev <= 0;
        end
        else begin
            o_vid_hsync <= i_vid_hsync;
            o_vid_vsync <= i_vid_vsync; 
            o_vid_VDE <= i_vid_VDE;
            o_vid_data <= {thresh_out, thresh_out, thresh_out};
            
            // Debounce and threshold control
            if(debounce_cnt < DEBOUNCE_LIMIT) begin
                debounce_cnt <= debounce_cnt + 1;
            end
            else begin
                debounce_cnt <= 0;
                // Increase threshold on BTN0 press
                if(btn_up && !btn_up_prev) begin
                    if(threshold + 8'd5 > 8'd255 || threshold > 8'd250)
                        threshold <= 8'd255;
                    else
                        threshold <= threshold + 8'd5;
                end
                else if(btn_down && !btn_down_prev) begin
                    if(threshold < 8'd5)
                        threshold <= 8'd0;
                    else
                        threshold <= threshold - 8'd5;
                end
                    
                btn_up_prev   <= btn_up;
                btn_down_prev <= btn_down;
            end
        end
    end
endmodule
