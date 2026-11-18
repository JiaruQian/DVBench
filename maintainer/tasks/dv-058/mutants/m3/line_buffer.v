`timescale 1ns / 1ps
// Module:      line_buffer.v
// Description: Single-line delay buffer implemented as a circular BRAM-based
//              shift register of depth LINE_WIDTH. Outputs the pixel that was
//              written LINE_WIDTH clock cycles ago, providing one full line of
//              delay for use in 3x3 neighbourhood window generation.
// Author:      5529114
// Date:        April 2026

module line_buffer #
(
    parameter DATA_WIDTH = 8,    // bits per pixel channel
    parameter LINE_WIDTH = 1920  // pixels per line
)
(
    input  wire                  clk,
    input  wire                  n_rst,
    input  wire                  en,          // enable - only advance when VDE active
    input  wire [DATA_WIDTH-1:0] pixel_in,    // current pixel input
    output reg  [DATA_WIDTH-1:0] pixel_out    // pixel output (one line delayed)
);

    // BRAM inference - Vivado automatically maps this to Block RAM
    // Size: LINE_WIDTH x DATA_WIDTH bits
    reg [DATA_WIDTH-1:0] mem [0:LINE_WIDTH-1];
    
    // Circular buffer pointer
    // $clog2(LINE_WIDTH) calculates minimum bits needed
    // e.g. LINE_WIDTH=1920 needs 11 bits (2^11=2048)
    reg [$clog2(LINE_WIDTH)-1:0] ptr;
    
    always @ (posedge clk) begin
        if(!n_rst) begin
            ptr       <= 0;
            pixel_out <= 0;
        end
        else if(en) begin
            // Read old pixel out before writing new pixel in
            pixel_out <= mem[ptr];
            // Write new pixel into current position
            mem[ptr]  <= pixel_in;
            // Advance pointer with wrap-around
            if(ptr == LINE_WIDTH - 1)
                ptr <= 0;
            else
                ptr <= ptr + 1;
        end
    end

endmodule