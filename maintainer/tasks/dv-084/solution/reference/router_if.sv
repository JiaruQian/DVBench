// router_if.sv — yapp_router UVM interface set (yapp input / 3×channel outputs / hbus registers)
// Integer clock half-period variable; reset is maintained by the interface itself. All RTL samples on negedge → drive using posedge clocking.
`timescale 1ns/1ps

// ---------- YAPP input channel ----------
interface yapp_if ();

  // Clock (int half-period variable, avoiding analog-style scheduling with real delays)
  int unsigned half = 5;          // Period 10ns
  logic        clk = 0;
  initial forever #(half) clk = ~clk;

  // Reset (maintained by the interface itself)
  logic reset = 1'b1;
  initial begin
    repeat (5) @(posedge clk);
    reset = 1'b0;
  end

  task pulse_reset();             // F06: Reset during transfer (data discard is expected; sb flushes synchronously)
    reset = 1'b1;
    repeat (5) @(posedge clk);
    reset = 1'b0;
  endtask

  task set_half(int unsigned h);  // F05: Runtime frequency change (called during inter-packet idle)
    half = h;
  endtask

  // YAPP signals
  logic [7:0] in_data;
  logic       in_data_vld;
  logic       in_suspend;
  logic       error;

  clocking cb @(posedge clk);
    default input #1step output #1;
    output in_data, in_data_vld;
    input  in_suspend, error;
  endclocking

endinterface


// ---------- Output channels 0/1/2 ----------
interface channel_if (input logic clk, input logic rst);

  logic [7:0] data;
  logic       data_vld;
  logic       suspend = 1'b0;     // Test-injected backpressure (F04)

  clocking cb @(posedge clk);
    default input #1step output #1;
    input  data, data_vld;
    output suspend;
  endclocking

endinterface


// ---------- HBUS register bus (inout data) ----------
interface hbus_if (input logic clk);

  logic [15:0] haddr;
  logic        hen;
  logic        hwr_rd;
  tri  [7:0]   hdata;
  logic [7:0]  hdata_w;
  logic        hdrive;
  assign hdata = hdrive ? hdata_w : 8'bz;

  clocking cb @(posedge clk);
    default input #1step output #1;
    output haddr, hen, hwr_rd, hdrive, hdata_w;
    input  hdata;
  endclocking

endinterface
