// tb_top.sv — yapp_router UVM top level (single DUT: no parameters, F08 uses the max_pkt_len register variant)
// Note: acceptance compilation does not define INT_SUPPORT → DUT has no output ports such as parity_intr; do not connect them
`timescale 1ns/1ps
module dvbench_top;
  initial begin #200000; $fatal(1,"REFERENCE_WATCHDOG_TIMEOUT"); end
  import uvm_pkg::*;
  import router_pkg::*;
  `include "uvm_macros.svh"

  yapp_if    in0();
  channel_if ch0(in0.clk, in0.reset);
  channel_if ch1(in0.clk, in0.reset);
  channel_if ch2(in0.clk, in0.reset);
  hbus_if    hb(in0.clk);

  yapp_router dut (
    .clock      (in0.clk),
    .reset      (in0.reset),
    .error      (in0.error),
    .in_data    (in0.in_data),
    .in_data_vld(in0.in_data_vld),
    .in_suspend (in0.in_suspend),
    .data_0     (ch0.data),  .data_vld_0(ch0.data_vld),  .suspend_0(ch0.suspend),
    .data_1     (ch1.data),  .data_vld_1(ch1.data_vld),  .suspend_1(ch1.suspend),
    .data_2     (ch2.data),  .data_vld_2(ch2.data_vld),  .suspend_2(ch2.suspend),
    .haddr      (hb.haddr),  .hdata(hb.hdata),
    .hen        (hb.hen),    .hwr_rd(hb.hwr_rd)
  );

  tri [7:0] expected_hdata;
  wire expected_error, expected_suspend;
  wire [7:0] expected_d0, expected_d1, expected_d2;
  wire expected_v0, expected_v1, expected_v2;
  assign expected_hdata = hb.hdrive ? hb.hdata_w : 8'bz;
  dvbench_model predictor(
    .clock(in0.clk),.reset(in0.reset),.in_data(in0.in_data),.in_data_vld(in0.in_data_vld),
    .error(expected_error),.in_suspend(expected_suspend),
    .data_0(expected_d0),.data_1(expected_d1),.data_2(expected_d2),
    .data_vld_0(expected_v0),.data_vld_1(expected_v1),.data_vld_2(expected_v2),
    .suspend_0(ch0.suspend),.suspend_1(ch1.suspend),.suspend_2(ch2.suspend),
    .haddr(hb.haddr),.hen(hb.hen),.hwr_rd(hb.hwr_rd),.hdata(expected_hdata));
  model_check independent_check(in0,ch0,ch1,ch2,hb,
      expected_error,expected_suspend,expected_d0,expected_d1,expected_d2,
      expected_v0,expected_v1,expected_v2,expected_hdata);
  initial begin
    uvm_config_db#(virtual yapp_if)::set(null, "uvm_test_top", "in_vif", in0);
    uvm_config_db#(virtual channel_if)::set(null, "uvm_test_top", "ch_vif_0", ch0);
    uvm_config_db#(virtual channel_if)::set(null, "uvm_test_top", "ch_vif_1", ch1);
    uvm_config_db#(virtual channel_if)::set(null, "uvm_test_top", "ch_vif_2", ch2);
    uvm_config_db#(virtual hbus_if)::set(null, "uvm_test_top", "hb_vif", hb);
    run_test("dvbench_test");   // Default comprehensive test (overridable with +UVM_TESTNAME)
  end

endmodule
