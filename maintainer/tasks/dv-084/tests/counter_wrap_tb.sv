`timescale 1ns/1ps
module counter_wrap_tb;
 logic clock=0,reset=1,in_data_vld=0,suspend_0=0,suspend_1=0,suspend_2=0,hen=0,hwr_rd=0,hdrive=0;
 logic [7:0] in_data=0,hdata_w=0;
 logic [15:0] haddr=0;
 tri[7:0] hdata,model_hdata;
 wire error,in_suspend,data_vld_0,data_vld_1,data_vld_2;
 wire[7:0] data_0,data_1,data_2;
 wire me,ms,mv0,mv1,mv2;wire[7:0] md0,md1,md2;
 assign hdata=hdrive?hdata_w:8'bz;
 assign model_hdata=hdrive?hdata_w:8'bz;
 always #5 clock=~clock;
 yapp_router dut(.*);
 dvbench_model predictor(.clock(clock),.reset(reset),.in_data(in_data),.in_data_vld(in_data_vld),.suspend_0(suspend_0),.suspend_1(suspend_1),.suspend_2(suspend_2),.hen(hen),.hwr_rd(hwr_rd),.haddr(haddr),.hdata(model_hdata),.error(me),.in_suspend(ms),.data_0(md0),.data_1(md1),.data_2(md2),.data_vld_0(mv0),.data_vld_1(mv1),.data_vld_2(mv2));
 task hostwrite(input [15:0] addr,input[7:0] value);
  @(negedge clock);#1;haddr=addr;hwr_rd=1;hen=1;hdrive=1;hdata_w=value;
  @(negedge clock);#1;hen=0;hdrive=0;repeat(2)@(negedge clock);
 endtask
 initial begin
  repeat(4)@(negedge clock);#1;reset=0;repeat(3)@(negedge clock);
  hostwrite(16'h1001,8'hf7);
  for(int n=0;n<260;n++)begin
   @(negedge clock);#1;in_data=8'h07;in_data_vld=1;
   @(negedge clock);#1;in_data=0;in_data_vld=0;
   repeat(3)@(negedge clock);
  end
  repeat(4)@(negedge clock);#1;haddr=16'h1006;hwr_rd=0;hen=1;
  @(negedge clock);#2;
  if(hdata!==8'hff || model_hdata!==8'hff)$fatal(1,"WRAP actual=%h model=%h",hdata,model_hdata);
  $display("COUNTER_WRAP actual=%h predicted=%h NATIVE_TEST_PASS",hdata,model_hdata);$finish;
 end
endmodule
