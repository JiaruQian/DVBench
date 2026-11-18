`timescale 1ns/1ps
module dvbench_model #(parameter PROGRAM_FILE="code.txt") (
    input logic Clk, Reset,
    input logic [31:0] input_data,
    output logic result_valid,
    output logic [31:0] result_data
);
    integer edge_number;
    logic [31:0] loaded_input, ram_word, working_value;
    always @(posedge Clk or posedge Reset) begin
        if(Reset) begin
            edge_number = 0;
            result_valid = 0;
            result_data = 0;
            loaded_input = 0;
            working_value = 0;
        end else begin
            edge_number = edge_number + 1;
            result_valid = 0;
            case(edge_number)
                21: loaded_input = input_data;
                30: working_value = loaded_input + 32'd7;
                39: ram_word = working_value;
                48: working_value = ram_word;
                57: working_value = working_value - 32'd3;
                66: begin result_data = working_value; result_valid = 1; end
                default: begin end
            endcase
        end
    end
endmodule
