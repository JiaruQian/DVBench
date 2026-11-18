`timescale 1ns/1ps
// Abstract cache entries store only the externally observable 32-bit line word.
module dvbench_model #(parameter int TAG_WIDTH=20,INDEX_WIDTH=6,OFFSET_WIDTH=6)(
input logic clk_i,rst_ni,instr_req_i,input logic [31:0] instr_addr_i,
output logic instr_gnt_o,instr_rvalid_o,output logic [31:0] instr_rdata_o,
input logic flush_i,output logic flush_ack_o,mem_req_valid_o,output logic [31:0] mem_req_addr_o,
output logic [7:0] mem_req_len_o,output logic [2:0] mem_req_size_o,input logic mem_req_ack_i,mem_rsp_valid_i,
input logic [255:0] mem_rsp_data_i,input logic mem_rsp_last_i,output logic miss_o,miss_event_o);
logic [19:0] tags[64][4];logic [31:0] words[64][4];bit valid[64][4];
integer request_phase,flush_cursor;logic [19:0] accepted_tag;logic [31:0] refill_address;
// A global binary-tree recency policy, rather than a replica of the RTL tree module.
integer newer_half,newer_low,newer_high;
function automatic integer lookup();integer found;found=-1;for(int w=0;w<4;w++)if(valid[instr_addr_i[11:6]][w]&&tags[instr_addr_i[11:6]][w]==accepted_tag)found=w;return found;endfunction
function automatic integer victim();integer chosen;chosen=-1;for(int w=3;w>=0;w--)if(!valid[instr_addr_i[11:6]][w])chosen=w;if(chosen<0)chosen=(1-newer_half)*2+((1-newer_half)==0?(1-newer_low):(1-newer_high));return chosen;endfunction
always_comb begin
 instr_gnt_o=(request_phase==0);instr_rvalid_o=0;instr_rdata_o=0;flush_ack_o=0;mem_req_valid_o=0;mem_req_addr_o=0;mem_req_len_o=3;mem_req_size_o=3;miss_o=0;miss_event_o=0;
 if(request_phase==1)begin
  if(lookup()>=0)begin instr_rvalid_o=1;instr_rdata_o=words[instr_addr_i[11:6]][lookup()];end
  else begin mem_req_valid_o=1;mem_req_addr_o=instr_addr_i;miss_o=1;miss_event_o=1;end
 end
 if(request_phase==2&&mem_rsp_valid_i)begin instr_rvalid_o=1;instr_rdata_o=mem_rsp_data_i[31:0];end
 if(request_phase==3&&flush_cursor==63)flush_ack_o=1;
end
always @(posedge clk_i or negedge rst_ni)begin : events
 integer h,v,next_phase,used;h=lookup();v=victim();used=h;
 if(!rst_ni)begin
  request_phase=0;flush_cursor=0;accepted_tag=0;refill_address=0;newer_half=1;newer_low=1;newer_high=1;
  for(int s=0;s<64;s++)for(int w=0;w<4;w++)begin tags[s][w]=0;words[s][w]=0;valid[s][w]=0;end
 end else begin
  next_phase=request_phase;
  if(request_phase==0)begin if(instr_req_i)next_phase=1;end
  if(request_phase==1)begin if(h>=0)next_phase=0;else if(mem_req_ack_i)next_phase=2;end
  if(request_phase==2&&mem_rsp_valid_i)begin
   next_phase=0;used=v;tags[refill_address[11:6]][v]=refill_address[31:12];words[refill_address[11:6]][v]=mem_rsp_data_i[31:0];valid[refill_address[11:6]][v]=1;
  end
  if(request_phase==3)begin
   for(int w=0;w<4;w++)valid[flush_cursor][w]=0;
   if(flush_cursor==63)next_phase=0;else flush_cursor=1-(flush_cursor%2);
  end
  if(used>=0)begin newer_half=used/2;if(used<2)newer_low=used%2;else newer_high=used%2;end
  if(request_phase==1&&h<0)refill_address=instr_addr_i;
  if(request_phase==0&&instr_req_i)accepted_tag=instr_addr_i[31:12];
  if(flush_i&&request_phase!=3)next_phase=3;
  request_phase=next_phase;
 end
end
endmodule
