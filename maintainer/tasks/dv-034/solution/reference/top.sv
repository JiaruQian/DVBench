`timescale 1ns/1ps
module dvbench_top;
import uvm_pkg::*;import native_pkg::*;
native_if vif();
alarm_clock_top dut(.alarm_button(vif.alarm_button),.alarm_sound(vif.alarm_sound),.clock(vif.clock),.fastwatch(vif.fastwatch),.key(vif.key),.ls_hour(vif.ls_hour),.ls_minute(vif.ls_minute),.ms_hour(vif.ms_hour),.ms_minute(vif.ms_minute),.reset(vif.reset),.time_button(vif.time_button));
dvbench_model predictor(.alarm_button(vif.alarm_button),.alarm_sound(vif.pred_alarm_sound),.clock(vif.clock),.fastwatch(vif.fastwatch),.key(vif.key),.ls_hour(vif.pred_ls_hour),.ls_minute(vif.pred_ls_minute),.ms_hour(vif.pred_ms_hour),.ms_minute(vif.pred_ms_minute),.reset(vif.reset),.time_button(vif.time_button));
initial begin uvm_config_db#(virtual native_if)::set(null,"*","vif",vif);run_test("dvbench_test");end
endmodule
