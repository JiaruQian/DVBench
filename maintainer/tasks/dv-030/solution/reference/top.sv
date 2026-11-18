`timescale 1ns/1ps
module dvbench_top;
import uvm_pkg::*;import native_pkg::*;
native_if vif();
Digital_lock_top dut(.CLOCK_50Mhz(vif.CLOCK_50Mhz),.HEX0(vif.HEX0),.KEY_0(vif.KEY_0),.LCD_BLON(vif.LCD_BLON),.LCD_DATA(vif.LCD_DATA),.LCD_EN(vif.LCD_EN),.LCD_ON(vif.LCD_ON),.LCD_RS(vif.LCD_RS),.LCD_RW(vif.LCD_RW),.key_valid(vif.key_valid),.keypad_input(vif.keypad_input),.lock(vif.lock),.lock_c(vif.lock_c));
dvbench_model predictor(.CLOCK_50Mhz(vif.CLOCK_50Mhz),.HEX0(vif.pred_HEX0),.KEY_0(vif.KEY_0),.LCD_BLON(vif.pred_LCD_BLON),.LCD_DATA(vif.pred_LCD_DATA),.LCD_EN(vif.pred_LCD_EN),.LCD_ON(vif.pred_LCD_ON),.LCD_RS(vif.pred_LCD_RS),.LCD_RW(vif.pred_LCD_RW),.key_valid(vif.key_valid),.keypad_input(vif.keypad_input),.lock(vif.pred_lock),.lock_c(vif.pred_lock_c));
initial begin uvm_config_db#(virtual native_if)::set(null,"*","vif",vif);run_test("dvbench_test");end
endmodule
