`timescale 1ns/1ps
module replay_top;
 reg clk=0,rst=0,sa=0,sx=0,sm=0,lq=0,sq=0,rr=0,flush=0;
 reg[31:0]ax=0,am=0,sd=0,rd=0;reg[3:0]be=0;wire stall,restart,req,refilling;wire[31:0]addr,data;
 integer points=0;bit armed=0;
 dvbench_model #(.sets(64)) obj(.clk_i(clk),.rst_i(rst),.stall_a(sa),.stall_x(sx),.stall_m(sm),.address_x(ax),.address_m(am),.load_q_m(lq),.store_q_m(sq),.store_data(sd),.store_byte_select(be),.refill_ready(rr),.refill_data(rd),.dflush(flush),.stall_request(stall),.restart_request(restart),.refill_request(req),.refill_address(addr),.refilling(refilling),.load_data(data));
 always #5 clk=~clk;
 task tick;@(negedge clk);endtask
 task sample; $display("TRACE %0d %b %h %h",points,{stall,restart,req,refilling},addr,data);points++;endtask
 always @(posedge clk)begin #2;if(armed)sample();end
 always @(posedge rst)begin #2;armed=1;sample();end
 initial begin
  tick();rst=1;repeat(3)tick();rst=0;repeat(520)tick();
  for(integer op=0;op<32;op++)begin
   ax=op*8192+(op%4)*4;tick();am=ax;lq=1;if(op==11)flush=1;tick();lq=0;flush=0;repeat(2)tick();
   for(integer j=0;j<4;j++)begin repeat(op%4)tick();rr=1;rd=$urandom;tick();rr=0;end
   sa=1;repeat(2)tick();sa=0;repeat(3)tick();
   if(op%4==1)begin ax=am^4;tick();end
   sq=1;sd=$urandom;be=op%16;tick();sq=0;repeat(2)tick();
   sx=1;ax=ax^32'h100;repeat(2)tick();sx=0;ax=am;tick();
   sm=1;sq=1;sd=$urandom;tick();sm=0;sq=0;repeat(2)tick();
   if(op==14 || op==24)begin flush=1;tick();flush=0;repeat(520)tick();end
   if(op==20)begin rst=1;repeat(3)tick();rst=0;repeat(520)tick();end
  end
  repeat(20)tick();$display("REPLAY_COMPLETED points=%0d",points);$finish;
 end
endmodule
