`timescale 1ns/1ps
module dvbench_top;
  import uvm_pkg::*;import vmult_pkg::*;
  logic clk=0;always #5 clk=~clk;
  vmult_if vif(clk);
  vmul_top #(.SOFT_THREAD(4),.HARD_THREAD(4),.MAX_ITER(1)) dut(
    .clk(vif.clk),
    .ctrl_alu_fn_i(vif.ctrl_alu_fn_i),
    .ctrl_reg_idxw_i(vif.ctrl_reg_idxw_i),
    .ctrl_reverse_i(vif.ctrl_reverse_i),
    .ctrl_wid_i(vif.ctrl_wid_i),
    .ctrl_wvd_i(vif.ctrl_wvd_i),
    .ctrl_wxd_i(vif.ctrl_wxd_i),
    .in1_i(vif.in1_i),
    .in2_i(vif.in2_i),
    .in3_i(vif.in3_i),
    .in_ready_o(vif.in_ready_o),
    .in_valid_i(vif.in_valid_i),
    .mask_i(vif.mask_i),
    .outv_ready_i(vif.outv_ready_i),
    .outv_reg_idxw_o(vif.outv_reg_idxw_o),
    .outv_valid_o(vif.outv_valid_o),
    .outv_warp_id_o(vif.outv_warp_id_o),
    .outv_wb_wxd_rd_o(vif.outv_wb_wxd_rd_o),
    .outv_wvd_mask_o(vif.outv_wvd_mask_o),
    .outv_wvd_o(vif.outv_wvd_o),
    .outx_ready_i(vif.outx_ready_i),
    .outx_reg_idwx_o(vif.outx_reg_idwx_o),
    .outx_valid_o(vif.outx_valid_o),
    .outx_warp_id_o(vif.outx_warp_id_o),
    .outx_wb_wxd_rd_o(vif.outx_wb_wxd_rd_o),
    .outx_wxd_o(vif.outx_wxd_o),
    .rst_n(vif.rst_n)
  );
  dvbench_model model(
    .clk(vif.clk),
    .ctrl_alu_fn_i(vif.ctrl_alu_fn_i),
    .ctrl_reg_idxw_i(vif.ctrl_reg_idxw_i),
    .ctrl_reverse_i(vif.ctrl_reverse_i),
    .ctrl_wid_i(vif.ctrl_wid_i),
    .ctrl_wvd_i(vif.ctrl_wvd_i),
    .ctrl_wxd_i(vif.ctrl_wxd_i),
    .in1_i(vif.in1_i),
    .in2_i(vif.in2_i),
    .in3_i(vif.in3_i),
    .in_ready_o(vif.expected_in_ready_o),
    .in_valid_i(vif.in_valid_i),
    .mask_i(vif.mask_i),
    .outv_ready_i(vif.outv_ready_i),
    .outv_reg_idxw_o(vif.expected_outv_reg_idxw_o),
    .outv_valid_o(vif.expected_outv_valid_o),
    .outv_warp_id_o(vif.expected_outv_warp_id_o),
    .outv_wb_wxd_rd_o(vif.expected_outv_wb_wxd_rd_o),
    .outv_wvd_mask_o(vif.expected_outv_wvd_mask_o),
    .outv_wvd_o(vif.expected_outv_wvd_o),
    .outx_ready_i(vif.outx_ready_i),
    .outx_reg_idwx_o(vif.expected_outx_reg_idwx_o),
    .outx_valid_o(vif.expected_outx_valid_o),
    .outx_warp_id_o(vif.expected_outx_warp_id_o),
    .outx_wb_wxd_rd_o(vif.expected_outx_wb_wxd_rd_o),
    .outx_wxd_o(vif.expected_outx_wxd_o),
    .rst_n(vif.rst_n)
  );
  initial begin
    vif.ctrl_alu_fn_i=0;
    vif.ctrl_reg_idxw_i=0;
    vif.ctrl_reverse_i=0;
    vif.ctrl_wid_i=0;
    vif.ctrl_wvd_i=0;
    vif.ctrl_wxd_i=0;
    vif.in1_i=0;
    vif.in2_i=0;
    vif.in3_i=0;
    vif.in_valid_i=0;
    vif.mask_i=0;
    vif.outv_ready_i=0;
    vif.outx_ready_i=0;
    vif.rst_n=0;
    vif.rst_n=0;uvm_config_db#(virtual vmult_if)::set(null,"*","vif",vif);run_test("dvbench_test");
  end
endmodule
