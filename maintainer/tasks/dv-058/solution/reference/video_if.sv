`timescale 1ns/1ps
interface video_if(input logic clk);
 logic n_rst=0;
 logic [3:0] sw=0,btn=0;
 logic [23:0] i_vid_data=0;
 logic i_vid_hsync=0,i_vid_vsync=0,i_vid_VDE=0;
 logic [3:0] led,expected_led;
 logic [23:0] o_vid_data,expected_data;
 logic o_vid_hsync,o_vid_vsync,o_vid_VDE;
 logic expected_hsync,expected_vsync,expected_VDE;
endinterface
