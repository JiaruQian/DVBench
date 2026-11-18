`timescale 1ns/1ps
module dvbench_model(
  input logic clock,
  input logic reset,
  input logic io_req_valid,
  input logic [6:0] io_req_bits_uop_uopc,
  input logic [31:0] io_req_bits_uop_inst,
  input logic [31:0] io_req_bits_uop_debug_inst,
  input logic io_req_bits_uop_is_rvc,
  input logic [39:0] io_req_bits_uop_debug_pc,
  input logic [2:0] io_req_bits_uop_iq_type,
  input logic [9:0] io_req_bits_uop_fu_code,
  input logic [3:0] io_req_bits_uop_ctrl_br_type,
  input logic [1:0] io_req_bits_uop_ctrl_op1_sel,
  input logic [2:0] io_req_bits_uop_ctrl_op2_sel,
  input logic [2:0] io_req_bits_uop_ctrl_imm_sel,
  input logic [3:0] io_req_bits_uop_ctrl_op_fcn,
  input logic io_req_bits_uop_ctrl_fcn_dw,
  input logic [2:0] io_req_bits_uop_ctrl_csr_cmd,
  input logic io_req_bits_uop_ctrl_is_load,
  input logic io_req_bits_uop_ctrl_is_sta,
  input logic io_req_bits_uop_ctrl_is_std,
  input logic [1:0] io_req_bits_uop_iw_state,
  input logic io_req_bits_uop_is_br,
  input logic io_req_bits_uop_is_jalr,
  input logic io_req_bits_uop_is_jal,
  input logic io_req_bits_uop_is_sfb,
  input logic [19:0] io_req_bits_uop_br_mask,
  input logic [4:0] io_req_bits_uop_br_tag,
  input logic [5:0] io_req_bits_uop_ftq_idx,
  input logic io_req_bits_uop_edge_inst,
  input logic [5:0] io_req_bits_uop_pc_lob,
  input logic io_req_bits_uop_taken,
  input logic [19:0] io_req_bits_uop_imm_packed,
  input logic [11:0] io_req_bits_uop_csr_addr,
  input logic [6:0] io_req_bits_uop_rob_idx,
  input logic [4:0] io_req_bits_uop_ldq_idx,
  input logic [4:0] io_req_bits_uop_stq_idx,
  input logic [1:0] io_req_bits_uop_rxq_idx,
  input logic [6:0] io_req_bits_uop_pdst,
  input logic [6:0] io_req_bits_uop_prs1,
  input logic [6:0] io_req_bits_uop_prs2,
  input logic [6:0] io_req_bits_uop_prs3,
  input logic [5:0] io_req_bits_uop_ppred,
  input logic io_req_bits_uop_prs1_busy,
  input logic io_req_bits_uop_prs2_busy,
  input logic io_req_bits_uop_prs3_busy,
  input logic io_req_bits_uop_ppred_busy,
  input logic [6:0] io_req_bits_uop_stale_pdst,
  input logic io_req_bits_uop_exception,
  input logic [63:0] io_req_bits_uop_exc_cause,
  input logic io_req_bits_uop_bypassable,
  input logic [4:0] io_req_bits_uop_mem_cmd,
  input logic [1:0] io_req_bits_uop_mem_size,
  input logic io_req_bits_uop_mem_signed,
  input logic io_req_bits_uop_is_fence,
  input logic io_req_bits_uop_is_fencei,
  input logic io_req_bits_uop_is_amo,
  input logic io_req_bits_uop_uses_ldq,
  input logic io_req_bits_uop_uses_stq,
  input logic io_req_bits_uop_is_sys_pc2epc,
  input logic io_req_bits_uop_is_unique,
  input logic io_req_bits_uop_flush_on_commit,
  input logic io_req_bits_uop_ldst_is_rs1,
  input logic [5:0] io_req_bits_uop_ldst,
  input logic [5:0] io_req_bits_uop_lrs1,
  input logic [5:0] io_req_bits_uop_lrs2,
  input logic [5:0] io_req_bits_uop_lrs3,
  input logic io_req_bits_uop_ldst_val,
  input logic [1:0] io_req_bits_uop_dst_rtype,
  input logic [1:0] io_req_bits_uop_lrs1_rtype,
  input logic [1:0] io_req_bits_uop_lrs2_rtype,
  input logic io_req_bits_uop_frs3_en,
  input logic io_req_bits_uop_fp_val,
  input logic io_req_bits_uop_fp_single,
  input logic io_req_bits_uop_xcpt_pf_if,
  input logic io_req_bits_uop_xcpt_ae_if,
  input logic io_req_bits_uop_xcpt_ma_if,
  input logic io_req_bits_uop_bp_debug_if,
  input logic io_req_bits_uop_bp_xcpt_if,
  input logic [1:0] io_req_bits_uop_debug_fsrc,
  input logic [1:0] io_req_bits_uop_debug_tsrc,
  input logic [64:0] io_req_bits_rs1_data,
  input logic [64:0] io_req_bits_rs2_data,
  output logic io_ll_iresp_valid,
  output logic [6:0] io_ll_iresp_bits_uop_rob_idx,
  output logic [6:0] io_ll_iresp_bits_uop_pdst,
  output logic io_ll_iresp_bits_uop_is_amo,
  output logic io_ll_iresp_bits_uop_uses_stq,
  output logic [1:0] io_ll_iresp_bits_uop_dst_rtype,
  output logic [64:0] io_ll_iresp_bits_data,
  output logic io_ll_fresp_valid,
  output logic [6:0] io_ll_fresp_bits_uop_uopc,
  output logic [19:0] io_ll_fresp_bits_uop_br_mask,
  output logic [6:0] io_ll_fresp_bits_uop_rob_idx,
  output logic [4:0] io_ll_fresp_bits_uop_stq_idx,
  output logic [6:0] io_ll_fresp_bits_uop_pdst,
  output logic [1:0] io_ll_fresp_bits_uop_mem_size,
  output logic io_ll_fresp_bits_uop_is_amo,
  output logic io_ll_fresp_bits_uop_uses_stq,
  output logic [1:0] io_ll_fresp_bits_uop_dst_rtype,
  output logic io_ll_fresp_bits_uop_fp_val,
  output logic [64:0] io_ll_fresp_bits_data,
  input logic [19:0] io_brupdate_b1_resolve_mask,
  input logic [19:0] io_brupdate_b1_mispredict_mask,
  output logic io_lsu_io_req_valid,
  output logic [6:0] io_lsu_io_req_bits_uop_uopc,
  output logic [31:0] io_lsu_io_req_bits_uop_inst,
  output logic [31:0] io_lsu_io_req_bits_uop_debug_inst,
  output logic io_lsu_io_req_bits_uop_is_rvc,
  output logic [39:0] io_lsu_io_req_bits_uop_debug_pc,
  output logic [2:0] io_lsu_io_req_bits_uop_iq_type,
  output logic [9:0] io_lsu_io_req_bits_uop_fu_code,
  output logic [3:0] io_lsu_io_req_bits_uop_ctrl_br_type,
  output logic [1:0] io_lsu_io_req_bits_uop_ctrl_op1_sel,
  output logic [2:0] io_lsu_io_req_bits_uop_ctrl_op2_sel,
  output logic [2:0] io_lsu_io_req_bits_uop_ctrl_imm_sel,
  output logic [3:0] io_lsu_io_req_bits_uop_ctrl_op_fcn,
  output logic io_lsu_io_req_bits_uop_ctrl_fcn_dw,
  output logic [2:0] io_lsu_io_req_bits_uop_ctrl_csr_cmd,
  output logic io_lsu_io_req_bits_uop_ctrl_is_load,
  output logic io_lsu_io_req_bits_uop_ctrl_is_sta,
  output logic io_lsu_io_req_bits_uop_ctrl_is_std,
  output logic [1:0] io_lsu_io_req_bits_uop_iw_state,
  output logic io_lsu_io_req_bits_uop_is_br,
  output logic io_lsu_io_req_bits_uop_is_jalr,
  output logic io_lsu_io_req_bits_uop_is_jal,
  output logic io_lsu_io_req_bits_uop_is_sfb,
  output logic [19:0] io_lsu_io_req_bits_uop_br_mask,
  output logic [4:0] io_lsu_io_req_bits_uop_br_tag,
  output logic [5:0] io_lsu_io_req_bits_uop_ftq_idx,
  output logic io_lsu_io_req_bits_uop_edge_inst,
  output logic [5:0] io_lsu_io_req_bits_uop_pc_lob,
  output logic io_lsu_io_req_bits_uop_taken,
  output logic [19:0] io_lsu_io_req_bits_uop_imm_packed,
  output logic [11:0] io_lsu_io_req_bits_uop_csr_addr,
  output logic [6:0] io_lsu_io_req_bits_uop_rob_idx,
  output logic [4:0] io_lsu_io_req_bits_uop_ldq_idx,
  output logic [4:0] io_lsu_io_req_bits_uop_stq_idx,
  output logic [1:0] io_lsu_io_req_bits_uop_rxq_idx,
  output logic [6:0] io_lsu_io_req_bits_uop_pdst,
  output logic [6:0] io_lsu_io_req_bits_uop_prs1,
  output logic [6:0] io_lsu_io_req_bits_uop_prs2,
  output logic [6:0] io_lsu_io_req_bits_uop_prs3,
  output logic [5:0] io_lsu_io_req_bits_uop_ppred,
  output logic io_lsu_io_req_bits_uop_prs1_busy,
  output logic io_lsu_io_req_bits_uop_prs2_busy,
  output logic io_lsu_io_req_bits_uop_prs3_busy,
  output logic io_lsu_io_req_bits_uop_ppred_busy,
  output logic [6:0] io_lsu_io_req_bits_uop_stale_pdst,
  output logic io_lsu_io_req_bits_uop_exception,
  output logic [63:0] io_lsu_io_req_bits_uop_exc_cause,
  output logic io_lsu_io_req_bits_uop_bypassable,
  output logic [4:0] io_lsu_io_req_bits_uop_mem_cmd,
  output logic [1:0] io_lsu_io_req_bits_uop_mem_size,
  output logic io_lsu_io_req_bits_uop_mem_signed,
  output logic io_lsu_io_req_bits_uop_is_fence,
  output logic io_lsu_io_req_bits_uop_is_fencei,
  output logic io_lsu_io_req_bits_uop_is_amo,
  output logic io_lsu_io_req_bits_uop_uses_ldq,
  output logic io_lsu_io_req_bits_uop_uses_stq,
  output logic io_lsu_io_req_bits_uop_is_sys_pc2epc,
  output logic io_lsu_io_req_bits_uop_is_unique,
  output logic io_lsu_io_req_bits_uop_flush_on_commit,
  output logic io_lsu_io_req_bits_uop_ldst_is_rs1,
  output logic [5:0] io_lsu_io_req_bits_uop_ldst,
  output logic [5:0] io_lsu_io_req_bits_uop_lrs1,
  output logic [5:0] io_lsu_io_req_bits_uop_lrs2,
  output logic [5:0] io_lsu_io_req_bits_uop_lrs3,
  output logic io_lsu_io_req_bits_uop_ldst_val,
  output logic [1:0] io_lsu_io_req_bits_uop_dst_rtype,
  output logic [1:0] io_lsu_io_req_bits_uop_lrs1_rtype,
  output logic [1:0] io_lsu_io_req_bits_uop_lrs2_rtype,
  output logic io_lsu_io_req_bits_uop_frs3_en,
  output logic io_lsu_io_req_bits_uop_fp_val,
  output logic io_lsu_io_req_bits_uop_fp_single,
  output logic io_lsu_io_req_bits_uop_xcpt_pf_if,
  output logic io_lsu_io_req_bits_uop_xcpt_ae_if,
  output logic io_lsu_io_req_bits_uop_xcpt_ma_if,
  output logic io_lsu_io_req_bits_uop_bp_debug_if,
  output logic io_lsu_io_req_bits_uop_bp_xcpt_if,
  output logic [1:0] io_lsu_io_req_bits_uop_debug_fsrc,
  output logic [1:0] io_lsu_io_req_bits_uop_debug_tsrc,
  output logic [63:0] io_lsu_io_req_bits_data,
  output logic [39:0] io_lsu_io_req_bits_addr,
  output logic io_lsu_io_req_bits_mxcpt_valid,
  output logic io_lsu_io_req_bits_sfence_valid,
  output logic io_lsu_io_req_bits_sfence_bits_rs1,
  output logic io_lsu_io_req_bits_sfence_bits_rs2,
  output logic [38:0] io_lsu_io_req_bits_sfence_bits_addr,
  input logic io_lsu_io_iresp_valid,
  input logic [6:0] io_lsu_io_iresp_bits_uop_rob_idx,
  input logic [6:0] io_lsu_io_iresp_bits_uop_pdst,
  input logic io_lsu_io_iresp_bits_uop_is_amo,
  input logic io_lsu_io_iresp_bits_uop_uses_stq,
  input logic [1:0] io_lsu_io_iresp_bits_uop_dst_rtype,
  input logic [63:0] io_lsu_io_iresp_bits_data,
  input logic io_lsu_io_fresp_valid,
  input logic [6:0] io_lsu_io_fresp_bits_uop_uopc,
  input logic [19:0] io_lsu_io_fresp_bits_uop_br_mask,
  input logic [6:0] io_lsu_io_fresp_bits_uop_rob_idx,
  input logic [4:0] io_lsu_io_fresp_bits_uop_stq_idx,
  input logic [6:0] io_lsu_io_fresp_bits_uop_pdst,
  input logic [1:0] io_lsu_io_fresp_bits_uop_mem_size,
  input logic io_lsu_io_fresp_bits_uop_is_amo,
  input logic io_lsu_io_fresp_bits_uop_uses_stq,
  input logic [1:0] io_lsu_io_fresp_bits_uop_dst_rtype,
  input logic io_lsu_io_fresp_bits_uop_fp_val,
  input logic [64:0] io_lsu_io_fresp_bits_data
);
logic active, unaligned, address_tag;
logic [63:0] effective_address;
logic signed [63:0] displacement;
always_comb begin
  active = io_req_valid && io_req_bits_uop_fu_code[2];
  displacement = $signed(io_req_bits_uop_imm_packed[19:8]);
  effective_address = io_req_bits_rs1_data[63:0] + displacement;
  unaligned = ((effective_address % (64'd1 << io_req_bits_uop_mem_size)) != 0);
  if (effective_address[38]) address_tag = (effective_address[63:39] == 25'h1ffffff);
  else address_tag = (effective_address[63:39] != 0);
  io_ll_iresp_valid = io_lsu_io_iresp_valid;
  io_ll_iresp_bits_uop_rob_idx = io_lsu_io_iresp_bits_uop_rob_idx;
  io_ll_iresp_bits_uop_pdst = io_lsu_io_iresp_bits_uop_pdst;
  io_ll_iresp_bits_uop_is_amo = io_lsu_io_iresp_bits_uop_is_amo;
  io_ll_iresp_bits_uop_uses_stq = io_lsu_io_iresp_bits_uop_uses_stq;
  io_ll_iresp_bits_uop_dst_rtype = io_lsu_io_iresp_bits_uop_dst_rtype;
  io_ll_iresp_bits_data = {1'b0, io_lsu_io_iresp_bits_data};
  io_ll_fresp_valid = io_lsu_io_fresp_valid;
  io_ll_fresp_bits_uop_uopc = io_lsu_io_fresp_bits_uop_uopc;
  io_ll_fresp_bits_uop_br_mask = io_lsu_io_fresp_bits_uop_br_mask;
  io_ll_fresp_bits_uop_rob_idx = io_lsu_io_fresp_bits_uop_rob_idx;
  io_ll_fresp_bits_uop_stq_idx = io_lsu_io_fresp_bits_uop_stq_idx;
  io_ll_fresp_bits_uop_pdst = io_lsu_io_fresp_bits_uop_pdst;
  io_ll_fresp_bits_uop_mem_size = io_lsu_io_fresp_bits_uop_mem_size;
  io_ll_fresp_bits_uop_is_amo = io_lsu_io_fresp_bits_uop_is_amo;
  io_ll_fresp_bits_uop_uses_stq = io_lsu_io_fresp_bits_uop_uses_stq;
  io_ll_fresp_bits_uop_dst_rtype = io_lsu_io_fresp_bits_uop_dst_rtype;
  io_ll_fresp_bits_uop_fp_val = io_lsu_io_fresp_bits_uop_fp_val;
  io_ll_fresp_bits_data = io_lsu_io_fresp_bits_data;
  io_lsu_io_req_bits_uop_uopc = io_req_bits_uop_uopc;
  io_lsu_io_req_bits_uop_inst = io_req_bits_uop_inst;
  io_lsu_io_req_bits_uop_debug_inst = io_req_bits_uop_debug_inst;
  io_lsu_io_req_bits_uop_is_rvc = io_req_bits_uop_is_rvc;
  io_lsu_io_req_bits_uop_debug_pc = io_req_bits_uop_debug_pc;
  io_lsu_io_req_bits_uop_iq_type = io_req_bits_uop_iq_type;
  io_lsu_io_req_bits_uop_fu_code = io_req_bits_uop_fu_code;
  io_lsu_io_req_bits_uop_ctrl_br_type = io_req_bits_uop_ctrl_br_type;
  io_lsu_io_req_bits_uop_ctrl_op1_sel = io_req_bits_uop_ctrl_op1_sel;
  io_lsu_io_req_bits_uop_ctrl_op2_sel = io_req_bits_uop_ctrl_op2_sel;
  io_lsu_io_req_bits_uop_ctrl_imm_sel = io_req_bits_uop_ctrl_imm_sel;
  io_lsu_io_req_bits_uop_ctrl_op_fcn = io_req_bits_uop_ctrl_op_fcn;
  io_lsu_io_req_bits_uop_ctrl_fcn_dw = io_req_bits_uop_ctrl_fcn_dw;
  io_lsu_io_req_bits_uop_ctrl_csr_cmd = io_req_bits_uop_ctrl_csr_cmd;
  io_lsu_io_req_bits_uop_ctrl_is_load = io_req_bits_uop_ctrl_is_load;
  io_lsu_io_req_bits_uop_ctrl_is_sta = io_req_bits_uop_ctrl_is_sta;
  io_lsu_io_req_bits_uop_ctrl_is_std = io_req_bits_uop_ctrl_is_std;
  io_lsu_io_req_bits_uop_iw_state = io_req_bits_uop_iw_state;
  io_lsu_io_req_bits_uop_is_br = io_req_bits_uop_is_br;
  io_lsu_io_req_bits_uop_is_jalr = io_req_bits_uop_is_jalr;
  io_lsu_io_req_bits_uop_is_jal = io_req_bits_uop_is_jal;
  io_lsu_io_req_bits_uop_is_sfb = io_req_bits_uop_is_sfb;
  io_lsu_io_req_bits_uop_br_mask = io_req_bits_uop_br_mask & ~io_brupdate_b1_resolve_mask;
  io_lsu_io_req_bits_uop_br_tag = io_req_bits_uop_br_tag;
  io_lsu_io_req_bits_uop_ftq_idx = io_req_bits_uop_ftq_idx;
  io_lsu_io_req_bits_uop_edge_inst = io_req_bits_uop_edge_inst;
  io_lsu_io_req_bits_uop_pc_lob = io_req_bits_uop_pc_lob;
  io_lsu_io_req_bits_uop_taken = io_req_bits_uop_taken;
  io_lsu_io_req_bits_uop_imm_packed = io_req_bits_uop_imm_packed;
  io_lsu_io_req_bits_uop_csr_addr = io_req_bits_uop_csr_addr;
  io_lsu_io_req_bits_uop_rob_idx = io_req_bits_uop_rob_idx;
  io_lsu_io_req_bits_uop_ldq_idx = io_req_bits_uop_ldq_idx;
  io_lsu_io_req_bits_uop_stq_idx = io_req_bits_uop_stq_idx;
  io_lsu_io_req_bits_uop_rxq_idx = io_req_bits_uop_rxq_idx;
  io_lsu_io_req_bits_uop_pdst = io_req_bits_uop_pdst;
  io_lsu_io_req_bits_uop_prs1 = io_req_bits_uop_prs1;
  io_lsu_io_req_bits_uop_prs2 = io_req_bits_uop_prs2;
  io_lsu_io_req_bits_uop_prs3 = io_req_bits_uop_prs3;
  io_lsu_io_req_bits_uop_ppred = io_req_bits_uop_ppred;
  io_lsu_io_req_bits_uop_prs1_busy = io_req_bits_uop_prs1_busy;
  io_lsu_io_req_bits_uop_prs2_busy = io_req_bits_uop_prs2_busy;
  io_lsu_io_req_bits_uop_prs3_busy = io_req_bits_uop_prs3_busy;
  io_lsu_io_req_bits_uop_ppred_busy = io_req_bits_uop_ppred_busy;
  io_lsu_io_req_bits_uop_stale_pdst = io_req_bits_uop_stale_pdst;
  io_lsu_io_req_bits_uop_exception = io_req_bits_uop_exception;
  io_lsu_io_req_bits_uop_exc_cause = io_req_bits_uop_exc_cause;
  io_lsu_io_req_bits_uop_bypassable = io_req_bits_uop_bypassable;
  io_lsu_io_req_bits_uop_mem_cmd = io_req_bits_uop_mem_cmd;
  io_lsu_io_req_bits_uop_mem_size = io_req_bits_uop_mem_size;
  io_lsu_io_req_bits_uop_mem_signed = io_req_bits_uop_mem_signed;
  io_lsu_io_req_bits_uop_is_fence = io_req_bits_uop_is_fence;
  io_lsu_io_req_bits_uop_is_fencei = io_req_bits_uop_is_fencei;
  io_lsu_io_req_bits_uop_is_amo = io_req_bits_uop_is_amo;
  io_lsu_io_req_bits_uop_uses_ldq = io_req_bits_uop_uses_ldq;
  io_lsu_io_req_bits_uop_uses_stq = io_req_bits_uop_uses_stq;
  io_lsu_io_req_bits_uop_is_sys_pc2epc = io_req_bits_uop_is_sys_pc2epc;
  io_lsu_io_req_bits_uop_is_unique = io_req_bits_uop_is_unique;
  io_lsu_io_req_bits_uop_flush_on_commit = io_req_bits_uop_flush_on_commit;
  io_lsu_io_req_bits_uop_ldst_is_rs1 = io_req_bits_uop_ldst_is_rs1;
  io_lsu_io_req_bits_uop_ldst = io_req_bits_uop_ldst;
  io_lsu_io_req_bits_uop_lrs1 = io_req_bits_uop_lrs1;
  io_lsu_io_req_bits_uop_lrs2 = io_req_bits_uop_lrs2;
  io_lsu_io_req_bits_uop_lrs3 = io_req_bits_uop_lrs3;
  io_lsu_io_req_bits_uop_ldst_val = io_req_bits_uop_ldst_val;
  io_lsu_io_req_bits_uop_dst_rtype = io_req_bits_uop_dst_rtype;
  io_lsu_io_req_bits_uop_lrs1_rtype = io_req_bits_uop_lrs1_rtype;
  io_lsu_io_req_bits_uop_lrs2_rtype = io_req_bits_uop_lrs2_rtype;
  io_lsu_io_req_bits_uop_frs3_en = io_req_bits_uop_frs3_en;
  io_lsu_io_req_bits_uop_fp_val = io_req_bits_uop_fp_val;
  io_lsu_io_req_bits_uop_fp_single = io_req_bits_uop_fp_single;
  io_lsu_io_req_bits_uop_xcpt_pf_if = io_req_bits_uop_xcpt_pf_if;
  io_lsu_io_req_bits_uop_xcpt_ae_if = io_req_bits_uop_xcpt_ae_if;
  io_lsu_io_req_bits_uop_xcpt_ma_if = io_req_bits_uop_xcpt_ma_if;
  io_lsu_io_req_bits_uop_bp_debug_if = io_req_bits_uop_bp_debug_if;
  io_lsu_io_req_bits_uop_bp_xcpt_if = io_req_bits_uop_bp_xcpt_if;
  io_lsu_io_req_bits_uop_debug_fsrc = io_req_bits_uop_debug_fsrc;
  io_lsu_io_req_bits_uop_debug_tsrc = io_req_bits_uop_debug_tsrc;
  io_lsu_io_req_valid = active && ((io_req_bits_uop_br_mask & io_brupdate_b1_mispredict_mask) == 0);
  io_lsu_io_req_bits_addr = {address_tag, effective_address[38:0]};
  io_lsu_io_req_bits_data = io_req_bits_rs2_data[63:0];
  io_lsu_io_req_bits_mxcpt_valid = active && unaligned && ((io_req_bits_uop_uopc == 1) || (io_req_bits_uop_uopc == 2) || (io_req_bits_uop_uopc == 7'h43));
  io_lsu_io_req_bits_sfence_valid = active && (io_req_bits_uop_mem_cmd == 20);
  io_lsu_io_req_bits_sfence_bits_rs1 = io_req_bits_uop_mem_size[0];
  io_lsu_io_req_bits_sfence_bits_rs2 = io_req_bits_uop_mem_size[1];
  io_lsu_io_req_bits_sfence_bits_addr = io_req_bits_rs1_data[38:0];
end
endmodule
