`timescale 1ns/1ps
module dvbench_top;
import uvm_pkg::*;import ss_pkg::*;
logic clk=0;always #5 clk=~clk;
ss_if vif(clk);
simt_stack dut(
.branch_ctl_mask_init_i(vif.branch_ctl_mask_init_i),
.branch_ctl_opcode_i(vif.branch_ctl_opcode_i),
.branch_ctl_pc_branch_i(vif.branch_ctl_pc_branch_i),
.branch_ctl_pc_execute_i(vif.branch_ctl_pc_execute_i),
.branch_ctl_ready_o(vif.branch_ctl_ready_o),
.branch_ctl_valid_i(vif.branch_ctl_valid_i),
.branch_ctl_wid_i(vif.branch_ctl_wid_i),
.clk(vif.clk),
.complete_valid_o(vif.complete_valid_o),
.complete_wid_o(vif.complete_wid_o),
.fetch_ctl_jump_o(vif.fetch_ctl_jump_o),
.fetch_ctl_new_pc_o(vif.fetch_ctl_new_pc_o),
.fetch_ctl_ready_i(vif.fetch_ctl_ready_i),
.fetch_ctl_valid_o(vif.fetch_ctl_valid_o),
.fetch_ctl_wid_o(vif.fetch_ctl_wid_o),
.if_mask_mask_i(vif.if_mask_mask_i),
.if_mask_ready_o(vif.if_mask_ready_o),
.if_mask_valid_i(vif.if_mask_valid_i),
.if_mask_wid_i(vif.if_mask_wid_i),
.input_wid_i(vif.input_wid_i),
.out_mask_o(vif.out_mask_o),
.pc_reconv_i(vif.pc_reconv_i),
.pc_reconv_valid_i(vif.pc_reconv_valid_i),
.rst_n(vif.rst_n)
);
dvbench_model model(
.branch_ctl_mask_init_i(vif.branch_ctl_mask_init_i),
.branch_ctl_opcode_i(vif.branch_ctl_opcode_i),
.branch_ctl_pc_branch_i(vif.branch_ctl_pc_branch_i),
.branch_ctl_pc_execute_i(vif.branch_ctl_pc_execute_i),
.branch_ctl_ready_o(vif.expected_branch_ctl_ready_o),
.branch_ctl_valid_i(vif.branch_ctl_valid_i),
.branch_ctl_wid_i(vif.branch_ctl_wid_i),
.clk(vif.clk),
.complete_valid_o(vif.expected_complete_valid_o),
.complete_wid_o(vif.expected_complete_wid_o),
.fetch_ctl_jump_o(vif.expected_fetch_ctl_jump_o),
.fetch_ctl_new_pc_o(vif.expected_fetch_ctl_new_pc_o),
.fetch_ctl_ready_i(vif.fetch_ctl_ready_i),
.fetch_ctl_valid_o(vif.expected_fetch_ctl_valid_o),
.fetch_ctl_wid_o(vif.expected_fetch_ctl_wid_o),
.if_mask_mask_i(vif.if_mask_mask_i),
.if_mask_ready_o(vif.expected_if_mask_ready_o),
.if_mask_valid_i(vif.if_mask_valid_i),
.if_mask_wid_i(vif.if_mask_wid_i),
.input_wid_i(vif.input_wid_i),
.out_mask_o(vif.expected_out_mask_o),
.pc_reconv_i(vif.pc_reconv_i),
.pc_reconv_valid_i(vif.pc_reconv_valid_i),
.rst_n(vif.rst_n)
);
initial begin
vif.branch_ctl_mask_init_i=0;
vif.branch_ctl_opcode_i=0;
vif.branch_ctl_pc_branch_i=0;
vif.branch_ctl_pc_execute_i=0;
vif.branch_ctl_valid_i=0;
vif.branch_ctl_wid_i=0;
vif.fetch_ctl_ready_i=0;
vif.if_mask_mask_i=0;
vif.if_mask_valid_i=0;
vif.if_mask_wid_i=0;
vif.input_wid_i=0;
vif.pc_reconv_i=0;
vif.pc_reconv_valid_i=0;
vif.rst_n=0;
vif.rst_n=0;uvm_config_db#(virtual ss_if)::set(null,"*","vif",vif);run_test("dvbench_test");
end
endmodule
