`timescale 1ns/1ps
module dvbench_model(
input logic clk,
input logic rst_n,
input logic warpReq_valid_i,
input logic [6:0] warpReq_dispatch2cu_wf_tag_dispatch_i,
input logic [2:0] warpReq_wid_i,
input logic [31:0] warpReq_dispatch2cu_start_pc_dispatch_i,
input logic warpRsp_ready_i,
input logic [6:0] wg_id_tag_i,
input logic pc_rsp_valid_i,
input logic [31:0] pc_rsp_addr_i,
input logic [1:0] pc_rsp_mask_i,
input logic [2:0] pc_rsp_wid_i,
input logic pc_rsp_status_i,
input logic branch_valid_i,
input logic [2:0] branch_wid_i,
input logic branch_jump_i,
input logic [31:0] branch_new_pc_i,
input logic warp_control_valid_i,
input logic warp_control_simt_stack_op_i,
input logic [2:0] warp_control_wid_i,
input logic [7:0] scoreboard_busy_i,
input logic [7:0] ibuffer_ready_i,
output logic warpRsp_valid_o,
output logic [2:0] warpRsp_wid_o,
output logic [2:0] wg_id_lookup_o,
output logic pc_req_valid_o,
output logic [31:0] pc_req_addr_o,
output logic [1:0] pc_req_mask_o,
output logic [2:0] pc_req_wid_o,
output logic branch_ready_o,
output logic warp_control_ready_o,
output logic [7:0] warp_ready_o,
output logic flush_valid_o,
output logic [2:0] flush_wid_o,
output logic flushCache_valid_o,
output logic [2:0] flushCache_wid_o
);
logic [7:0] running,waiting,group_members[0:7];
logic [31:0] address[0:7],updated_address[0:7];
logic [1:0] lanes[0:7],updated_lanes[0:7];
logic [7:0] eligible;
logic [2:0] selected;
logic found,branch_accept,control_accept,ending;
integer population;
logic [31:0] target,aligned_target;
logic replay_selected;
always @* begin
eligible=running&ibuffer_ready_i;
selected=0;found=0;population=0;
for(integer bank=0;bank<8;bank++)begin
population=population+running[bank];
if(!found&&eligible[bank])begin selected=bank;found=1;end
end
flushCache_valid_o=pc_rsp_valid_i&&pc_rsp_status_i;
flushCache_wid_o=pc_rsp_wid_i;
branch_ready_o=!flushCache_valid_o;
branch_accept=branch_valid_i&&branch_ready_o;
warp_control_ready_o=!branch_accept&&!flushCache_valid_o;
control_accept=warp_control_valid_i&&warp_control_ready_o;
ending=control_accept&&warp_control_simt_stack_op_i;
warpRsp_valid_o=ending;warpRsp_wid_o=warp_control_wid_i;
wg_id_lookup_o=warp_control_wid_i;
flush_valid_o=(branch_accept&&branch_jump_i)||ending;
flush_wid_o=(branch_accept&&branch_jump_i)?branch_wid_i:warp_control_wid_i;
warp_ready_o=running&~waiting&~scoreboard_busy_i;
pc_req_wid_o=selected;pc_req_addr_o=address[selected];pc_req_mask_o=lanes[selected];
pc_req_valid_o=eligible[selected]&&!(branch_accept&&branch_jump_i&&branch_wid_i==selected);
replay_selected=(eligible==0)&&((population>1)||(!pc_rsp_valid_i&&running==1));
for(integer bank=0;bank<8;bank++)begin
updated_address[bank]=address[bank];updated_lanes[bank]=lanes[bank];
target=0;
if(warpReq_valid_i&&warpReq_wid_i==bank)target=warpReq_dispatch2cu_start_pc_dispatch_i;
else if(pc_rsp_valid_i&&pc_rsp_status_i&&pc_rsp_wid_i==bank)target=pc_rsp_addr_i;
else if(branch_accept&&branch_jump_i&&branch_wid_i==bank)target=branch_new_pc_i;
else if(bank==selected&&replay_selected)target=address[selected];
aligned_target=target&32'hfffffff8;
if((warpReq_valid_i&&warpReq_wid_i==bank)||(branch_accept&&branch_jump_i&&branch_wid_i==bank))begin
updated_address[bank]=aligned_target;
updated_lanes[bank][0]=(aligned_target>=target);
updated_lanes[bank][1]=((aligned_target+32'd4)>=target);
end else if(pc_rsp_valid_i&&pc_rsp_status_i&&pc_rsp_wid_i==bank)begin
updated_address[bank]=target;updated_lanes[bank]=pc_rsp_mask_i;
end else if(bank==selected)begin
if(replay_selected)begin updated_address[bank]=address[selected];updated_lanes[bank]=lanes[selected];end
else begin updated_address[bank]=address[bank]+32'd8;updated_lanes[bank]=3;end
end
end
end
always @(posedge clk or negedge rst_n)begin
if(!rst_n)begin
running<=0;waiting<=0;
for(integer bank=0;bank<8;bank++)begin group_members[bank]<=0;address[bank]<=0;lanes[bank]<=0;end
end else begin
for(integer bank=0;bank<8;bank++)begin address[bank]<=updated_address[bank];lanes[bank]<=updated_lanes[bank];end
running<=(running|(warpReq_valid_i?(8'b1<<warpReq_wid_i):0))&~(ending?(8'b1<<warp_control_wid_i):0);
if(warpReq_valid_i)group_members[warpReq_dispatch2cu_wf_tag_dispatch_i[6:4]]<=group_members[warpReq_dispatch2cu_wf_tag_dispatch_i[6:4]]|(8'b1<<warpReq_wid_i);
else if(ending&&warpRsp_ready_i)group_members[wg_id_tag_i[6:4]]<=group_members[wg_id_tag_i[6:4]]&~(8'b1<<warp_control_wid_i);
if(control_accept&&!warp_control_simt_stack_op_i)begin
if((waiting|(8'b1<<warp_control_wid_i))==group_members[wg_id_tag_i[6:4]])waiting<=waiting&~group_members[wg_id_tag_i[6:4]];
else waiting<=waiting|(8'b1<<warp_control_wid_i);
end
end
end
endmodule
