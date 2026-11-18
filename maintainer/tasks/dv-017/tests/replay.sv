`timescale 1ns/1ps
// Independent D replay: native inputs only, three parameter profiles.
// Uses exactly the same model/model.sv as the UVM predictor.
module sram_d_profile #(parameter int N=4,AW=12,DW=32,parameter bit MASK=0,
 parameter IMPL="PPC",parameter int PROFILE=0)(
 input logic clk,output bit done=0,output int comparisons=0,output int mismatches=0);

 logic rst_n=0;
 logic [N-1:0] req='0,wr='0;
 logic [AW-1:0] addr[N]='{default:'0};
 logic [DW-1:0] wd[N]='{default:'0},wm[N]='{default:'0};
 logic rv=0;
 logic [DW-1:0] rd='0;
 logic [1:0] err='0;
 logic [N-1:0] gnt,rvalid,egnt,ervalid;
 logic [DW-1:0] rdata[N],erdata[N];
 logic [1:0] error[N],eerror[N];
 logic sreq,swrite,esreq,eswrite;
 logic [AW-1:0] saddr,esaddr;
 logic [DW-1:0] swdata,swmask,eswdata,eswmask;
prim_sram_arbiter #(.N(N),.SramAw(AW),.SramDw(DW),.ArbiterImpl(IMPL),.EnMask(MASK)) dut (
 .clk_i(clk),
 .rst_ni(rst_n),
 .req_i(req),
 .req_addr_i(addr),
 .req_write_i(wr),
 .req_wdata_i(wd),
 .req_wmask_i(wm),
 .sram_rvalid_i(rv),
 .sram_rdata_i(rd),
 .sram_rerror_i(err),
 .gnt_o(gnt),
 .rsp_rvalid_o(rvalid),
 .rsp_rdata_o(rdata),
 .rsp_error_o(error),
 .sram_req_o(sreq),
 .sram_addr_o(saddr),
 .sram_write_o(swrite),
 .sram_wdata_o(swdata),
 .sram_wmask_o(swmask));
dvbench_model #(.N(N),.SramAw(AW),.SramDw(DW),.ArbiterImpl(IMPL),.EnMask(MASK)) predictor (
 .clk_i(clk),
 .rst_ni(rst_n),
 .req_i(req),
 .req_addr_i(addr),
 .req_write_i(wr),
 .req_wdata_i(wd),
 .req_wmask_i(wm),
 .sram_rvalid_i(rv),
 .sram_rdata_i(rd),
 .sram_rerror_i(err),
 .gnt_o(egnt),
 .rsp_rvalid_o(ervalid),
 .rsp_rdata_o(erdata),
 .rsp_error_o(eerror),
 .sram_req_o(esreq),
 .sram_addr_o(esaddr),
 .sram_write_o(eswrite),
 .sram_wdata_o(eswdata),
 .sram_wmask_o(eswmask));

 function bit[N-1:0] one(int p);return 1<<p;endfunction
 task check_one(bit bad,string field_name);
  comparisons++;
  if(bad)begin
   mismatches++;
   if(mismatches<=10)$display("D_MISMATCH profile=%0d time=%0t field=%s",PROFILE,$time,field_name);
  end
 endtask
 task check_outputs();
  check_one(gnt!==egnt,"grant");check_one(sreq!==esreq,"request");
  check_one(rvalid!==ervalid,"response-owner");
  if(esreq)begin
   check_one(saddr!==esaddr,"address");check_one(swrite!==eswrite,"write");
   check_one(swdata!==eswdata,"write-data");check_one(swmask!==eswmask,"write-mask");
  end
  for(int p=0;p<N;p++)begin
   check_one(rdata[p]!==erdata[p],$sformatf("broadcast-data[%0d]",p));
   check_one(error[p]!==eerror[p],$sformatf("broadcast-error[%0d]",p));
  end
 endtask
 task drive(bit rn=1,bit[N-1:0] r='0,bit[N-1:0] w='0,bit valid=0,int abase=0,
            bit[DW-1:0] data='0,bit[DW-1:0] mask='1,
            bit[DW-1:0] response='0,bit[1:0] e=0);
  @(negedge clk);
  rst_n=rn;req=r;wr=w;rv=valid;rd=response;err=e;
  for(int p=0;p<N;p++)begin addr[p]=AW'(abase+29*p);wd[p]=data^DW'(32'h10204081*p);wm[p]=mask;end
  #1;check_outputs();#1;
 endtask
 task reset_clean();drive(0);drive(0);drive(1);drive(1);endtask
 initial begin
  int seed;
  bit[N-1:0] block_req,block_wr;
  bit[AW-1:0] block_addr[N];
  bit[DW-1:0] block_wd[N],block_wm[N];
  seed=1;void'($value$plusargs("SEED=%d",seed));seed=seed+97*PROFILE;void'($urandom(seed));
  reset_clean();
  drive(0);drive(0);
  drive(1,one(N-1),'0,0,'h110);drive(1,one(0),'0,0,'h220);
  drive(1,'0,'0,1,0,'0,'1,32'h01234567,1);
  drive(1,'0,'0,1,0,'0,'1,32'h89ABCDEF,2);
  reset_clean();
  for(int k=0;k<4*N;k++)drive(1,'1,'1,0,k,32'hAA000000+k,32'hA5A55A5A);
  drive(1,one(N-1),one(N-1),0,'hfff,'1,'0);
  drive(1,one(0),one(0),0,0,'0,'1);drive(1);
  reset_clean();
  drive(1,one(0)|one(N-1),one(N-1),0,'h333,32'h12345678,32'h00FF00FF);
  drive(1,one(0),'0,0,'h444);
  drive(1,'0,'0,1,0,'0,'1,32'hFEDCBA98,3);
  drive(1,'0,'0,1,0,'0,'1,32'h76543210,2);
  drive(1,'0,'0,1,0,'0,'1,32'h22334455,1);
  reset_clean();
  for(int k=0;k<4;k++)drive(1,one(k%N),'0,0,'h500+k);
  drive(1,one(N-1),'0,0,'h510);
  drive(1,one(0),'0,1,'h511,'0,'1,32'hDEADBEEF,1);
  drive(1,one(1),'0,1,'h512,'0,'1,32'hBEEFCAFE,2);
  for(int k=0;k<5;k++)drive(1,'0,'0,1,0,'0,'1,$urandom(),2'(k));
  drive(0,'1,'0,1,'h678,'0,'1,32'h1A2B3C4D,3);
  drive(1,one(0),'0,0,'h679);drive(1,one(1),'0,0,'h67a);
  drive(1,'0,'0,1,0,'0,'1,32'h5E6F7081,1);
  for(int k=0;k<4;k++)drive(1,'0,'0,0,0,'0,'1,32'h19283746^(32'h10203040*k),2'(k));
  reset_clean();
  for(int k=0;k<1600;k++)begin
   if(k%N==0)begin
    block_req=$urandom();block_wr=$urandom();
    for(int p=0;p<N;p++)begin block_addr[p]=$urandom();block_wd[p]=$urandom();block_wm[p]=$urandom();end
   end
   @(negedge clk);
   rst_n=1;req=block_req;wr=block_wr;rv=($urandom_range(0,4)!=0);
   rd=$urandom();err=2'($urandom());
   for(int p=0;p<N;p++)begin addr[p]=block_addr[p];wd[p]=block_wd[p];wm[p]=block_wm[p];end
   #1;check_outputs();#1;
  end
  for(int k=0;k<8;k++)drive(1,'0,'0,k<4,0,'0,'1,$urandom(),2'(k));
  @(posedge clk);#2;
  $display("D_PROFILE_COMPLETE profile=%0d N=%0d MASK=%0d IMPL=%s comparisons=%0d mismatches=%0d",PROFILE,N,MASK,IMPL,comparisons,mismatches);
  done=1;
 end
endmodule
module replay;
 logic clk=0;always #5 clk=~clk;
 wire d0,d1,d2;
 wire[31:0] c0,c1,c2,m0,m1,m2;
 sram_d_profile #(.N(4),.MASK(0),.IMPL("PPC"),.PROFILE(0)) p0(clk,d0,c0,m0);
 sram_d_profile #(.N(4),.MASK(1),.IMPL("PPC"),.PROFILE(1)) p1(clk,d1,c1,m1);
 sram_d_profile #(.N(2),.MASK(1),.IMPL("BINTREE"),.PROFILE(2)) p2(clk,d2,c2,m2);
 initial begin
  wait(d0&&d1&&d2);
  $display("D_REPLAY_COMPLETE comparisons=%0d mismatches=%0d",c0+c1+c2,m0+m1+m2);
  $finish;
 end
endmodule
