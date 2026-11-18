`timescale 1ns/1ps
module dvbench_top;
import uvm_pkg::*; import reference_pkg::*;
reference_if vif();
top_stopwatch_watch dut(.btnL(vif.btnL),.btnR(vif.btnR),.btnU(vif.btnU),.btuD(vif.btuD),.clk(vif.clk),.fnd_com(vif.fnd_com),.fnd_data(vif.fnd_data),.led(vif.led),.rst(vif.rst),.sw(vif.sw));
dvbench_model predictor_model(.btnL(vif.btnL),.btnR(vif.btnR),.btnU(vif.btnU),.btuD(vif.btuD),.clk(vif.clk),.fnd_com(vif.predicted_fnd_com),.fnd_data(vif.predicted_fnd_data),.led(vif.predicted_led),.rst(vif.rst),.sw(vif.sw));
initial begin uvm_config_db#(virtual reference_if)::set(null,"*","vif",vif); run_test("dvbench_test"); end
endmodule
