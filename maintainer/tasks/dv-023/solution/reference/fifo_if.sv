`timescale 1ns/1ps
interface fifo_if(input logic w_clk,r_clk);
 logic rst=1,we=0,re=0;
 logic [7:0] wdata=0;
 wire [7:0] rdata,expected_data;
 wire full,empty,expected_full,expected_empty;
endinterface
