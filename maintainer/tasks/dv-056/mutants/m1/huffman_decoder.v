`timescale 1ns / 1ps

module huffman_decoder (
    input  wire          clk,
    input  wire          rst_n,
    input  wire          huff_dec_start,
    input  wire [1023:0] bs_in,
    input  wire [10:0]   bs_len,

    output reg  [767:0]  rle_out,
    output reg  [6:0]    rle_count,
    output reg           huff_dec_done
);

    reg [15:0] huff_code [0:255];
    reg [4:0]  huff_len  [0:255];
    integer _i;
    initial begin
       
        for (_i=0;_i<256;_i=_i+1) begin huff_code[_i]=0; huff_len[_i]=0; end
        huff_code[8'h00] = 16'b0000000000001010; huff_len[8'h00] = 5'd4;
        huff_code[8'h01] = 16'b0000000000000000; huff_len[8'h01] = 5'd2;
        huff_code[8'h02] = 16'b0000000000000001; huff_len[8'h02] = 5'd2;
        huff_code[8'h03] = 16'b0000000000000100; huff_len[8'h03] = 5'd3;
        huff_code[8'h04] = 16'b0000000000001011; huff_len[8'h04] = 5'd4;
        huff_code[8'h05] = 16'b0000000000011010; huff_len[8'h05] = 5'd5;
        huff_code[8'h06] = 16'b0000000001111000; huff_len[8'h06] = 5'd7;
        huff_code[8'h07] = 16'b0000000011111000; huff_len[8'h07] = 5'd8;
        huff_code[8'h08] = 16'b0000001111110110; huff_len[8'h08] = 5'd10;
        huff_code[8'h09] = 16'b1111111110000010; huff_len[8'h09] = 5'd16;
        huff_code[8'h0A] = 16'b1111111110000011; huff_len[8'h0A] = 5'd16;
        huff_code[8'h11] = 16'b0000000000001100; huff_len[8'h11] = 5'd4;
        huff_code[8'h12] = 16'b0000000000011011; huff_len[8'h12] = 5'd5;
        huff_code[8'h13] = 16'b0000000001111001; huff_len[8'h13] = 5'd7;
        huff_code[8'h14] = 16'b0000000111110110; huff_len[8'h14] = 5'd9;
        huff_code[8'h15] = 16'b0000011111110110; huff_len[8'h15] = 5'd11;
        huff_code[8'h16] = 16'b1111111110000100; huff_len[8'h16] = 5'd16;
        huff_code[8'h17] = 16'b1111111110000101; huff_len[8'h17] = 5'd16;
        huff_code[8'h18] = 16'b1111111110000110; huff_len[8'h18] = 5'd16;
        huff_code[8'h19] = 16'b1111111110000111; huff_len[8'h19] = 5'd16;
        huff_code[8'h1A] = 16'b1111111110001000; huff_len[8'h1A] = 5'd16;
        huff_code[8'h21] = 16'b0000000000011100; huff_len[8'h21] = 5'd5;
        huff_code[8'h22] = 16'b0000000011111001; huff_len[8'h22] = 5'd8;
        huff_code[8'h23] = 16'b0000001111110111; huff_len[8'h23] = 5'd10;
        huff_code[8'h24] = 16'b0000111111110100; huff_len[8'h24] = 5'd12;
        huff_code[8'h25] = 16'b1111111110001001; huff_len[8'h25] = 5'd16;
        huff_code[8'h26] = 16'b1111111110001010; huff_len[8'h26] = 5'd16;
        huff_code[8'h27] = 16'b1111111110001011; huff_len[8'h27] = 5'd16;
        huff_code[8'h28] = 16'b1111111110001100; huff_len[8'h28] = 5'd16;
        huff_code[8'h29] = 16'b1111111110001101; huff_len[8'h29] = 5'd16;
        huff_code[8'h2A] = 16'b1111111110001110; huff_len[8'h2A] = 5'd16;
        huff_code[8'h31] = 16'b0000000000111010; huff_len[8'h31] = 5'd6;
        huff_code[8'h32] = 16'b0000000111110111; huff_len[8'h32] = 5'd9;
        huff_code[8'h33] = 16'b0000111111110101; huff_len[8'h33] = 5'd12;
        huff_code[8'h34] = 16'b1111111110001111; huff_len[8'h34] = 5'd16;
        huff_code[8'h35] = 16'b1111111110010000; huff_len[8'h35] = 5'd16;
        huff_code[8'h36] = 16'b1111111110010001; huff_len[8'h36] = 5'd16;
        huff_code[8'h37] = 16'b1111111110010010; huff_len[8'h37] = 5'd16;
        huff_code[8'h38] = 16'b1111111110010011; huff_len[8'h38] = 5'd16;
        huff_code[8'h39] = 16'b1111111110010100; huff_len[8'h39] = 5'd16;
        huff_code[8'h3A] = 16'b1111111110010101; huff_len[8'h3A] = 5'd16;
        huff_code[8'h41] = 16'b0000000000111011; huff_len[8'h41] = 5'd6;
        huff_code[8'h42] = 16'b0000001111111000; huff_len[8'h42] = 5'd10;
        huff_code[8'h43] = 16'b1111111110010110; huff_len[8'h43] = 5'd16;
        huff_code[8'h44] = 16'b1111111110010111; huff_len[8'h44] = 5'd16;
        huff_code[8'h45] = 16'b1111111110011000; huff_len[8'h45] = 5'd16;
        huff_code[8'h46] = 16'b1111111110011001; huff_len[8'h46] = 5'd16;
        huff_code[8'h47] = 16'b1111111110011010; huff_len[8'h47] = 5'd16;
        huff_code[8'h48] = 16'b1111111110011011; huff_len[8'h48] = 5'd16;
        huff_code[8'h49] = 16'b1111111110011100; huff_len[8'h49] = 5'd16;
        huff_code[8'h4A] = 16'b1111111110011101; huff_len[8'h4A] = 5'd16;
        huff_code[8'h51] = 16'b0000000001111010; huff_len[8'h51] = 5'd7;
        huff_code[8'h52] = 16'b0000011111110111; huff_len[8'h52] = 5'd11;
        huff_code[8'h53] = 16'b1111111110011110; huff_len[8'h53] = 5'd16;
        huff_code[8'h54] = 16'b1111111110011111; huff_len[8'h54] = 5'd16;
        huff_code[8'h55] = 16'b1111111110100000; huff_len[8'h55] = 5'd16;
        huff_code[8'h56] = 16'b1111111110100001; huff_len[8'h56] = 5'd16;
        huff_code[8'h57] = 16'b1111111110100010; huff_len[8'h57] = 5'd16;
        huff_code[8'h58] = 16'b1111111110100011; huff_len[8'h58] = 5'd16;
        huff_code[8'h59] = 16'b1111111110100100; huff_len[8'h59] = 5'd16;
        huff_code[8'h5A] = 16'b1111111110100101; huff_len[8'h5A] = 5'd16;
        huff_code[8'h61] = 16'b0000000001111011; huff_len[8'h61] = 5'd7;
        huff_code[8'h62] = 16'b0000111111110110; huff_len[8'h62] = 5'd12;
        huff_code[8'h63] = 16'b1111111110100110; huff_len[8'h63] = 5'd16;
        huff_code[8'h64] = 16'b1111111110100111; huff_len[8'h64] = 5'd16;
        huff_code[8'h65] = 16'b1111111110101000; huff_len[8'h65] = 5'd16;
        huff_code[8'h66] = 16'b1111111110101001; huff_len[8'h66] = 5'd16;
        huff_code[8'h67] = 16'b1111111110101010; huff_len[8'h67] = 5'd16;
        huff_code[8'h68] = 16'b1111111110101011; huff_len[8'h68] = 5'd16;
        huff_code[8'h69] = 16'b1111111110101100; huff_len[8'h69] = 5'd16;
        huff_code[8'h6A] = 16'b1111111110101101; huff_len[8'h6A] = 5'd16;
        huff_code[8'h71] = 16'b0000000011111010; huff_len[8'h71] = 5'd8;
        huff_code[8'h72] = 16'b0000111111110111; huff_len[8'h72] = 5'd12;
        huff_code[8'h73] = 16'b1111111110101110; huff_len[8'h73] = 5'd16;
        huff_code[8'h74] = 16'b1111111110101111; huff_len[8'h74] = 5'd16;
        huff_code[8'h75] = 16'b1111111110110000; huff_len[8'h75] = 5'd16;
        huff_code[8'h76] = 16'b1111111110110001; huff_len[8'h76] = 5'd16;
        huff_code[8'h77] = 16'b1111111110110010; huff_len[8'h77] = 5'd16;
        huff_code[8'h78] = 16'b1111111110110011; huff_len[8'h78] = 5'd16;
        huff_code[8'h79] = 16'b1111111110110100; huff_len[8'h79] = 5'd16;
        huff_code[8'h7A] = 16'b1111111110110101; huff_len[8'h7A] = 5'd16;
        huff_code[8'h81] = 16'b0000000111111000; huff_len[8'h81] = 5'd9;
        huff_code[8'h82] = 16'b0111111111000000; huff_len[8'h82] = 5'd15;
        huff_code[8'h83] = 16'b1111111110110110; huff_len[8'h83] = 5'd16;
        huff_code[8'h84] = 16'b1111111110110111; huff_len[8'h84] = 5'd16;
        huff_code[8'h85] = 16'b1111111110111000; huff_len[8'h85] = 5'd16;
        huff_code[8'h86] = 16'b1111111110111001; huff_len[8'h86] = 5'd16;
        huff_code[8'h87] = 16'b1111111110111010; huff_len[8'h87] = 5'd16;
        huff_code[8'h88] = 16'b1111111110111011; huff_len[8'h88] = 5'd16;
        huff_code[8'h89] = 16'b1111111110111100; huff_len[8'h89] = 5'd16;
        huff_code[8'h8A] = 16'b1111111110111101; huff_len[8'h8A] = 5'd16;
        huff_code[8'h91] = 16'b0000000111111001; huff_len[8'h91] = 5'd9;
        huff_code[8'h92] = 16'b1111111110111110; huff_len[8'h92] = 5'd16;
        huff_code[8'h93] = 16'b1111111110111111; huff_len[8'h93] = 5'd16;
        huff_code[8'h94] = 16'b1111111111000000; huff_len[8'h94] = 5'd16;
        huff_code[8'h95] = 16'b1111111111000001; huff_len[8'h95] = 5'd16;
        huff_code[8'h96] = 16'b1111111111000010; huff_len[8'h96] = 5'd16;
        huff_code[8'h97] = 16'b1111111111000011; huff_len[8'h97] = 5'd16;
        huff_code[8'h98] = 16'b1111111111000100; huff_len[8'h98] = 5'd16;
        huff_code[8'h99] = 16'b1111111111000101; huff_len[8'h99] = 5'd16;
        huff_code[8'h9A] = 16'b1111111111000110; huff_len[8'h9A] = 5'd16;
        huff_code[8'hA1] = 16'b0000000111111010; huff_len[8'hA1] = 5'd9;
        huff_code[8'hA2] = 16'b1111111111000111; huff_len[8'hA2] = 5'd16;
        huff_code[8'hA3] = 16'b1111111111001000; huff_len[8'hA3] = 5'd16;
        huff_code[8'hA4] = 16'b1111111111001001; huff_len[8'hA4] = 5'd16;
        huff_code[8'hA5] = 16'b1111111111001010; huff_len[8'hA5] = 5'd16;
        huff_code[8'hA6] = 16'b1111111111001011; huff_len[8'hA6] = 5'd16;
        huff_code[8'hA7] = 16'b1111111111001100; huff_len[8'hA7] = 5'd16;
        huff_code[8'hA8] = 16'b1111111111001101; huff_len[8'hA8] = 5'd16;
        huff_code[8'hA9] = 16'b1111111111001110; huff_len[8'hA9] = 5'd16;
        huff_code[8'hAA] = 16'b1111111111001111; huff_len[8'hAA] = 5'd16;
        huff_code[8'hB1] = 16'b0000001111111001; huff_len[8'hB1] = 5'd10;
        huff_code[8'hB2] = 16'b1111111111010000; huff_len[8'hB2] = 5'd16;
        huff_code[8'hB3] = 16'b1111111111010001; huff_len[8'hB3] = 5'd16;
        huff_code[8'hB4] = 16'b1111111111010010; huff_len[8'hB4] = 5'd16;
        huff_code[8'hB5] = 16'b1111111111010011; huff_len[8'hB5] = 5'd16;
        huff_code[8'hB6] = 16'b1111111111010100; huff_len[8'hB6] = 5'd16;
        huff_code[8'hB7] = 16'b1111111111010101; huff_len[8'hB7] = 5'd16;
        huff_code[8'hB8] = 16'b1111111111010110; huff_len[8'hB8] = 5'd16;
        huff_code[8'hB9] = 16'b1111111111010111; huff_len[8'hB9] = 5'd16;
        huff_code[8'hBA] = 16'b1111111111011000; huff_len[8'hBA] = 5'd16;
        huff_code[8'hC1] = 16'b0000001111111010; huff_len[8'hC1] = 5'd10;
        huff_code[8'hC2] = 16'b1111111111011001; huff_len[8'hC2] = 5'd16;
        huff_code[8'hC3] = 16'b1111111111011010; huff_len[8'hC3] = 5'd16;
        huff_code[8'hC4] = 16'b1111111111011011; huff_len[8'hC4] = 5'd16;
        huff_code[8'hC5] = 16'b1111111111011100; huff_len[8'hC5] = 5'd16;
        huff_code[8'hC6] = 16'b1111111111011101; huff_len[8'hC6] = 5'd16;
        huff_code[8'hC7] = 16'b1111111111011110; huff_len[8'hC7] = 5'd16;
        huff_code[8'hC8] = 16'b1111111111011111; huff_len[8'hC8] = 5'd16;
        huff_code[8'hC9] = 16'b1111111111100000; huff_len[8'hC9] = 5'd16;
        huff_code[8'hCA] = 16'b1111111111100001; huff_len[8'hCA] = 5'd16;
        huff_code[8'hD1] = 16'b0000011111111000; huff_len[8'hD1] = 5'd11;
        huff_code[8'hD2] = 16'b1111111111100010; huff_len[8'hD2] = 5'd16;
        huff_code[8'hD3] = 16'b1111111111100011; huff_len[8'hD3] = 5'd16;
        huff_code[8'hD4] = 16'b1111111111100100; huff_len[8'hD4] = 5'd16;
        huff_code[8'hD5] = 16'b1111111111100101; huff_len[8'hD5] = 5'd16;
        huff_code[8'hD6] = 16'b1111111111100110; huff_len[8'hD6] = 5'd16;
        huff_code[8'hD7] = 16'b1111111111100111; huff_len[8'hD7] = 5'd16;
        huff_code[8'hD8] = 16'b1111111111101000; huff_len[8'hD8] = 5'd16;
        huff_code[8'hD9] = 16'b1111111111101001; huff_len[8'hD9] = 5'd16;
        huff_code[8'hDA] = 16'b1111111111101010; huff_len[8'hDA] = 5'd16;
        huff_code[8'hE1] = 16'b1111111111101011; huff_len[8'hE1] = 5'd16;
        huff_code[8'hE2] = 16'b1111111111101100; huff_len[8'hE2] = 5'd16;
        huff_code[8'hE3] = 16'b1111111111101101; huff_len[8'hE3] = 5'd16;
        huff_code[8'hE4] = 16'b1111111111101110; huff_len[8'hE4] = 5'd16;
        huff_code[8'hE5] = 16'b1111111111101111; huff_len[8'hE5] = 5'd16;
        huff_code[8'hE6] = 16'b1111111111110000; huff_len[8'hE6] = 5'd16;
        huff_code[8'hE7] = 16'b1111111111110001; huff_len[8'hE7] = 5'd16;
        huff_code[8'hE8] = 16'b1111111111110010; huff_len[8'hE8] = 5'd16;
        huff_code[8'hE9] = 16'b1111111111110011; huff_len[8'hE9] = 5'd16;
        huff_code[8'hEA] = 16'b1111111111110100; huff_len[8'hEA] = 5'd16;
        huff_code[8'hF0] = 16'b0000011111111001; huff_len[8'hF0] = 5'd11;
        huff_code[8'hF1] = 16'b1111111111110101; huff_len[8'hF1] = 5'd16;
        huff_code[8'hF2] = 16'b1111111111110110; huff_len[8'hF2] = 5'd16;
        huff_code[8'hF3] = 16'b1111111111110111; huff_len[8'hF3] = 5'd16;
        huff_code[8'hF4] = 16'b1111111111111000; huff_len[8'hF4] = 5'd16;
        huff_code[8'hF5] = 16'b1111111111111001; huff_len[8'hF5] = 5'd16;
        huff_code[8'hF6] = 16'b1111111111111010; huff_len[8'hF6] = 5'd16;
        huff_code[8'hF7] = 16'b1111111111111011; huff_len[8'hF7] = 5'd16;
        huff_code[8'hF8] = 16'b1111111111111100; huff_len[8'hF8] = 5'd16;
        huff_code[8'hF9] = 16'b1111111111111101; huff_len[8'hF9] = 5'd16;
        huff_code[8'hFA] = 16'b1111111111111110; huff_len[8'hFA] = 5'd16;
    end

    function signed [7:0] vlc_to_amp;
        input [3:0] cat;
        input [7:0] vlc;
        reg   [7:0] mask;
        begin
            if (cat != 4'd0) vlc_to_amp = 8'sd0;
            else begin
                mask = (8'd1 << cat) - 8'd1;
                if (vlc[cat-1] == 1'b1) vlc_to_amp = vlc & mask;
                else                    vlc_to_amp = (vlc & mask) - mask;
            end
        end
    endfunction

    localparam S_IDLE=3'd0, S_READ_HC=3'd1, S_CHECK=3'd2,
               S_READ_VLC=3'd3, S_WRITE_PAIR=3'd4, S_DONE=3'd5;

    reg [2:0]  state;
    reg [10:0] bit_ptr;
    reg [15:0] code_buf;
    reg [4:0]  code_len;
    reg [7:0]  vlc_buf;
    reg [3:0]  vlc_needed, vlc_count;
    reg [3:0]  curr_run, curr_cat;
    reg [6:0]  pair_idx, pair_count;

    reg        match_found;
    reg [3:0]  match_run, match_cat;
    integer k;

    always @(*) begin
        match_found = 1'b0; match_run = 4'd0; match_cat = 4'd0;
        for (k = 0; k < 256; k = k + 1) begin
            if (!match_found && huff_len[k] != 5'd0 &&
                huff_len[k] == code_len && huff_code[k] == code_buf) begin
                match_found = 1'b1;
                match_run   = k[7:4];
                match_cat   = k[3:0];
            end
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state<=S_IDLE; bit_ptr<=0; code_buf<=0; code_len<=0;
            vlc_buf<=0; vlc_needed<=0; vlc_count<=0;
            curr_run<=0; curr_cat<=0; pair_idx<=0; pair_count<=0;
            rle_out<=0; rle_count<=0; huff_dec_done<=0;
        end else begin
            huff_dec_done <= 1'b0;
            case (state)
                S_IDLE: if (huff_dec_start) begin
                    bit_ptr<=0; code_buf<=0; code_len<=0;
                    pair_idx<=0; pair_count<=0; rle_out<=0;
                    state<=S_READ_HC;
                end

                S_READ_HC: begin
                    if (bit_ptr >= bs_len) state <= S_DONE;
                    else begin
                        code_buf <= {code_buf[14:0], bs_in[bit_ptr]};
                        code_len <= code_len + 5'd1;
                        bit_ptr  <= bit_ptr + 11'd1;
                        state    <= S_CHECK;
                    end
                end

                S_CHECK: begin
                    if (match_found) begin
                        curr_run <= match_run; curr_cat <= match_cat;
                        code_buf <= 16'd0; code_len <= 5'd0;
                        if (match_run==4'd0 && match_cat==4'd0) begin
                            rle_out[pair_idx*12 +: 12] <= {4'd0, 8'sd0}; 
                            pair_count <= pair_idx + 1;
                            pair_idx   <= pair_idx + 1;
                            state      <= S_DONE;
                        end else if (match_cat==4'd0) begin
                            rle_out[pair_idx*12 +: 12] <= {match_run, 8'sd0}; 
                            pair_count <= pair_idx + 1;
                            pair_idx   <= pair_idx + 1;
                            state      <= S_READ_HC;
                        end else begin
                            vlc_buf<=0; vlc_needed<=match_cat; vlc_count<=0;
                            state<=S_READ_VLC;
                        end
                    end else begin
                        if (code_len >= 5'd16) state <= S_DONE;
                        else                    state <= S_READ_HC;
                    end
                end

                S_READ_VLC: begin
                    if (vlc_count < vlc_needed) begin
                        vlc_buf   <= {vlc_buf[6:0], bs_in[bit_ptr]};
                        bit_ptr   <= bit_ptr + 11'd1;
                        vlc_count <= vlc_count + 4'd1;
                    end else state <= S_WRITE_PAIR;
                end

                S_WRITE_PAIR: begin
                    rle_out[pair_idx*12 +: 12] <= {curr_run, vlc_to_amp(curr_cat, vlc_buf)};
                    pair_count <= pair_idx + 1;
                    pair_idx   <= pair_idx + 1;
                    state      <= S_READ_HC;
                end

                S_DONE: begin
                    huff_dec_done <= 1'b1;
                    rle_count     <= pair_count;
                    state         <= S_IDLE;
                end
            endcase
        end
    end
endmodule