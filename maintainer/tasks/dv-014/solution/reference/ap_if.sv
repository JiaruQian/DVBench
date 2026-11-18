`timescale 1ns/1ps
interface ap_if(input logic sys_clk);
 logic rst_n=1;wire scl,expected_scl;tri1 sda,expected_sda;
 wire[3:0] led,expected_led;wire[5:0] sel,expected_sel;wire[7:0] seg,expected_seg;
 integer actual_stops,actual_reads,expected_stops,expected_reads;
endinterface
