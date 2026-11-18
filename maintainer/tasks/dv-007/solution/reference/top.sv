`timescale 1ns/1ps
module dvbench_top;
import uvm_pkg::*;
import reference_pkg::*;
native_if bus();
ram_2x336 dut(.R0_addr(bus.R0_addr),.R0_en(bus.R0_en),.R0_clk(bus.R0_clk),.R0_data(bus.R0_data),.W0_addr(bus.W0_addr),.W0_en(bus.W0_en),.W0_clk(bus.W0_clk),.W0_data(bus.W0_data),.W0_mask(bus.W0_mask));
dvbench_model predictor_model(.R0_addr(bus.R0_addr),.R0_en(bus.R0_en),.R0_clk(bus.R0_clk),.R0_data(bus.exp_R0_data),.W0_addr(bus.W0_addr),.W0_en(bus.W0_en),.W0_clk(bus.W0_clk),.W0_data(bus.W0_data),.W0_mask(bus.W0_mask));
initial begin
  uvm_config_db#(virtual native_if)::set(null,"*","bus",bus);
  run_test("dvbench_test");
end
endmodule
