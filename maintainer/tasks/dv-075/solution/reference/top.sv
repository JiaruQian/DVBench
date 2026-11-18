// tb_top.sv — axi_rdma UVM top level (dual DUT instances: F08 parameter dimension)
// dut0: Default big-endian + MAX_BURST=16 (burst boundary 16/tail segment)
// dut1: Little-endian (stream/memory) + MAX_BURST=256 (LE tkeep patterns + large arlen single burst)
`timescale 1ns/1ps
module dvbench_top;
  import uvm_pkg::*;
  import rdma_pkg::*;
  `include "uvm_macros.svh"

  rdma_if if0();
  rdma_if if1();

  axi_rdma #(
    .ADDRESS_BITS(32), .LENGTH_BITS(32), .MAX_BURST(16),
    .STREAM_BIG_ENDIAN("TRUE"), .MEM_BIG_ENDIAN("TRUE")
  ) dut0 (
    .aclk(if0.aclk), .aresetn(if0.aresetn),
    .cmd_address(if0.cmd_address), .cmd_bytes(if0.cmd_bytes),
    .cmd_valid(if0.cmd_valid), .cmd_ready(if0.cmd_ready),
    .axi_m_arid(if0.axi_m_arid), .axi_m_araddr(if0.axi_m_araddr),
    .axi_m_arlen(if0.axi_m_arlen), .axi_m_arsize(if0.axi_m_arsize),
    .axi_m_arburst(if0.axi_m_arburst), .axi_m_arvalid(if0.axi_m_arvalid),
    .axi_m_arready(if0.axi_m_arready),
    .axi_m_rid(if0.axi_m_rid), .axi_m_rdata(if0.axi_m_rdata),
    .axi_m_rresp(if0.axi_m_rresp), .axi_m_rlast(if0.axi_m_rlast),
    .axi_m_rvalid(if0.axi_m_rvalid), .axi_m_rready(if0.axi_m_rready),
    .dout_tdata(if0.dout_tdata), .dout_tkeep(if0.dout_tkeep),
    .dout_tlast(if0.dout_tlast), .dout_tvalid(if0.dout_tvalid),
    .dout_tready(if0.dout_tready)
  );

  // dut1: Little-endian (stream/memory) + MAX_BURST=256 (large arlen / full-width stimulus for the low bits of fetch)
  axi_rdma #(
    .ADDRESS_BITS(32), .LENGTH_BITS(32), .MAX_BURST(256),
    .STREAM_BIG_ENDIAN("FALSE"), .MEM_BIG_ENDIAN("FALSE")
  ) dut1 (
    .aclk(if1.aclk), .aresetn(if1.aresetn),
    .cmd_address(if1.cmd_address), .cmd_bytes(if1.cmd_bytes),
    .cmd_valid(if1.cmd_valid), .cmd_ready(if1.cmd_ready),
    .axi_m_arid(if1.axi_m_arid), .axi_m_araddr(if1.axi_m_araddr),
    .axi_m_arlen(if1.axi_m_arlen), .axi_m_arsize(if1.axi_m_arsize),
    .axi_m_arburst(if1.axi_m_arburst), .axi_m_arvalid(if1.axi_m_arvalid),
    .axi_m_arready(if1.axi_m_arready),
    .axi_m_rid(if1.axi_m_rid), .axi_m_rdata(if1.axi_m_rdata),
    .axi_m_rresp(if1.axi_m_rresp), .axi_m_rlast(if1.axi_m_rlast),
    .axi_m_rvalid(if1.axi_m_rvalid), .axi_m_rready(if1.axi_m_rready),
    .dout_tdata(if1.dout_tdata), .dout_tkeep(if1.dout_tkeep),
    .dout_tlast(if1.dout_tlast), .dout_tvalid(if1.dout_tvalid),
    .dout_tready(if1.dout_tready)
  );

  rdma_model_check #(.MB(16),.BE("TRUE")) check0(if0);
  rdma_model_check #(.MB(256),.BE("FALSE")) check1(if1);

  initial begin
    uvm_config_db#(virtual rdma_if)::set(null, "uvm_test_top", "vif0", if0);
    uvm_config_db#(virtual rdma_if)::set(null, "uvm_test_top", "vif1", if1);
    uvm_config_db#(int)::set(null, "uvm_test_top.env0*", "mem_be",    1);
    uvm_config_db#(int)::set(null, "uvm_test_top.env0*", "stream_be", 1);
    uvm_config_db#(int)::set(null, "uvm_test_top.env0*", "max_burst", 16);
    uvm_config_db#(int)::set(null, "uvm_test_top.env1*", "mem_be",    0);
    uvm_config_db#(int)::set(null, "uvm_test_top.env1*", "stream_be", 0);
    uvm_config_db#(int)::set(null, "uvm_test_top.env1*", "max_burst", 256);
    run_test("dvbench_test");   // Default comprehensive test (overridable with +UVM_TESTNAME)
  end

endmodule
