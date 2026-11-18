`timescale 1ns / 1ps
// trigger_dec=0 → pass all 64 values unchanged
// trigger_dec=1 → add 1 to all 64 values

module dec_ht_payload (
    input  wire         clk,
    input  wire         rst_n,
    input  wire         payload_start,
    input  wire [511:0] raster_in,
    input  wire         trigger_dec,

    output reg  [511:0] payload_out,
    output reg          payload_done
);

    reg [5:0] idx;
    reg       processing;

    wire signed [7:0] curr_val;
    assign curr_val = $signed(raster_in[idx*8 +: 8]);

    wire signed [7:0] modified;
    assign modified = (curr_val == 8'sd127) ?
                       8'sd127 :
                       curr_val + 8'sd1;

    wire signed [7:0] final_val;
    assign final_val = trigger_dec ? modified : curr_val;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            idx          <= 6'd0;
            processing   <= 1'b0;
            payload_done <= 1'b0;
            payload_out  <= 512'd0;
        end
        else begin
            payload_done <= 1'b0;

            if (payload_start) begin
                processing <= 1'b1;
                idx        <= 6'd0;
            end

            if (processing) begin
                payload_out[idx*8 +: 8] <= final_val;

                if (idx == 6'd63) begin
                    processing   <= 1'b0;
                    payload_done <= 1'b1;
                end
                else
                    idx <= idx + 6'd1;
            end
        end
    end

endmodule