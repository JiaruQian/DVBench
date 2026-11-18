`timescale 1ns/1ps
module dvbench_top;
 import uvm_pkg::*;import ap_pkg::*;
 logic sys_clk=0;always #10 sys_clk=~sys_clk;
 ap_if vif(sys_clk);
 initial begin #1;vif.rst_n=0;end
 ap3216c_top dut(.sys_clk(sys_clk),.sys_rst_n(vif.rst_n),.ap_scl(vif.scl),.ap_sda(vif.sda),.led(vif.led),.sel(vif.sel),.seg_led(vif.seg));
 dvbench_model predictor(.sys_clk(sys_clk),.sys_rst_n(vif.rst_n),.ap_scl(vif.expected_scl),.ap_sda(vif.expected_sda),.led(vif.expected_led),.sel(vif.expected_sel),.seg_led(vif.expected_seg));
 ap_sensor_slave actual_sensor(.rst_n(vif.rst_n),.scl(vif.scl),.sda(vif.sda),.stops(vif.actual_stops),.read_bytes(vif.actual_reads));
 ap_sensor_slave expected_sensor(.rst_n(vif.rst_n),.scl(vif.expected_scl),.sda(vif.expected_sda),.stops(vif.expected_stops),.read_bytes(vif.expected_reads));
 initial begin uvm_config_db#(virtual ap_if)::set(null,"*","vif",vif);run_test("dvbench_test");end
 initial begin #400000000;$fatal(1,"AP reference watchdog");end
endmodule
