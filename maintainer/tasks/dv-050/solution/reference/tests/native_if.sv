`timescale 1ns/1ps
interface native_if;
logic clk;
logic reset_n;
logic init;
logic next;
logic mode;
logic [511:0] block;
logic ready;
logic [255:0] digest;
logic digest_valid;
logic exp_ready;
logic [255:0] exp_digest;
logic exp_digest_valid;
initial clk=0;always #5 clk=~clk;

task idle(input int n);repeat(n)begin @(negedge clk);init=0;next=0;end endtask
task request(input bit first,input bit md,input logic[511:0] b,input bit both=0);
 @(negedge clk);init=first;next=!first||both;mode=md;block=b;
 @(negedge clk);init=0;next=0;
endtask
task exercise();
 logic[511:0] b;
 init=0;next=0;mode=1;block=0;reset_n=1;#2;reset_n=0;
 idle(3);@(negedge clk);reset_n=1;idle(2);
 // Direct continuation immediately after reset, then full-domain patterns.
 request(0,1,'0);idle(70);
 for(int md=0;md<2;md++)begin
  request(1,md,'0);idle(70);request(1,md,'1);idle(70);
  for(int k=0;k<16;k++)b[k*32+:32]=32'h1020304*(k+1);
  request(1,md,b);idle(70);
 end
 b=512'h61626380000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000018;
 for(int m=0;m<2;m++)begin
  request(1,m,b);idle(70);
  request(0,!m,~b);idle(70);
  request(1,m,'1,1);idle(70);
 end
 for(int j=0;j<36;j++)begin
  for(int k=0;k<16;k++)b[32*k+:32]=$urandom;
  request((j%3)==0,j%2,b);
  if(j%4==0)begin idle(10);request(1,!mode,~b);end
  idle(70);
 end
 for(int age=0;age<66;age+=13)begin
  request(1,1,b);idle(age);#2;reset_n=0;#2;reset_n=1;idle(70);
  request(1,0,~b);idle(70);
 end
 // Exact busy disturbances and a retained command across completion.
 for(int ix=0;ix<4;ix++)begin
  int age;age=(ix==0)?1:(ix==1)?10:(ix==2)?64:65;
  request(1,1,b);idle(age-1);request(1,0,~b,1);idle(80);
 end
 // next held high independently from init.
 @(negedge clk);init=0;next=1;mode=0;block=~b;
 repeat(140)@(negedge clk);init=0;next=0;idle(80);
 @(negedge clk);init=1;next=1;mode=1;block=b;
 repeat(140)@(negedge clk);
 init=0;next=0;idle(75);
 @(negedge clk);init=1;next=0;mode=0;block=b;
 repeat(65) @(negedge clk);
 mode=1;block=~b;
 repeat(70) @(negedge clk);
 mode=0;block=b;
 repeat(70) @(negedge clk);
 init=0;next=0;idle(75);
endtask

endinterface
