`timescale 1ns/1ps
module dvbench_top;
 import uvm_pkg::*; import video_pkg::*;
 logic clk=0; always #1 clk=~clk;
 video_if vif(clk);
 video_filter_top #(.DATA_WIDTH(24),.IMAGE_WIDTH(384),.IMAGE_HEIGHT(64),.BLINK_RATE(6),.DEBOUNCE_LIMIT(2500000)) dut(.clk(clk),.n_rst(vif.n_rst),.sw(vif.sw),.btn(vif.btn),.led(vif.led),
 .i_vid_data(vif.i_vid_data),.i_vid_hsync(vif.i_vid_hsync),.i_vid_vsync(vif.i_vid_vsync),.i_vid_VDE(vif.i_vid_VDE),
 .o_vid_data(vif.o_vid_data),.o_vid_hsync(vif.o_vid_hsync),.o_vid_vsync(vif.o_vid_vsync),.o_vid_VDE(vif.o_vid_VDE));
 dvbench_model #(.DATA_WIDTH(24),.IMAGE_WIDTH(384),.IMAGE_HEIGHT(64),.BLINK_RATE(6),.DEBOUNCE_LIMIT(2500000)) predicted(.clk(clk),.n_rst(vif.n_rst),.sw(vif.sw),.btn(vif.btn),.led(vif.expected_led),
 .i_vid_data(vif.i_vid_data),.i_vid_hsync(vif.i_vid_hsync),.i_vid_vsync(vif.i_vid_vsync),.i_vid_VDE(vif.i_vid_VDE),
 .o_vid_data(vif.expected_data),.o_vid_hsync(vif.expected_hsync),.o_vid_vsync(vif.expected_vsync),.o_vid_VDE(vif.expected_VDE));
 initial begin uvm_config_db#(virtual video_if)::set(null,"*","vif",vif); run_test(); end
endmodule
