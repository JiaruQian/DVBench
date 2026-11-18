`timescale 1ns / 1ps
// Module:      text_overlay.v
// Description: Text overlay module that renders the active filter name as white
//              text on a black background box in the top-right corner of the
//              frame. Uses font_rom.v for 8x8 bitmap font rendered at 5x scale
//              (40x40 pixels per character). Pixel position tracked via vsync
//              and VDE edge detection. Filter name updates combinationally
//              based on filter_sel input.
// Author:      5529114
// Date:        April 2026

module text_overlay #
(
    parameter DATA_WIDTH   = 24,
    parameter IMAGE_WIDTH  = 1920,
    parameter IMAGE_HEIGHT = 1080
)
(
    input  wire                  clk,
    input  wire                  n_rst,
    input  wire [2:0]            filter_sel,
    input  wire                  i_vid_hsync,
    input  wire                  i_vid_vsync,
    input  wire                  i_vid_VDE,
    input  wire [DATA_WIDTH-1:0] i_vid_data,
    output reg  [DATA_WIDTH-1:0] o_vid_data
);

    // -------------------------------------------------------------------------
    // Track x and y pixel position using VDE and sync signals
    // -------------------------------------------------------------------------
    reg [10:0] x_cnt;
    reg [10:0] y_cnt;
    reg        last_VDE;
    reg        last_vsync;

    always @ (posedge clk) begin
        if(!n_rst) begin
            x_cnt      <= 0;
            y_cnt      <= 0;
            last_VDE   <= 0;
            last_vsync <= 0;
        end
        else begin
            last_VDE   <= i_vid_VDE;
            last_vsync <= i_vid_vsync;

            // Reset y on vsync falling edge (start of new frame)
            if(!i_vid_vsync && last_vsync) begin
                y_cnt <= 0;
            end
            // Increment y on falling edge of VDE (end of active line)
            else if(!i_vid_VDE && last_VDE) begin
                y_cnt <= y_cnt + 1;
            end

            // x counter
            if(i_vid_VDE) begin
                if(x_cnt == IMAGE_WIDTH - 1)
                    x_cnt <= 0;
                else
                    x_cnt <= x_cnt + 1;
            end
            else begin
                x_cnt <= 0;
            end
        end
    end

    // -------------------------------------------------------------------------
    // Text box: top left corner, 16px tall, wide enough for 9 chars
    // -------------------------------------------------------------------------
    localparam SCALE  = 5;
    localparam CHAR_W = 8 * SCALE;  // 40 pixels per character
    localparam CHAR_H = 8 * SCALE;  // 40 pixels per character height
    localparam PAD    = 4;
    localparam BOX_W  = 9 * CHAR_W + 2 * PAD;  // 9 chars + padding
    localparam BOX_H  = CHAR_H + 2 * PAD;       // char height + padding

    wire in_box;
    assign in_box = (x_cnt >= (IMAGE_WIDTH - BOX_W)) && 
                    (x_cnt < IMAGE_WIDTH) && 
                    (y_cnt < BOX_H);

    // -------------------------------------------------------------------------
    // Filter name lookup
    // -------------------------------------------------------------------------
    reg [6:0] filter_name [0:8];

    always @(*) begin
        case(filter_sel)
            3'b000: begin // NORMAL
                filter_name[0]=7'd78; filter_name[1]=7'd79;
                filter_name[2]=7'd82; filter_name[3]=7'd77;
                filter_name[4]=7'd65; filter_name[5]=7'd76;
                filter_name[6]=7'd32; filter_name[7]=7'd32;
                filter_name[8]=7'd32;
            end
            3'b001: begin // GREYSCALE
                filter_name[0]=7'd71; filter_name[1]=7'd82;
                filter_name[2]=7'd69; filter_name[3]=7'd89;
                filter_name[4]=7'd83; filter_name[5]=7'd67;
                filter_name[6]=7'd65; filter_name[7]=7'd76;
                filter_name[8]=7'd69;
            end
            3'b010: begin // NEGATIVE
                filter_name[0]=7'd78; filter_name[1]=7'd69;
                filter_name[2]=7'd71; filter_name[3]=7'd65;
                filter_name[4]=7'd84; filter_name[5]=7'd73;
                filter_name[6]=7'd86; filter_name[7]=7'd69;
                filter_name[8]=7'd32;
            end
            3'b011: begin // THRESHOLD
                filter_name[0]=7'd84; filter_name[1]=7'd72;
                filter_name[2]=7'd82; filter_name[3]=7'd69;
                filter_name[4]=7'd83; filter_name[5]=7'd72;
                filter_name[6]=7'd79; filter_name[7]=7'd76;
                filter_name[8]=7'd68;
            end
            3'b100: begin // GAUSSIAN
                filter_name[0]=7'd71; filter_name[1]=7'd65;
                filter_name[2]=7'd85; filter_name[3]=7'd83;
                filter_name[4]=7'd83; filter_name[5]=7'd73;
                filter_name[6]=7'd65; filter_name[7]=7'd78;
                filter_name[8]=7'd32;
            end
            3'b101: begin // SHARPEN
                filter_name[0]=7'd83; filter_name[1]=7'd72;
                filter_name[2]=7'd65; filter_name[3]=7'd82;
                filter_name[4]=7'd80; filter_name[5]=7'd69;
                filter_name[6]=7'd78; filter_name[7]=7'd32;
                filter_name[8]=7'd32;
            end
            3'b110: begin // SOBEL
                filter_name[0]=7'd83; filter_name[1]=7'd79;
                filter_name[2]=7'd66; filter_name[3]=7'd69;
                filter_name[4]=7'd76; filter_name[5]=7'd32;
                filter_name[6]=7'd32; filter_name[7]=7'd32;
                filter_name[8]=7'd32;
            end
            3'b111: begin // EMBOSS
                filter_name[0]=7'd69; filter_name[1]=7'd77;
                filter_name[2]=7'd66; filter_name[3]=7'd79;
                filter_name[4]=7'd83; filter_name[5]=7'd83;
                filter_name[6]=7'd32; filter_name[7]=7'd32;
                filter_name[8]=7'd32;
            end
            default: begin
                filter_name[0]=7'd32; filter_name[1]=7'd32;
                filter_name[2]=7'd32; filter_name[3]=7'd32;
                filter_name[4]=7'd32; filter_name[5]=7'd32;
                filter_name[6]=7'd32; filter_name[7]=7'd32;
                filter_name[8]=7'd32;
            end
        endcase
    end

    // -------------------------------------------------------------------------
    // Text region and scaled character position
    // -------------------------------------------------------------------------
    wire [10:0] tx, ty;
    assign tx = x_cnt - (IMAGE_WIDTH - BOX_W) - PAD;
    assign ty = y_cnt - PAD;

    wire in_text;
    assign in_text = in_box &&
                     (x_cnt >= PAD) && (y_cnt >= PAD) &&
                     (tx < 9 * CHAR_W) && (ty < CHAR_H);

    // Divide by CHAR_W to get character index
    // Divide by SCALE to get pixel within character
    wire [3:0] char_idx;
    wire [2:0] char_px;
    wire [2:0] char_row;

    assign char_idx = tx / CHAR_W;               // which character (0-8)
    assign char_px  = (tx % CHAR_W) / SCALE;     // pixel within char (0-7)
    assign char_row = ty / SCALE;                 // row within char (0-7)

    wire [6:0] cur_char;
    assign cur_char = (char_idx <= 4'd8) ? filter_name[char_idx] : 7'd32;

    wire [7:0] bitmap;
    font_rom u_font (
        .char_code(cur_char),
        .row      (char_row),
        .bitmap   (bitmap)
    );

    wire pixel_on;
    assign pixel_on = bitmap[7 - char_px];

    // -------------------------------------------------------------------------
    // Output
    // -------------------------------------------------------------------------
    always @(posedge clk) begin
        if(!n_rst)
            o_vid_data <= 0;
        else begin
            if(in_text && pixel_on)
                o_vid_data <= 24'hFFFFFF;  // white text
            else if(in_box)
                o_vid_data <= 24'h000000;  // black background
            else
                o_vid_data <= i_vid_data;  // normal video
        end
    end

endmodule
