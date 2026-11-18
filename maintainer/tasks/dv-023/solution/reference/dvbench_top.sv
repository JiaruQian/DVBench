`timescale 1ns/1ps
module dvbench_top;
 import uvm_pkg::*;import fifo_pkg::*;
 logic w_clk=0,r_clk=0;
 always #5 w_clk=~w_clk;
 always #7 r_clk=~r_clk;
 fifo_if vif(w_clk,r_clk);
 fifo #(.ADDR(16),.BIT_WIDTH(8)) dut(.w_clk(w_clk),.r_clk(r_clk),.rst(vif.rst),.we(vif.we),.re(vif.re),.wdata(vif.wdata),.rdata(vif.rdata),.full(vif.full),.empty(vif.empty));
 dvbench_model #(.ADDR(16),.BIT_WIDTH(8)) predictor(.w_clk(w_clk),.r_clk(r_clk),.rst(vif.rst),.we(vif.we),.re(vif.re),.wdata(vif.wdata),.rdata(vif.expected_data),.full(vif.expected_full),.empty(vif.expected_empty));
 initial begin
   uvm_config_db#(virtual fifo_if)::set(null,"*","vif",vif);
   run_test("dvbench_test");
 end
 initial begin #1000000;$fatal(1,"reference watchdog");end
endmodule
