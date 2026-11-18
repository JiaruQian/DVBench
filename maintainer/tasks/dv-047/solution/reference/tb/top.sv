`timescale 1ns/1ps
module dvbench_top;
import uvm_pkg::*;import test_pkg::*;aes_if vif();
Decryption dut(.in(vif.in),.Key(vif.Key),.counter(vif.counter),.clk(vif.clk),.out(vif.out),.maxRound(vif.maxRound));
dvbench_model predictor(.in(vif.in),.Key(vif.Key),.counter(vif.counter),.clk(vif.clk),.out(vif.expected),.maxRound(vif.maxRound));
initial begin uvm_config_db#(virtual aes_if)::set(null,"*","vif",vif);run_test("dvbench_test");end
endmodule
