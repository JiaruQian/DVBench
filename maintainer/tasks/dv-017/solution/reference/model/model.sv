`timescale 1ns/1ps
// v1 abstract rotating priority and accepted-read owner history.
// No dependency on actual DUT outputs or implementation modules.
module dvbench_model #(
 parameter int unsigned N=4,SramDw=32,SramAw=12,
 parameter ArbiterImpl="PPC", parameter bit EnMask=0
)(
 input clk_i,rst_ni,
 input [N-1:0] req_i,
 input [SramAw-1:0] req_addr_i[N],
 input [N-1:0] req_write_i,
 input [SramDw-1:0] req_wdata_i[N],req_wmask_i[N],
 output logic [N-1:0] gnt_o,rsp_rvalid_o,
 output logic [SramDw-1:0] rsp_rdata_o[N],
 output logic [1:0] rsp_error_o[N],
 output logic sram_req_o,
 output logic [SramAw-1:0] sram_addr_o,
 output logic sram_write_o,
 output logic [SramDw-1:0] sram_wdata_o,sram_wmask_o,
 input sram_rvalid_i,
 input [SramDw-1:0] sram_rdata_i,
 input [1:0] sram_rerror_i
);
 int unsigned next_priority,pending;
 logic warmup;
 logic [N-1:0] owners[4];
 int winner,payload_index,candidate;
 logic push_owner,pop_owner;
 always_comb begin
  winner=-1; candidate=0;
  for(int k=0;k<N;k++) begin
   candidate=(next_priority+k)%N;
   if(winner<0 && req_i[candidate]) winner=candidate;
  end
  gnt_o='0; sram_req_o=|req_i;
  if(winner>=0) gnt_o[winner]=1;
  payload_index=winner;
  if(winner<0) begin
   if(N==1) payload_index=0;
   else if(ArbiterImpl=="BINTREE" && (N&(N-1))==0) payload_index=N-1;
  end
  sram_addr_o='0;sram_write_o=0;sram_wdata_o='0;
  sram_wmask_o=EnMask?'0:'1;
  if(payload_index>=0) begin
   sram_addr_o=req_addr_i[payload_index];
   sram_write_o=req_write_i[payload_index];
   sram_wdata_o=req_wdata_i[payload_index];
   sram_wmask_o=EnMask?req_wmask_i[payload_index]:'1;
  end
  rsp_rvalid_o='0;
  if(pending!=0 && sram_rvalid_i) rsp_rvalid_o=owners[0];
  for(int p=0;p<N;p++) begin
   rsp_rdata_o[p]=sram_rdata_i;rsp_error_o[p]=sram_rerror_i;
  end
  push_owner=winner>=0 && !sram_write_o && pending<4 && !warmup;
  pop_owner=pending!=0 && sram_rvalid_i && !warmup;
 end
 always @(posedge clk_i or negedge rst_ni) begin
  if(!rst_ni) begin
   next_priority<=0;pending<=0;warmup<=1;
   for(int j=0;j<4;j++) owners[j]<='0;
  end else begin
   warmup<=0;
   if(winner>=0) next_priority<=(winner+1)%N;
   if(pop_owner) for(int j=0;j<3;j++) owners[j]<=owners[j+1];
   if(push_owner) owners[pending-(pop_owner?1:0)]<=gnt_o;
   case({push_owner,pop_owner})
    2'b10:pending<=pending+1;
    2'b01:pending<=pending-1;
    default:pending<=pending;
   endcase
  end
 end
endmodule
