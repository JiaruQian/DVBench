`timescale 1ns/1ps
module dvbench_model #(parameter BUFFER_WIDTH=159,parameter SIZE_IBUFFER=2,parameter NUM_FETCH=2)(
input logic clk,
input logic rst_n,
input logic ibuffer_in_valid_i,
input logic [1:0] ibuffer_in_control_mask_i,
input logic ibuffer_flush_wid_valid_i,
input logic [2:0] ibuffer_flush_wid_i,
input logic [7:0] ibuffer2issue_io_in_ready_i,
input logic [7:0] warp_sche_io_warp_ready_i,
input logic [7:0] ibuffer2issue_grant_i,
input logic [63:0] ibuffer_in_control_Signals_inst_i,
input logic [5:0] ibuffer_in_control_Signals_wid_i,
input logic [1:0] ibuffer_in_control_Signals_fp_i,
input logic [3:0] ibuffer_in_control_Signals_branch_i,
input logic [1:0] ibuffer_in_control_Signals_simt_stack_i,
input logic [1:0] ibuffer_in_control_Signals_simt_stack_op_i,
input logic [1:0] ibuffer_in_control_Signals_barrier_i,
input logic [3:0] ibuffer_in_control_Signals_csr_i,
input logic [1:0] ibuffer_in_control_Signals_reverse_i,
input logic [3:0] ibuffer_in_control_Signals_sel_alu2_i,
input logic [3:0] ibuffer_in_control_Signals_sel_alu1_i,
input logic [3:0] ibuffer_in_control_Signals_sel_alu3_i,
input logic [1:0] ibuffer_in_control_Signals_isvec_i,
input logic [1:0] ibuffer_in_control_Signals_mask_i,
input logic [7:0] ibuffer_in_control_Signals_sel_imm_i,
input logic [3:0] ibuffer_in_control_Signals_mem_whb_i,
input logic [1:0] ibuffer_in_control_Signals_mem_unsigned_i,
input logic [11:0] ibuffer_in_control_Signals_alu_fn_i,
input logic [1:0] ibuffer_in_control_Signals_force_rm_rtz_i,
input logic [1:0] ibuffer_in_control_Signals_is_vls12_i,
input logic [1:0] ibuffer_in_control_Signals_mem_i,
input logic [1:0] ibuffer_in_control_Signals_mul_i,
input logic [1:0] ibuffer_in_control_Signals_tc_i,
input logic [1:0] ibuffer_in_control_Signals_disable_mask_i,
input logic [1:0] ibuffer_in_control_Signals_custom_signal_0_i,
input logic [3:0] ibuffer_in_control_Signals_mem_cmd_i,
input logic [3:0] ibuffer_in_control_Signals_mop_i,
input logic [15:0] ibuffer_in_control_Signals_reg_idx1_i,
input logic [15:0] ibuffer_in_control_Signals_reg_idx2_i,
input logic [15:0] ibuffer_in_control_Signals_reg_idx3_i,
input logic [15:0] ibuffer_in_control_Signals_reg_idxw_i,
input logic [1:0] ibuffer_in_control_Signals_wvd_i,
input logic [1:0] ibuffer_in_control_Signals_fence_i,
input logic [1:0] ibuffer_in_control_Signals_sfu_i,
input logic [1:0] ibuffer_in_control_Signals_readmask_i,
input logic [1:0] ibuffer_in_control_Signals_writemask_i,
input logic [1:0] ibuffer_in_control_Signals_wxd_i,
input logic [63:0] ibuffer_in_control_Signals_pc_i,
input logic [11:0] ibuffer_in_control_Signals_imm_ext_i,
input logic [1:0] ibuffer_in_control_Signals_atomic_i,
input logic [1:0] ibuffer_in_control_Signals_aq_i,
input logic [1:0] ibuffer_in_control_Signals_rl_i,
input logic [5:0] ibuffer_in_control_Signals_rm_i,
input logic [1:0] ibuffer_in_control_Signals_rm_is_static_i,
output logic ibuffer_in_ready_o,
output logic [7:0] ibuffer_ready_o,
output logic [7:0] ibuffer_out_valid_o,
output logic [255:0] ibuffer_warps_control_Signals_inst_o,
output logic [23:0] ibuffer_warps_control_Signals_wid_o,
output logic [7:0] ibuffer_warps_control_Signals_fp_o,
output logic [15:0] ibuffer_warps_control_Signals_branch_o,
output logic [7:0] ibuffer_warps_control_Signals_simt_stack_o,
output logic [7:0] ibuffer_warps_control_Signals_simt_stack_op_o,
output logic [7:0] ibuffer_warps_control_Signals_barrier_o,
output logic [15:0] ibuffer_warps_control_Signals_csr_o,
output logic [7:0] ibuffer_warps_control_Signals_reverse_o,
output logic [15:0] ibuffer_warps_control_Signals_sel_alu2_o,
output logic [15:0] ibuffer_warps_control_Signals_sel_alu1_o,
output logic [15:0] ibuffer_warps_control_Signals_sel_alu3_o,
output logic [7:0] ibuffer_warps_control_Signals_isvec_o,
output logic [7:0] ibuffer_warps_control_Signals_mask_o,
output logic [31:0] ibuffer_warps_control_Signals_sel_imm_o,
output logic [15:0] ibuffer_warps_control_Signals_mem_whb_o,
output logic [7:0] ibuffer_warps_control_Signals_mem_unsigned_o,
output logic [47:0] ibuffer_warps_control_Signals_alu_fn_o,
output logic [7:0] ibuffer_warps_control_Signals_force_rm_rtz_o,
output logic [7:0] ibuffer_warps_control_Signals_is_vls12_o,
output logic [7:0] ibuffer_warps_control_Signals_mem_o,
output logic [7:0] ibuffer_warps_control_Signals_mul_o,
output logic [7:0] ibuffer_warps_control_Signals_tc_o,
output logic [7:0] ibuffer_warps_control_Signals_disable_mask_o,
output logic [7:0] ibuffer_warps_control_Signals_custom_signal_0_o,
output logic [15:0] ibuffer_warps_control_Signals_mem_cmd_o,
output logic [15:0] ibuffer_warps_control_Signals_mop_o,
output logic [63:0] ibuffer_warps_control_Signals_reg_idx1_o,
output logic [63:0] ibuffer_warps_control_Signals_reg_idx2_o,
output logic [63:0] ibuffer_warps_control_Signals_reg_idx3_o,
output logic [63:0] ibuffer_warps_control_Signals_reg_idxw_o,
output logic [7:0] ibuffer_warps_control_Signals_wvd_o,
output logic [7:0] ibuffer_warps_control_Signals_fence_o,
output logic [7:0] ibuffer_warps_control_Signals_sfu_o,
output logic [7:0] ibuffer_warps_control_Signals_readmask_o,
output logic [7:0] ibuffer_warps_control_Signals_wxd_o,
output logic [255:0] ibuffer_warps_control_Signals_pc_o,
output logic [47:0] ibuffer_warps_control_Signals_imm_ext_o,
output logic [7:0] ibuffer_warps_control_Signals_atomic_o,
output logic [7:0] ibuffer_warps_control_Signals_aq_o,
output logic [7:0] ibuffer_warps_control_Signals_rl_o,
output logic [23:0] ibuffer_warps_control_Signals_rm_o,
output logic [7:0] ibuffer_warps_control_Signals_rm_is_static_o
);
logic [1:0] pending_count [0:7],eligible_lanes [0:7],queued_validity [0:7][0:1];
logic [7:0] take_head,accept_pair,downstream;
logic [63:0] pending_inst [0:7][0:1],active_inst [0:7];
logic [5:0] pending_wid [0:7][0:1],active_wid [0:7];
logic [1:0] pending_fp [0:7][0:1],active_fp [0:7];
logic [3:0] pending_branch [0:7][0:1],active_branch [0:7];
logic [1:0] pending_simt_stack [0:7][0:1],active_simt_stack [0:7];
logic [1:0] pending_simt_stack_op [0:7][0:1],active_simt_stack_op [0:7];
logic [1:0] pending_barrier [0:7][0:1],active_barrier [0:7];
logic [3:0] pending_csr [0:7][0:1],active_csr [0:7];
logic [1:0] pending_reverse [0:7][0:1],active_reverse [0:7];
logic [3:0] pending_sel_alu2 [0:7][0:1],active_sel_alu2 [0:7];
logic [3:0] pending_sel_alu1 [0:7][0:1],active_sel_alu1 [0:7];
logic [3:0] pending_sel_alu3 [0:7][0:1],active_sel_alu3 [0:7];
logic [1:0] pending_isvec [0:7][0:1],active_isvec [0:7];
logic [1:0] pending_mask [0:7][0:1],active_mask [0:7];
logic [7:0] pending_sel_imm [0:7][0:1],active_sel_imm [0:7];
logic [3:0] pending_mem_whb [0:7][0:1],active_mem_whb [0:7];
logic [1:0] pending_mem_unsigned [0:7][0:1],active_mem_unsigned [0:7];
logic [11:0] pending_alu_fn [0:7][0:1],active_alu_fn [0:7];
logic [1:0] pending_force_rm_rtz [0:7][0:1],active_force_rm_rtz [0:7];
logic [1:0] pending_is_vls12 [0:7][0:1],active_is_vls12 [0:7];
logic [1:0] pending_mem [0:7][0:1],active_mem [0:7];
logic [1:0] pending_mul [0:7][0:1],active_mul [0:7];
logic [1:0] pending_tc [0:7][0:1],active_tc [0:7];
logic [1:0] pending_disable_mask [0:7][0:1],active_disable_mask [0:7];
logic [1:0] pending_custom_signal_0 [0:7][0:1],active_custom_signal_0 [0:7];
logic [3:0] pending_mem_cmd [0:7][0:1],active_mem_cmd [0:7];
logic [3:0] pending_mop [0:7][0:1],active_mop [0:7];
logic [15:0] pending_reg_idx1 [0:7][0:1],active_reg_idx1 [0:7];
logic [15:0] pending_reg_idx2 [0:7][0:1],active_reg_idx2 [0:7];
logic [15:0] pending_reg_idx3 [0:7][0:1],active_reg_idx3 [0:7];
logic [15:0] pending_reg_idxw [0:7][0:1],active_reg_idxw [0:7];
logic [1:0] pending_wvd [0:7][0:1],active_wvd [0:7];
logic [1:0] pending_fence [0:7][0:1],active_fence [0:7];
logic [1:0] pending_sfu [0:7][0:1],active_sfu [0:7];
logic [1:0] pending_readmask [0:7][0:1],active_readmask [0:7];
logic [1:0] pending_wxd [0:7][0:1],active_wxd [0:7];
logic [63:0] pending_pc [0:7][0:1],active_pc [0:7];
logic [11:0] pending_imm_ext [0:7][0:1],active_imm_ext [0:7];
logic [1:0] pending_atomic [0:7][0:1],active_atomic [0:7];
logic [1:0] pending_aq [0:7][0:1],active_aq [0:7];
logic [1:0] pending_rl [0:7][0:1],active_rl [0:7];
logic [5:0] pending_rm [0:7][0:1],active_rm [0:7];
logic [1:0] pending_rm_is_static [0:7][0:1],active_rm_is_static [0:7];
always @* begin
ibuffer_in_ready_o=(pending_count[ibuffer_in_control_Signals_wid_i[2:0]]<2);
for(integer bank=0;bank<8;bank++)begin
ibuffer_ready_o[bank]=(pending_count[bank]<2);
ibuffer_out_valid_o[bank]=(eligible_lanes[bank]!=0);
downstream[bank]=ibuffer2issue_io_in_ready_i[bank]&&warp_sche_io_warp_ready_i[bank];
take_head[bank]=(eligible_lanes[bank]==0)&&downstream[bank]&&(pending_count[bank]>0);
accept_pair[bank]=ibuffer_in_valid_i&&ibuffer_in_ready_o&&(ibuffer_in_control_Signals_wid_i[2:0]==bank);
ibuffer_warps_control_Signals_inst_o[bank*32+:32]=active_inst[bank][(eligible_lanes[bank]==2?32:0)+:32];
ibuffer_warps_control_Signals_wid_o[bank*3+:3]=active_wid[bank][(eligible_lanes[bank]==2?3:0)+:3];
ibuffer_warps_control_Signals_fp_o[bank*1+:1]=active_fp[bank][(eligible_lanes[bank]==2?1:0)+:1];
ibuffer_warps_control_Signals_branch_o[bank*2+:2]=active_branch[bank][(eligible_lanes[bank]==2?2:0)+:2];
ibuffer_warps_control_Signals_simt_stack_o[bank*1+:1]=active_simt_stack[bank][(eligible_lanes[bank]==2?1:0)+:1];
ibuffer_warps_control_Signals_simt_stack_op_o[bank*1+:1]=active_simt_stack_op[bank][(eligible_lanes[bank]==2?1:0)+:1];
ibuffer_warps_control_Signals_barrier_o[bank*1+:1]=active_barrier[bank][(eligible_lanes[bank]==2?1:0)+:1];
ibuffer_warps_control_Signals_csr_o[bank*2+:2]=active_csr[bank][(eligible_lanes[bank]==2?2:0)+:2];
ibuffer_warps_control_Signals_reverse_o[bank*1+:1]=active_reverse[bank][(eligible_lanes[bank]==2?1:0)+:1];
ibuffer_warps_control_Signals_sel_alu2_o[bank*2+:2]=active_sel_alu2[bank][(eligible_lanes[bank]==2?2:0)+:2];
ibuffer_warps_control_Signals_sel_alu1_o[bank*2+:2]=active_sel_alu1[bank][(eligible_lanes[bank]==2?2:0)+:2];
ibuffer_warps_control_Signals_sel_alu3_o[bank*2+:2]=active_sel_alu3[bank][(eligible_lanes[bank]==2?2:0)+:2];
ibuffer_warps_control_Signals_isvec_o[bank*1+:1]=active_isvec[bank][(eligible_lanes[bank]==2?1:0)+:1];
ibuffer_warps_control_Signals_mask_o[bank*1+:1]=active_mask[bank][(eligible_lanes[bank]==2?1:0)+:1];
ibuffer_warps_control_Signals_sel_imm_o[bank*4+:4]=active_sel_imm[bank][(eligible_lanes[bank]==2?4:0)+:4];
ibuffer_warps_control_Signals_mem_whb_o[bank*2+:2]=active_mem_whb[bank][(eligible_lanes[bank]==2?2:0)+:2];
ibuffer_warps_control_Signals_mem_unsigned_o[bank*1+:1]=active_mem_unsigned[bank][(eligible_lanes[bank]==2?1:0)+:1];
ibuffer_warps_control_Signals_alu_fn_o[bank*6+:6]=active_alu_fn[bank][(eligible_lanes[bank]==2?6:0)+:6];
ibuffer_warps_control_Signals_force_rm_rtz_o[bank*1+:1]=active_force_rm_rtz[bank][(eligible_lanes[bank]==2?1:0)+:1];
ibuffer_warps_control_Signals_is_vls12_o[bank*1+:1]=active_is_vls12[bank][(eligible_lanes[bank]==2?1:0)+:1];
ibuffer_warps_control_Signals_mem_o[bank*1+:1]=active_mem[bank][(eligible_lanes[bank]==2?1:0)+:1];
ibuffer_warps_control_Signals_mul_o[bank*1+:1]=active_mul[bank][(eligible_lanes[bank]==2?1:0)+:1];
ibuffer_warps_control_Signals_tc_o[bank*1+:1]=active_tc[bank][(eligible_lanes[bank]==2?1:0)+:1];
ibuffer_warps_control_Signals_disable_mask_o[bank*1+:1]=active_disable_mask[bank][(eligible_lanes[bank]==2?1:0)+:1];
ibuffer_warps_control_Signals_custom_signal_0_o[bank*1+:1]=active_custom_signal_0[bank][(eligible_lanes[bank]==2?1:0)+:1];
ibuffer_warps_control_Signals_mem_cmd_o[bank*2+:2]=active_mem_cmd[bank][(eligible_lanes[bank]==2?2:0)+:2];
ibuffer_warps_control_Signals_mop_o[bank*2+:2]=active_mop[bank][(eligible_lanes[bank]==2?2:0)+:2];
ibuffer_warps_control_Signals_reg_idx1_o[bank*8+:8]=active_reg_idx1[bank][(eligible_lanes[bank]==2?8:0)+:8];
ibuffer_warps_control_Signals_reg_idx2_o[bank*8+:8]=active_reg_idx2[bank][(eligible_lanes[bank]==2?8:0)+:8];
ibuffer_warps_control_Signals_reg_idx3_o[bank*8+:8]=active_reg_idx3[bank][(eligible_lanes[bank]==2?8:0)+:8];
ibuffer_warps_control_Signals_reg_idxw_o[bank*8+:8]=active_reg_idxw[bank][(eligible_lanes[bank]==2?8:0)+:8];
ibuffer_warps_control_Signals_wvd_o[bank*1+:1]=active_wvd[bank][(eligible_lanes[bank]==2?1:0)+:1];
ibuffer_warps_control_Signals_fence_o[bank*1+:1]=active_fence[bank][(eligible_lanes[bank]==2?1:0)+:1];
ibuffer_warps_control_Signals_sfu_o[bank*1+:1]=active_sfu[bank][(eligible_lanes[bank]==2?1:0)+:1];
ibuffer_warps_control_Signals_readmask_o[bank*1+:1]=active_readmask[bank][(eligible_lanes[bank]==2?1:0)+:1];
ibuffer_warps_control_Signals_wxd_o[bank*1+:1]=active_wxd[bank][(eligible_lanes[bank]==2?1:0)+:1];
ibuffer_warps_control_Signals_pc_o[bank*32+:32]=active_pc[bank][(eligible_lanes[bank]==2?32:0)+:32];
ibuffer_warps_control_Signals_imm_ext_o[bank*6+:6]=active_imm_ext[bank][(eligible_lanes[bank]==2?6:0)+:6];
ibuffer_warps_control_Signals_atomic_o[bank*1+:1]=active_atomic[bank][(eligible_lanes[bank]==2?1:0)+:1];
ibuffer_warps_control_Signals_aq_o[bank*1+:1]=active_aq[bank][(eligible_lanes[bank]==2?1:0)+:1];
ibuffer_warps_control_Signals_rl_o[bank*1+:1]=active_rl[bank][(eligible_lanes[bank]==2?1:0)+:1];
ibuffer_warps_control_Signals_rm_o[bank*3+:3]=active_rm[bank][(eligible_lanes[bank]==2?3:0)+:3];
ibuffer_warps_control_Signals_rm_is_static_o[bank*1+:1]=active_rm_is_static[bank][(eligible_lanes[bank]==2?1:0)+:1];
end
end
always @(posedge clk or negedge rst_n)begin
for(integer bank=0;bank<8;bank++)begin
if(!rst_n)begin
pending_count[bank]<=0;eligible_lanes[bank]<=0;queued_validity[bank][0]<=0;queued_validity[bank][1]<=0;
pending_inst[bank][0]<=0;pending_inst[bank][1]<=0;active_inst[bank]<=0;
pending_wid[bank][0]<=0;pending_wid[bank][1]<=0;active_wid[bank]<=0;
pending_fp[bank][0]<=0;pending_fp[bank][1]<=0;active_fp[bank]<=0;
pending_branch[bank][0]<=0;pending_branch[bank][1]<=0;active_branch[bank]<=0;
pending_simt_stack[bank][0]<=0;pending_simt_stack[bank][1]<=0;active_simt_stack[bank]<=0;
pending_simt_stack_op[bank][0]<=0;pending_simt_stack_op[bank][1]<=0;active_simt_stack_op[bank]<=0;
pending_barrier[bank][0]<=0;pending_barrier[bank][1]<=0;active_barrier[bank]<=0;
pending_csr[bank][0]<=0;pending_csr[bank][1]<=0;active_csr[bank]<=0;
pending_reverse[bank][0]<=0;pending_reverse[bank][1]<=0;active_reverse[bank]<=0;
pending_sel_alu2[bank][0]<=0;pending_sel_alu2[bank][1]<=0;active_sel_alu2[bank]<=0;
pending_sel_alu1[bank][0]<=0;pending_sel_alu1[bank][1]<=0;active_sel_alu1[bank]<=0;
pending_sel_alu3[bank][0]<=0;pending_sel_alu3[bank][1]<=0;active_sel_alu3[bank]<=0;
pending_isvec[bank][0]<=0;pending_isvec[bank][1]<=0;active_isvec[bank]<=0;
pending_mask[bank][0]<=0;pending_mask[bank][1]<=0;active_mask[bank]<=0;
pending_sel_imm[bank][0]<=0;pending_sel_imm[bank][1]<=0;active_sel_imm[bank]<=0;
pending_mem_whb[bank][0]<=0;pending_mem_whb[bank][1]<=0;active_mem_whb[bank]<=0;
pending_mem_unsigned[bank][0]<=0;pending_mem_unsigned[bank][1]<=0;active_mem_unsigned[bank]<=0;
pending_alu_fn[bank][0]<=0;pending_alu_fn[bank][1]<=0;active_alu_fn[bank]<=0;
pending_force_rm_rtz[bank][0]<=0;pending_force_rm_rtz[bank][1]<=0;active_force_rm_rtz[bank]<=0;
pending_is_vls12[bank][0]<=0;pending_is_vls12[bank][1]<=0;active_is_vls12[bank]<=0;
pending_mem[bank][0]<=0;pending_mem[bank][1]<=0;active_mem[bank]<=0;
pending_mul[bank][0]<=0;pending_mul[bank][1]<=0;active_mul[bank]<=0;
pending_tc[bank][0]<=0;pending_tc[bank][1]<=0;active_tc[bank]<=0;
pending_disable_mask[bank][0]<=0;pending_disable_mask[bank][1]<=0;active_disable_mask[bank]<=0;
pending_custom_signal_0[bank][0]<=0;pending_custom_signal_0[bank][1]<=0;active_custom_signal_0[bank]<=0;
pending_mem_cmd[bank][0]<=0;pending_mem_cmd[bank][1]<=0;active_mem_cmd[bank]<=0;
pending_mop[bank][0]<=0;pending_mop[bank][1]<=0;active_mop[bank]<=0;
pending_reg_idx1[bank][0]<=0;pending_reg_idx1[bank][1]<=0;active_reg_idx1[bank]<=0;
pending_reg_idx2[bank][0]<=0;pending_reg_idx2[bank][1]<=0;active_reg_idx2[bank]<=0;
pending_reg_idx3[bank][0]<=0;pending_reg_idx3[bank][1]<=0;active_reg_idx3[bank]<=0;
pending_reg_idxw[bank][0]<=0;pending_reg_idxw[bank][1]<=0;active_reg_idxw[bank]<=0;
pending_wvd[bank][0]<=0;pending_wvd[bank][1]<=0;active_wvd[bank]<=0;
pending_fence[bank][0]<=0;pending_fence[bank][1]<=0;active_fence[bank]<=0;
pending_sfu[bank][0]<=0;pending_sfu[bank][1]<=0;active_sfu[bank]<=0;
pending_readmask[bank][0]<=0;pending_readmask[bank][1]<=0;active_readmask[bank]<=0;
pending_wxd[bank][0]<=0;pending_wxd[bank][1]<=0;active_wxd[bank]<=0;
pending_pc[bank][0]<=0;pending_pc[bank][1]<=0;active_pc[bank]<=0;
pending_imm_ext[bank][0]<=0;pending_imm_ext[bank][1]<=0;active_imm_ext[bank]<=0;
pending_atomic[bank][0]<=0;pending_atomic[bank][1]<=0;active_atomic[bank]<=0;
pending_aq[bank][0]<=0;pending_aq[bank][1]<=0;active_aq[bank]<=0;
pending_rl[bank][0]<=0;pending_rl[bank][1]<=0;active_rl[bank]<=0;
pending_rm[bank][0]<=0;pending_rm[bank][1]<=0;active_rm[bank]<=0;
pending_rm_is_static[bank][0]<=0;pending_rm_is_static[bank][1]<=0;active_rm_is_static[bank]<=0;
end else if(ibuffer_flush_wid_valid_i&&ibuffer_flush_wid_i==bank)begin
pending_count[bank]<=0;eligible_lanes[bank]<=0;queued_validity[bank][0]<=0;queued_validity[bank][1]<=0;
pending_inst[bank][0]<=0;pending_inst[bank][1]<=0;active_inst[bank]<=0;
pending_wid[bank][0]<=0;pending_wid[bank][1]<=0;active_wid[bank]<=0;
pending_fp[bank][0]<=0;pending_fp[bank][1]<=0;active_fp[bank]<=0;
pending_branch[bank][0]<=0;pending_branch[bank][1]<=0;active_branch[bank]<=0;
pending_simt_stack[bank][0]<=0;pending_simt_stack[bank][1]<=0;active_simt_stack[bank]<=0;
pending_simt_stack_op[bank][0]<=0;pending_simt_stack_op[bank][1]<=0;active_simt_stack_op[bank]<=0;
pending_barrier[bank][0]<=0;pending_barrier[bank][1]<=0;active_barrier[bank]<=0;
pending_csr[bank][0]<=0;pending_csr[bank][1]<=0;active_csr[bank]<=0;
pending_reverse[bank][0]<=0;pending_reverse[bank][1]<=0;active_reverse[bank]<=0;
pending_sel_alu2[bank][0]<=0;pending_sel_alu2[bank][1]<=0;active_sel_alu2[bank]<=0;
pending_sel_alu1[bank][0]<=0;pending_sel_alu1[bank][1]<=0;active_sel_alu1[bank]<=0;
pending_sel_alu3[bank][0]<=0;pending_sel_alu3[bank][1]<=0;active_sel_alu3[bank]<=0;
pending_isvec[bank][0]<=0;pending_isvec[bank][1]<=0;active_isvec[bank]<=0;
pending_mask[bank][0]<=0;pending_mask[bank][1]<=0;active_mask[bank]<=0;
pending_sel_imm[bank][0]<=0;pending_sel_imm[bank][1]<=0;active_sel_imm[bank]<=0;
pending_mem_whb[bank][0]<=0;pending_mem_whb[bank][1]<=0;active_mem_whb[bank]<=0;
pending_mem_unsigned[bank][0]<=0;pending_mem_unsigned[bank][1]<=0;active_mem_unsigned[bank]<=0;
pending_alu_fn[bank][0]<=0;pending_alu_fn[bank][1]<=0;active_alu_fn[bank]<=0;
pending_force_rm_rtz[bank][0]<=0;pending_force_rm_rtz[bank][1]<=0;active_force_rm_rtz[bank]<=0;
pending_is_vls12[bank][0]<=0;pending_is_vls12[bank][1]<=0;active_is_vls12[bank]<=0;
pending_mem[bank][0]<=0;pending_mem[bank][1]<=0;active_mem[bank]<=0;
pending_mul[bank][0]<=0;pending_mul[bank][1]<=0;active_mul[bank]<=0;
pending_tc[bank][0]<=0;pending_tc[bank][1]<=0;active_tc[bank]<=0;
pending_disable_mask[bank][0]<=0;pending_disable_mask[bank][1]<=0;active_disable_mask[bank]<=0;
pending_custom_signal_0[bank][0]<=0;pending_custom_signal_0[bank][1]<=0;active_custom_signal_0[bank]<=0;
pending_mem_cmd[bank][0]<=0;pending_mem_cmd[bank][1]<=0;active_mem_cmd[bank]<=0;
pending_mop[bank][0]<=0;pending_mop[bank][1]<=0;active_mop[bank]<=0;
pending_reg_idx1[bank][0]<=0;pending_reg_idx1[bank][1]<=0;active_reg_idx1[bank]<=0;
pending_reg_idx2[bank][0]<=0;pending_reg_idx2[bank][1]<=0;active_reg_idx2[bank]<=0;
pending_reg_idx3[bank][0]<=0;pending_reg_idx3[bank][1]<=0;active_reg_idx3[bank]<=0;
pending_reg_idxw[bank][0]<=0;pending_reg_idxw[bank][1]<=0;active_reg_idxw[bank]<=0;
pending_wvd[bank][0]<=0;pending_wvd[bank][1]<=0;active_wvd[bank]<=0;
pending_fence[bank][0]<=0;pending_fence[bank][1]<=0;active_fence[bank]<=0;
pending_sfu[bank][0]<=0;pending_sfu[bank][1]<=0;active_sfu[bank]<=0;
pending_readmask[bank][0]<=0;pending_readmask[bank][1]<=0;active_readmask[bank]<=0;
pending_wxd[bank][0]<=0;pending_wxd[bank][1]<=0;active_wxd[bank]<=0;
pending_pc[bank][0]<=0;pending_pc[bank][1]<=0;active_pc[bank]<=0;
pending_imm_ext[bank][0]<=0;pending_imm_ext[bank][1]<=0;active_imm_ext[bank]<=0;
pending_atomic[bank][0]<=0;pending_atomic[bank][1]<=0;active_atomic[bank]<=0;
pending_aq[bank][0]<=0;pending_aq[bank][1]<=0;active_aq[bank]<=0;
pending_rl[bank][0]<=0;pending_rl[bank][1]<=0;active_rl[bank]<=0;
pending_rm[bank][0]<=0;pending_rm[bank][1]<=0;active_rm[bank]<=0;
pending_rm_is_static[bank][0]<=0;pending_rm_is_static[bank][1]<=0;active_rm_is_static[bank]<=0;
end else begin
case({accept_pair[bank],take_head[bank]})
2'b10:pending_count[bank]<=pending_count[bank]+1;
2'b01:pending_count[bank]<=pending_count[bank]-1;
default:begin end
endcase
if(take_head[bank])begin
eligible_lanes[bank]<=queued_validity[bank][0];
queued_validity[bank][0]<=queued_validity[bank][1];
active_inst[bank]<=pending_inst[bank][0];pending_inst[bank][0]<=pending_inst[bank][1];
active_wid[bank]<=pending_wid[bank][0];pending_wid[bank][0]<=pending_wid[bank][1];
active_fp[bank]<=pending_fp[bank][0];pending_fp[bank][0]<=pending_fp[bank][1];
active_branch[bank]<=pending_branch[bank][0];pending_branch[bank][0]<=pending_branch[bank][1];
active_simt_stack[bank]<=pending_simt_stack[bank][0];pending_simt_stack[bank][0]<=pending_simt_stack[bank][1];
active_simt_stack_op[bank]<=pending_simt_stack_op[bank][0];pending_simt_stack_op[bank][0]<=pending_simt_stack_op[bank][1];
active_barrier[bank]<=pending_barrier[bank][0];pending_barrier[bank][0]<=pending_barrier[bank][1];
active_csr[bank]<=pending_csr[bank][0];pending_csr[bank][0]<=pending_csr[bank][1];
active_reverse[bank]<=pending_reverse[bank][0];pending_reverse[bank][0]<=pending_reverse[bank][1];
active_sel_alu2[bank]<=pending_sel_alu2[bank][0];pending_sel_alu2[bank][0]<=pending_sel_alu2[bank][1];
active_sel_alu1[bank]<=pending_sel_alu1[bank][0];pending_sel_alu1[bank][0]<=pending_sel_alu1[bank][1];
active_sel_alu3[bank]<=pending_sel_alu3[bank][0];pending_sel_alu3[bank][0]<=pending_sel_alu3[bank][1];
active_isvec[bank]<=pending_isvec[bank][0];pending_isvec[bank][0]<=pending_isvec[bank][1];
active_mask[bank]<=pending_mask[bank][0];pending_mask[bank][0]<=pending_mask[bank][1];
active_sel_imm[bank]<=pending_sel_imm[bank][0];pending_sel_imm[bank][0]<=pending_sel_imm[bank][1];
active_mem_whb[bank]<=pending_mem_whb[bank][0];pending_mem_whb[bank][0]<=pending_mem_whb[bank][1];
active_mem_unsigned[bank]<=pending_mem_unsigned[bank][0];pending_mem_unsigned[bank][0]<=pending_mem_unsigned[bank][1];
active_alu_fn[bank]<=pending_alu_fn[bank][0];pending_alu_fn[bank][0]<=pending_alu_fn[bank][1];
active_force_rm_rtz[bank]<=pending_force_rm_rtz[bank][0];pending_force_rm_rtz[bank][0]<=pending_force_rm_rtz[bank][1];
active_is_vls12[bank]<=pending_is_vls12[bank][0];pending_is_vls12[bank][0]<=pending_is_vls12[bank][1];
active_mem[bank]<=pending_mem[bank][0];pending_mem[bank][0]<=pending_mem[bank][1];
active_mul[bank]<=pending_mul[bank][0];pending_mul[bank][0]<=pending_mul[bank][1];
active_tc[bank]<=pending_tc[bank][0];pending_tc[bank][0]<=pending_tc[bank][1];
active_disable_mask[bank]<=pending_disable_mask[bank][0];pending_disable_mask[bank][0]<=pending_disable_mask[bank][1];
active_custom_signal_0[bank]<=pending_custom_signal_0[bank][0];pending_custom_signal_0[bank][0]<=pending_custom_signal_0[bank][1];
active_mem_cmd[bank]<=pending_mem_cmd[bank][0];pending_mem_cmd[bank][0]<=pending_mem_cmd[bank][1];
active_mop[bank]<=pending_mop[bank][0];pending_mop[bank][0]<=pending_mop[bank][1];
active_reg_idx1[bank]<=pending_reg_idx1[bank][0];pending_reg_idx1[bank][0]<=pending_reg_idx1[bank][1];
active_reg_idx2[bank]<=pending_reg_idx2[bank][0];pending_reg_idx2[bank][0]<=pending_reg_idx2[bank][1];
active_reg_idx3[bank]<=pending_reg_idx3[bank][0];pending_reg_idx3[bank][0]<=pending_reg_idx3[bank][1];
active_reg_idxw[bank]<=pending_reg_idxw[bank][0];pending_reg_idxw[bank][0]<=pending_reg_idxw[bank][1];
active_wvd[bank]<=pending_wvd[bank][0];pending_wvd[bank][0]<=pending_wvd[bank][1];
active_fence[bank]<=pending_fence[bank][0];pending_fence[bank][0]<=pending_fence[bank][1];
active_sfu[bank]<=pending_sfu[bank][0];pending_sfu[bank][0]<=pending_sfu[bank][1];
active_readmask[bank]<=pending_readmask[bank][0];pending_readmask[bank][0]<=pending_readmask[bank][1];
active_wxd[bank]<=pending_wxd[bank][0];pending_wxd[bank][0]<=pending_wxd[bank][1];
active_pc[bank]<=pending_pc[bank][0];pending_pc[bank][0]<=pending_pc[bank][1];
active_imm_ext[bank]<=pending_imm_ext[bank][0];pending_imm_ext[bank][0]<=pending_imm_ext[bank][1];
active_atomic[bank]<=pending_atomic[bank][0];pending_atomic[bank][0]<=pending_atomic[bank][1];
active_aq[bank]<=pending_aq[bank][0];pending_aq[bank][0]<=pending_aq[bank][1];
active_rl[bank]<=pending_rl[bank][0];pending_rl[bank][0]<=pending_rl[bank][1];
active_rm[bank]<=pending_rm[bank][0];pending_rm[bank][0]<=pending_rm[bank][1];
active_rm_is_static[bank]<=pending_rm_is_static[bank][0];pending_rm_is_static[bank][0]<=pending_rm_is_static[bank][1];
end else if(eligible_lanes[bank]!=0&&downstream[bank]&&ibuffer2issue_grant_i[bank])begin
eligible_lanes[bank]<=eligible_lanes[bank][0]?(eligible_lanes[bank]&2'b10):0;
end
if(accept_pair[bank])begin
queued_validity[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_mask_i;
pending_inst[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_inst_i;
pending_wid[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_wid_i;
pending_fp[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_fp_i;
pending_branch[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_branch_i;
pending_simt_stack[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_simt_stack_i;
pending_simt_stack_op[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_simt_stack_op_i;
pending_barrier[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_barrier_i;
pending_csr[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_csr_i;
pending_reverse[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_reverse_i;
pending_sel_alu2[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_sel_alu2_i;
pending_sel_alu1[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_sel_alu1_i;
pending_sel_alu3[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_sel_alu3_i;
pending_isvec[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_isvec_i;
pending_mask[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_mask_i;
pending_sel_imm[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_sel_imm_i;
pending_mem_whb[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_mem_whb_i;
pending_mem_unsigned[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_mem_unsigned_i;
pending_alu_fn[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_alu_fn_i;
pending_force_rm_rtz[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_force_rm_rtz_i;
pending_is_vls12[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_is_vls12_i;
pending_mem[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_mem_i;
pending_mul[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_mul_i;
pending_tc[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_tc_i;
pending_disable_mask[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_disable_mask_i;
pending_custom_signal_0[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_custom_signal_0_i;
pending_mem_cmd[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_mem_cmd_i;
pending_mop[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_mop_i;
pending_reg_idx1[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_reg_idx1_i;
pending_reg_idx2[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_reg_idx2_i;
pending_reg_idx3[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_reg_idx3_i;
pending_reg_idxw[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_reg_idxw_i;
pending_wvd[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_wvd_i;
pending_fence[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_fence_i;
pending_sfu[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_sfu_i;
pending_readmask[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_readmask_i;
pending_wxd[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_wxd_i;
pending_pc[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_pc_i;
pending_imm_ext[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_imm_ext_i;
pending_atomic[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_atomic_i;
pending_aq[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_aq_i;
pending_rl[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_rl_i;
pending_rm[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_rm_i;
pending_rm_is_static[bank][pending_count[bank]-take_head[bank]]<=ibuffer_in_control_Signals_rm_is_static_i;
end
end
end
end
endmodule
