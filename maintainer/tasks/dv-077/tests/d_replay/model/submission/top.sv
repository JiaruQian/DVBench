`timescale 1ns/1ps
module dvbench_top;
import uvm_pkg::*;import meta_package::*;import diag_pkg::*;
logic clk=0;always #5 clk=~clk;
logic reset_n=0,ecdsa_lh_wr=0;
logic [11:0] ecdsa_lh_waddr=0;
logic [255:0] ecdsa_lh_wdata=0;
logic [63:0] ecdsa_lh_sn_wdata=0;
logic [5:0] ecdsa_lh_ppl_wdata=0;
logic irl_lh_valid=0;
logic [127:0] irl_lh_hdr_data=0;
irl_lh_meta_type irl_lh_meta_data;
logic irl_lh_sop=0,irl_lh_eop=0,ecdsa_lh_ready=1;
wire lh_ecdsa_hash_valid,lh_pp_valid,lh_pp_sop,lh_pp_eop,lh_ecdsa_valid,lh_ecdsa_sop,lh_ecdsa_eop;
wire [255:0] lh_ecdsa_hash_data;
wire [127:0] lh_pp_hdr_data,lh_ecdsa_hdr_data;
lh_pp_meta_type lh_pp_meta_data;
lh_ecdsa_meta_type lh_ecdsa_meta_data;
dvbench_model dut(
  .clk(clk), .reset_n(reset_n),
  .ecdsa_lh_wr(ecdsa_lh_wr), .ecdsa_lh_waddr(ecdsa_lh_waddr),
  .ecdsa_lh_wdata(ecdsa_lh_wdata), .ecdsa_lh_sn_wdata(ecdsa_lh_sn_wdata),
  .ecdsa_lh_ppl_wdata(ecdsa_lh_ppl_wdata), .ecdsa_lh_ready(ecdsa_lh_ready),
  .irl_lh_valid(irl_lh_valid), .irl_lh_hdr_data(irl_lh_hdr_data),
  .irl_lh_meta_data(irl_lh_meta_data), .irl_lh_sop(irl_lh_sop), .irl_lh_eop(irl_lh_eop),
  .lh_ecdsa_hash_valid(lh_ecdsa_hash_valid), .lh_ecdsa_hash_data(lh_ecdsa_hash_data),
  .lh_ecdsa_valid(lh_ecdsa_valid), .lh_ecdsa_hdr_data(lh_ecdsa_hdr_data),
  .lh_ecdsa_meta_data(lh_ecdsa_meta_data), .lh_ecdsa_sop(lh_ecdsa_sop), .lh_ecdsa_eop(lh_ecdsa_eop),
  .lh_pp_valid(lh_pp_valid), .lh_pp_hdr_data(lh_pp_hdr_data),
  .lh_pp_meta_data(lh_pp_meta_data), .lh_pp_sop(lh_pp_sop), .lh_pp_eop(lh_pp_eop)
);

int cyc=0,scenario=0;
function automatic logic[73:0] pack_pp(input lh_pp_meta_type m);
 return {m.hdr_len,m.buf_ptr,m.len,m.port,m.rci,m.fid,m.tid,m.type1,m.type3,m.discard};
endfunction
function automatic logic[81:0] pack_ec(input lh_ecdsa_meta_type m);
 return {m.traffic_class,m.hdr_len,m.buf_ptr,m.len,m.port,m.rci,m.fid,m.tid,m.type1,m.type3,m.discard};
endfunction
function automatic logic[81:0] pack_in(input irl_lh_meta_type m);
 return {m.traffic_class,m.hdr_len,m.buf_ptr,m.len,m.port,m.rci,m.fid,m.tid,m.type1,m.type3,m.discard};
endfunction
always @(posedge clk)begin
 cyc++;
 $display("D_INPUT %0d %b %b %h %h %h %h %b %h %h %b %b %b",cyc,reset_n,ecdsa_lh_wr,ecdsa_lh_waddr,ecdsa_lh_wdata,ecdsa_lh_sn_wdata,ecdsa_lh_ppl_wdata,irl_lh_valid,irl_lh_hdr_data,pack_in(irl_lh_meta_data),irl_lh_sop,irl_lh_eop,ecdsa_lh_ready);
 #1;
 $display("D_TRACE %0d %b %b %h %h %b %b %b %h %h %b %b %b %h",cyc,reset_n,lh_pp_valid,lh_pp_hdr_data,pack_pp(lh_pp_meta_data),lh_pp_sop,lh_pp_eop,lh_ecdsa_valid,lh_ecdsa_hdr_data,pack_ec(lh_ecdsa_meta_data),lh_ecdsa_sop,lh_ecdsa_eop,lh_ecdsa_hash_valid,lh_ecdsa_hash_data);
end
task idle(input int n);
 @(negedge clk);irl_lh_valid=0;irl_lh_sop=0;irl_lh_eop=0;ecdsa_lh_wr=0;repeat(n)@(negedge clk);
endtask
task rst(input int sc);
 scenario=sc;@(negedge clk);reset_n=0;irl_lh_valid=0;irl_lh_sop=0;irl_lh_eop=0;ecdsa_lh_wr=0;
 repeat(3)@(negedge clk);reset_n=1;repeat(4100)@(negedge clk);
endtask
task wr(input logic[255:0] h,input logic[63:0] sn,input int fid=17);
 @(negedge clk);ecdsa_lh_wr=1;ecdsa_lh_waddr=12'(fid);ecdsa_lh_wdata=h;ecdsa_lh_sn_wdata=sn;ecdsa_lh_ppl_wdata=39;
 @(negedge clk);ecdsa_lh_wr=0;repeat(8)@(negedge clk);
endtask
task frame(input bit t1,input bit t3,input int n,input logic[63:0] sn,input int tag,input int gap=0,input int fid=17);
 for(int i=0;i<n;i++)begin
  @(negedge clk);if(gap>0&&i==n/2)begin irl_lh_valid=0;repeat(gap)@(negedge clk);end
  irl_lh_valid=1;irl_lh_sop=(i==0);irl_lh_eop=(i==n-1);
  irl_lh_meta_data='{default:'0};
  irl_lh_meta_data.traffic_class=8'(tag*17+i);irl_lh_meta_data.hdr_len=8'(tag*11);irl_lh_meta_data.buf_ptr=12'(tag*71);
  irl_lh_meta_data.len=14'(tag*101);irl_lh_meta_data.port=3'(tag);irl_lh_meta_data.rci=12'(tag*67);irl_lh_meta_data.fid=12'(fid);
  irl_lh_meta_data.tid=10'(tag*13);irl_lh_meta_data.type1=t1;irl_lh_meta_data.type3=t3;
  irl_lh_hdr_data={16'hd00d,16'(tag),32'(i),i==0?sn:64'({$urandom,$urandom})};
  $display("NATIVE IN scenario=%0d cycle=%0d data=%032x sop=%b eop=%b type1=%b type3=%b",scenario,cyc+1,irl_lh_hdr_data,irl_lh_sop,irl_lh_eop,t1,t3);
 end
 @(negedge clk);irl_lh_valid=0;irl_lh_sop=0;irl_lh_eop=0;
endtask
initial begin
 irl_lh_meta_data='{default:'0};
 rst(1);frame(0,1,8,64'hcafe,1,2);idle(80);
 rst(2);wr(0,64'h1234);frame(0,0,8,64'hcafe,2);idle(80);
 rst(3);wr(0,64'h1234);frame(1,0,8,64'hcafe,3);idle(80);
 rst(4);wr(0,64'h1234);frame(1,0,8,64'h1234,4);idle(80);
 rst(5);wr(256'hdeadbeef,64'h1234);frame(0,0,8,64'hcafe,5);idle(80);
 rst(6);wr(256'hdeadbeef,64'h1234);frame(1,0,8,64'h1234,6);idle(80);
 rst(7);wr(256'hdeadbeef,64'h1234);frame(1,0,8,64'hcafe,7);idle(80);
 rst(8);wr(0,64'h1234);frame(0,0,62,64'hcafe,8,2);idle(100);
 rst(9);wr(256'hdeadbeef,64'h1234);frame(0,1,16,64'hcafe,90);frame(0,0,8,64'hcafe,9);idle(100);
 rst(10);frame(1,1,1,64'h7777,10);idle(100);
 rst(11);wr(0,64'h1234);frame(1,0,5,64'h1234,11);idle(100);
 rst(12);wr(0,64'h1234);frame(1,0,62,64'h7777,12,4);idle(120);
 rst(13);wr(0,64'h1234);frame(0,1,20,64'h7777,13);frame(1,0,8,64'h1234,14);frame(0,1,8,64'h7777,15);idle(180);
 rst(14);wr(256'hdeadbeef,64'h1234);frame(0,1,62,64'hcafe,16);frame(0,0,8,64'hcafe,17);idle(160);
 rst(15);ecdsa_lh_ready=0;wr(0,64'hcafe);frame(1,0,12,64'hcafe,18,3);idle(120);ecdsa_lh_ready=1;
 rst(16);frame(0,1,12,64'hcafe,19);idle(100);
 rst(17);wr(0,64'h1234);frame(0,0,1,64'hbeef,20);idle(100);
 rst(18);wr(256'h1,64'h1234);frame(0,0,2,64'hbeef,21);idle(100);
 rst(19);wr(256'h1,64'h1234);frame(1,0,1,64'hbeef,22);idle(100);
 rst(20);wr(0,64'h1234);frame(1,0,1,64'h1234,23);idle(100);
 rst(21);wr(0,64'h1234);frame(1,0,4,64'h1234,24);idle(100);
 rst(22);wr(0,64'h1234,0);frame(1,0,8,64'h1234,25,0,0);idle(100);
 rst(23);wr(0,64'hffffffffffffffff,4095);frame(1,0,8,64'hffffffffffffffff,26,0,4095);idle(100);
 rst(24);wr(0,64'h1234);wr(0,64'h5678);frame(1,0,8,64'h1234,27);idle(100);
 rst(25);frame(0,1,20,64'hcafe,28);@(negedge clk);reset_n=0;repeat(3)@(negedge clk);reset_n=1;repeat(4100)@(negedge clk);frame(0,1,8,64'hbeef,29);idle(100);
 diagnostic_done=1;
end
initial run_test("dvbench_test");
endmodule
