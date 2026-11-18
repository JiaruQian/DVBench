`timescale 1ns / 1ps

module rle_decoder (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         rle_dec_start,
    input  wire [767:0] rle_in,
    input  wire [6:0]   rle_count,

    output reg  [511:0] zigzag_out,
    output reg          rle_dec_done
);

    localparam S_IDLE      = 2'd0;
    localparam S_READ_PAIR = 2'd1;
    localparam S_INS_ZERO  = 2'd2;
    localparam S_DONE      = 2'd3;

    reg [1:0] state;
    reg [6:0] pair_idx;
    reg [5:0] out_idx;
    reg [3:0] zero_cnt;

    wire [3:0]        curr_run;
    wire signed [7:0] curr_amp;

    assign curr_run = rle_in[pair_idx*12+8 +: 4];
    assign curr_amp = $signed(rle_in[pair_idx*12 +: 8]);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state        <= S_IDLE;
            pair_idx     <= 7'd0;
            out_idx      <= 6'd0;
            zero_cnt     <= 4'd0;
            rle_dec_done <= 1'b0;
            zigzag_out   <= 512'd0;
        end
        else begin
            rle_dec_done <= 1'b0;

            case (state)

                S_IDLE: begin
                    if (rle_dec_start) begin
                        pair_idx   <= 7'd0;
                        out_idx    <= 6'd0;
                        zero_cnt   <= 4'd0;
                        zigzag_out <= 512'd0;
                        state      <= S_READ_PAIR;
                    end
                end

                S_READ_PAIR: begin
             
                    if (curr_run == 4'd0 ||
                        curr_amp == 8'sd0) begin
                        state <= S_DONE;
                    end
                
                    else if (pair_idx >= rle_count) begin
                        state <= S_DONE;
                    end
              
                    else if (curr_run == 4'd0) begin
                        zigzag_out[out_idx*8 +: 8] <= curr_amp;
                        out_idx  <= out_idx + 1;
                        pair_idx <= pair_idx + 1;
                    end
                
                    else begin
                        zero_cnt <= curr_run;
                        state    <= S_INS_ZERO;
                    end
                end

                S_INS_ZERO: begin
                    
                    zigzag_out[out_idx*8 +: 8] <= 8'sd0;
                    zero_cnt <= zero_cnt - 1;

                    if (zero_cnt == 4'd1) begin
                        
                        zigzag_out[(out_idx+1)*8 +: 8] <= curr_amp;
                        out_idx  <= out_idx + 2;
                        pair_idx <= pair_idx + 1;
                        state    <= S_READ_PAIR;
                    end
                    else begin
                        
                        out_idx <= out_idx + 1;
                    end
                    
                end

                S_DONE: begin
                    rle_dec_done <= 1'b1;
                    state        <= S_IDLE;
                end

            endcase
        end
    end

endmodule