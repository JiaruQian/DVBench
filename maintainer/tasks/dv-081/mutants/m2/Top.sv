`include "Macros.svh"

module Top #(parameter PROGRAM_FILE = "program.mem") (
    input clk,
    input rst,
    input [31:0] input_data,
    output reg result_valid,
    output reg [31:0] result_data
);

    wire        [`I_SIZE - 1 : 0] instruction;
    wire signed [`D_SIZE - 1 : 0] data_in;
    wire signed [`D_SIZE - 1 : 0] memory_data;
    wire                          read;
    wire                          write;
    wire        [`A_SIZE - 1 : 0] instr_addr;
    wire        [`A_SIZE - 1 : 0] data_addr;
    wire signed [`D_SIZE - 1 : 0] data_out;
    reg peripheral_read_selected;
    reg [31:0] peripheral_read_data;
    wire output_selected = data_addr == 10'h3ff;
    wire input_selected = data_addr == 10'h3fe;
    assign data_in = peripheral_read_selected ? peripheral_read_data : memory_data;
    always @(posedge clk) begin
        if (!rst) begin
            result_valid <= 1'b0;
            result_data <= 32'd0;
            peripheral_read_selected <= 1'b0;
            peripheral_read_data <= 32'd0;
        end else begin
            if (read) begin
                peripheral_read_selected <= input_selected || output_selected;
                if (input_selected)
                    peripheral_read_data <= input_data;
                else if (output_selected)
                    peripheral_read_data <= result_data;
            end
            result_valid <= write && !read && output_selected;
            if (write && !read && output_selected)
                result_data <= data_out;
        end
    end

    Processor processor(
        .clk(clk),
        .rst(rst),
        .instruction(instruction),
        .data_in(data_in),
        .read(read),
        .write(write),
        .pc(instr_addr),
        .addr(data_addr),
        .data_out(data_out)
    );

    Program_Memory #(.PROGRAM_FILE(PROGRAM_FILE)) program_memory(
        .addr(instr_addr),
        .instruction(instruction)
    );

    Data_Memory data_memory(
        .clk(clk),    
        .read(read && !output_selected && !input_selected),   
        .write(write && !output_selected && !input_selected && rst),
        .addr(data_addr),   
        .data_in(data_out),
        .data_out(memory_data)
    );

endmodule
