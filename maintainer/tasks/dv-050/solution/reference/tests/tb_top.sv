`timescale 1ns/1ps
module dvbench_top;
import uvm_pkg::*;import verify_pkg::*;
native_if pins();
sha256_core dut(.clk(pins.clk),.reset_n(pins.reset_n),.init(pins.init),.next(pins.next),.mode(pins.mode),.block(pins.block),.ready(pins.ready),.digest(pins.digest),.digest_valid(pins.digest_valid));
dvbench_model predicted(.clk(pins.clk),.reset_n(pins.reset_n),.init(pins.init),.next(pins.next),.mode(pins.mode),.block(pins.block),.ready(pins.exp_ready),.digest(pins.exp_digest),.digest_valid(pins.exp_digest_valid));
initial begin uvm_config_db#(virtual native_if)::set(null,"*","vif",pins);run_test();end
endmodule
