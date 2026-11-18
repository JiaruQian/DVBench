`timescale 1ns/1ps
module model_check(yapp_if a,channel_if c0,channel_if c1,channel_if c2,hbus_if hb,
 input logic pe, ps,input logic[7:0] d0,d1,d2,input logic v0,v1,v2,input wire[7:0] hd);
 import uvm_pkg::*;
 `include "uvm_macros.svh"
 int checks=0, bad=0;
 task ck(input bit ok,input string msg);
   checks++;
   if(!ok) begin
     bad++; if(bad<=20) `uvm_error("NATIVE_MODEL",msg)
   end
 endtask
 always @(posedge a.clk) begin
   #1;
   if(!a.reset) begin
     ck({c0.data_vld,c1.data_vld,c2.data_vld}==={v0,v1,v2},"valid");
     if(c0.data_vld) ck(c0.data===d0,"channel0 data");
     if(c1.data_vld) ck(c1.data===d1,"channel1 data");
     if(c2.data_vld) ck(c2.data===d2,"channel2 data");
   end
 end
 always @(negedge a.clk) begin
   #1;
   if(!a.reset) begin
     ck(a.error===pe,"parity error");
     ck(a.in_suspend===ps,"input suspend");
     if(hb.hen && !hb.hwr_rd) ck(hb.hdata===hd,$sformatf("hbus %h actual %h predicted %h",hb.haddr,hb.hdata,hd));
   end
 end
 final $display("MODEL_CHECKS=%0d MODEL_MISMATCHES=%0d",checks,bad);
endmodule
