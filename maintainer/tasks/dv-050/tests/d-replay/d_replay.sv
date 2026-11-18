`timescale 1ns/1ps
module d_replay;
logic clk=0,reset_n=1,init=0,next=0,mode=1;
logic[511:0] block=0;wire ready,digest_valid,m_ready,m_valid;wire[255:0]digest,m_digest;
sha256_core dut(.*);
dvbench_model oracle(.clk(clk),.reset_n(reset_n),.init(init),.next(next),.mode(mode),.block(block),.ready(m_ready),.digest(m_digest),.digest_valid(m_valid));
always #5 clk=~clk;
int points=0,bad=0;bit active=0;
task compare();
 if(active)begin
  points++;
  if({ready,digest,digest_valid}!=={m_ready,m_digest,m_valid})begin
   bad++;if(bad==1)$display("D_FIRST_MISMATCH time=%0t actual=%h expected=%h",$time,{ready,digest,digest_valid},{m_ready,m_digest,m_valid});
  end
 end
endtask
always @(posedge clk or negedge reset_n)begin #1;compare();end
task drive(input bit i,n,md,input logic[511:0] b,input int cycles=1);
 @(negedge clk);init=i;next=n;mode=md;block=b;repeat(cycles-1)@(negedge clk);
endtask
task reset_between_edges();
 @(negedge clk);init=0;next=0;#2;reset_n=0;#2;reset_n=1;
endtask
initial begin
 logic[511:0] b;
 active=1;#2;reset_n=0;#2;reset_n=1;
 drive(0,1,0,'0);drive(0,0,1,'1,69); // next from zero after reset
 for(int md=0;md<2;md++)begin
  b=512'h61626380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018;
  drive(1,0,md,b);drive(0,0,!md,~b,66);
  if(md==1 && digest!==256'hba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad)$fatal(1,"D_SHA256_KAT");
  if(md==0 && digest[255:32]!==224'h23097d223405d8228642a477bda255b32aadbce4bda0b3f7e36c9da7)$fatal(1,"D_SHA224_KAT");
  for(int j=0;j<5;j++)begin
   for(int k=0;k<16;k++)b[k*32+:32]=$urandom;
   drive(0,1,j%2,b);drive(0,0,!md,~b,66);
  end
 end
 // Disturb all busy ages, including completion; keep a command through next idle.
 for(int age=1;age<=65;age++)begin
  for(int k=0;k<16;k++)b[k*32+:32]=$urandom;
  drive(1,0,age%2,b);drive(0,0,0,~b,age-1>0?age-1:1);
  drive(1,1,!(age%2),~b);drive(0,0,0,b,70);
 end
 for(int age=0;age<=65;age+=5)begin
  drive(1,0,1,b);drive(0,0,0,b,age+1);reset_between_edges();drive(0,0,1,b,70);
 end
 drive(1,1,1,'1,204);drive(0,0,0,0,80);
 #2;$display("DVBench_D_POINTS %0d MISMATCHES %0d",points,bad);$finish;
end
endmodule
