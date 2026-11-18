`timescale 1ns/1ps
module dvbench_top;
import uvm_pkg::*;
import smem_pkg::*;
smem_if vif();
always #5 vif.clk=~vif.clk;
shared_mem dut(.clk(vif.clk),.rst_n(vif.rst_n),.core_req_valid_i(vif.core_req_valid_i),.core_req_instrid_i(vif.core_req_instrid_i),.core_req_iswrite_i(vif.core_req_iswrite_i),.core_req_tag_i(vif.core_req_tag_i),.core_req_setidx_i(vif.core_req_setidx_i),.core_req_activemask_i(vif.core_req_activemask_i),.core_req_blockoffset_i(vif.core_req_blockoffset_i),.core_req_wordoffset1h_i(vif.core_req_wordoffset1h_i),.core_req_data_i(vif.core_req_data_i),.core_rsp_ready_i(vif.core_rsp_ready_i),.core_req_ready_o(vif.core_req_ready_o),.core_rsp_valid_o(vif.core_rsp_valid_o),.core_rsp_iswrite_o(vif.core_rsp_iswrite_o),.core_rsp_instrid_o(vif.core_rsp_instrid_o),.core_rsp_data_o(vif.core_rsp_data_o),.core_rsp_activemask_o(vif.core_rsp_activemask_o));
dvbench_model predictor(.clk(vif.clk),.rst_n(vif.rst_n),.core_req_valid_i(vif.core_req_valid_i),.core_req_instrid_i(vif.core_req_instrid_i),.core_req_iswrite_i(vif.core_req_iswrite_i),.core_req_tag_i(vif.core_req_tag_i),.core_req_setidx_i(vif.core_req_setidx_i),.core_req_activemask_i(vif.core_req_activemask_i),.core_req_blockoffset_i(vif.core_req_blockoffset_i),.core_req_wordoffset1h_i(vif.core_req_wordoffset1h_i),.core_req_data_i(vif.core_req_data_i),.core_rsp_ready_i(vif.core_rsp_ready_i),.core_req_ready_o(vif.expected_core_req_ready_o),.core_rsp_valid_o(vif.expected_core_rsp_valid_o),.core_rsp_iswrite_o(vif.expected_core_rsp_iswrite_o),.core_rsp_instrid_o(vif.expected_core_rsp_instrid_o),.core_rsp_data_o(vif.expected_core_rsp_data_o),.core_rsp_activemask_o(vif.expected_core_rsp_activemask_o));
initial begin uvm_config_db#(virtual smem_if)::set(null,"*","vif",vif);run_test("dvbench_test");end
endmodule
