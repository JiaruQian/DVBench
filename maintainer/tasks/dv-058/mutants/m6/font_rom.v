`timescale 1ns / 1ps
// Module:      font_rom.v
// Description: Read-only bitmap font lookup table for 8x8 pixel characters.
//              Supports uppercase ASCII characters A-Z and space (codes 32-90).
//              Takes a 7-bit ASCII character code and 3-bit row index as inputs
//              and outputs an 8-bit bitmap row for use by text_overlay.v.
// Author:      5529114
// Date:        April 2026

module font_rom
(
    input  wire [6:0]  char_code,  // ASCII code (32-90)
    input  wire [2:0]  row,        // row within character (0-7)
    output reg  [7:0]  bitmap      // 8 pixel row bitmap
);

always @(*) begin
    case(char_code)
        // Space
        7'd32: case(row)
            3'd0: bitmap = 8'b00000000;
            3'd1: bitmap = 8'b00000000;
            3'd2: bitmap = 8'b00000000;
            3'd3: bitmap = 8'b00000000;
            3'd4: bitmap = 8'b00000000;
            3'd5: bitmap = 8'b00000000;
            3'd6: bitmap = 8'b00000000;
            3'd7: bitmap = 8'b00000000;
            default: bitmap = 8'b00000000;
        endcase
        // A
        7'd65: case(row)
            3'd0: bitmap = 8'b00111100;
            3'd1: bitmap = 8'b01100110;
            3'd2: bitmap = 8'b01100110;
            3'd3: bitmap = 8'b01111110;
            3'd4: bitmap = 8'b01100110;
            3'd5: bitmap = 8'b01100110;
            3'd6: bitmap = 8'b01100110;
            3'd7: bitmap = 8'b00000000;
            default: bitmap = 8'b00000000;
        endcase
        // B
        7'd66: case(row)
            3'd0: bitmap = 8'b01111100;
            3'd1: bitmap = 8'b01100110;
            3'd2: bitmap = 8'b01100110;
            3'd3: bitmap = 8'b01111100;
            3'd4: bitmap = 8'b01100110;
            3'd5: bitmap = 8'b01100110;
            3'd6: bitmap = 8'b01111100;
            3'd7: bitmap = 8'b00000000;
            default: bitmap = 8'b00000000;
        endcase
        // C
        7'd67: case(row)
            3'd0: bitmap = 8'b00111100;
            3'd1: bitmap = 8'b01100110;
            3'd2: bitmap = 8'b01100000;
            3'd3: bitmap = 8'b01100000;
            3'd4: bitmap = 8'b01100000;
            3'd5: bitmap = 8'b01100110;
            3'd6: bitmap = 8'b00111100;
            3'd7: bitmap = 8'b00000000;
            default: bitmap = 8'b00000000;
        endcase
        // D
        7'd68: case(row)
            3'd0: bitmap = 8'b01111000;
            3'd1: bitmap = 8'b01101100;
            3'd2: bitmap = 8'b01100110;
            3'd3: bitmap = 8'b01100110;
            3'd4: bitmap = 8'b01100110;
            3'd5: bitmap = 8'b01101100;
            3'd6: bitmap = 8'b01111000;
            3'd7: bitmap = 8'b00000000;
            default: bitmap = 8'b00000000;
        endcase
        // E
        7'd69: case(row)
            3'd0: bitmap = 8'b01111110;
            3'd1: bitmap = 8'b01100000;
            3'd2: bitmap = 8'b01100000;
            3'd3: bitmap = 8'b01111100;
            3'd4: bitmap = 8'b01100000;
            3'd5: bitmap = 8'b01100000;
            3'd6: bitmap = 8'b01111110;
            3'd7: bitmap = 8'b00000000;
            default: bitmap = 8'b00000000;
        endcase
        // F
        7'd70: case(row)
            3'd0: bitmap = 8'b01111110;
            3'd1: bitmap = 8'b01100000;
            3'd2: bitmap = 8'b01100000;
            3'd3: bitmap = 8'b01111100;
            3'd4: bitmap = 8'b01100000;
            3'd5: bitmap = 8'b01100000;
            3'd6: bitmap = 8'b01100000;
            3'd7: bitmap = 8'b00000000;
            default: bitmap = 8'b00000000;
        endcase
        // G
        7'd71: case(row)
            3'd0: bitmap = 8'b00111100;
            3'd1: bitmap = 8'b01100110;
            3'd2: bitmap = 8'b01100000;
            3'd3: bitmap = 8'b01101110;
            3'd4: bitmap = 8'b01100110;
            3'd5: bitmap = 8'b01100110;
            3'd6: bitmap = 8'b00111100;
            3'd7: bitmap = 8'b00000000;
            default: bitmap = 8'b00000000;
        endcase
        // H
        7'd72: case(row)
            3'd0: bitmap = 8'b01100110;
            3'd1: bitmap = 8'b01100110;
            3'd2: bitmap = 8'b01100110;
            3'd3: bitmap = 8'b01111110;
            3'd4: bitmap = 8'b01100110;
            3'd5: bitmap = 8'b01100110;
            3'd6: bitmap = 8'b01100110;
            3'd7: bitmap = 8'b00000000;
            default: bitmap = 8'b00000000;
        endcase
        // I
        7'd73: case(row)
            3'd0: bitmap = 8'b00111100;
            3'd1: bitmap = 8'b00011000;
            3'd2: bitmap = 8'b00011000;
            3'd3: bitmap = 8'b00011000;
            3'd4: bitmap = 8'b00011000;
            3'd5: bitmap = 8'b00011000;
            3'd6: bitmap = 8'b00111100;
            3'd7: bitmap = 8'b00000000;
            default: bitmap = 8'b00000000;
        endcase
        // L
        7'd76: case(row)
            3'd0: bitmap = 8'b01100000;
            3'd1: bitmap = 8'b01100000;
            3'd2: bitmap = 8'b01100000;
            3'd3: bitmap = 8'b01100000;
            3'd4: bitmap = 8'b01100000;
            3'd5: bitmap = 8'b01100000;
            3'd6: bitmap = 8'b01111110;
            3'd7: bitmap = 8'b00000000;
            default: bitmap = 8'b00000000;
        endcase
        // M
        7'd77: case(row)
            3'd0: bitmap = 8'b01000010;
            3'd1: bitmap = 8'b01100110;
            3'd2: bitmap = 8'b01111110;
            3'd3: bitmap = 8'b01011010;
            3'd4: bitmap = 8'b01000010;
            3'd5: bitmap = 8'b01000010;
            3'd6: bitmap = 8'b01000010;
            3'd7: bitmap = 8'b00000000;
            default: bitmap = 8'b00000000;
        endcase
        // N
        7'd78: case(row)
            3'd0: bitmap = 8'b01100110;
            3'd1: bitmap = 8'b01110110;
            3'd2: bitmap = 8'b01111110;
            3'd3: bitmap = 8'b01101110;
            3'd4: bitmap = 8'b01100110;
            3'd5: bitmap = 8'b01100110;
            3'd6: bitmap = 8'b01100110;
            3'd7: bitmap = 8'b00000000;
            default: bitmap = 8'b00000000;
        endcase
        // O
        7'd79: case(row)
            3'd0: bitmap = 8'b00111100;
            3'd1: bitmap = 8'b01100110;
            3'd2: bitmap = 8'b01100110;
            3'd3: bitmap = 8'b01100110;
            3'd4: bitmap = 8'b01100110;
            3'd5: bitmap = 8'b01100110;
            3'd6: bitmap = 8'b00111100;
            3'd7: bitmap = 8'b00000000;
            default: bitmap = 8'b00000000;
        endcase
        // P
        7'd80: case(row)
            3'd0: bitmap = 8'b01111100;
            3'd1: bitmap = 8'b01100110;
            3'd2: bitmap = 8'b01100110;
            3'd3: bitmap = 8'b01111100;
            3'd4: bitmap = 8'b01100000;
            3'd5: bitmap = 8'b01100000;
            3'd6: bitmap = 8'b01100000;
            3'd7: bitmap = 8'b00000000;
            default: bitmap = 8'b00000000;
        endcase
        // R
        7'd82: case(row)
            3'd0: bitmap = 8'b01111100;
            3'd1: bitmap = 8'b01100110;
            3'd2: bitmap = 8'b01100110;
            3'd3: bitmap = 8'b01111100;
            3'd4: bitmap = 8'b01101100;
            3'd5: bitmap = 8'b01100110;
            3'd6: bitmap = 8'b01100110;
            3'd7: bitmap = 8'b00000000;
            default: bitmap = 8'b00000000;
        endcase
        // S
        7'd83: case(row)
            3'd0: bitmap = 8'b00111100;
            3'd1: bitmap = 8'b01100110;
            3'd2: bitmap = 8'b01100000;
            3'd3: bitmap = 8'b00111100;
            3'd4: bitmap = 8'b00000110;
            3'd5: bitmap = 8'b01100110;
            3'd6: bitmap = 8'b00111100;
            3'd7: bitmap = 8'b00000000;
            default: bitmap = 8'b00000000;
        endcase
        // T
        7'd84: case(row)
            3'd0: bitmap = 8'b01111110;
            3'd1: bitmap = 8'b00011000;
            3'd2: bitmap = 8'b00011000;
            3'd3: bitmap = 8'b00011000;
            3'd4: bitmap = 8'b00011000;
            3'd5: bitmap = 8'b00011000;
            3'd6: bitmap = 8'b00011000;
            3'd7: bitmap = 8'b00000000;
            default: bitmap = 8'b00000000;
        endcase
        // U
        7'd85: case(row)
            3'd0: bitmap = 8'b01100110;
            3'd1: bitmap = 8'b01100110;
            3'd2: bitmap = 8'b01100110;
            3'd3: bitmap = 8'b01100110;
            3'd4: bitmap = 8'b01100110;
            3'd5: bitmap = 8'b01100110;
            3'd6: bitmap = 8'b00111100;
            3'd7: bitmap = 8'b00000000;
            default: bitmap = 8'b00000000;
        endcase
        // V
        7'd86: case(row)
            3'd0: bitmap = 8'b01100110;
            3'd1: bitmap = 8'b01100110;
            3'd2: bitmap = 8'b01100110;
            3'd3: bitmap = 8'b01100110;
            3'd4: bitmap = 8'b01100110;
            3'd5: bitmap = 8'b00111100;
            3'd6: bitmap = 8'b00011000;
            3'd7: bitmap = 8'b00000000;
            default: bitmap = 8'b00000000;
        endcase
        // W
        7'd87: case(row)
            3'd0: bitmap = 8'b01000010;
            3'd1: bitmap = 8'b01000010;
            3'd2: bitmap = 8'b01000010;
            3'd3: bitmap = 8'b01011010;
            3'd4: bitmap = 8'b01111110;
            3'd5: bitmap = 8'b01100110;
            3'd6: bitmap = 8'b01000010;
            3'd7: bitmap = 8'b00000000;
            default: bitmap = 8'b00000000;
        endcase
        // X (for split screen indicator)
        7'd88: case(row)
            3'd0: bitmap = 8'b01100110;
            3'd1: bitmap = 8'b01100110;
            3'd2: bitmap = 8'b00111100;
            3'd3: bitmap = 8'b00011000;
            3'd4: bitmap = 8'b00111100;
            3'd5: bitmap = 8'b01100110;
            3'd6: bitmap = 8'b01100110;
            3'd7: bitmap = 8'b00000000;
            default: bitmap = 8'b00000000;
        endcase
        // Y
        7'd89: case(row)
            3'd0: bitmap = 8'b01100110;
            3'd1: bitmap = 8'b01100110;
            3'd2: bitmap = 8'b01100110;
            3'd3: bitmap = 8'b00111100;
            3'd4: bitmap = 8'b00011000;
            3'd5: bitmap = 8'b00011000;
            3'd6: bitmap = 8'b00011000;
            3'd7: bitmap = 8'b00000000;
            default: bitmap = 8'b00000000;
        endcase
        default: bitmap = 8'b00000000;
    endcase
end

endmodule