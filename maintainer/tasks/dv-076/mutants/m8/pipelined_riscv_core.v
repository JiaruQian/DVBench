`include "parameters.vh"



module pipelined_riscv_core#(
    parameter WIDTH = 32,
    parameter PROGRAM_FILE = "program3.hex"
)(
    input wire                  i_clk, 
    input wire                  i_rstn,
    input wire [WIDTH-1:0]       input_data,
    output reg                  result_valid,
    output reg [WIDTH-1:0]       result_data

);

// Instruction Memory Nets 
wire [WIDTH - 1 : 0]            instr_add;
wire [WIDTH - 1 : 0]            instr;

// Data Memory 

wire [WIDTH - 1 : 0]            w_data;
wire [WIDTH - 1 : 0]            r_data;
wire [`D_ADD_SIZE - 1 : 0]      w_data_add;

wire                            we; 
wire [WIDTH-1:0] ram_data;
wire output_selected = w_data_add == 32'hfffffffc;
wire input_selected = w_data_add == 32'hfffffff8;
assign r_data = input_selected ? input_data : (output_selected ? result_data : ram_data);
always @(posedge i_clk or negedge i_rstn) begin
    if (!i_rstn) begin
        result_valid <= 1'b0;
        result_data <= 0;
    end else begin
        result_valid <= we && output_selected;
        if (we && output_selected)
            result_data <= w_data;
    end
end


instr_mem #(.PROGRAM_FILE(PROGRAM_FILE)) u0(
    .i_add          (instr_add),
    .o_instr        (instr)
);


data_mem u1(
    .i_clk          (i_clk),
    .i_rstn         (i_rstn),
    .i_we           (we && !output_selected && !input_selected),
    .i_add          (w_data_add),
    .i_data         (w_data),
    .o_data         (ram_data)
);


pipelined_riscv_datapath u2(
    .i_clk          (i_clk),
    .i_rstn         (i_rstn),
    // Instruction Memory Interface 
        
    
    .i_instr_mem_out(instr),
    .o_instr_add    (instr_add),
    
    // Date Memory Interface 
    
    .o_we           (we),
    .o_d_add        (w_data_add),
    .o_w_data       (w_data),
    .i_r_data       (r_data)
);

endmodule 
