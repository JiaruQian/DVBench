// tb_top.sv — dpc_5x5 UVM top level: interface + DUT + default comprehensive test t_main
`timescale 1ns/1ps
module dvbench_top;
  import uvm_pkg::*;
  import dpc_pkg::*;

  dpc_if uif ();

  dpc_5x5 dut (
    .clk             (uif.clk),
    .reset_n         (uif.rst_n),
    .bayer_format    (uif.bayer_format),
    .i_dpc_threshold (uif.i_dpc_threshold),
    .i_video_syn     (uif.i_video_syn),
    .i_data_r0       (uif.i_data_r0),
    .i_data_r1       (uif.i_data_r1),
    .i_data_r2       (uif.i_data_r2),
    .i_data_r3       (uif.i_data_r3),
    .i_data_r4       (uif.i_data_r4),
    .o_video_sync    (uif.o_video_sync),
    .o_data          (uif.o_data)
  );

  dvbench_model prediction(
    .clk(uif.clk),.reset_n(uif.rst_n),.bayer_format(uif.bayer_format),
    .i_dpc_threshold(uif.i_dpc_threshold),.i_video_syn(uif.i_video_syn),
    .i_data_r0(uif.i_data_r0),.i_data_r1(uif.i_data_r1),.i_data_r2(uif.i_data_r2),.i_data_r3(uif.i_data_r3),.i_data_r4(uif.i_data_r4),
    .o_data(uif.expected_data),.o_video_sync(uif.expected_sync));
  initial begin
    uvm_config_db#(virtual dpc_if)::set(null, "*", "vif", uif);
    run_test("dvbench_test");
  end

  // Watchdog: total sequence length ~2100 cycles × 4ns ≈ 8.5us, 3-fold margin
  initial begin
    #1000000;
    $fatal(1,"WATCHDOG: timeout");
    $finish;
  end
endmodule
