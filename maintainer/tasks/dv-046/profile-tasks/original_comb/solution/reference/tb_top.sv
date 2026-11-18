`timescale 1ns/1ps
module dvbench_top;import uvm_pkg::*;import pins_pkg::*;logic clk_i=0;always #5 clk_i=~clk_i;pins_if v(clk_i);
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
assign {rst_ni,operands_i,is_boxed_i,rnd_mode_i,op_i,op_mod_i,tag_i,mask_i,aux_i,in_valid_i,flush_i,out_ready_i,reg_ena_i}=v.drive_inputs;
fpnew_fma #(.FpFormat(fpnew_pkg::FP32),.NumPipeRegs(0),.PipeConfig(fpnew_pkg::BEFORE),.TagType(logic[3:0]),.AuxType(logic[1:0])) dut(.rst_ni(rst_ni),.operands_i(operands_i),.is_boxed_i(is_boxed_i),.rnd_mode_i(fpnew_pkg::roundmode_e'(rnd_mode_i)),.op_i(fpnew_pkg::operation_e'(op_i)),.op_mod_i(op_mod_i),.tag_i(tag_i),.mask_i(mask_i),.aux_i(aux_i),.in_valid_i(in_valid_i),.flush_i(flush_i),.out_ready_i(out_ready_i),.reg_ena_i(reg_ena_i),.result_o(result_o),.status_o(status_o),.extension_bit_o(extension_bit_o),.tag_o(tag_o),.mask_o(mask_o),.aux_o(aux_o),.out_valid_o(out_valid_o),.in_ready_o(in_ready_o),.busy_o(busy_o),.clk_i(clk_i));
assign v.actual={result_o,status_o,extension_bit_o,tag_o,mask_o,aux_o,out_valid_o,in_ready_o,busy_o};
logic m_rst_ni;
logic[2:0][31:0] m_operands_i;
logic[2:0] m_is_boxed_i;
logic[2:0] m_rnd_mode_i;
logic[3:0] m_op_i;
logic m_op_mod_i;
logic[3:0] m_tag_i;
logic m_mask_i;
logic[1:0] m_aux_i;
logic m_in_valid_i;
logic m_flush_i;
logic m_out_ready_i;
logic[0:0] m_reg_ena_i;
wire[31:0] m_result_o;
wire[4:0] m_status_o;
wire m_extension_bit_o;
wire[3:0] m_tag_o;
wire m_mask_o;
wire[1:0] m_aux_o;
wire m_out_valid_o;
wire m_in_ready_o;
wire m_busy_o;
assign {m_rst_ni,m_operands_i,m_is_boxed_i,m_rnd_mode_i,m_op_i,m_op_mod_i,m_tag_i,m_mask_i,m_aux_i,m_in_valid_i,m_flush_i,m_out_ready_i,m_reg_ena_i}=v.drive_inputs;
dvbench_model #(.FpFormat(0),.NumPipeRegs(0),.PipeConfig(0),.TagType(logic[3:0]),.AuxType(logic[1:0])) model(.rst_ni(m_rst_ni),.operands_i(m_operands_i),.is_boxed_i(m_is_boxed_i),.rnd_mode_i(m_rnd_mode_i),.op_i(m_op_i),.op_mod_i(m_op_mod_i),.tag_i(m_tag_i),.mask_i(m_mask_i),.aux_i(m_aux_i),.in_valid_i(m_in_valid_i),.flush_i(m_flush_i),.out_ready_i(m_out_ready_i),.reg_ena_i(m_reg_ena_i),.result_o(m_result_o),.status_o(m_status_o),.extension_bit_o(m_extension_bit_o),.tag_o(m_tag_o),.mask_o(m_mask_o),.aux_o(m_aux_o),.out_valid_o(m_out_valid_o),.in_ready_o(m_in_ready_o),.busy_o(m_busy_o),.clk_i(clk_i));
assign v.expected={m_result_o,m_status_o,m_extension_bit_o,m_tag_o,m_mask_o,m_aux_o,m_out_valid_o,m_in_ready_o,m_busy_o};

always_comb begin v.mask={ {37{v.expected[2]===1'b1}},1'b1,{7{v.expected[2]===1'b1}},3'b111};end
initial begin uvm_config_db#(virtual pins_if)::set(null,"*","vif",v);run_test("dvbench_test");end
endmodule
