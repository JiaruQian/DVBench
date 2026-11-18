`timescale 1ns/1ps
module dvbench_top;
import uvm_pkg::*;import bench_pkg::*;
bench_if vif();
wire [127:0] expected_plaintext;
TOPpipelined dut(.ciphertext(vif.ciphertext),.key10(vif.key10),.rst(vif.rst),.clk(vif.clk),.plaintext(vif.plaintext));
dvbench_model predictor(.ciphertext(vif.ciphertext),.key10(vif.key10),.rst(vif.rst),.clk(vif.clk),.plaintext(expected_plaintext));
assign vif.expected={expected_plaintext};
initial begin uvm_config_db#(virtual bench_if)::set(null,"*","vif",vif);run_test("dvbench_test");end
endmodule
