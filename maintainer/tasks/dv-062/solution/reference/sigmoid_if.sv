`timescale 1ns/1ps
// sigmoid_if.sv — fp32_sigmoid_pipeline interface: integer half-period clock + self-held reset + driving/observation
interface sigmoid_if ();

  int unsigned half = 1;              // Integer half-period (real delays are ~300x slower)
  logic clk = 1'b0;
  initial forever #(half) clk = ~clk;

  logic rst = 1'b1;                   // Active high, in reset at power-up; driver is responsible for release
  logic clear = 1'b0;
  logic valid = 1'b0;
  logic [31:0] data = 32'h0;
  logic invalid = 1'b0;
  logic [2:0] scn = 3'd0;            // Scenario tag (coverage context, driver->monitor)

  logic valid_o;
  logic [31:0] result_o;
  logic invalid_o;
  logic expected_valid;
  logic [31:0] expected_result;
  logic expected_invalid;

  // Driver-side clocking block (reading back output ports is prohibited; monitor reads raw signals)
  clocking cb @(posedge clk);
    default input #1step output #1;
    output clear, valid, data, invalid, scn;
    input rst, valid_o, result_o, invalid_o;
  endclocking

  task automatic release_reset();
    repeat (2) @(negedge clk);
    rst = 1'b0;
  endtask

  // Runtime reset: drive stimulus low, then pulse rst to drain the pipeline (clear the top-level valid pipeline)
  task automatic pulse_reset();
    rst = 1'b1;
    valid = 1'b0;
    clear = 1'b0;
    repeat (3) @(negedge clk);
    rst = 1'b0;
  endtask

endinterface
