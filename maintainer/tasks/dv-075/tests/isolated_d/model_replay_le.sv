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
dvbench_model #(.MAX_BURST(256),.MEM_BIG_ENDIAN("FALSE"),.STREAM_BIG_ENDIAN("FALSE")) target(.aclk(aclk),.aresetn(aresetn),.cmd_address(cmd_address),.cmd_bytes(cmd_bytes),.cmd_valid(cmd_valid),.axi_m_arready(axi_m_arready),.axi_m_rid(axi_m_rid),.axi_m_rdata(axi_m_rdata),.axi_m_rresp(axi_m_rresp),.axi_m_rlast(axi_m_rlast),.axi_m_rvalid(axi_m_rvalid),.dout_tready(dout_tready),.cmd_ready(cmd_ready),.axi_m_arid(axi_m_arid),.axi_m_araddr(axi_m_araddr),.axi_m_arlen(axi_m_arlen),.axi_m_arsize(axi_m_arsize),.axi_m_arburst(axi_m_arburst),.axi_m_arvalid(axi_m_arvalid),.axi_m_rready(axi_m_rready),.dout_tdata(dout_tdata),.dout_tkeep(dout_tkeep),.dout_tlast(dout_tlast),.dout_tvalid(dout_tvalid));
integer fd,tr,rc;initial begin
 fd=$fopen("events.history","r");tr=$fopen("replay.trace","w");
 while(!$feof(fd))begin
 rc=$fscanf(fd,"%h %h %h %h %h %h %h %h %h %h %h\n",aresetn,cmd_address,cmd_bytes,cmd_valid,axi_m_arready,axi_m_rid,axi_m_rdata,axi_m_rresp,axi_m_rlast,axi_m_rvalid,dout_tready);
 if(rc!=11)break;
 @(posedge aclk);#1;
 $fwrite(tr,"%h %h %h %h %h %h %h %h %h %h %h %h\n",cmd_ready,axi_m_arid,axi_m_araddr,axi_m_arlen,axi_m_arsize,axi_m_arburst,axi_m_arvalid,axi_m_rready,dout_tdata,dout_tkeep,dout_tlast,dout_tvalid);
 @(negedge aclk);
 end
 $display("NATIVE_TEST_PASS MODEL_REPLAY");$finish;
end
endmodule
