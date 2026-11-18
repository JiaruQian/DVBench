`timescale 1ns/1ps
module dvbench_model #(
    parameter WIDTH = 32,
    parameter PROGRAM_FILE = "program3.hex"
)(
    input wire i_clk,
    input wire i_rstn,
    input wire [WIDTH-1:0] input_data,
    output logic result_valid,
    output logic [WIDTH-1:0] result_data
);
integer elapsed_edges;
logic [WIDTH-1:0] sampled_input;
always @(posedge i_clk or negedge i_rstn) begin
    if (!i_rstn) begin
        elapsed_edges <= 0;
        sampled_input <= 0;
        result_valid <= 0;
        result_data <= 0;
    end else begin
        if (elapsed_edges < 67) elapsed_edges <= elapsed_edges + 1;
        if (elapsed_edges == 20) sampled_input <= input_data;
        result_valid <= elapsed_edges == 65;
        if (elapsed_edges == 65) result_data <= sampled_input + 32'd4;
    end
end
endmodule
