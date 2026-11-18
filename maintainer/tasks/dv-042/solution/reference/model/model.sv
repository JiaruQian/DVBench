`timescale 1ns/1ps
module dvbench_model(
input logic clk,rst_n,
input logic [31:0] ctrl_inst_i,
input logic [1:0] ctrl_csr_i,
input logic ctrl_custom_signal_0_i,ctrl_isvec_i,
input logic [7:0] ctrl_reg_idxw_i,
input logic ctrl_wxd_i,
input logic [2:0] ctrl_wid_i,
input logic in_valid_i,out_ready_i,
input logic [31:0] in1_i,
input logic [8:0] rm_wid_i,
input logic [2:0] lsu_wid_i,simt_wid_i,
input logic CTA2csr_valid_i,
input logic [3:0] dispatch2cu_wg_wf_count_i,
input logic [9:0] dispatch2cu_wf_size_dispatch_i,
input logic [10:0] dispatch2cu_sgpr_base_dispatch_i,dispatch2cu_vgpr_base_dispatch_i,
input logic [6:0] dispatch2cu_wf_tag_dispatch_i,
input logic [17:0] dispatch2cu_lds_base_dispatch_i,
input logic [31:0] dispatch2cu_pds_base_dispatch_i,dispatch2cu_csr_knl_dispatch_i,
input logic [9:0] dispatch2cu_wgid_x_dispatch_i,dispatch2cu_wgid_y_dispatch_i,dispatch2cu_wgid_z_dispatch_i,
input logic [31:0] dispatch2cu_wg_id_i,
input logic [2:0] wid_i,
output logic in_ready_o,out_valid_o,
output logic [31:0] wb_wxd_rd_o,
output logic wxd_o,
output logic [7:0] reg_idxw_o,
output logic [2:0] warp_id_o,
output logic [8:0] rm_o,
output logic [87:0] sgpr_base_o,vgpr_base_o,
output logic [31:0] lsu_tid_o,lsu_pds_o,lsu_numw_o,simt_rpc_o
);
logic [31:0] values [0:7][0:24];
logic [10:0] scalar_base [0:7],vector_base [0:7];
logic occupied,vector_initialized;
integer selected_address;
logic [31:0] old_value,new_value,result_value;
logic accepted,writes;

function automatic integer slot(input logic [11:0] address);
case(address)
12'h300:slot=0;12'h304:slot=1;12'h305:slot=2;
12'h340:slot=3;12'h341:slot=4;12'h342:slot=5;12'h343:slot=6;12'h344:slot=7;
12'h002:slot=8;12'h003:slot=9;12'h001:slot=10;12'hc21:slot=11;
12'h800:slot=12;12'h801:slot=13;12'h802:slot=14;12'h803:slot=15;
12'h804:slot=16;12'h805:slot=17;12'h806:slot=18;12'h807:slot=19;
12'h808:slot=20;12'h809:slot=21;12'h80a:slot=22;12'h80b:slot=23;12'h80c:slot=24;
default:slot=-1;
endcase
endfunction

always @* begin
in_ready_o=(!occupied||out_ready_i)&&!CTA2csr_valid_i;
out_valid_o=occupied;
accepted=in_valid_i&&in_ready_o;
writes=accepted&&(ctrl_csr_i!=0);
selected_address=slot(ctrl_inst_i[31:20]);
old_value=0;
if(selected_address>=0)old_value=values[ctrl_wid_i][selected_address];
if(selected_address==9)old_value=(values[ctrl_wid_i][8]<<5)|values[ctrl_wid_i][10];
case(ctrl_csr_i)
1:new_value=in1_i;
2:new_value=old_value|in1_i;
3:new_value=old_value&~in1_i;
default:new_value=0;
endcase
result_value=old_value;
if(writes&&ctrl_custom_signal_0_i)result_value=in1_i;
else if(writes&&ctrl_isvec_i)result_value=vector_initialized?((in1_i<4)?in1_i:4):0;
for(integer bank=0;bank<8;bank++)begin
sgpr_base_o[bank*11+:11]=scalar_base[bank];
vgpr_base_o[bank*11+:11]=vector_base[bank];
end
for(integer query=0;query<3;query++)rm_o[query*3+:3]=values[rm_wid_i[query*3+:3]][8][2:0];
lsu_tid_o=values[lsu_wid_i][17]*4;
lsu_pds_o=values[lsu_wid_i][19];
lsu_numw_o=values[lsu_wid_i][13];
simt_rpc_o=values[simt_wid_i][24];
end

always @(posedge clk or negedge rst_n)begin
if(!rst_n)begin
occupied<=0;vector_initialized<=0;
wb_wxd_rd_o<=0;wxd_o<=0;reg_idxw_o<=0;warp_id_o<=0;
for(integer bank=0;bank<8;bank++)begin
scalar_base[bank]<=0;vector_base[bank]<=0;
for(integer entry=0;entry<25;entry++)values[bank][entry]<=0;
end
end else begin
vector_initialized<=1;
for(integer bank=0;bank<8;bank++)begin
values[bank][0]<=values[bank][0]|32'h1800;
values[bank][11]<=32'h10;
end
if(occupied&&out_ready_i)occupied<=0;
if(accepted)begin
occupied<=1;wb_wxd_rd_o<=result_value;wxd_o<=ctrl_wxd_i;
reg_idxw_o<=ctrl_reg_idxw_i;warp_id_o<=ctrl_wid_i;
end
if(writes)begin
if(ctrl_custom_signal_0_i)values[ctrl_wid_i][24]<=in1_i;
case(selected_address)
0:values[ctrl_wid_i][0]<=(new_value&32'h88)|32'h1800;
1,7:values[ctrl_wid_i][selected_address]<=new_value&32'h888;
3,4,5,6:values[ctrl_wid_i][selected_address]<=new_value;
8:values[ctrl_wid_i][8]<=new_value&7;
10:values[ctrl_wid_i][10]<=new_value&31;
23:if(!ctrl_custom_signal_0_i)values[ctrl_wid_i][23]<=new_value;
default:begin end
endcase
end
if(CTA2csr_valid_i)begin
values[wid_i][12]<={27'b0,dispatch2cu_wf_tag_dispatch_i[2:0],2'b0};
values[wid_i][13]<=dispatch2cu_wg_wf_count_i;
values[wid_i][14]<=dispatch2cu_wf_size_dispatch_i;
values[wid_i][15]<=dispatch2cu_csr_knl_dispatch_i;
values[wid_i][16]<=dispatch2cu_wg_id_i;
values[wid_i][17]<=dispatch2cu_wf_tag_dispatch_i[2:0];
values[wid_i][18]<=32'h70000000|dispatch2cu_lds_base_dispatch_i;
values[wid_i][19]<=dispatch2cu_pds_base_dispatch_i;
values[wid_i][20]<=dispatch2cu_wgid_x_dispatch_i;
values[wid_i][21]<=dispatch2cu_wgid_y_dispatch_i;
values[wid_i][22]<=dispatch2cu_wgid_z_dispatch_i;
scalar_base[wid_i]<=dispatch2cu_sgpr_base_dispatch_i;
vector_base[wid_i]<=dispatch2cu_vgpr_base_dispatch_i;
end
end
end
endmodule
