`timescale 1ns/1ps
module dvbench_top;
import uvm_pkg::*;
import reference_pkg::*;
native_if bus();
i2c dut(.scl(bus.scl),.o_data(bus.o_data),.s_busy(bus.s_busy),.s_done(bus.s_done),.sda_en(bus.sda_en),.sda(bus.sda),.clk(bus.clk),.rst_n(bus.rst_n),.addr(bus.addr),.cmd(bus.cmd),.data(bus.data),.rd_wr(bus.rd_wr),.init(bus.init),.wr(bus.wr));
dvbench_model predictor_model(.scl(bus.exp_scl),.o_data(bus.exp_o_data),.s_busy(bus.exp_s_busy),.s_done(bus.exp_s_done),.sda_en(bus.exp_sda_en),.sda(bus.exp_sda),.clk(bus.clk),.rst_n(bus.rst_n),.addr(bus.addr),.cmd(bus.cmd),.data(bus.data),.rd_wr(bus.rd_wr),.init(bus.init),.wr(bus.wr));
initial begin
  uvm_config_db#(virtual native_if)::set(null,"*","bus",bus);
  run_test("dvbench_test");
end
endmodule
