`timescale 1ns/1ps
module dvbench_top;logic clk_i=0;always #5 clk_i=~clk_i;logic[118:0]drive_inputs=0;wire[47:0]observed;logic[47:0]mask;
logic rst_ni;
logic[2:0][31:0] operands_i;
logic[2:0] is_boxed_i;
logic[2:0] rnd_mode_i;
logic[3:0] op_i;
logic op_mod_i;
logic[3:0] tag_i;
logic mask_i;
logic[1:0] aux_i;
logic in_valid_i;
logic flush_i;
logic out_ready_i;
logic[0:0] reg_ena_i;
wire[31:0] result_o;
wire[4:0] status_o;
wire extension_bit_o;
wire[3:0] tag_o;
wire mask_o;
wire[1:0] aux_o;
wire out_valid_o;
wire in_ready_o;
wire busy_o;
assign {rst_ni,operands_i,is_boxed_i,rnd_mode_i,op_i,op_mod_i,tag_i,mask_i,aux_i,in_valid_i,flush_i,out_ready_i,reg_ena_i}=drive_inputs;
`ifdef MODEL
dvbench_model #(.FpFormat(0),.NumPipeRegs(0),.PipeConfig(0),.TagType(logic[3:0]),.AuxType(logic[1:0])) dut(.rst_ni(rst_ni),.operands_i(operands_i),.is_boxed_i(is_boxed_i),.rnd_mode_i(rnd_mode_i),.op_i(op_i),.op_mod_i(op_mod_i),.tag_i(tag_i),.mask_i(mask_i),.aux_i(aux_i),.in_valid_i(in_valid_i),.flush_i(flush_i),.out_ready_i(out_ready_i),.reg_ena_i(reg_ena_i),.result_o(result_o),.status_o(status_o),.extension_bit_o(extension_bit_o),.tag_o(tag_o),.mask_o(mask_o),.aux_o(aux_o),.out_valid_o(out_valid_o),.in_ready_o(in_ready_o),.busy_o(busy_o),.clk_i(clk_i));
`else
fpnew_fma #(.FpFormat(fpnew_pkg::FP32),.NumPipeRegs(0),.PipeConfig(fpnew_pkg::BEFORE),.TagType(logic[3:0]),.AuxType(logic[1:0])) dut(.rst_ni(rst_ni),.operands_i(operands_i),.is_boxed_i(is_boxed_i),.rnd_mode_i(fpnew_pkg::roundmode_e'(rnd_mode_i)),.op_i(fpnew_pkg::operation_e'(op_i)),.op_mod_i(op_mod_i),.tag_i(tag_i),.mask_i(mask_i),.aux_i(aux_i),.in_valid_i(in_valid_i),.flush_i(flush_i),.out_ready_i(out_ready_i),.reg_ena_i(reg_ena_i),.result_o(result_o),.status_o(status_o),.extension_bit_o(extension_bit_o),.tag_o(tag_o),.mask_o(mask_o),.aux_o(aux_o),.out_valid_o(out_valid_o),.in_ready_o(in_ready_o),.busy_o(busy_o),.clk_i(clk_i));
`endif
assign observed={result_o,status_o,extension_bit_o,tag_o,mask_o,aux_o,out_valid_o,in_ready_o,busy_o};
always_comb mask={ {37{observed[2]===1'b1}},1'b1,{7{observed[2]===1'b1}},3'b111};
int fd,inp,point=0;task sample;point++;$fdisplay(fd,"%0d %h %h",point,observed,mask);endtask
task drive(input logic[118:0]d);@(negedge clk_i);drive_inputs=d;#1;$fdisplay(inp,"%h",d);sample();@(posedge clk_i);#1;sample();#1;endtask
`include "stimulus.svh"
initial begin fd=$fopen("trace.txt","w");inp=$fopen("inputs.txt","w");history();$fclose(fd);$fclose(inp);$finish;end
endmodule
