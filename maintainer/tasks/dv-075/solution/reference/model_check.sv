module rdma_model_check #(parameter MB=16,BE="TRUE")(rdma_if p);
 import uvm_pkg::*;
 `include "uvm_macros.svh"
 wire cmd_ready,axi_m_arvalid,axi_m_rready,dout_tlast,dout_tvalid;
 wire [3:0] axi_m_arid,dout_tkeep; wire [31:0] axi_m_araddr,dout_tdata;
 wire [7:0] axi_m_arlen;wire [2:0] axi_m_arsize;wire [1:0] axi_m_arburst;
 dvbench_model #(.MAX_BURST(MB),.MEM_BIG_ENDIAN(BE),.STREAM_BIG_ENDIAN(BE)) predictor(
 .aclk(p.aclk),.aresetn(p.aresetn),.cmd_address(p.cmd_address),.cmd_bytes(p.cmd_bytes),.cmd_valid(p.cmd_valid),
 .axi_m_arready(p.axi_m_arready),.axi_m_rid(p.axi_m_rid),.axi_m_rdata(p.axi_m_rdata),.axi_m_rresp(p.axi_m_rresp),
 .axi_m_rlast(p.axi_m_rlast),.axi_m_rvalid(p.axi_m_rvalid),.dout_tready(p.dout_tready),
 .cmd_ready(cmd_ready),.axi_m_arvalid(axi_m_arvalid),.axi_m_rready(axi_m_rready),.dout_tlast(dout_tlast),.dout_tvalid(dout_tvalid),
 .axi_m_arid(axi_m_arid),.axi_m_araddr(axi_m_araddr),.axi_m_arlen(axi_m_arlen),.axi_m_arsize(axi_m_arsize),.axi_m_arburst(axi_m_arburst),.dout_tkeep(dout_tkeep),.dout_tdata(dout_tdata));
 int comparisons=0,errors=0; logic [31:0] mask;
 always @(negedge p.aclk) begin
  if(p.aresetn)begin
   mask=0;for(int j=0;j<4;j++)if(dout_tkeep[j])mask[8*j+:8]=255;
   comparisons++;
   if({cmd_ready,axi_m_arvalid,axi_m_rready,dout_tvalid} !== {p.cmd_ready,p.axi_m_arvalid,p.axi_m_rready,p.dout_tvalid} ||
      (axi_m_arvalid && {axi_m_arid,axi_m_araddr,axi_m_arlen,axi_m_arsize,axi_m_arburst} !== {p.axi_m_arid,p.axi_m_araddr,p.axi_m_arlen,p.axi_m_arsize,p.axi_m_arburst}) ||
      (dout_tvalid && {dout_tdata&mask,dout_tkeep,dout_tlast} !== {p.dout_tdata&mask,p.dout_tkeep,p.dout_tlast}))begin
     errors++;if(errors<8)`uvm_error("MODEL",$sformatf("native prediction mismatch at %0t control e=%b a=%b data e=%h/%h a=%h/%h",$time,{cmd_ready,axi_m_arvalid,axi_m_rready,dout_tvalid},{p.cmd_ready,p.axi_m_arvalid,p.axi_m_rready,p.dout_tvalid},dout_tdata,dout_tkeep,p.dout_tdata,p.dout_tkeep))
   end
  end
 end
 final $display("MODEL_POINTS %m %0d %0d",comparisons,errors);
endmodule
