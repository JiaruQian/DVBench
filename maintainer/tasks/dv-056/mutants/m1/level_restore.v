`timescale 1ns / 1ps
// PURPOSE: Add 128 back to each IDCT output value
//          Clip result to valid pixel range [0, 255]
// INPUT:  idct_in   [575:0] - 64 × 9-bit signed IDCT values
//         restore_start     - pulse to start
// OUTPUT: pixel_out [511:0] - 64 × 8-bit unsigned pixels
//         restore_done      - pulse when complete

module level_restore (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        restore_start,
    input  wire [575:0] idct_in,      // 64 × 9-bit signed

    output reg  [511:0] pixel_out,    // 64 × 8-bit unsigned
    output reg          restore_done
);

    reg [5:0] coeff_idx;
    reg       processing;

    wire signed [8:0] curr_val;
    assign curr_val = $signed(idct_in[coeff_idx*9 +: 9]);

    wire signed [9:0] restored;
    assign restored = curr_val + 10'sd128;

    wire [7:0] clipped;
    assign clipped = (restored > 10'sd255) ? 8'd255 :
                     (restored < 10'sd0)   ? 8'd0   :
                      restored[7:0];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            coeff_idx    <= 6'd0;
            processing   <= 1'b0;
            restore_done <= 1'b0;
            pixel_out    <= 512'd0;
        end
        else begin
            restore_done <= 1'b0;

            if (restore_start) begin
                processing <= 1'b1;
                coeff_idx  <= 6'd0;
            end

            if (processing) begin
                pixel_out[coeff_idx*8 +: 8] <= clipped;

                if (coeff_idx == 6'd63) begin
                    processing   <= 1'b0;
                    restore_done <= 1'b1;
                end
                else
                    coeff_idx <= coeff_idx + 6'd1;
            end
        end
    end

endmodule