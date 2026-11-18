`timescale 1ns/1ps
module fifo_replay;
 logic w_clk=0,r_clk=0,rst=1,we=0,re=0;logic [7:0] wdata=0;
 wire [7:0] rdata;wire full,empty;
 integer seed=1;int unsigned rng;
 always #5 w_clk=~w_clk;
 always #7 r_clk=~r_clk;
`ifdef DVBENCH_REPLAY_MODEL
 dvbench_model #(.ADDR(16),.BIT_WIDTH(8)) core(.*);
`else
 fifo #(.ADDR(16),.BIT_WIDTH(8)) core(.*);
`endif
 function automatic int unsigned next_rand();rng^=rng<<13;rng^=rng>>17;rng^=rng<<5;return rng;endfunction
 task automatic drive(bit w,bit r,bit reset,bit[7:0] d,int n=1);
  @(negedge w_clk);we=w;re=r;rst=reset;wdata=d;repeat(n)@(negedge w_clk);we=0;re=0;
 endtask
 always @(posedge w_clk or posedge r_clk or posedge rst)begin
   #1;$display("TRACE %0t %b %b %h",$time,full,empty,empty?8'h00:rdata);
 end
 initial begin
  if(!$value$plusargs("SEED=%d",seed))seed=1;rng=32'(seed);
  drive(0,0,1,0,3);drive(0,0,0,0,2);
  for(int i=0;i<16;i++)drive(1,0,0,8'(i*17));
  drive(1,0,0,8'h37,4);drive(1,1,0,8'hab,4);drive(0,1,0,0,30);
  drive(1,1,0,8'h55,4);drive(1,0,0,8'ha5,5);drive(0,0,1,0,3);drive(0,0,0,0,2);
  for(int i=0;i<16;i++)drive(1,0,0,8'(255-i));
  for(int i=0;i<500;i++)begin int unsigned v;v=next_rand();drive(v[0],v[1],0,v[15:8],1+(v[3:2]));end
  drive(0,1,0,0,30);drive(0,0,0,0,3);$display("REPLAY_COMPLETED seed=%0d",seed);$finish;
 end
endmodule
