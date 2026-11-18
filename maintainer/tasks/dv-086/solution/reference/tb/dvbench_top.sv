`timescale 1ns/1ps
module dvbench_top;
import uvm_pkg::*;import aluexe_pkg::*;
aluexe_if vif();
instruction_cache dut(
.clk(vif.clk),
.rst_n(vif.rst_n),
.invalid_i(vif.invalid_i),
.core_req_valid_i(vif.core_req_valid_i),
.core_req_addr_i(vif.core_req_addr_i),
.core_req_mask_i(vif.core_req_mask_i),
.core_req_wid_i(vif.core_req_wid_i),
.flush_pipe_valid_i(vif.flush_pipe_valid_i),
.flush_pipe_wid_i(vif.flush_pipe_wid_i),
.core_rsp_valid_o(vif.core_rsp_valid_o),
.core_rsp_addr_o(vif.core_rsp_addr_o),
.core_rsp_data_o(vif.core_rsp_data_o),
.core_rsp_mask_o(vif.core_rsp_mask_o),
.core_rsp_wid_o(vif.core_rsp_wid_o),
.core_rsp_status_o(vif.core_rsp_status_o),
.mem_rsp_ready_o(vif.mem_rsp_ready_o),
.mem_rsp_valid_i(vif.mem_rsp_valid_i),
.mem_rsp_d_source_i(vif.mem_rsp_d_source_i),
.mem_rsp_d_addr_i(vif.mem_rsp_d_addr_i),
.mem_rsp_d_data_i(vif.mem_rsp_d_data_i),
.mem_req_ready_i(vif.mem_req_ready_i),
.mem_req_valid_o(vif.mem_req_valid_o),
.mem_req_a_source_o(vif.mem_req_a_source_o),
.mem_req_a_addr_o(vif.mem_req_a_addr_o)
);
dvbench_model predictor(
.clk(vif.clk),
.rst_n(vif.rst_n),
.invalid_i(vif.invalid_i),
.core_req_valid_i(vif.core_req_valid_i),
.core_req_addr_i(vif.core_req_addr_i),
.core_req_mask_i(vif.core_req_mask_i),
.core_req_wid_i(vif.core_req_wid_i),
.flush_pipe_valid_i(vif.flush_pipe_valid_i),
.flush_pipe_wid_i(vif.flush_pipe_wid_i),
.core_rsp_valid_o(vif.expected_core_rsp_valid_o),
.core_rsp_addr_o(vif.expected_core_rsp_addr_o),
.core_rsp_data_o(vif.expected_core_rsp_data_o),
.core_rsp_mask_o(vif.expected_core_rsp_mask_o),
.core_rsp_wid_o(vif.expected_core_rsp_wid_o),
.core_rsp_status_o(vif.expected_core_rsp_status_o),
.mem_rsp_ready_o(vif.expected_mem_rsp_ready_o),
.mem_rsp_valid_i(vif.mem_rsp_valid_i),
.mem_rsp_d_source_i(vif.mem_rsp_d_source_i),
.mem_rsp_d_addr_i(vif.mem_rsp_d_addr_i),
.mem_rsp_d_data_i(vif.mem_rsp_d_data_i),
.mem_req_ready_i(vif.mem_req_ready_i),
.mem_req_valid_o(vif.expected_mem_req_valid_o),
.mem_req_a_source_o(vif.expected_mem_req_a_source_o),
.mem_req_a_addr_o(vif.expected_mem_req_a_addr_o)
);
initial begin vif.clk=0;forever #5 vif.clk=~vif.clk;end
initial begin uvm_config_db#(virtual aluexe_if)::set(null,"*","vif",vif);run_test("dvbench_test");end
endmodule
