// dpc_if.sv — DPC 5x5 interface: integer half-period clock + self-maintained reset (negedge alignment to prevent sampling races)
`timescale 1ns/1ps

interface dpc_if ();

  // Reset (maintained by the interface itself; pulse_reset is for reset-related feature injection)
  logic rst_n = 1'b0;

  // Stimulus side
  logic       bayer_format;
  logic [7:0] i_dpc_threshold;
  logic [2:0] i_video_syn;          // {V, D, H}
  logic [7:0] i_data_r0, i_data_r1, i_data_r2, i_data_r3, i_data_r4;
  // Observation side
  logic [2:0] o_video_sync;
  logic [7:0] o_data;
  logic [7:0] expected_data;
  logic [2:0] expected_sync;

  // Integer half-period clock (real delays trigger analog-style scheduling, ~300× slower)
  initial begin
    bayer_format=0;i_dpc_threshold=0;i_video_syn=0;
    i_data_r0=0;i_data_r1=0;i_data_r2=0;i_data_r3=0;i_data_r4=0;
  end
  int unsigned half = 2;            // Period 4ns
  logic clk = 0;
  initial forever #(half) clk = ~clk;

  initial begin
    repeat (6) @(negedge clk);
    rst_n = 1'b1;
  end

  // Runtime reset: aligned to the negedge (posedge sampling will not see a mid-cycle level)
  task pulse_reset();
    @(negedge clk);
    rst_n = 1'b0;
    repeat (5) @(negedge clk);
    rst_n = 1'b1;
  endtask

  // Driving-side output / sampling-side input (rst_n is for monitor sampling every cycle)
  clocking cb @(posedge clk);
    default input #1step output #1;
    output bayer_format, i_dpc_threshold, i_video_syn;
    output i_data_r0, i_data_r1, i_data_r2, i_data_r3, i_data_r4;
    input rst_n, o_video_sync, o_data;
  endclocking

endinterface
