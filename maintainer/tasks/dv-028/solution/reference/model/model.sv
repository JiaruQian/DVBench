`timescale 1ns/1ps
module dvbench_model(
input logic clock,
input logic reset,
input logic io_iss_valids_0,
input logic io_iss_valids_1,
input logic [6:0] io_iss_uops_0_uopc,
input logic [31:0] io_iss_uops_0_inst,
input logic [31:0] io_iss_uops_0_debug_inst,
input logic io_iss_uops_0_is_rvc,
input logic [39:0] io_iss_uops_0_debug_pc,
input logic [2:0] io_iss_uops_0_iq_type,
input logic [9:0] io_iss_uops_0_fu_code,
input logic [1:0] io_iss_uops_0_iw_state,
input logic io_iss_uops_0_is_br,
input logic io_iss_uops_0_is_jalr,
input logic io_iss_uops_0_is_jal,
input logic io_iss_uops_0_is_sfb,
input logic [19:0] io_iss_uops_0_br_mask,
input logic [4:0] io_iss_uops_0_br_tag,
input logic [5:0] io_iss_uops_0_ftq_idx,
input logic io_iss_uops_0_edge_inst,
input logic [5:0] io_iss_uops_0_pc_lob,
input logic io_iss_uops_0_taken,
input logic [19:0] io_iss_uops_0_imm_packed,
input logic [11:0] io_iss_uops_0_csr_addr,
input logic [6:0] io_iss_uops_0_rob_idx,
input logic [4:0] io_iss_uops_0_ldq_idx,
input logic [4:0] io_iss_uops_0_stq_idx,
input logic [1:0] io_iss_uops_0_rxq_idx,
input logic [6:0] io_iss_uops_0_pdst,
input logic [6:0] io_iss_uops_0_prs1,
input logic [6:0] io_iss_uops_0_prs2,
input logic [6:0] io_iss_uops_0_prs3,
input logic [5:0] io_iss_uops_0_ppred,
input logic io_iss_uops_0_prs1_busy,
input logic io_iss_uops_0_prs2_busy,
input logic io_iss_uops_0_prs3_busy,
input logic io_iss_uops_0_ppred_busy,
input logic [6:0] io_iss_uops_0_stale_pdst,
input logic io_iss_uops_0_exception,
input logic [63:0] io_iss_uops_0_exc_cause,
input logic io_iss_uops_0_bypassable,
input logic [4:0] io_iss_uops_0_mem_cmd,
input logic [1:0] io_iss_uops_0_mem_size,
input logic io_iss_uops_0_mem_signed,
input logic io_iss_uops_0_is_fence,
input logic io_iss_uops_0_is_fencei,
input logic io_iss_uops_0_is_amo,
input logic io_iss_uops_0_uses_ldq,
input logic io_iss_uops_0_uses_stq,
input logic io_iss_uops_0_is_sys_pc2epc,
input logic io_iss_uops_0_is_unique,
input logic io_iss_uops_0_flush_on_commit,
input logic io_iss_uops_0_ldst_is_rs1,
input logic [5:0] io_iss_uops_0_ldst,
input logic [5:0] io_iss_uops_0_lrs1,
input logic [5:0] io_iss_uops_0_lrs2,
input logic [5:0] io_iss_uops_0_lrs3,
input logic io_iss_uops_0_ldst_val,
input logic [1:0] io_iss_uops_0_dst_rtype,
input logic [1:0] io_iss_uops_0_lrs1_rtype,
input logic [1:0] io_iss_uops_0_lrs2_rtype,
input logic io_iss_uops_0_frs3_en,
input logic io_iss_uops_0_fp_val,
input logic io_iss_uops_0_fp_single,
input logic io_iss_uops_0_xcpt_pf_if,
input logic io_iss_uops_0_xcpt_ae_if,
input logic io_iss_uops_0_xcpt_ma_if,
input logic io_iss_uops_0_bp_debug_if,
input logic io_iss_uops_0_bp_xcpt_if,
input logic [1:0] io_iss_uops_0_debug_fsrc,
input logic [1:0] io_iss_uops_0_debug_tsrc,
input logic [6:0] io_iss_uops_1_uopc,
input logic [31:0] io_iss_uops_1_inst,
input logic [31:0] io_iss_uops_1_debug_inst,
input logic io_iss_uops_1_is_rvc,
input logic [39:0] io_iss_uops_1_debug_pc,
input logic [2:0] io_iss_uops_1_iq_type,
input logic [9:0] io_iss_uops_1_fu_code,
input logic [1:0] io_iss_uops_1_iw_state,
input logic io_iss_uops_1_is_br,
input logic io_iss_uops_1_is_jalr,
input logic io_iss_uops_1_is_jal,
input logic io_iss_uops_1_is_sfb,
input logic [19:0] io_iss_uops_1_br_mask,
input logic [4:0] io_iss_uops_1_br_tag,
input logic [5:0] io_iss_uops_1_ftq_idx,
input logic io_iss_uops_1_edge_inst,
input logic [5:0] io_iss_uops_1_pc_lob,
input logic io_iss_uops_1_taken,
input logic [19:0] io_iss_uops_1_imm_packed,
input logic [11:0] io_iss_uops_1_csr_addr,
input logic [6:0] io_iss_uops_1_rob_idx,
input logic [4:0] io_iss_uops_1_ldq_idx,
input logic [4:0] io_iss_uops_1_stq_idx,
input logic [1:0] io_iss_uops_1_rxq_idx,
input logic [6:0] io_iss_uops_1_pdst,
input logic [6:0] io_iss_uops_1_prs1,
input logic [6:0] io_iss_uops_1_prs2,
input logic [6:0] io_iss_uops_1_prs3,
input logic [5:0] io_iss_uops_1_ppred,
input logic io_iss_uops_1_prs1_busy,
input logic io_iss_uops_1_prs2_busy,
input logic io_iss_uops_1_prs3_busy,
input logic io_iss_uops_1_ppred_busy,
input logic [6:0] io_iss_uops_1_stale_pdst,
input logic io_iss_uops_1_exception,
input logic [63:0] io_iss_uops_1_exc_cause,
input logic io_iss_uops_1_bypassable,
input logic [4:0] io_iss_uops_1_mem_cmd,
input logic [1:0] io_iss_uops_1_mem_size,
input logic io_iss_uops_1_mem_signed,
input logic io_iss_uops_1_is_fence,
input logic io_iss_uops_1_is_fencei,
input logic io_iss_uops_1_is_amo,
input logic io_iss_uops_1_uses_ldq,
input logic io_iss_uops_1_uses_stq,
input logic io_iss_uops_1_is_sys_pc2epc,
input logic io_iss_uops_1_is_unique,
input logic io_iss_uops_1_flush_on_commit,
input logic io_iss_uops_1_ldst_is_rs1,
input logic [5:0] io_iss_uops_1_ldst,
input logic [5:0] io_iss_uops_1_lrs1,
input logic [5:0] io_iss_uops_1_lrs2,
input logic [5:0] io_iss_uops_1_lrs3,
input logic io_iss_uops_1_ldst_val,
input logic [1:0] io_iss_uops_1_dst_rtype,
input logic [1:0] io_iss_uops_1_lrs1_rtype,
input logic [1:0] io_iss_uops_1_lrs2_rtype,
input logic io_iss_uops_1_frs3_en,
input logic io_iss_uops_1_fp_val,
input logic io_iss_uops_1_fp_single,
input logic io_iss_uops_1_xcpt_pf_if,
input logic io_iss_uops_1_xcpt_ae_if,
input logic io_iss_uops_1_xcpt_ma_if,
input logic io_iss_uops_1_bp_debug_if,
input logic io_iss_uops_1_bp_xcpt_if,
input logic [1:0] io_iss_uops_1_debug_fsrc,
input logic [1:0] io_iss_uops_1_debug_tsrc,
output logic [6:0] io_rf_read_ports_0_addr,
input logic [64:0] io_rf_read_ports_0_data,
output logic [6:0] io_rf_read_ports_1_addr,
input logic [64:0] io_rf_read_ports_1_data,
output logic [6:0] io_rf_read_ports_2_addr,
input logic [64:0] io_rf_read_ports_2_data,
output logic [6:0] io_rf_read_ports_3_addr,
input logic [64:0] io_rf_read_ports_3_data,
output logic [6:0] io_rf_read_ports_4_addr,
input logic [64:0] io_rf_read_ports_4_data,
output logic [6:0] io_rf_read_ports_5_addr,
input logic [64:0] io_rf_read_ports_5_data,
output logic io_exe_reqs_0_valid,
output logic [6:0] io_exe_reqs_0_bits_uop_uopc,
output logic [31:0] io_exe_reqs_0_bits_uop_inst,
output logic [31:0] io_exe_reqs_0_bits_uop_debug_inst,
output logic io_exe_reqs_0_bits_uop_is_rvc,
output logic [39:0] io_exe_reqs_0_bits_uop_debug_pc,
output logic [2:0] io_exe_reqs_0_bits_uop_iq_type,
output logic [9:0] io_exe_reqs_0_bits_uop_fu_code,
output logic [3:0] io_exe_reqs_0_bits_uop_ctrl_br_type,
output logic [1:0] io_exe_reqs_0_bits_uop_ctrl_op1_sel,
output logic [2:0] io_exe_reqs_0_bits_uop_ctrl_op2_sel,
output logic [2:0] io_exe_reqs_0_bits_uop_ctrl_imm_sel,
output logic [3:0] io_exe_reqs_0_bits_uop_ctrl_op_fcn,
output logic io_exe_reqs_0_bits_uop_ctrl_fcn_dw,
output logic [2:0] io_exe_reqs_0_bits_uop_ctrl_csr_cmd,
output logic io_exe_reqs_0_bits_uop_ctrl_is_load,
output logic io_exe_reqs_0_bits_uop_ctrl_is_sta,
output logic io_exe_reqs_0_bits_uop_ctrl_is_std,
output logic [1:0] io_exe_reqs_0_bits_uop_iw_state,
output logic io_exe_reqs_0_bits_uop_iw_p1_poisoned,
output logic io_exe_reqs_0_bits_uop_iw_p2_poisoned,
output logic io_exe_reqs_0_bits_uop_is_br,
output logic io_exe_reqs_0_bits_uop_is_jalr,
output logic io_exe_reqs_0_bits_uop_is_jal,
output logic io_exe_reqs_0_bits_uop_is_sfb,
output logic [19:0] io_exe_reqs_0_bits_uop_br_mask,
output logic [4:0] io_exe_reqs_0_bits_uop_br_tag,
output logic [5:0] io_exe_reqs_0_bits_uop_ftq_idx,
output logic io_exe_reqs_0_bits_uop_edge_inst,
output logic [5:0] io_exe_reqs_0_bits_uop_pc_lob,
output logic io_exe_reqs_0_bits_uop_taken,
output logic [19:0] io_exe_reqs_0_bits_uop_imm_packed,
output logic [11:0] io_exe_reqs_0_bits_uop_csr_addr,
output logic [6:0] io_exe_reqs_0_bits_uop_rob_idx,
output logic [4:0] io_exe_reqs_0_bits_uop_ldq_idx,
output logic [4:0] io_exe_reqs_0_bits_uop_stq_idx,
output logic [1:0] io_exe_reqs_0_bits_uop_rxq_idx,
output logic [6:0] io_exe_reqs_0_bits_uop_pdst,
output logic [6:0] io_exe_reqs_0_bits_uop_prs1,
output logic [6:0] io_exe_reqs_0_bits_uop_prs2,
output logic [6:0] io_exe_reqs_0_bits_uop_prs3,
output logic [5:0] io_exe_reqs_0_bits_uop_ppred,
output logic io_exe_reqs_0_bits_uop_prs1_busy,
output logic io_exe_reqs_0_bits_uop_prs2_busy,
output logic io_exe_reqs_0_bits_uop_prs3_busy,
output logic io_exe_reqs_0_bits_uop_ppred_busy,
output logic [6:0] io_exe_reqs_0_bits_uop_stale_pdst,
output logic io_exe_reqs_0_bits_uop_exception,
output logic [63:0] io_exe_reqs_0_bits_uop_exc_cause,
output logic io_exe_reqs_0_bits_uop_bypassable,
output logic [4:0] io_exe_reqs_0_bits_uop_mem_cmd,
output logic [1:0] io_exe_reqs_0_bits_uop_mem_size,
output logic io_exe_reqs_0_bits_uop_mem_signed,
output logic io_exe_reqs_0_bits_uop_is_fence,
output logic io_exe_reqs_0_bits_uop_is_fencei,
output logic io_exe_reqs_0_bits_uop_is_amo,
output logic io_exe_reqs_0_bits_uop_uses_ldq,
output logic io_exe_reqs_0_bits_uop_uses_stq,
output logic io_exe_reqs_0_bits_uop_is_sys_pc2epc,
output logic io_exe_reqs_0_bits_uop_is_unique,
output logic io_exe_reqs_0_bits_uop_flush_on_commit,
output logic io_exe_reqs_0_bits_uop_ldst_is_rs1,
output logic [5:0] io_exe_reqs_0_bits_uop_ldst,
output logic [5:0] io_exe_reqs_0_bits_uop_lrs1,
output logic [5:0] io_exe_reqs_0_bits_uop_lrs2,
output logic [5:0] io_exe_reqs_0_bits_uop_lrs3,
output logic io_exe_reqs_0_bits_uop_ldst_val,
output logic [1:0] io_exe_reqs_0_bits_uop_dst_rtype,
output logic [1:0] io_exe_reqs_0_bits_uop_lrs1_rtype,
output logic [1:0] io_exe_reqs_0_bits_uop_lrs2_rtype,
output logic io_exe_reqs_0_bits_uop_frs3_en,
output logic io_exe_reqs_0_bits_uop_fp_val,
output logic io_exe_reqs_0_bits_uop_fp_single,
output logic io_exe_reqs_0_bits_uop_xcpt_pf_if,
output logic io_exe_reqs_0_bits_uop_xcpt_ae_if,
output logic io_exe_reqs_0_bits_uop_xcpt_ma_if,
output logic io_exe_reqs_0_bits_uop_bp_debug_if,
output logic io_exe_reqs_0_bits_uop_bp_xcpt_if,
output logic [1:0] io_exe_reqs_0_bits_uop_debug_fsrc,
output logic [1:0] io_exe_reqs_0_bits_uop_debug_tsrc,
output logic [64:0] io_exe_reqs_0_bits_rs1_data,
output logic [64:0] io_exe_reqs_0_bits_rs2_data,
output logic [64:0] io_exe_reqs_0_bits_rs3_data,
output logic io_exe_reqs_1_valid,
output logic [6:0] io_exe_reqs_1_bits_uop_uopc,
output logic [31:0] io_exe_reqs_1_bits_uop_inst,
output logic [31:0] io_exe_reqs_1_bits_uop_debug_inst,
output logic io_exe_reqs_1_bits_uop_is_rvc,
output logic [39:0] io_exe_reqs_1_bits_uop_debug_pc,
output logic [2:0] io_exe_reqs_1_bits_uop_iq_type,
output logic [9:0] io_exe_reqs_1_bits_uop_fu_code,
output logic [3:0] io_exe_reqs_1_bits_uop_ctrl_br_type,
output logic [1:0] io_exe_reqs_1_bits_uop_ctrl_op1_sel,
output logic [2:0] io_exe_reqs_1_bits_uop_ctrl_op2_sel,
output logic [2:0] io_exe_reqs_1_bits_uop_ctrl_imm_sel,
output logic [3:0] io_exe_reqs_1_bits_uop_ctrl_op_fcn,
output logic io_exe_reqs_1_bits_uop_ctrl_fcn_dw,
output logic [2:0] io_exe_reqs_1_bits_uop_ctrl_csr_cmd,
output logic io_exe_reqs_1_bits_uop_ctrl_is_load,
output logic io_exe_reqs_1_bits_uop_ctrl_is_sta,
output logic io_exe_reqs_1_bits_uop_ctrl_is_std,
output logic [1:0] io_exe_reqs_1_bits_uop_iw_state,
output logic io_exe_reqs_1_bits_uop_iw_p1_poisoned,
output logic io_exe_reqs_1_bits_uop_iw_p2_poisoned,
output logic io_exe_reqs_1_bits_uop_is_br,
output logic io_exe_reqs_1_bits_uop_is_jalr,
output logic io_exe_reqs_1_bits_uop_is_jal,
output logic io_exe_reqs_1_bits_uop_is_sfb,
output logic [19:0] io_exe_reqs_1_bits_uop_br_mask,
output logic [4:0] io_exe_reqs_1_bits_uop_br_tag,
output logic [5:0] io_exe_reqs_1_bits_uop_ftq_idx,
output logic io_exe_reqs_1_bits_uop_edge_inst,
output logic [5:0] io_exe_reqs_1_bits_uop_pc_lob,
output logic io_exe_reqs_1_bits_uop_taken,
output logic [19:0] io_exe_reqs_1_bits_uop_imm_packed,
output logic [11:0] io_exe_reqs_1_bits_uop_csr_addr,
output logic [6:0] io_exe_reqs_1_bits_uop_rob_idx,
output logic [4:0] io_exe_reqs_1_bits_uop_ldq_idx,
output logic [4:0] io_exe_reqs_1_bits_uop_stq_idx,
output logic [1:0] io_exe_reqs_1_bits_uop_rxq_idx,
output logic [6:0] io_exe_reqs_1_bits_uop_pdst,
output logic [6:0] io_exe_reqs_1_bits_uop_prs1,
output logic [6:0] io_exe_reqs_1_bits_uop_prs2,
output logic [6:0] io_exe_reqs_1_bits_uop_prs3,
output logic [5:0] io_exe_reqs_1_bits_uop_ppred,
output logic io_exe_reqs_1_bits_uop_prs1_busy,
output logic io_exe_reqs_1_bits_uop_prs2_busy,
output logic io_exe_reqs_1_bits_uop_prs3_busy,
output logic io_exe_reqs_1_bits_uop_ppred_busy,
output logic [6:0] io_exe_reqs_1_bits_uop_stale_pdst,
output logic io_exe_reqs_1_bits_uop_exception,
output logic [63:0] io_exe_reqs_1_bits_uop_exc_cause,
output logic io_exe_reqs_1_bits_uop_bypassable,
output logic [4:0] io_exe_reqs_1_bits_uop_mem_cmd,
output logic [1:0] io_exe_reqs_1_bits_uop_mem_size,
output logic io_exe_reqs_1_bits_uop_mem_signed,
output logic io_exe_reqs_1_bits_uop_is_fence,
output logic io_exe_reqs_1_bits_uop_is_fencei,
output logic io_exe_reqs_1_bits_uop_is_amo,
output logic io_exe_reqs_1_bits_uop_uses_ldq,
output logic io_exe_reqs_1_bits_uop_uses_stq,
output logic io_exe_reqs_1_bits_uop_is_sys_pc2epc,
output logic io_exe_reqs_1_bits_uop_is_unique,
output logic io_exe_reqs_1_bits_uop_flush_on_commit,
output logic io_exe_reqs_1_bits_uop_ldst_is_rs1,
output logic [5:0] io_exe_reqs_1_bits_uop_ldst,
output logic [5:0] io_exe_reqs_1_bits_uop_lrs1,
output logic [5:0] io_exe_reqs_1_bits_uop_lrs2,
output logic [5:0] io_exe_reqs_1_bits_uop_lrs3,
output logic io_exe_reqs_1_bits_uop_ldst_val,
output logic [1:0] io_exe_reqs_1_bits_uop_dst_rtype,
output logic [1:0] io_exe_reqs_1_bits_uop_lrs1_rtype,
output logic [1:0] io_exe_reqs_1_bits_uop_lrs2_rtype,
output logic io_exe_reqs_1_bits_uop_frs3_en,
output logic io_exe_reqs_1_bits_uop_fp_val,
output logic io_exe_reqs_1_bits_uop_fp_single,
output logic io_exe_reqs_1_bits_uop_xcpt_pf_if,
output logic io_exe_reqs_1_bits_uop_xcpt_ae_if,
output logic io_exe_reqs_1_bits_uop_xcpt_ma_if,
output logic io_exe_reqs_1_bits_uop_bp_debug_if,
output logic io_exe_reqs_1_bits_uop_bp_xcpt_if,
output logic [1:0] io_exe_reqs_1_bits_uop_debug_fsrc,
output logic [1:0] io_exe_reqs_1_bits_uop_debug_tsrc,
output logic [64:0] io_exe_reqs_1_bits_rs1_data,
output logic [64:0] io_exe_reqs_1_bits_rs2_data,
output logic [64:0] io_exe_reqs_1_bits_rs3_data,
input logic io_kill,
input logic [19:0] io_brupdate_b1_resolve_mask,
input logic [19:0] io_brupdate_b1_mispredict_mask
);
typedef struct packed {
  logic [6:0] uopc;
  logic [31:0] inst;
  logic [31:0] debug_inst;
  logic is_rvc;
  logic [39:0] debug_pc;
  logic [2:0] iq_type;
  logic [9:0] fu_code;
  logic [3:0] ctrl_br_type;
  logic [1:0] ctrl_op1_sel;
  logic [2:0] ctrl_op2_sel;
  logic [2:0] ctrl_imm_sel;
  logic [3:0] ctrl_op_fcn;
  logic ctrl_fcn_dw;
  logic [2:0] ctrl_csr_cmd;
  logic ctrl_is_load;
  logic ctrl_is_sta;
  logic ctrl_is_std;
  logic [1:0] iw_state;
  logic iw_p1_poisoned;
  logic iw_p2_poisoned;
  logic is_br;
  logic is_jalr;
  logic is_jal;
  logic is_sfb;
  logic [19:0] br_mask;
  logic [4:0] br_tag;
  logic [5:0] ftq_idx;
  logic edge_inst;
  logic [5:0] pc_lob;
  logic taken;
  logic [19:0] imm_packed;
  logic [11:0] csr_addr;
  logic [6:0] rob_idx;
  logic [4:0] ldq_idx;
  logic [4:0] stq_idx;
  logic [1:0] rxq_idx;
  logic [6:0] pdst;
  logic [6:0] prs1;
  logic [6:0] prs2;
  logic [6:0] prs3;
  logic [5:0] ppred;
  logic prs1_busy;
  logic prs2_busy;
  logic prs3_busy;
  logic ppred_busy;
  logic [6:0] stale_pdst;
  logic exception;
  logic [63:0] exc_cause;
  logic bypassable;
  logic [4:0] mem_cmd;
  logic [1:0] mem_size;
  logic mem_signed;
  logic is_fence;
  logic is_fencei;
  logic is_amo;
  logic uses_ldq;
  logic uses_stq;
  logic is_sys_pc2epc;
  logic is_unique;
  logic flush_on_commit;
  logic ldst_is_rs1;
  logic [5:0] ldst;
  logic [5:0] lrs1;
  logic [5:0] lrs2;
  logic [5:0] lrs3;
  logic ldst_val;
  logic [1:0] dst_rtype;
  logic [1:0] lrs1_rtype;
  logic [1:0] lrs2_rtype;
  logic frs3_en;
  logic fp_val;
  logic fp_single;
  logic xcpt_pf_if;
  logic xcpt_ae_if;
  logic xcpt_ma_if;
  logic bp_debug_if;
  logic bp_xcpt_if;
  logic [1:0] debug_fsrc;
  logic [1:0] debug_tsrc;
} operation_t;
operation_t decoded0,decoded1,issued0,issued1,executing0,executing1;
logic issued_valid[0:1],cancelled[0:1];
logic [2:0] zero_source[0:1];
function automatic logic [16:0] decode_control(input logic [6:0] opcode,input integer lane);
  logic [3:0] branch_type,function_code;
  logic [1:0] first_source;
  logic [2:0] second_source,immediate_kind;
  logic full_width;
  begin
    branch_type=0;first_source=0;second_source=0;immediate_kind=0;function_code=0;full_width=1;
    if(opcode<14 || opcode==41 || opcode==43 || opcode==46 || opcode==48 || opcode==50) second_source=1;
    if(opcode==4) begin first_source=1;immediate_kind=3;end
    if(opcode>=16 && opcode<=31) immediate_kind=2;
    if(opcode>=43 && opcode<=51) full_width=0;
    if(opcode>=70 && opcode<=(lane==0?104:100) && opcode!=86) function_code=15;
    case(opcode)
      7'd6:function_code=4'd7;
      7'd7:function_code=4'd6;
      7'd8:function_code=4'd4;
      7'd9:function_code=4'd12;
      7'd10:function_code=4'd14;
      7'd11:function_code=4'd1;
      7'd12:function_code=4'd11;
      7'd13:function_code=4'd5;
      7'd14:function_code=4'd1;
      7'd16:function_code=4'd10;
      7'd17:function_code=4'd12;
      7'd18:function_code=4'd14;
      7'd19:function_code=4'd7;
      7'd20:function_code=4'd6;
      7'd21:function_code=4'd4;
      7'd22:function_code=4'd11;
      7'd23:function_code=4'd5;
      7'd24:function_code=4'd10;
      7'd25:function_code=4'd10;
      7'd26:function_code=4'd12;
      7'd27:function_code=4'd14;
      7'd28:function_code=4'd12;
      7'd29:function_code=4'd14;
      7'd45:function_code=4'd10;
      7'd46:function_code=4'd1;
      7'd47:function_code=4'd1;
      7'd48:function_code=4'd11;
      7'd49:function_code=4'd11;
      7'd50:function_code=4'd5;
      7'd51:function_code=4'd5;
      default:begin end
    endcase
    case(opcode)
      7'd24:branch_type=4'd2;
      7'd25:branch_type=4'd1;
      7'd26:branch_type=4'd3;
      7'd27:branch_type=4'd4;
      7'd28:branch_type=4'd5;
      7'd29:branch_type=4'd6;
      default:begin end
    endcase
    decode_control={branch_type,first_source,second_source,immediate_kind,function_code,full_width};
  end
endfunction
always_comb begin
  decoded0.uopc=io_iss_uops_0_uopc;
  decoded0.inst=io_iss_uops_0_inst;
  decoded0.debug_inst=io_iss_uops_0_debug_inst;
  decoded0.is_rvc=io_iss_uops_0_is_rvc;
  decoded0.debug_pc=io_iss_uops_0_debug_pc;
  decoded0.iq_type=io_iss_uops_0_iq_type;
  decoded0.fu_code=io_iss_uops_0_fu_code;
  decoded0.iw_state=io_iss_uops_0_iw_state;
  decoded0.is_br=io_iss_uops_0_is_br;
  decoded0.is_jalr=io_iss_uops_0_is_jalr;
  decoded0.is_jal=io_iss_uops_0_is_jal;
  decoded0.is_sfb=io_iss_uops_0_is_sfb;
  decoded0.br_mask=io_iss_uops_0_br_mask;
  decoded0.br_tag=io_iss_uops_0_br_tag;
  decoded0.ftq_idx=io_iss_uops_0_ftq_idx;
  decoded0.edge_inst=io_iss_uops_0_edge_inst;
  decoded0.pc_lob=io_iss_uops_0_pc_lob;
  decoded0.taken=io_iss_uops_0_taken;
  decoded0.imm_packed=io_iss_uops_0_imm_packed;
  decoded0.csr_addr=io_iss_uops_0_csr_addr;
  decoded0.rob_idx=io_iss_uops_0_rob_idx;
  decoded0.ldq_idx=io_iss_uops_0_ldq_idx;
  decoded0.stq_idx=io_iss_uops_0_stq_idx;
  decoded0.rxq_idx=io_iss_uops_0_rxq_idx;
  decoded0.pdst=io_iss_uops_0_pdst;
  decoded0.prs1=io_iss_uops_0_prs1;
  decoded0.prs2=io_iss_uops_0_prs2;
  decoded0.prs3=io_iss_uops_0_prs3;
  decoded0.ppred=io_iss_uops_0_ppred;
  decoded0.prs1_busy=io_iss_uops_0_prs1_busy;
  decoded0.prs2_busy=io_iss_uops_0_prs2_busy;
  decoded0.prs3_busy=io_iss_uops_0_prs3_busy;
  decoded0.ppred_busy=io_iss_uops_0_ppred_busy;
  decoded0.stale_pdst=io_iss_uops_0_stale_pdst;
  decoded0.exception=io_iss_uops_0_exception;
  decoded0.exc_cause=io_iss_uops_0_exc_cause;
  decoded0.bypassable=io_iss_uops_0_bypassable;
  decoded0.mem_cmd=io_iss_uops_0_mem_cmd;
  decoded0.mem_size=io_iss_uops_0_mem_size;
  decoded0.mem_signed=io_iss_uops_0_mem_signed;
  decoded0.is_fence=io_iss_uops_0_is_fence;
  decoded0.is_fencei=io_iss_uops_0_is_fencei;
  decoded0.is_amo=io_iss_uops_0_is_amo;
  decoded0.uses_ldq=io_iss_uops_0_uses_ldq;
  decoded0.uses_stq=io_iss_uops_0_uses_stq;
  decoded0.is_sys_pc2epc=io_iss_uops_0_is_sys_pc2epc;
  decoded0.is_unique=io_iss_uops_0_is_unique;
  decoded0.flush_on_commit=io_iss_uops_0_flush_on_commit;
  decoded0.ldst_is_rs1=io_iss_uops_0_ldst_is_rs1;
  decoded0.ldst=io_iss_uops_0_ldst;
  decoded0.lrs1=io_iss_uops_0_lrs1;
  decoded0.lrs2=io_iss_uops_0_lrs2;
  decoded0.lrs3=io_iss_uops_0_lrs3;
  decoded0.ldst_val=io_iss_uops_0_ldst_val;
  decoded0.dst_rtype=io_iss_uops_0_dst_rtype;
  decoded0.lrs1_rtype=io_iss_uops_0_lrs1_rtype;
  decoded0.lrs2_rtype=io_iss_uops_0_lrs2_rtype;
  decoded0.frs3_en=io_iss_uops_0_frs3_en;
  decoded0.fp_val=io_iss_uops_0_fp_val;
  decoded0.fp_single=io_iss_uops_0_fp_single;
  decoded0.xcpt_pf_if=io_iss_uops_0_xcpt_pf_if;
  decoded0.xcpt_ae_if=io_iss_uops_0_xcpt_ae_if;
  decoded0.xcpt_ma_if=io_iss_uops_0_xcpt_ma_if;
  decoded0.bp_debug_if=io_iss_uops_0_bp_debug_if;
  decoded0.bp_xcpt_if=io_iss_uops_0_bp_xcpt_if;
  decoded0.debug_fsrc=io_iss_uops_0_debug_fsrc;
  decoded0.debug_tsrc=io_iss_uops_0_debug_tsrc;
  {decoded0.ctrl_br_type,decoded0.ctrl_op1_sel,decoded0.ctrl_op2_sel,decoded0.ctrl_imm_sel,decoded0.ctrl_op_fcn,decoded0.ctrl_fcn_dw}=decode_control(io_iss_uops_0_uopc,0);
  decoded0.ctrl_csr_cmd=0;
  decoded0.ctrl_is_load=(io_iss_uops_0_uopc==1);
  decoded0.ctrl_is_sta=(io_iss_uops_0_uopc==2 || io_iss_uops_0_uopc==67);
  decoded0.ctrl_is_std=(io_iss_uops_0_uopc==3 || ((io_iss_uops_0_uopc==2 || io_iss_uops_0_uopc==67) && io_iss_uops_0_lrs2_rtype==0));
  decoded0.iw_p1_poisoned=0;
  decoded0.iw_p2_poisoned=0;
  if(io_iss_uops_0_uopc==67 || (io_iss_uops_0_uopc==1 && io_iss_uops_0_mem_cmd==6)) decoded0.imm_packed=0;
  decoded1.uopc=io_iss_uops_1_uopc;
  decoded1.inst=io_iss_uops_1_inst;
  decoded1.debug_inst=io_iss_uops_1_debug_inst;
  decoded1.is_rvc=io_iss_uops_1_is_rvc;
  decoded1.debug_pc=io_iss_uops_1_debug_pc;
  decoded1.iq_type=io_iss_uops_1_iq_type;
  decoded1.fu_code=io_iss_uops_1_fu_code;
  decoded1.iw_state=io_iss_uops_1_iw_state;
  decoded1.is_br=io_iss_uops_1_is_br;
  decoded1.is_jalr=io_iss_uops_1_is_jalr;
  decoded1.is_jal=io_iss_uops_1_is_jal;
  decoded1.is_sfb=io_iss_uops_1_is_sfb;
  decoded1.br_mask=io_iss_uops_1_br_mask;
  decoded1.br_tag=io_iss_uops_1_br_tag;
  decoded1.ftq_idx=io_iss_uops_1_ftq_idx;
  decoded1.edge_inst=io_iss_uops_1_edge_inst;
  decoded1.pc_lob=io_iss_uops_1_pc_lob;
  decoded1.taken=io_iss_uops_1_taken;
  decoded1.imm_packed=io_iss_uops_1_imm_packed;
  decoded1.csr_addr=io_iss_uops_1_csr_addr;
  decoded1.rob_idx=io_iss_uops_1_rob_idx;
  decoded1.ldq_idx=io_iss_uops_1_ldq_idx;
  decoded1.stq_idx=io_iss_uops_1_stq_idx;
  decoded1.rxq_idx=io_iss_uops_1_rxq_idx;
  decoded1.pdst=io_iss_uops_1_pdst;
  decoded1.prs1=io_iss_uops_1_prs1;
  decoded1.prs2=io_iss_uops_1_prs2;
  decoded1.prs3=io_iss_uops_1_prs3;
  decoded1.ppred=io_iss_uops_1_ppred;
  decoded1.prs1_busy=io_iss_uops_1_prs1_busy;
  decoded1.prs2_busy=io_iss_uops_1_prs2_busy;
  decoded1.prs3_busy=io_iss_uops_1_prs3_busy;
  decoded1.ppred_busy=io_iss_uops_1_ppred_busy;
  decoded1.stale_pdst=io_iss_uops_1_stale_pdst;
  decoded1.exception=io_iss_uops_1_exception;
  decoded1.exc_cause=io_iss_uops_1_exc_cause;
  decoded1.bypassable=io_iss_uops_1_bypassable;
  decoded1.mem_cmd=io_iss_uops_1_mem_cmd;
  decoded1.mem_size=io_iss_uops_1_mem_size;
  decoded1.mem_signed=io_iss_uops_1_mem_signed;
  decoded1.is_fence=io_iss_uops_1_is_fence;
  decoded1.is_fencei=io_iss_uops_1_is_fencei;
  decoded1.is_amo=io_iss_uops_1_is_amo;
  decoded1.uses_ldq=io_iss_uops_1_uses_ldq;
  decoded1.uses_stq=io_iss_uops_1_uses_stq;
  decoded1.is_sys_pc2epc=io_iss_uops_1_is_sys_pc2epc;
  decoded1.is_unique=io_iss_uops_1_is_unique;
  decoded1.flush_on_commit=io_iss_uops_1_flush_on_commit;
  decoded1.ldst_is_rs1=io_iss_uops_1_ldst_is_rs1;
  decoded1.ldst=io_iss_uops_1_ldst;
  decoded1.lrs1=io_iss_uops_1_lrs1;
  decoded1.lrs2=io_iss_uops_1_lrs2;
  decoded1.lrs3=io_iss_uops_1_lrs3;
  decoded1.ldst_val=io_iss_uops_1_ldst_val;
  decoded1.dst_rtype=io_iss_uops_1_dst_rtype;
  decoded1.lrs1_rtype=io_iss_uops_1_lrs1_rtype;
  decoded1.lrs2_rtype=io_iss_uops_1_lrs2_rtype;
  decoded1.frs3_en=io_iss_uops_1_frs3_en;
  decoded1.fp_val=io_iss_uops_1_fp_val;
  decoded1.fp_single=io_iss_uops_1_fp_single;
  decoded1.xcpt_pf_if=io_iss_uops_1_xcpt_pf_if;
  decoded1.xcpt_ae_if=io_iss_uops_1_xcpt_ae_if;
  decoded1.xcpt_ma_if=io_iss_uops_1_xcpt_ma_if;
  decoded1.bp_debug_if=io_iss_uops_1_bp_debug_if;
  decoded1.bp_xcpt_if=io_iss_uops_1_bp_xcpt_if;
  decoded1.debug_fsrc=io_iss_uops_1_debug_fsrc;
  decoded1.debug_tsrc=io_iss_uops_1_debug_tsrc;
  {decoded1.ctrl_br_type,decoded1.ctrl_op1_sel,decoded1.ctrl_op2_sel,decoded1.ctrl_imm_sel,decoded1.ctrl_op_fcn,decoded1.ctrl_fcn_dw}=decode_control(io_iss_uops_1_uopc,1);
  decoded1.ctrl_csr_cmd=0;
  decoded1.ctrl_is_load=(io_iss_uops_1_uopc==1);
  decoded1.ctrl_is_sta=(io_iss_uops_1_uopc==2 || io_iss_uops_1_uopc==67);
  decoded1.ctrl_is_std=(io_iss_uops_1_uopc==3 || ((io_iss_uops_1_uopc==2 || io_iss_uops_1_uopc==67) && io_iss_uops_1_lrs2_rtype==0));
  decoded1.iw_p1_poisoned=0;
  decoded1.iw_p2_poisoned=0;
  if(io_iss_uops_1_uopc==67 || (io_iss_uops_1_uopc==1 && io_iss_uops_1_mem_cmd==6)) decoded1.imm_packed=0;
end
assign io_exe_reqs_0_bits_uop_uopc=executing0.uopc;
assign io_exe_reqs_0_bits_uop_inst=executing0.inst;
assign io_exe_reqs_0_bits_uop_debug_inst=executing0.debug_inst;
assign io_exe_reqs_0_bits_uop_is_rvc=executing0.is_rvc;
assign io_exe_reqs_0_bits_uop_debug_pc=executing0.debug_pc;
assign io_exe_reqs_0_bits_uop_iq_type=executing0.iq_type;
assign io_exe_reqs_0_bits_uop_fu_code=executing0.fu_code;
assign io_exe_reqs_0_bits_uop_ctrl_br_type=executing0.ctrl_br_type;
assign io_exe_reqs_0_bits_uop_ctrl_op1_sel=executing0.ctrl_op1_sel;
assign io_exe_reqs_0_bits_uop_ctrl_op2_sel=executing0.ctrl_op2_sel;
assign io_exe_reqs_0_bits_uop_ctrl_imm_sel=executing0.ctrl_imm_sel;
assign io_exe_reqs_0_bits_uop_ctrl_op_fcn=executing0.ctrl_op_fcn;
assign io_exe_reqs_0_bits_uop_ctrl_fcn_dw=executing0.ctrl_fcn_dw;
assign io_exe_reqs_0_bits_uop_ctrl_csr_cmd=executing0.ctrl_csr_cmd;
assign io_exe_reqs_0_bits_uop_ctrl_is_load=executing0.ctrl_is_load;
assign io_exe_reqs_0_bits_uop_ctrl_is_sta=executing0.ctrl_is_sta;
assign io_exe_reqs_0_bits_uop_ctrl_is_std=executing0.ctrl_is_std;
assign io_exe_reqs_0_bits_uop_iw_state=executing0.iw_state;
assign io_exe_reqs_0_bits_uop_iw_p1_poisoned=executing0.iw_p1_poisoned;
assign io_exe_reqs_0_bits_uop_iw_p2_poisoned=executing0.iw_p2_poisoned;
assign io_exe_reqs_0_bits_uop_is_br=executing0.is_br;
assign io_exe_reqs_0_bits_uop_is_jalr=executing0.is_jalr;
assign io_exe_reqs_0_bits_uop_is_jal=executing0.is_jal;
assign io_exe_reqs_0_bits_uop_is_sfb=executing0.is_sfb;
assign io_exe_reqs_0_bits_uop_br_mask=executing0.br_mask;
assign io_exe_reqs_0_bits_uop_br_tag=executing0.br_tag;
assign io_exe_reqs_0_bits_uop_ftq_idx=executing0.ftq_idx;
assign io_exe_reqs_0_bits_uop_edge_inst=executing0.edge_inst;
assign io_exe_reqs_0_bits_uop_pc_lob=executing0.pc_lob;
assign io_exe_reqs_0_bits_uop_taken=executing0.taken;
assign io_exe_reqs_0_bits_uop_imm_packed=executing0.imm_packed;
assign io_exe_reqs_0_bits_uop_csr_addr=executing0.csr_addr;
assign io_exe_reqs_0_bits_uop_rob_idx=executing0.rob_idx;
assign io_exe_reqs_0_bits_uop_ldq_idx=executing0.ldq_idx;
assign io_exe_reqs_0_bits_uop_stq_idx=executing0.stq_idx;
assign io_exe_reqs_0_bits_uop_rxq_idx=executing0.rxq_idx;
assign io_exe_reqs_0_bits_uop_pdst=executing0.pdst;
assign io_exe_reqs_0_bits_uop_prs1=executing0.prs1;
assign io_exe_reqs_0_bits_uop_prs2=executing0.prs2;
assign io_exe_reqs_0_bits_uop_prs3=executing0.prs3;
assign io_exe_reqs_0_bits_uop_ppred=executing0.ppred;
assign io_exe_reqs_0_bits_uop_prs1_busy=executing0.prs1_busy;
assign io_exe_reqs_0_bits_uop_prs2_busy=executing0.prs2_busy;
assign io_exe_reqs_0_bits_uop_prs3_busy=executing0.prs3_busy;
assign io_exe_reqs_0_bits_uop_ppred_busy=executing0.ppred_busy;
assign io_exe_reqs_0_bits_uop_stale_pdst=executing0.stale_pdst;
assign io_exe_reqs_0_bits_uop_exception=executing0.exception;
assign io_exe_reqs_0_bits_uop_exc_cause=executing0.exc_cause;
assign io_exe_reqs_0_bits_uop_bypassable=executing0.bypassable;
assign io_exe_reqs_0_bits_uop_mem_cmd=executing0.mem_cmd;
assign io_exe_reqs_0_bits_uop_mem_size=executing0.mem_size;
assign io_exe_reqs_0_bits_uop_mem_signed=executing0.mem_signed;
assign io_exe_reqs_0_bits_uop_is_fence=executing0.is_fence;
assign io_exe_reqs_0_bits_uop_is_fencei=executing0.is_fencei;
assign io_exe_reqs_0_bits_uop_is_amo=executing0.is_amo;
assign io_exe_reqs_0_bits_uop_uses_ldq=executing0.uses_ldq;
assign io_exe_reqs_0_bits_uop_uses_stq=executing0.uses_stq;
assign io_exe_reqs_0_bits_uop_is_sys_pc2epc=executing0.is_sys_pc2epc;
assign io_exe_reqs_0_bits_uop_is_unique=executing0.is_unique;
assign io_exe_reqs_0_bits_uop_flush_on_commit=executing0.flush_on_commit;
assign io_exe_reqs_0_bits_uop_ldst_is_rs1=executing0.ldst_is_rs1;
assign io_exe_reqs_0_bits_uop_ldst=executing0.ldst;
assign io_exe_reqs_0_bits_uop_lrs1=executing0.lrs1;
assign io_exe_reqs_0_bits_uop_lrs2=executing0.lrs2;
assign io_exe_reqs_0_bits_uop_lrs3=executing0.lrs3;
assign io_exe_reqs_0_bits_uop_ldst_val=executing0.ldst_val;
assign io_exe_reqs_0_bits_uop_dst_rtype=executing0.dst_rtype;
assign io_exe_reqs_0_bits_uop_lrs1_rtype=executing0.lrs1_rtype;
assign io_exe_reqs_0_bits_uop_lrs2_rtype=executing0.lrs2_rtype;
assign io_exe_reqs_0_bits_uop_frs3_en=executing0.frs3_en;
assign io_exe_reqs_0_bits_uop_fp_val=executing0.fp_val;
assign io_exe_reqs_0_bits_uop_fp_single=executing0.fp_single;
assign io_exe_reqs_0_bits_uop_xcpt_pf_if=executing0.xcpt_pf_if;
assign io_exe_reqs_0_bits_uop_xcpt_ae_if=executing0.xcpt_ae_if;
assign io_exe_reqs_0_bits_uop_xcpt_ma_if=executing0.xcpt_ma_if;
assign io_exe_reqs_0_bits_uop_bp_debug_if=executing0.bp_debug_if;
assign io_exe_reqs_0_bits_uop_bp_xcpt_if=executing0.bp_xcpt_if;
assign io_exe_reqs_0_bits_uop_debug_fsrc=executing0.debug_fsrc;
assign io_exe_reqs_0_bits_uop_debug_tsrc=executing0.debug_tsrc;
always_comb cancelled[0]=io_kill || ((issued0.br_mask & io_brupdate_b1_mispredict_mask)!=0);
assign io_rf_read_ports_0_addr=io_iss_uops_0_prs1;
assign io_rf_read_ports_1_addr=io_iss_uops_0_prs2;
assign io_rf_read_ports_2_addr=io_iss_uops_0_prs3;
assign io_exe_reqs_1_bits_uop_uopc=executing1.uopc;
assign io_exe_reqs_1_bits_uop_inst=executing1.inst;
assign io_exe_reqs_1_bits_uop_debug_inst=executing1.debug_inst;
assign io_exe_reqs_1_bits_uop_is_rvc=executing1.is_rvc;
assign io_exe_reqs_1_bits_uop_debug_pc=executing1.debug_pc;
assign io_exe_reqs_1_bits_uop_iq_type=executing1.iq_type;
assign io_exe_reqs_1_bits_uop_fu_code=executing1.fu_code;
assign io_exe_reqs_1_bits_uop_ctrl_br_type=executing1.ctrl_br_type;
assign io_exe_reqs_1_bits_uop_ctrl_op1_sel=executing1.ctrl_op1_sel;
assign io_exe_reqs_1_bits_uop_ctrl_op2_sel=executing1.ctrl_op2_sel;
assign io_exe_reqs_1_bits_uop_ctrl_imm_sel=executing1.ctrl_imm_sel;
assign io_exe_reqs_1_bits_uop_ctrl_op_fcn=executing1.ctrl_op_fcn;
assign io_exe_reqs_1_bits_uop_ctrl_fcn_dw=executing1.ctrl_fcn_dw;
assign io_exe_reqs_1_bits_uop_ctrl_csr_cmd=executing1.ctrl_csr_cmd;
assign io_exe_reqs_1_bits_uop_ctrl_is_load=executing1.ctrl_is_load;
assign io_exe_reqs_1_bits_uop_ctrl_is_sta=executing1.ctrl_is_sta;
assign io_exe_reqs_1_bits_uop_ctrl_is_std=executing1.ctrl_is_std;
assign io_exe_reqs_1_bits_uop_iw_state=executing1.iw_state;
assign io_exe_reqs_1_bits_uop_iw_p1_poisoned=executing1.iw_p1_poisoned;
assign io_exe_reqs_1_bits_uop_iw_p2_poisoned=executing1.iw_p2_poisoned;
assign io_exe_reqs_1_bits_uop_is_br=executing1.is_br;
assign io_exe_reqs_1_bits_uop_is_jalr=executing1.is_jalr;
assign io_exe_reqs_1_bits_uop_is_jal=executing1.is_jal;
assign io_exe_reqs_1_bits_uop_is_sfb=executing1.is_sfb;
assign io_exe_reqs_1_bits_uop_br_mask=executing1.br_mask;
assign io_exe_reqs_1_bits_uop_br_tag=executing1.br_tag;
assign io_exe_reqs_1_bits_uop_ftq_idx=executing1.ftq_idx;
assign io_exe_reqs_1_bits_uop_edge_inst=executing1.edge_inst;
assign io_exe_reqs_1_bits_uop_pc_lob=executing1.pc_lob;
assign io_exe_reqs_1_bits_uop_taken=executing1.taken;
assign io_exe_reqs_1_bits_uop_imm_packed=executing1.imm_packed;
assign io_exe_reqs_1_bits_uop_csr_addr=executing1.csr_addr;
assign io_exe_reqs_1_bits_uop_rob_idx=executing1.rob_idx;
assign io_exe_reqs_1_bits_uop_ldq_idx=executing1.ldq_idx;
assign io_exe_reqs_1_bits_uop_stq_idx=executing1.stq_idx;
assign io_exe_reqs_1_bits_uop_rxq_idx=executing1.rxq_idx;
assign io_exe_reqs_1_bits_uop_pdst=executing1.pdst;
assign io_exe_reqs_1_bits_uop_prs1=executing1.prs1;
assign io_exe_reqs_1_bits_uop_prs2=executing1.prs2;
assign io_exe_reqs_1_bits_uop_prs3=executing1.prs3;
assign io_exe_reqs_1_bits_uop_ppred=executing1.ppred;
assign io_exe_reqs_1_bits_uop_prs1_busy=executing1.prs1_busy;
assign io_exe_reqs_1_bits_uop_prs2_busy=executing1.prs2_busy;
assign io_exe_reqs_1_bits_uop_prs3_busy=executing1.prs3_busy;
assign io_exe_reqs_1_bits_uop_ppred_busy=executing1.ppred_busy;
assign io_exe_reqs_1_bits_uop_stale_pdst=executing1.stale_pdst;
assign io_exe_reqs_1_bits_uop_exception=executing1.exception;
assign io_exe_reqs_1_bits_uop_exc_cause=executing1.exc_cause;
assign io_exe_reqs_1_bits_uop_bypassable=executing1.bypassable;
assign io_exe_reqs_1_bits_uop_mem_cmd=executing1.mem_cmd;
assign io_exe_reqs_1_bits_uop_mem_size=executing1.mem_size;
assign io_exe_reqs_1_bits_uop_mem_signed=executing1.mem_signed;
assign io_exe_reqs_1_bits_uop_is_fence=executing1.is_fence;
assign io_exe_reqs_1_bits_uop_is_fencei=executing1.is_fencei;
assign io_exe_reqs_1_bits_uop_is_amo=executing1.is_amo;
assign io_exe_reqs_1_bits_uop_uses_ldq=executing1.uses_ldq;
assign io_exe_reqs_1_bits_uop_uses_stq=executing1.uses_stq;
assign io_exe_reqs_1_bits_uop_is_sys_pc2epc=executing1.is_sys_pc2epc;
assign io_exe_reqs_1_bits_uop_is_unique=executing1.is_unique;
assign io_exe_reqs_1_bits_uop_flush_on_commit=executing1.flush_on_commit;
assign io_exe_reqs_1_bits_uop_ldst_is_rs1=executing1.ldst_is_rs1;
assign io_exe_reqs_1_bits_uop_ldst=executing1.ldst;
assign io_exe_reqs_1_bits_uop_lrs1=executing1.lrs1;
assign io_exe_reqs_1_bits_uop_lrs2=executing1.lrs2;
assign io_exe_reqs_1_bits_uop_lrs3=executing1.lrs3;
assign io_exe_reqs_1_bits_uop_ldst_val=executing1.ldst_val;
assign io_exe_reqs_1_bits_uop_dst_rtype=executing1.dst_rtype;
assign io_exe_reqs_1_bits_uop_lrs1_rtype=executing1.lrs1_rtype;
assign io_exe_reqs_1_bits_uop_lrs2_rtype=executing1.lrs2_rtype;
assign io_exe_reqs_1_bits_uop_frs3_en=executing1.frs3_en;
assign io_exe_reqs_1_bits_uop_fp_val=executing1.fp_val;
assign io_exe_reqs_1_bits_uop_fp_single=executing1.fp_single;
assign io_exe_reqs_1_bits_uop_xcpt_pf_if=executing1.xcpt_pf_if;
assign io_exe_reqs_1_bits_uop_xcpt_ae_if=executing1.xcpt_ae_if;
assign io_exe_reqs_1_bits_uop_xcpt_ma_if=executing1.xcpt_ma_if;
assign io_exe_reqs_1_bits_uop_bp_debug_if=executing1.bp_debug_if;
assign io_exe_reqs_1_bits_uop_bp_xcpt_if=executing1.bp_xcpt_if;
assign io_exe_reqs_1_bits_uop_debug_fsrc=executing1.debug_fsrc;
assign io_exe_reqs_1_bits_uop_debug_tsrc=executing1.debug_tsrc;
always_comb cancelled[1]=io_kill || ((issued1.br_mask & io_brupdate_b1_mispredict_mask)!=0);
assign io_rf_read_ports_3_addr=io_iss_uops_1_prs1;
assign io_rf_read_ports_4_addr=io_iss_uops_1_prs2;
assign io_rf_read_ports_5_addr=io_iss_uops_1_prs3;
always @(posedge clock) begin
  io_exe_reqs_0_valid<=reset?1'b0:(issued_valid[0] && !cancelled[0]);
  executing0.uopc<=cancelled[0]?'0:issued0.uopc;
  executing0.inst<=cancelled[0]?'0:issued0.inst;
  executing0.debug_inst<=cancelled[0]?'0:issued0.debug_inst;
  executing0.is_rvc<=cancelled[0]?'0:issued0.is_rvc;
  executing0.debug_pc<=cancelled[0]?'0:issued0.debug_pc;
  executing0.iq_type<=cancelled[0]?'0:issued0.iq_type;
  executing0.fu_code<=cancelled[0]?'0:issued0.fu_code;
  executing0.ctrl_br_type<=cancelled[0]?'0:issued0.ctrl_br_type;
  executing0.ctrl_op1_sel<=cancelled[0]?'0:issued0.ctrl_op1_sel;
  executing0.ctrl_op2_sel<=cancelled[0]?'0:issued0.ctrl_op2_sel;
  executing0.ctrl_imm_sel<=cancelled[0]?'0:issued0.ctrl_imm_sel;
  executing0.ctrl_op_fcn<=cancelled[0]?'0:issued0.ctrl_op_fcn;
  executing0.ctrl_fcn_dw<=cancelled[0]?'0:issued0.ctrl_fcn_dw;
  executing0.ctrl_csr_cmd<=cancelled[0]?'0:issued0.ctrl_csr_cmd;
  executing0.ctrl_is_load<=cancelled[0]?'0:issued0.ctrl_is_load;
  executing0.ctrl_is_sta<=cancelled[0]?'0:issued0.ctrl_is_sta;
  executing0.ctrl_is_std<=cancelled[0]?'0:issued0.ctrl_is_std;
  executing0.iw_state<=cancelled[0]?'0:issued0.iw_state;
  executing0.iw_p1_poisoned<=cancelled[0]?'0:issued0.iw_p1_poisoned;
  executing0.iw_p2_poisoned<=cancelled[0]?'0:issued0.iw_p2_poisoned;
  executing0.is_br<=cancelled[0]?'0:issued0.is_br;
  executing0.is_jalr<=cancelled[0]?'0:issued0.is_jalr;
  executing0.is_jal<=cancelled[0]?'0:issued0.is_jal;
  executing0.is_sfb<=cancelled[0]?'0:issued0.is_sfb;
  executing0.br_mask<=issued0.br_mask & ~io_brupdate_b1_resolve_mask;
  executing0.br_tag<=cancelled[0]?'0:issued0.br_tag;
  executing0.ftq_idx<=cancelled[0]?'0:issued0.ftq_idx;
  executing0.edge_inst<=cancelled[0]?'0:issued0.edge_inst;
  executing0.pc_lob<=cancelled[0]?'0:issued0.pc_lob;
  executing0.taken<=cancelled[0]?'0:issued0.taken;
  executing0.imm_packed<=cancelled[0]?'0:issued0.imm_packed;
  executing0.csr_addr<=cancelled[0]?'0:issued0.csr_addr;
  executing0.rob_idx<=cancelled[0]?'0:issued0.rob_idx;
  executing0.ldq_idx<=cancelled[0]?'0:issued0.ldq_idx;
  executing0.stq_idx<=cancelled[0]?'0:issued0.stq_idx;
  executing0.rxq_idx<=cancelled[0]?'0:issued0.rxq_idx;
  executing0.pdst<=cancelled[0]?'0:issued0.pdst;
  executing0.prs1<=cancelled[0]?'0:issued0.prs1;
  executing0.prs2<=cancelled[0]?'0:issued0.prs2;
  executing0.prs3<=cancelled[0]?'0:issued0.prs3;
  executing0.ppred<=cancelled[0]?'0:issued0.ppred;
  executing0.prs1_busy<=cancelled[0]?'0:issued0.prs1_busy;
  executing0.prs2_busy<=cancelled[0]?'0:issued0.prs2_busy;
  executing0.prs3_busy<=cancelled[0]?'0:issued0.prs3_busy;
  executing0.ppred_busy<=cancelled[0]?'0:issued0.ppred_busy;
  executing0.stale_pdst<=cancelled[0]?'0:issued0.stale_pdst;
  executing0.exception<=cancelled[0]?'0:issued0.exception;
  executing0.exc_cause<=cancelled[0]?'0:issued0.exc_cause;
  executing0.bypassable<=cancelled[0]?'0:issued0.bypassable;
  executing0.mem_cmd<=cancelled[0]?'0:issued0.mem_cmd;
  executing0.mem_size<=cancelled[0]?'0:issued0.mem_size;
  executing0.mem_signed<=cancelled[0]?'0:issued0.mem_signed;
  executing0.is_fence<=cancelled[0]?'0:issued0.is_fence;
  executing0.is_fencei<=cancelled[0]?'0:issued0.is_fencei;
  executing0.is_amo<=cancelled[0]?'0:issued0.is_amo;
  executing0.uses_ldq<=cancelled[0]?'0:issued0.uses_ldq;
  executing0.uses_stq<=cancelled[0]?'0:issued0.uses_stq;
  executing0.is_sys_pc2epc<=cancelled[0]?'0:issued0.is_sys_pc2epc;
  executing0.is_unique<=cancelled[0]?'0:issued0.is_unique;
  executing0.flush_on_commit<=cancelled[0]?'0:issued0.flush_on_commit;
  executing0.ldst_is_rs1<=cancelled[0]?'0:issued0.ldst_is_rs1;
  executing0.ldst<=cancelled[0]?'0:issued0.ldst;
  executing0.lrs1<=cancelled[0]?'0:issued0.lrs1;
  executing0.lrs2<=cancelled[0]?'0:issued0.lrs2;
  executing0.lrs3<=cancelled[0]?'0:issued0.lrs3;
  executing0.ldst_val<=cancelled[0]?'0:issued0.ldst_val;
  executing0.dst_rtype<=cancelled[0]?2'd2:issued0.dst_rtype;
  executing0.lrs1_rtype<=cancelled[0]?'0:issued0.lrs1_rtype;
  executing0.lrs2_rtype<=cancelled[0]?'0:issued0.lrs2_rtype;
  executing0.frs3_en<=cancelled[0]?'0:issued0.frs3_en;
  executing0.fp_val<=cancelled[0]?'0:issued0.fp_val;
  executing0.fp_single<=cancelled[0]?'0:issued0.fp_single;
  executing0.xcpt_pf_if<=cancelled[0]?'0:issued0.xcpt_pf_if;
  executing0.xcpt_ae_if<=cancelled[0]?'0:issued0.xcpt_ae_if;
  executing0.xcpt_ma_if<=cancelled[0]?'0:issued0.xcpt_ma_if;
  executing0.bp_debug_if<=cancelled[0]?'0:issued0.bp_debug_if;
  executing0.bp_xcpt_if<=cancelled[0]?'0:issued0.bp_xcpt_if;
  executing0.debug_fsrc<=cancelled[0]?'0:issued0.debug_fsrc;
  executing0.debug_tsrc<=cancelled[0]?'0:issued0.debug_tsrc;
  io_exe_reqs_0_bits_rs1_data<=zero_source[0][0]?65'b0:io_rf_read_ports_0_data;
  zero_source[0][0]<=(io_iss_uops_0_prs1==0);
  io_exe_reqs_0_bits_rs2_data<=zero_source[0][1]?65'b0:io_rf_read_ports_1_data;
  zero_source[0][1]<=(io_iss_uops_0_prs2==0);
  io_exe_reqs_0_bits_rs3_data<=zero_source[0][2]?65'b0:io_rf_read_ports_2_data;
  zero_source[0][2]<=(io_iss_uops_0_prs3==0);
  issued_valid[0]<=io_iss_valids_0 && ((io_iss_uops_0_br_mask & io_brupdate_b1_mispredict_mask)==0);
  issued0<=decoded0;
  issued0.br_mask<=decoded0.br_mask & ~io_brupdate_b1_resolve_mask;
  io_exe_reqs_1_valid<=reset?1'b0:(issued_valid[1] && !cancelled[1]);
  executing1.uopc<=cancelled[1]?'0:issued1.uopc;
  executing1.inst<=cancelled[1]?'0:issued1.inst;
  executing1.debug_inst<=cancelled[1]?'0:issued1.debug_inst;
  executing1.is_rvc<=cancelled[1]?'0:issued1.is_rvc;
  executing1.debug_pc<=cancelled[1]?'0:issued1.debug_pc;
  executing1.iq_type<=cancelled[1]?'0:issued1.iq_type;
  executing1.fu_code<=cancelled[1]?'0:issued1.fu_code;
  executing1.ctrl_br_type<=cancelled[1]?'0:issued1.ctrl_br_type;
  executing1.ctrl_op1_sel<=cancelled[1]?'0:issued1.ctrl_op1_sel;
  executing1.ctrl_op2_sel<=cancelled[1]?'0:issued1.ctrl_op2_sel;
  executing1.ctrl_imm_sel<=cancelled[1]?'0:issued1.ctrl_imm_sel;
  executing1.ctrl_op_fcn<=cancelled[1]?'0:issued1.ctrl_op_fcn;
  executing1.ctrl_fcn_dw<=cancelled[1]?'0:issued1.ctrl_fcn_dw;
  executing1.ctrl_csr_cmd<=cancelled[1]?'0:issued1.ctrl_csr_cmd;
  executing1.ctrl_is_load<=cancelled[1]?'0:issued1.ctrl_is_load;
  executing1.ctrl_is_sta<=cancelled[1]?'0:issued1.ctrl_is_sta;
  executing1.ctrl_is_std<=cancelled[1]?'0:issued1.ctrl_is_std;
  executing1.iw_state<=cancelled[1]?'0:issued1.iw_state;
  executing1.iw_p1_poisoned<=cancelled[1]?'0:issued1.iw_p1_poisoned;
  executing1.iw_p2_poisoned<=cancelled[1]?'0:issued1.iw_p2_poisoned;
  executing1.is_br<=cancelled[1]?'0:issued1.is_br;
  executing1.is_jalr<=cancelled[1]?'0:issued1.is_jalr;
  executing1.is_jal<=cancelled[1]?'0:issued1.is_jal;
  executing1.is_sfb<=cancelled[1]?'0:issued1.is_sfb;
  executing1.br_mask<=issued1.br_mask & ~io_brupdate_b1_resolve_mask;
  executing1.br_tag<=cancelled[1]?'0:issued1.br_tag;
  executing1.ftq_idx<=cancelled[1]?'0:issued1.ftq_idx;
  executing1.edge_inst<=cancelled[1]?'0:issued1.edge_inst;
  executing1.pc_lob<=cancelled[1]?'0:issued1.pc_lob;
  executing1.taken<=cancelled[1]?'0:issued1.taken;
  executing1.imm_packed<=cancelled[1]?'0:issued1.imm_packed;
  executing1.csr_addr<=cancelled[1]?'0:issued1.csr_addr;
  executing1.rob_idx<=cancelled[1]?'0:issued1.rob_idx;
  executing1.ldq_idx<=cancelled[1]?'0:issued1.ldq_idx;
  executing1.stq_idx<=cancelled[1]?'0:issued1.stq_idx;
  executing1.rxq_idx<=cancelled[1]?'0:issued1.rxq_idx;
  executing1.pdst<=cancelled[1]?'0:issued1.pdst;
  executing1.prs1<=cancelled[1]?'0:issued1.prs1;
  executing1.prs2<=cancelled[1]?'0:issued1.prs2;
  executing1.prs3<=cancelled[1]?'0:issued1.prs3;
  executing1.ppred<=cancelled[1]?'0:issued1.ppred;
  executing1.prs1_busy<=cancelled[1]?'0:issued1.prs1_busy;
  executing1.prs2_busy<=cancelled[1]?'0:issued1.prs2_busy;
  executing1.prs3_busy<=cancelled[1]?'0:issued1.prs3_busy;
  executing1.ppred_busy<=cancelled[1]?'0:issued1.ppred_busy;
  executing1.stale_pdst<=cancelled[1]?'0:issued1.stale_pdst;
  executing1.exception<=cancelled[1]?'0:issued1.exception;
  executing1.exc_cause<=cancelled[1]?'0:issued1.exc_cause;
  executing1.bypassable<=cancelled[1]?'0:issued1.bypassable;
  executing1.mem_cmd<=cancelled[1]?'0:issued1.mem_cmd;
  executing1.mem_size<=cancelled[1]?'0:issued1.mem_size;
  executing1.mem_signed<=cancelled[1]?'0:issued1.mem_signed;
  executing1.is_fence<=cancelled[1]?'0:issued1.is_fence;
  executing1.is_fencei<=cancelled[1]?'0:issued1.is_fencei;
  executing1.is_amo<=cancelled[1]?'0:issued1.is_amo;
  executing1.uses_ldq<=cancelled[1]?'0:issued1.uses_ldq;
  executing1.uses_stq<=cancelled[1]?'0:issued1.uses_stq;
  executing1.is_sys_pc2epc<=cancelled[1]?'0:issued1.is_sys_pc2epc;
  executing1.is_unique<=cancelled[1]?'0:issued1.is_unique;
  executing1.flush_on_commit<=cancelled[1]?'0:issued1.flush_on_commit;
  executing1.ldst_is_rs1<=cancelled[1]?'0:issued1.ldst_is_rs1;
  executing1.ldst<=cancelled[1]?'0:issued1.ldst;
  executing1.lrs1<=cancelled[1]?'0:issued1.lrs1;
  executing1.lrs2<=cancelled[1]?'0:issued1.lrs2;
  executing1.lrs3<=cancelled[1]?'0:issued1.lrs3;
  executing1.ldst_val<=cancelled[1]?'0:issued1.ldst_val;
  executing1.dst_rtype<=cancelled[1]?2'd2:issued1.dst_rtype;
  executing1.lrs1_rtype<=cancelled[1]?'0:issued1.lrs1_rtype;
  executing1.lrs2_rtype<=cancelled[1]?'0:issued1.lrs2_rtype;
  executing1.frs3_en<=cancelled[1]?'0:issued1.frs3_en;
  executing1.fp_val<=cancelled[1]?'0:issued1.fp_val;
  executing1.fp_single<=cancelled[1]?'0:issued1.fp_single;
  executing1.xcpt_pf_if<=cancelled[1]?'0:issued1.xcpt_pf_if;
  executing1.xcpt_ae_if<=cancelled[1]?'0:issued1.xcpt_ae_if;
  executing1.xcpt_ma_if<=cancelled[1]?'0:issued1.xcpt_ma_if;
  executing1.bp_debug_if<=cancelled[1]?'0:issued1.bp_debug_if;
  executing1.bp_xcpt_if<=cancelled[1]?'0:issued1.bp_xcpt_if;
  executing1.debug_fsrc<=cancelled[1]?'0:issued1.debug_fsrc;
  executing1.debug_tsrc<=cancelled[1]?'0:issued1.debug_tsrc;
  io_exe_reqs_1_bits_rs1_data<=zero_source[1][0]?65'b0:io_rf_read_ports_3_data;
  zero_source[1][0]<=(io_iss_uops_1_prs1==0);
  io_exe_reqs_1_bits_rs2_data<=zero_source[1][1]?65'b0:io_rf_read_ports_4_data;
  zero_source[1][1]<=(io_iss_uops_1_prs2==0);
  io_exe_reqs_1_bits_rs3_data<=zero_source[1][2]?65'b0:io_rf_read_ports_5_data;
  zero_source[1][2]<=(io_iss_uops_1_prs3==0);
  issued_valid[1]<=io_iss_valids_1 && ((io_iss_uops_1_br_mask & io_brupdate_b1_mispredict_mask)==0);
  issued1<=decoded1;
  issued1.br_mask<=decoded1.br_mask & ~io_brupdate_b1_resolve_mask;
end

endmodule
