`timescale 1ns/1ps
module dvbench_top;
import uvm_pkg::*;
import reference_pkg::*;
native_if bus();
cva6_fifo_v3 #(.FALL_THROUGH(1'b1)) dut(.clk_i(bus.clk_i),.rst_ni(bus.rst_ni),.flush_i(bus.flush_i),.testmode_i(bus.testmode_i),.full_o(bus.full_o),.empty_o(bus.empty_o),.usage_o(bus.usage_o),.data_i(bus.data_i),.push_i(bus.push_i),.data_o(bus.data_o),.pop_i(bus.pop_i));
dvbench_model predictor_model(.clk_i(bus.clk_i),.rst_ni(bus.rst_ni),.flush_i(bus.flush_i),.testmode_i(bus.testmode_i),.full_o(bus.exp_full_o),.empty_o(bus.exp_empty_o),.usage_o(bus.exp_usage_o),.data_i(bus.data_i),.push_i(bus.push_i),.data_o(bus.exp_data_o),.pop_i(bus.pop_i));
initial begin
  uvm_config_db#(virtual native_if)::set(null,"*","bus",bus);
  run_test("dvbench_test");
end
endmodule
