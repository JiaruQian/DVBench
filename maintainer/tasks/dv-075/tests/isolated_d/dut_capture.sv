`timescale 1ns/1ps
module isolated_d;
logic aclk=0;always #2 aclk=~aclk;
logic aresetn;
logic [31:0] cmd_address;
logic [31:0] cmd_bytes;
logic cmd_valid;
logic axi_m_arready;
logic [3:0] axi_m_rid;
logic [31:0] axi_m_rdata;
logic [1:0] axi_m_rresp;
logic axi_m_rlast;
logic axi_m_rvalid;
logic dout_tready;
logic cmd_ready;
logic [3:0] axi_m_arid;
logic [31:0] axi_m_araddr;
logic [7:0] axi_m_arlen;
logic [2:0] axi_m_arsize;
logic [1:0] axi_m_arburst;
logic axi_m_arvalid;
logic axi_m_rready;
logic [31:0] dout_tdata;
logic [3:0] dout_tkeep;
logic dout_tlast;
logic dout_tvalid;
axi_rdma #(.MAX_BURST(16)) target(.aclk(aclk),.aresetn(aresetn),.cmd_address(cmd_address),.cmd_bytes(cmd_bytes),.cmd_valid(cmd_valid),.axi_m_arready(axi_m_arready),.axi_m_rid(axi_m_rid),.axi_m_rdata(axi_m_rdata),.axi_m_rresp(axi_m_rresp),.axi_m_rlast(axi_m_rlast),.axi_m_rvalid(axi_m_rvalid),.dout_tready(dout_tready),.cmd_ready(cmd_ready),.axi_m_arid(axi_m_arid),.axi_m_araddr(axi_m_araddr),.axi_m_arlen(axi_m_arlen),.axi_m_arsize(axi_m_arsize),.axi_m_arburst(axi_m_arburst),.axi_m_arvalid(axi_m_arvalid),.axi_m_rready(axi_m_rready),.dout_tdata(dout_tdata),.dout_tkeep(dout_tkeep),.dout_tlast(dout_tlast),.dout_tvalid(dout_tvalid));
integer h,tr;integer cycles=0;
initial begin h=$fopen("replay.history","w");tr=$fopen("replay.trace","w");end
always @(posedge aclk) begin
 #1;
 $fwrite(h,"%h %h %h %h %h %h %h %h %h %h %h\n",aresetn,cmd_address,cmd_bytes,cmd_valid,axi_m_arready,axi_m_rid,axi_m_rdata,axi_m_rresp,axi_m_rlast,axi_m_rvalid,dout_tready);
 $fwrite(tr,"%h %h %h %h %h %h %h %h %h %h %h %h\n",cmd_ready,axi_m_arid,axi_m_araddr,axi_m_arlen,axi_m_arsize,axi_m_arburst,axi_m_arvalid,axi_m_rready,dout_tdata,dout_tkeep,dout_tlast,dout_tvalid);
 cycles++;
 if(cycles>=18000)begin $display("NATIVE_TEST_PASS D_CAPTURE %0d",cycles);$finish;end
end
int seed,junk;int watchdog;int remaining,offset;
initial begin
 seed=1;junk=$value$plusargs("ntb_random_seed=%d",seed);junk=$urandom(seed);
 aresetn=0;cmd_address=0;cmd_bytes=0;cmd_valid=0;axi_m_arready=0;
 axi_m_rid=0;axi_m_rdata=0;axi_m_rresp=0;axi_m_rlast=0;axi_m_rvalid=0;dout_tready=1;
 repeat(4)@(negedge aclk);aresetn=1;
 for(int k=0;k<48;k++)begin
  while(!cmd_ready)@(negedge aclk);
  cmd_address=32'h3000+(k%4);cmd_bytes=(k<16)?k:(k==16?1025:($urandom_range(1,90)));
  cmd_valid=1;@(negedge aclk);cmd_valid=0;
  repeat(280)@(negedge aclk);
  if(k%9==8)begin aresetn=0;repeat(4)@(negedge aclk);aresetn=1;end
 end
end
int pending=0;int recv=0;bit first=1;
always @(negedge aclk)begin
 if(!aresetn)begin axi_m_arready=0;axi_m_rvalid=0;pending=0;recv=0;end
 else begin
  axi_m_arready=($urandom_range(0,3)!=0);
  dout_tready=($urandom_range(0,4)!=0);
 end
end
always @(posedge aclk)begin
 if(aresetn)begin
  if(axi_m_arvalid&&axi_m_arready)pending+=axi_m_arlen+1;
  if(axi_m_rvalid&&axi_m_rready)begin pending--;recv++;end
 end
end
// Drive R on the falling edge, keeping stalled payload invariant.
always @(negedge aclk)begin
 if(aresetn)begin
  if(!axi_m_rvalid||first)begin
   axi_m_rvalid=(pending>0)&&($urandom_range(0,3)!=0);
   axi_m_rdata=$urandom;axi_m_rresp=$urandom;axi_m_rid=$urandom;axi_m_rlast=$urandom;
  end
 end
end
always @(posedge aclk) first <= axi_m_rvalid&&axi_m_rready;
endmodule
