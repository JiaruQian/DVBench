`timescale 1ns/1ps
module dvbench_top;
import uvm_pkg::*;import meta_package::*;import reference_pkg::*;
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
logic_hash dut(
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
wire exp_lh_ecdsa_hash_valid,exp_lh_pp_valid,exp_lh_pp_sop,exp_lh_pp_eop,exp_lh_ecdsa_valid,exp_lh_ecdsa_sop,exp_lh_ecdsa_eop;
wire[255:0] exp_lh_ecdsa_hash_data;
wire[127:0] exp_lh_pp_hdr_data,exp_lh_ecdsa_hdr_data;
lh_pp_meta_type exp_lh_pp_meta_data;
lh_ecdsa_meta_type exp_lh_ecdsa_meta_data;
dvbench_model prediction(.clk(clk),.reset_n(reset_n),.ecdsa_lh_wr(ecdsa_lh_wr),.ecdsa_lh_waddr(ecdsa_lh_waddr),.ecdsa_lh_wdata(ecdsa_lh_wdata),.ecdsa_lh_sn_wdata(ecdsa_lh_sn_wdata),.ecdsa_lh_ppl_wdata(ecdsa_lh_ppl_wdata),.irl_lh_valid(irl_lh_valid),.irl_lh_hdr_data(irl_lh_hdr_data),.irl_lh_meta_data(irl_lh_meta_data),.irl_lh_sop(irl_lh_sop),.irl_lh_eop(irl_lh_eop),.ecdsa_lh_ready(ecdsa_lh_ready),.lh_ecdsa_hash_valid(exp_lh_ecdsa_hash_valid),.lh_ecdsa_hash_data(exp_lh_ecdsa_hash_data),.lh_pp_valid(exp_lh_pp_valid),.lh_pp_hdr_data(exp_lh_pp_hdr_data),.lh_pp_meta_data(exp_lh_pp_meta_data),.lh_pp_sop(exp_lh_pp_sop),.lh_pp_eop(exp_lh_pp_eop),.lh_ecdsa_valid(exp_lh_ecdsa_valid),.lh_ecdsa_hdr_data(exp_lh_ecdsa_hdr_data),.lh_ecdsa_meta_data(exp_lh_ecdsa_meta_data),.lh_ecdsa_sop(exp_lh_ecdsa_sop),.lh_ecdsa_eop(exp_lh_ecdsa_eop));
int cyc=0,scenario=0;
int isolated_due=-1;
logic [127:0] isolated_data;

typedef struct packed {logic[127:0] data;logic[81:0] meta;logic sop,eop;} obs_t;
obs_t actual_pp[$],expected_pp[$],actual_ec[$],expected_ec[$],oa,oe;
logic[255:0] actual_hash[$],expected_hash[$],ha,he;

function automatic logic[73:0] pack_pp(input lh_pp_meta_type m);
 return {m.hdr_len,m.buf_ptr,m.len,m.port,m.rci,m.fid,m.tid,m.type1,m.type3,m.discard};
endfunction
function automatic logic[81:0] pack_ec(input lh_ecdsa_meta_type m);
 return {m.traffic_class,m.hdr_len,m.buf_ptr,m.len,m.port,m.rci,m.fid,m.tid,m.type1,m.type3,m.discard};
endfunction
task automatic check_pair(input obs_t a,e,input bit pp);
 bit bad;logic[127:0] mask;
 mask='1;
 // Type2's final low sixteen bits have no public defined value.
 if(pp && e.eop && !e.meta[2] && !e.meta[1])mask[15:0]=0;
 bad=((a.data&mask)!==(e.data&mask))||(a.meta!==e.meta)||(a.sop!==e.sop)||(a.eop!==e.eop);
 compared++;if(bad)begin mismatches++;if(mismatches<12)
 $display("LH_COMPARE channel=%s point=%0d actual=%h/%h/%b%b expected=%h/%h/%b%b",pp?"PP":"ECD",compared,a.data,a.meta,a.sop,a.eop,e.data,e.meta,e.sop,e.eop);
 end
endtask
always @(posedge clk)begin
 cyc++;
 if(!reset_n) isolated_due=-1;
 else if((scenario==350 || scenario==351) && irl_lh_valid && irl_lh_sop)begin
   isolated_due=cyc+4;isolated_data=irl_lh_hdr_data;
 end
 #1;
 if(reset_n && (scenario==350 || scenario==351) && isolated_due>=0)begin
   if(cyc<isolated_due && lh_pp_valid!==0)begin
     mismatches++;$display("LH_ISOLATED_FIRST_EARLY cycle=%0d due=%0d",cyc,isolated_due);
   end
   if(cyc==isolated_due)begin
     compared++;
     if(lh_pp_valid!==1 || lh_pp_sop!==1 || lh_pp_hdr_data!==isolated_data)begin
       mismatches++;$display("LH_ISOLATED_FIRST_LATENCY cycle=%0d valid=%b sop=%b",cyc,lh_pp_valid,lh_pp_sop);
     end
   end
 end
 if(!reset_n)begin
   if(lh_pp_valid!==0||lh_ecdsa_valid!==0||lh_ecdsa_hash_valid!==0)begin mismatches++;$display("LH_RESET_VALID_ERROR");end
   actual_pp.delete();expected_pp.delete();actual_ec.delete();expected_ec.delete();actual_hash.delete();expected_hash.delete();
 end else begin
   if(lh_pp_valid)begin oa.data=lh_pp_hdr_data;oa.meta={8'b0,pack_pp(lh_pp_meta_data)};oa.sop=lh_pp_sop;oa.eop=lh_pp_eop;actual_pp.push_back(oa);actual_count++;end
   if(exp_lh_pp_valid)begin oe.data=exp_lh_pp_hdr_data;oe.meta={8'b0,pack_pp(exp_lh_pp_meta_data)};oe.sop=exp_lh_pp_sop;oe.eop=exp_lh_pp_eop;expected_pp.push_back(oe);expected_count++;end
   if(lh_ecdsa_valid)begin oa.data=lh_ecdsa_hdr_data;oa.meta=pack_ec(lh_ecdsa_meta_data);oa.sop=lh_ecdsa_sop;oa.eop=lh_ecdsa_eop;actual_ec.push_back(oa);actual_count++;end
   if(exp_lh_ecdsa_valid)begin oe.data=exp_lh_ecdsa_hdr_data;oe.meta=pack_ec(exp_lh_ecdsa_meta_data);oe.sop=exp_lh_ecdsa_sop;oe.eop=exp_lh_ecdsa_eop;expected_ec.push_back(oe);expected_count++;end
   if(lh_ecdsa_hash_valid)begin actual_hash.push_back(lh_ecdsa_hash_data);actual_count++;end
   if(exp_lh_ecdsa_hash_valid)begin expected_hash.push_back(exp_lh_ecdsa_hash_data);expected_count++;end
   while(actual_pp.size()&&expected_pp.size())begin oa=actual_pp.pop_front();oe=expected_pp.pop_front();check_pair(oa,oe,1);end
   while(actual_ec.size()&&expected_ec.size())begin oa=actual_ec.pop_front();oe=expected_ec.pop_front();check_pair(oa,oe,0);end
   while(actual_hash.size()&&expected_hash.size())begin
     ha=actual_hash.pop_front();he=expected_hash.pop_front();compared++;
     if(ha!==he)begin mismatches++;$display("LH_HASH_COMPARE actual=%h expected=%h",ha,he);end
   end
 end
end
task audit_scenario;
 #2;
 if(actual_pp.size()+expected_pp.size()+actual_ec.size()+expected_ec.size()+actual_hash.size()+expected_hash.size()>0)begin
   mismatches++;$display("LH_MISSING scenario=%0d queues=%0d/%0d/%0d/%0d/%0d/%0d",scenario,actual_pp.size(),expected_pp.size(),actual_ec.size(),expected_ec.size(),actual_hash.size(),expected_hash.size());
 end
 $display("LH_SCENARIO id=%0d compared=%0d mismatches=%0d actual=%0d expected=%0d",scenario,compared,mismatches,actual_count,expected_count);
endtask
task idle(input int n);
 @(negedge clk);irl_lh_valid=0;irl_lh_sop=0;irl_lh_eop=0;ecdsa_lh_wr=0;repeat(n)@(negedge clk);
endtask
task rst(input int sc);
 if(scenario>0)audit_scenario();scenario=sc;@(negedge clk);reset_n=0;irl_lh_valid=0;irl_lh_sop=0;irl_lh_eop=0;ecdsa_lh_wr=0;
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
 for(int word_index=0;word_index<8;word_index++)begin
  rst(100+word_index);wr(256'hffffffff << (32*word_index),64'h1234);
  frame(1,0,12,64'h1234,100+word_index,2);idle(180);
 end
 rst(110);wr(0,64'hffffffff00000000);frame(1,0,8,64'h0000000000000000,110);idle(180);
 rst(111);wr(0,64'h00000000ffffffff);frame(1,0,8,64'hffffffffffffffff,111);idle(180);
 for(int address_bit=8;address_bit<12;address_bit++)begin
  rst(120+address_bit);wr(0,64'h1234,17);wr(0,64'h5678,17^(1<<address_bit));
  frame(1,0,8,64'h1234,120+address_bit,0,17);idle(180);
  frame(1,0,8,64'h5678,140+address_bit,0,17^(1<<address_bit));idle(180);
 end
 rst(350);idle(1);frame(0,1,8,64'h1234,350);idle(100);
 rst(351);idle(2);frame(0,1,8,64'h5678,351);idle(100);
 for(int case_index=0;case_index<4;case_index++)begin
  int selected_fid;
  int prior_expected_count;
  selected_fid=(case_index==0)?0:(case_index==1)?4095:(case_index==2)?12'h555:12'haaa;
  rst(400+case_index);
  @(negedge clk);ecdsa_lh_wr=1;ecdsa_lh_waddr=12'(selected_fid);
  ecdsa_lh_wdata=0;ecdsa_lh_sn_wdata=64'h1111222233334444;ecdsa_lh_ppl_wdata=6'd3;
  @(negedge clk);ecdsa_lh_wr=1;ecdsa_lh_waddr=12'(selected_fid);
  ecdsa_lh_wdata=0;ecdsa_lh_sn_wdata=64'haaaabbbbccccdddd;ecdsa_lh_ppl_wdata=6'd59;
  @(negedge clk);ecdsa_lh_wr=0;
  repeat(4)@(negedge clk);
  prior_expected_count=expected_count;
  frame(1,0,8,64'haaaabbbbccccdddd,400+case_index,0,selected_fid);
  idle(100);
  if(expected_count-prior_expected_count!=5)begin
   mismatches++;
   $display("LH_WAW_VACUITY case=%0d predicted_transactions=%0d expected=5",case_index,expected_count-prior_expected_count);
  end
 end
 for(int case_index=0;case_index<2;case_index++)begin
  int prior_expected_count;
  rst(500+case_index*2);
  wr(0,case_index==0?64'd1:64'hffffffffffffffff,4094);
  wr(0,case_index==0?64'd1:64'hffffffffffffffff,4095);
  rst(501+case_index*2);
  prior_expected_count=expected_count;
  frame(1,0,8,0,500+case_index*2,0,4094);
  idle(100);
  if(expected_count-prior_expected_count!=5)begin
   mismatches++;
   $display("LH_SCAN_CONTROL_VACUITY case=%0d predicted_transactions=%0d expected=5",case_index,expected_count-prior_expected_count);
  end
  prior_expected_count=expected_count;
  frame(1,0,8,0,501+case_index*2,0,4095);
  idle(100);
  if(expected_count-prior_expected_count!=5)begin
   mismatches++;
   $display("LH_SCAN_LAST_VACUITY case=%0d predicted_transactions=%0d expected=5",case_index,expected_count-prior_expected_count);
  end
 end
 audit_scenario();reference_done=1;
end
initial run_test("dvbench_test");
endmodule
