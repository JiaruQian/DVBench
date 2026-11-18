// DWconv_OutputControl
// The logic is to write and output normally in cnt_in order; the next layer reads data only when cnt_in=31
module DWconv_OutputControl (
    input signed [7:0] input_data0,
    input signed [7:0] input_data1,
    input signed [7:0] input_data2,
    input signed [7:0] input_data3,
    input clk,
    input rst_b,
    input en,
    input [4:0] cnt_in,  // 32
    input [3:0] pos_in,  // 9
    output reg [4:0] cnt_out,
    output reg [3:0] pos_out,
    output [0:32*8-1] pwconv_weight,
    output reg [0:32*8-1] output_data0,
    output reg [0:32*8-1] output_data1,
    output reg [0:32*8-1] output_data2,
    output reg [0:32*8-1] output_data3
);
    // cnt flow
    always @(posedge clk or negedge rst_b) begin
        if (!rst_b) begin
            cnt_out <= 0;
        end else begin
            if (en) cnt_out <= cnt_in;
            else cnt_out <= cnt_out;
        end
    end

    // pos flow
    always @(posedge clk or negedge rst_b) begin
        if (!rst_b) begin
            pos_out <= 0;
        end else begin
            if (en) pos_out <= pos_in;
            else pos_out <= pos_out;
        end
    end

    // pwconv weight sram
    PWconv_Conv_WeightSelector u_pwconv_weightselector (
       .clk(clk),
       .rst_b(rst_b),
       .en(en),
       .cnt(cnt_in),
       .selected_weight(pwconv_weight)
    );

    // output depends only on cnt
    always @(posedge clk or negedge rst_b) begin
        if (!rst_b) begin
            output_data0 <= 0;
            output_data1 <= 0;
            output_data2 <= 0;
            output_data3 <= 0;
        end else begin
            if (en) begin
                output_data0[cnt_in*7+:8] <= input_data0;
                output_data1[cnt_in*8+:8] <= input_data1;
                output_data2[cnt_in*8+:8] <= input_data2;
                output_data3[cnt_in*8+:8] <= input_data3;
            end else begin
                output_data0 <= output_data0;
                output_data1 <= output_data1;
                output_data2 <= output_data2;
                output_data3 <= output_data3;
            end
        end
    end

endmodule
