// tb_top.sv — yapp_router UVM top level (single DUT: no parameters, F08 uses the max_pkt_len register variant)
// Note: acceptance compilation does not define INT_SUPPORT → DUT has no output ports such as parity_intr; do not connect them
`timescale 1ns/1ps
module isolated_d;
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

  int history_fd,trace_fd;
  initial begin history_fd=$fopen("replay.history","w");trace_fd=$fopen("replay.trace","w");end
  always @(in0.clk or in0.reset or in0.in_data or in0.in_data_vld or ch0.suspend or ch1.suspend or ch2.suspend or hb.haddr or hb.hen or hb.hwr_rd or hb.hdrive or hb.hdata_w)
    if(history_fd) $fdisplay(history_fd,"%0.3f %b %b %h %b %b %b %b %h %b %b %b %h",$realtime,in0.clk,in0.reset,in0.in_data,in0.in_data_vld,ch0.suspend,ch1.suspend,ch2.suspend,hb.haddr,hb.hen,hb.hwr_rd,hb.hdrive,hb.hdata_w);
  always @(in0.clk) begin
    #2;
    if(trace_fd) $fdisplay(trace_fd,"%0.3f %b %b %b %b %b %h %b %h %b %h %b %b %h",$realtime,in0.clk,in0.reset,in0.error,in0.in_suspend,ch0.data_vld,ch0.data,ch1.data_vld,ch1.data,ch2.data_vld,ch2.data,hb.hen,hb.hwr_rd,hb.hdata);
  end
  initial begin
    uvm_config_db#(virtual yapp_if)::set(null, "uvm_test_top", "in_vif", in0);
    uvm_config_db#(virtual channel_if)::set(null, "uvm_test_top", "ch_vif_0", ch0);
    uvm_config_db#(virtual channel_if)::set(null, "uvm_test_top", "ch_vif_1", ch1);
    uvm_config_db#(virtual channel_if)::set(null, "uvm_test_top", "ch_vif_2", ch2);
    uvm_config_db#(virtual hbus_if)::set(null, "uvm_test_top", "hb_vif", hb);
    run_test("dvbench_test");   // Default comprehensive test (overridable with +UVM_TESTNAME)
  end

endmodule
