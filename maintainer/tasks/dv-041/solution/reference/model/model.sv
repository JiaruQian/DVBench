`timescale 1ns/1ps
module dvbench_model(
  input logic clock,
  output logic [32:0] io_mem_access_bits_address,
  output logic [127:0] io_mem_access_bits_data,
  output logic [15:0] io_mem_access_bits_mask,
  output logic [2:0] io_mem_access_bits_opcode,
  output logic [2:0] io_mem_access_bits_param,
  output logic [3:0] io_mem_access_bits_size,
  output logic [3:0] io_mem_access_bits_source,
  input logic io_mem_access_ready,
  output logic io_mem_access_valid,
  input logic [127:0] io_mem_ack_bits_data,
  input logic io_mem_ack_valid,
  input logic [39:0] io_req_bits_addr,
  input logic [63:0] io_req_bits_data,
  input logic io_req_bits_is_hella,
  input logic io_req_bits_uop_bp_debug_if,
  input logic io_req_bits_uop_bp_xcpt_if,
  input logic [19:0] io_req_bits_uop_br_mask,
  input logic [4:0] io_req_bits_uop_br_tag,
  input logic io_req_bits_uop_bypassable,
  input logic [11:0] io_req_bits_uop_csr_addr,
  input logic [3:0] io_req_bits_uop_ctrl_br_type,
  input logic [2:0] io_req_bits_uop_ctrl_csr_cmd,
  input logic io_req_bits_uop_ctrl_fcn_dw,
  input logic [2:0] io_req_bits_uop_ctrl_imm_sel,
  input logic io_req_bits_uop_ctrl_is_load,
  input logic io_req_bits_uop_ctrl_is_sta,
  input logic io_req_bits_uop_ctrl_is_std,
  input logic [1:0] io_req_bits_uop_ctrl_op1_sel,
  input logic [2:0] io_req_bits_uop_ctrl_op2_sel,
  input logic [3:0] io_req_bits_uop_ctrl_op_fcn,
  input logic [1:0] io_req_bits_uop_debug_fsrc,
  input logic [31:0] io_req_bits_uop_debug_inst,
  input logic [39:0] io_req_bits_uop_debug_pc,
  input logic [1:0] io_req_bits_uop_debug_tsrc,
  input logic [1:0] io_req_bits_uop_dst_rtype,
  input logic io_req_bits_uop_edge_inst,
  input logic [63:0] io_req_bits_uop_exc_cause,
  input logic io_req_bits_uop_exception,
  input logic io_req_bits_uop_flush_on_commit,
  input logic io_req_bits_uop_fp_single,
  input logic io_req_bits_uop_fp_val,
  input logic io_req_bits_uop_frs3_en,
  input logic [5:0] io_req_bits_uop_ftq_idx,
  input logic [9:0] io_req_bits_uop_fu_code,
  input logic [19:0] io_req_bits_uop_imm_packed,
  input logic [31:0] io_req_bits_uop_inst,
  input logic [2:0] io_req_bits_uop_iq_type,
  input logic io_req_bits_uop_is_amo,
  input logic io_req_bits_uop_is_br,
  input logic io_req_bits_uop_is_fence,
  input logic io_req_bits_uop_is_fencei,
  input logic io_req_bits_uop_is_jal,
  input logic io_req_bits_uop_is_jalr,
  input logic io_req_bits_uop_is_rvc,
  input logic io_req_bits_uop_is_sfb,
  input logic io_req_bits_uop_is_sys_pc2epc,
  input logic io_req_bits_uop_is_unique,
  input logic io_req_bits_uop_iw_p1_poisoned,
  input logic io_req_bits_uop_iw_p2_poisoned,
  input logic [1:0] io_req_bits_uop_iw_state,
  input logic [4:0] io_req_bits_uop_ldq_idx,
  input logic [5:0] io_req_bits_uop_ldst,
  input logic io_req_bits_uop_ldst_is_rs1,
  input logic io_req_bits_uop_ldst_val,
  input logic [5:0] io_req_bits_uop_lrs1,
  input logic [1:0] io_req_bits_uop_lrs1_rtype,
  input logic [5:0] io_req_bits_uop_lrs2,
  input logic [1:0] io_req_bits_uop_lrs2_rtype,
  input logic [5:0] io_req_bits_uop_lrs3,
  input logic [4:0] io_req_bits_uop_mem_cmd,
  input logic io_req_bits_uop_mem_signed,
  input logic [1:0] io_req_bits_uop_mem_size,
  input logic [5:0] io_req_bits_uop_pc_lob,
  input logic [6:0] io_req_bits_uop_pdst,
  input logic [5:0] io_req_bits_uop_ppred,
  input logic io_req_bits_uop_ppred_busy,
  input logic [6:0] io_req_bits_uop_prs1,
  input logic io_req_bits_uop_prs1_busy,
  input logic [6:0] io_req_bits_uop_prs2,
  input logic io_req_bits_uop_prs2_busy,
  input logic [6:0] io_req_bits_uop_prs3,
  input logic io_req_bits_uop_prs3_busy,
  input logic [6:0] io_req_bits_uop_rob_idx,
  input logic [1:0] io_req_bits_uop_rxq_idx,
  input logic [6:0] io_req_bits_uop_stale_pdst,
  input logic [4:0] io_req_bits_uop_stq_idx,
  input logic io_req_bits_uop_taken,
  input logic [6:0] io_req_bits_uop_uopc,
  input logic io_req_bits_uop_uses_ldq,
  input logic io_req_bits_uop_uses_stq,
  input logic io_req_bits_uop_xcpt_ae_if,
  input logic io_req_bits_uop_xcpt_ma_if,
  input logic io_req_bits_uop_xcpt_pf_if,
  output logic io_req_ready,
  input logic io_req_valid,
  output logic [63:0] io_resp_bits_data,
  output logic io_resp_bits_is_hella,
  output logic io_resp_bits_uop_bp_debug_if,
  output logic io_resp_bits_uop_bp_xcpt_if,
  output logic [19:0] io_resp_bits_uop_br_mask,
  output logic [4:0] io_resp_bits_uop_br_tag,
  output logic io_resp_bits_uop_bypassable,
  output logic [11:0] io_resp_bits_uop_csr_addr,
  output logic [3:0] io_resp_bits_uop_ctrl_br_type,
  output logic [2:0] io_resp_bits_uop_ctrl_csr_cmd,
  output logic io_resp_bits_uop_ctrl_fcn_dw,
  output logic [2:0] io_resp_bits_uop_ctrl_imm_sel,
  output logic io_resp_bits_uop_ctrl_is_load,
  output logic io_resp_bits_uop_ctrl_is_sta,
  output logic io_resp_bits_uop_ctrl_is_std,
  output logic [1:0] io_resp_bits_uop_ctrl_op1_sel,
  output logic [2:0] io_resp_bits_uop_ctrl_op2_sel,
  output logic [3:0] io_resp_bits_uop_ctrl_op_fcn,
  output logic [1:0] io_resp_bits_uop_debug_fsrc,
  output logic [31:0] io_resp_bits_uop_debug_inst,
  output logic [39:0] io_resp_bits_uop_debug_pc,
  output logic [1:0] io_resp_bits_uop_debug_tsrc,
  output logic [1:0] io_resp_bits_uop_dst_rtype,
  output logic io_resp_bits_uop_edge_inst,
  output logic [63:0] io_resp_bits_uop_exc_cause,
  output logic io_resp_bits_uop_exception,
  output logic io_resp_bits_uop_flush_on_commit,
  output logic io_resp_bits_uop_fp_single,
  output logic io_resp_bits_uop_fp_val,
  output logic io_resp_bits_uop_frs3_en,
  output logic [5:0] io_resp_bits_uop_ftq_idx,
  output logic [9:0] io_resp_bits_uop_fu_code,
  output logic [19:0] io_resp_bits_uop_imm_packed,
  output logic [31:0] io_resp_bits_uop_inst,
  output logic [2:0] io_resp_bits_uop_iq_type,
  output logic io_resp_bits_uop_is_amo,
  output logic io_resp_bits_uop_is_br,
  output logic io_resp_bits_uop_is_fence,
  output logic io_resp_bits_uop_is_fencei,
  output logic io_resp_bits_uop_is_jal,
  output logic io_resp_bits_uop_is_jalr,
  output logic io_resp_bits_uop_is_rvc,
  output logic io_resp_bits_uop_is_sfb,
  output logic io_resp_bits_uop_is_sys_pc2epc,
  output logic io_resp_bits_uop_is_unique,
  output logic io_resp_bits_uop_iw_p1_poisoned,
  output logic io_resp_bits_uop_iw_p2_poisoned,
  output logic [1:0] io_resp_bits_uop_iw_state,
  output logic [4:0] io_resp_bits_uop_ldq_idx,
  output logic [5:0] io_resp_bits_uop_ldst,
  output logic io_resp_bits_uop_ldst_is_rs1,
  output logic io_resp_bits_uop_ldst_val,
  output logic [5:0] io_resp_bits_uop_lrs1,
  output logic [1:0] io_resp_bits_uop_lrs1_rtype,
  output logic [5:0] io_resp_bits_uop_lrs2,
  output logic [1:0] io_resp_bits_uop_lrs2_rtype,
  output logic [5:0] io_resp_bits_uop_lrs3,
  output logic [4:0] io_resp_bits_uop_mem_cmd,
  output logic io_resp_bits_uop_mem_signed,
  output logic [1:0] io_resp_bits_uop_mem_size,
  output logic [5:0] io_resp_bits_uop_pc_lob,
  output logic [6:0] io_resp_bits_uop_pdst,
  output logic [5:0] io_resp_bits_uop_ppred,
  output logic io_resp_bits_uop_ppred_busy,
  output logic [6:0] io_resp_bits_uop_prs1,
  output logic io_resp_bits_uop_prs1_busy,
  output logic [6:0] io_resp_bits_uop_prs2,
  output logic io_resp_bits_uop_prs2_busy,
  output logic [6:0] io_resp_bits_uop_prs3,
  output logic io_resp_bits_uop_prs3_busy,
  output logic [6:0] io_resp_bits_uop_rob_idx,
  output logic [1:0] io_resp_bits_uop_rxq_idx,
  output logic [6:0] io_resp_bits_uop_stale_pdst,
  output logic [4:0] io_resp_bits_uop_stq_idx,
  output logic io_resp_bits_uop_taken,
  output logic [6:0] io_resp_bits_uop_uopc,
  output logic io_resp_bits_uop_uses_ldq,
  output logic io_resp_bits_uop_uses_stq,
  output logic io_resp_bits_uop_xcpt_ae_if,
  output logic io_resp_bits_uop_xcpt_ma_if,
  output logic io_resp_bits_uop_xcpt_pf_if,
  input logic io_resp_ready,
  output logic io_resp_valid,
  input logic reset
);
  typedef enum logic [1:0] {IDLE, ACCESS, WAIT_ACK, RESPONSE} phase_t;
  phase_t phase;
  logic [39:0] saved_io_req_bits_addr;
  logic [63:0] saved_io_req_bits_data;
  logic saved_io_req_bits_is_hella;
  logic saved_io_req_bits_uop_bp_debug_if;
  logic saved_io_req_bits_uop_bp_xcpt_if;
  logic [19:0] saved_io_req_bits_uop_br_mask;
  logic [4:0] saved_io_req_bits_uop_br_tag;
  logic saved_io_req_bits_uop_bypassable;
  logic [11:0] saved_io_req_bits_uop_csr_addr;
  logic [3:0] saved_io_req_bits_uop_ctrl_br_type;
  logic [2:0] saved_io_req_bits_uop_ctrl_csr_cmd;
  logic saved_io_req_bits_uop_ctrl_fcn_dw;
  logic [2:0] saved_io_req_bits_uop_ctrl_imm_sel;
  logic saved_io_req_bits_uop_ctrl_is_load;
  logic saved_io_req_bits_uop_ctrl_is_sta;
  logic saved_io_req_bits_uop_ctrl_is_std;
  logic [1:0] saved_io_req_bits_uop_ctrl_op1_sel;
  logic [2:0] saved_io_req_bits_uop_ctrl_op2_sel;
  logic [3:0] saved_io_req_bits_uop_ctrl_op_fcn;
  logic [1:0] saved_io_req_bits_uop_debug_fsrc;
  logic [31:0] saved_io_req_bits_uop_debug_inst;
  logic [39:0] saved_io_req_bits_uop_debug_pc;
  logic [1:0] saved_io_req_bits_uop_debug_tsrc;
  logic [1:0] saved_io_req_bits_uop_dst_rtype;
  logic saved_io_req_bits_uop_edge_inst;
  logic [63:0] saved_io_req_bits_uop_exc_cause;
  logic saved_io_req_bits_uop_exception;
  logic saved_io_req_bits_uop_flush_on_commit;
  logic saved_io_req_bits_uop_fp_single;
  logic saved_io_req_bits_uop_fp_val;
  logic saved_io_req_bits_uop_frs3_en;
  logic [5:0] saved_io_req_bits_uop_ftq_idx;
  logic [9:0] saved_io_req_bits_uop_fu_code;
  logic [19:0] saved_io_req_bits_uop_imm_packed;
  logic [31:0] saved_io_req_bits_uop_inst;
  logic [2:0] saved_io_req_bits_uop_iq_type;
  logic saved_io_req_bits_uop_is_amo;
  logic saved_io_req_bits_uop_is_br;
  logic saved_io_req_bits_uop_is_fence;
  logic saved_io_req_bits_uop_is_fencei;
  logic saved_io_req_bits_uop_is_jal;
  logic saved_io_req_bits_uop_is_jalr;
  logic saved_io_req_bits_uop_is_rvc;
  logic saved_io_req_bits_uop_is_sfb;
  logic saved_io_req_bits_uop_is_sys_pc2epc;
  logic saved_io_req_bits_uop_is_unique;
  logic saved_io_req_bits_uop_iw_p1_poisoned;
  logic saved_io_req_bits_uop_iw_p2_poisoned;
  logic [1:0] saved_io_req_bits_uop_iw_state;
  logic [4:0] saved_io_req_bits_uop_ldq_idx;
  logic [5:0] saved_io_req_bits_uop_ldst;
  logic saved_io_req_bits_uop_ldst_is_rs1;
  logic saved_io_req_bits_uop_ldst_val;
  logic [5:0] saved_io_req_bits_uop_lrs1;
  logic [1:0] saved_io_req_bits_uop_lrs1_rtype;
  logic [5:0] saved_io_req_bits_uop_lrs2;
  logic [1:0] saved_io_req_bits_uop_lrs2_rtype;
  logic [5:0] saved_io_req_bits_uop_lrs3;
  logic [4:0] saved_io_req_bits_uop_mem_cmd;
  logic saved_io_req_bits_uop_mem_signed;
  logic [1:0] saved_io_req_bits_uop_mem_size;
  logic [5:0] saved_io_req_bits_uop_pc_lob;
  logic [6:0] saved_io_req_bits_uop_pdst;
  logic [5:0] saved_io_req_bits_uop_ppred;
  logic saved_io_req_bits_uop_ppred_busy;
  logic [6:0] saved_io_req_bits_uop_prs1;
  logic saved_io_req_bits_uop_prs1_busy;
  logic [6:0] saved_io_req_bits_uop_prs2;
  logic saved_io_req_bits_uop_prs2_busy;
  logic [6:0] saved_io_req_bits_uop_prs3;
  logic saved_io_req_bits_uop_prs3_busy;
  logic [6:0] saved_io_req_bits_uop_rob_idx;
  logic [1:0] saved_io_req_bits_uop_rxq_idx;
  logic [6:0] saved_io_req_bits_uop_stale_pdst;
  logic [4:0] saved_io_req_bits_uop_stq_idx;
  logic saved_io_req_bits_uop_taken;
  logic [6:0] saved_io_req_bits_uop_uopc;
  logic saved_io_req_bits_uop_uses_ldq;
  logic saved_io_req_bits_uop_uses_stq;
  logic saved_io_req_bits_uop_xcpt_ae_if;
  logic saved_io_req_bits_uop_xcpt_ma_if;
  logic saved_io_req_bits_uop_xcpt_pf_if;
  logic [63:0] saved_word;
  logic returns_data;
  logic atomic_command;
  logic [31:0] selected_word;
  logic [15:0] selected_half;
  logic [7:0] selected_byte;
  always_comb begin
    returns_data = saved_io_req_bits_uop_mem_cmd inside {5'd0,5'd4,5'd6,5'd7,5'd8,5'd9,5'd10,5'd11,5'd12,5'd13,5'd14,5'd15,5'd16};
    atomic_command = saved_io_req_bits_uop_mem_cmd inside {5'd4,5'd8,5'd9,5'd10,5'd11,5'd12,5'd13,5'd14,5'd15};
  end
  always @(posedge clock) begin
    if(phase==IDLE && io_req_valid) begin
      saved_io_req_bits_addr <= io_req_bits_addr;
      saved_io_req_bits_data <= io_req_bits_data;
      saved_io_req_bits_is_hella <= io_req_bits_is_hella;
      saved_io_req_bits_uop_bp_debug_if <= io_req_bits_uop_bp_debug_if;
      saved_io_req_bits_uop_bp_xcpt_if <= io_req_bits_uop_bp_xcpt_if;
      saved_io_req_bits_uop_br_mask <= io_req_bits_uop_br_mask;
      saved_io_req_bits_uop_br_tag <= io_req_bits_uop_br_tag;
      saved_io_req_bits_uop_bypassable <= io_req_bits_uop_bypassable;
      saved_io_req_bits_uop_csr_addr <= io_req_bits_uop_csr_addr;
      saved_io_req_bits_uop_ctrl_br_type <= io_req_bits_uop_ctrl_br_type;
      saved_io_req_bits_uop_ctrl_csr_cmd <= io_req_bits_uop_ctrl_csr_cmd;
      saved_io_req_bits_uop_ctrl_fcn_dw <= io_req_bits_uop_ctrl_fcn_dw;
      saved_io_req_bits_uop_ctrl_imm_sel <= io_req_bits_uop_ctrl_imm_sel;
      saved_io_req_bits_uop_ctrl_is_load <= io_req_bits_uop_ctrl_is_load;
      saved_io_req_bits_uop_ctrl_is_sta <= io_req_bits_uop_ctrl_is_sta;
      saved_io_req_bits_uop_ctrl_is_std <= io_req_bits_uop_ctrl_is_std;
      saved_io_req_bits_uop_ctrl_op1_sel <= io_req_bits_uop_ctrl_op1_sel;
      saved_io_req_bits_uop_ctrl_op2_sel <= io_req_bits_uop_ctrl_op2_sel;
      saved_io_req_bits_uop_ctrl_op_fcn <= io_req_bits_uop_ctrl_op_fcn;
      saved_io_req_bits_uop_debug_fsrc <= io_req_bits_uop_debug_fsrc;
      saved_io_req_bits_uop_debug_inst <= io_req_bits_uop_debug_inst;
      saved_io_req_bits_uop_debug_pc <= io_req_bits_uop_debug_pc;
      saved_io_req_bits_uop_debug_tsrc <= io_req_bits_uop_debug_tsrc;
      saved_io_req_bits_uop_dst_rtype <= io_req_bits_uop_dst_rtype;
      saved_io_req_bits_uop_edge_inst <= io_req_bits_uop_edge_inst;
      saved_io_req_bits_uop_exc_cause <= io_req_bits_uop_exc_cause;
      saved_io_req_bits_uop_exception <= io_req_bits_uop_exception;
      saved_io_req_bits_uop_flush_on_commit <= io_req_bits_uop_flush_on_commit;
      saved_io_req_bits_uop_fp_single <= io_req_bits_uop_fp_single;
      saved_io_req_bits_uop_fp_val <= io_req_bits_uop_fp_val;
      saved_io_req_bits_uop_frs3_en <= io_req_bits_uop_frs3_en;
      saved_io_req_bits_uop_ftq_idx <= io_req_bits_uop_ftq_idx;
      saved_io_req_bits_uop_fu_code <= io_req_bits_uop_fu_code;
      saved_io_req_bits_uop_imm_packed <= io_req_bits_uop_imm_packed;
      saved_io_req_bits_uop_inst <= io_req_bits_uop_inst;
      saved_io_req_bits_uop_iq_type <= io_req_bits_uop_iq_type;
      saved_io_req_bits_uop_is_amo <= io_req_bits_uop_is_amo;
      saved_io_req_bits_uop_is_br <= io_req_bits_uop_is_br;
      saved_io_req_bits_uop_is_fence <= io_req_bits_uop_is_fence;
      saved_io_req_bits_uop_is_fencei <= io_req_bits_uop_is_fencei;
      saved_io_req_bits_uop_is_jal <= io_req_bits_uop_is_jal;
      saved_io_req_bits_uop_is_jalr <= io_req_bits_uop_is_jalr;
      saved_io_req_bits_uop_is_rvc <= io_req_bits_uop_is_rvc;
      saved_io_req_bits_uop_is_sfb <= io_req_bits_uop_is_sfb;
      saved_io_req_bits_uop_is_sys_pc2epc <= io_req_bits_uop_is_sys_pc2epc;
      saved_io_req_bits_uop_is_unique <= io_req_bits_uop_is_unique;
      saved_io_req_bits_uop_iw_p1_poisoned <= io_req_bits_uop_iw_p1_poisoned;
      saved_io_req_bits_uop_iw_p2_poisoned <= io_req_bits_uop_iw_p2_poisoned;
      saved_io_req_bits_uop_iw_state <= io_req_bits_uop_iw_state;
      saved_io_req_bits_uop_ldq_idx <= io_req_bits_uop_ldq_idx;
      saved_io_req_bits_uop_ldst <= io_req_bits_uop_ldst;
      saved_io_req_bits_uop_ldst_is_rs1 <= io_req_bits_uop_ldst_is_rs1;
      saved_io_req_bits_uop_ldst_val <= io_req_bits_uop_ldst_val;
      saved_io_req_bits_uop_lrs1 <= io_req_bits_uop_lrs1;
      saved_io_req_bits_uop_lrs1_rtype <= io_req_bits_uop_lrs1_rtype;
      saved_io_req_bits_uop_lrs2 <= io_req_bits_uop_lrs2;
      saved_io_req_bits_uop_lrs2_rtype <= io_req_bits_uop_lrs2_rtype;
      saved_io_req_bits_uop_lrs3 <= io_req_bits_uop_lrs3;
      saved_io_req_bits_uop_mem_cmd <= io_req_bits_uop_mem_cmd;
      saved_io_req_bits_uop_mem_signed <= io_req_bits_uop_mem_signed;
      saved_io_req_bits_uop_mem_size <= io_req_bits_uop_mem_size;
      saved_io_req_bits_uop_pc_lob <= io_req_bits_uop_pc_lob;
      saved_io_req_bits_uop_pdst <= io_req_bits_uop_pdst;
      saved_io_req_bits_uop_ppred <= io_req_bits_uop_ppred;
      saved_io_req_bits_uop_ppred_busy <= io_req_bits_uop_ppred_busy;
      saved_io_req_bits_uop_prs1 <= io_req_bits_uop_prs1;
      saved_io_req_bits_uop_prs1_busy <= io_req_bits_uop_prs1_busy;
      saved_io_req_bits_uop_prs2 <= io_req_bits_uop_prs2;
      saved_io_req_bits_uop_prs2_busy <= io_req_bits_uop_prs2_busy;
      saved_io_req_bits_uop_prs3 <= io_req_bits_uop_prs3;
      saved_io_req_bits_uop_prs3_busy <= io_req_bits_uop_prs3_busy;
      saved_io_req_bits_uop_rob_idx <= io_req_bits_uop_rob_idx;
      saved_io_req_bits_uop_rxq_idx <= io_req_bits_uop_rxq_idx;
      saved_io_req_bits_uop_stale_pdst <= io_req_bits_uop_stale_pdst;
      saved_io_req_bits_uop_stq_idx <= io_req_bits_uop_stq_idx;
      saved_io_req_bits_uop_taken <= io_req_bits_uop_taken;
      saved_io_req_bits_uop_uopc <= io_req_bits_uop_uopc;
      saved_io_req_bits_uop_uses_ldq <= io_req_bits_uop_uses_ldq;
      saved_io_req_bits_uop_uses_stq <= io_req_bits_uop_uses_stq;
      saved_io_req_bits_uop_xcpt_ae_if <= io_req_bits_uop_xcpt_ae_if;
      saved_io_req_bits_uop_xcpt_ma_if <= io_req_bits_uop_xcpt_ma_if;
      saved_io_req_bits_uop_xcpt_pf_if <= io_req_bits_uop_xcpt_pf_if;
    end
    if(phase==WAIT_ACK && io_mem_ack_valid && returns_data)
      saved_word <= io_mem_ack_bits_data >> (saved_io_req_bits_addr[3] ? 64 : 0);
    if(reset) phase <= IDLE;
    else case(phase)
      IDLE: if(io_req_valid) phase <= ACCESS;
      ACCESS: if(io_mem_access_ready) phase <= WAIT_ACK;
      WAIT_ACK: if(io_mem_ack_valid) phase <= RESPONSE;
      RESPONSE: if(!returns_data || io_resp_ready) phase <= IDLE;
    endcase
  end
  assign io_req_ready = phase==IDLE;
  assign io_mem_access_valid = phase==ACCESS;
  assign io_resp_valid = phase==RESPONSE && returns_data;
  assign io_resp_bits_is_hella = saved_io_req_bits_is_hella;
  assign io_resp_bits_uop_bp_debug_if = saved_io_req_bits_uop_bp_debug_if;
  assign io_resp_bits_uop_bp_xcpt_if = saved_io_req_bits_uop_bp_xcpt_if;
  assign io_resp_bits_uop_br_mask = saved_io_req_bits_uop_br_mask;
  assign io_resp_bits_uop_br_tag = saved_io_req_bits_uop_br_tag;
  assign io_resp_bits_uop_bypassable = saved_io_req_bits_uop_bypassable;
  assign io_resp_bits_uop_csr_addr = saved_io_req_bits_uop_csr_addr;
  assign io_resp_bits_uop_ctrl_br_type = saved_io_req_bits_uop_ctrl_br_type;
  assign io_resp_bits_uop_ctrl_csr_cmd = saved_io_req_bits_uop_ctrl_csr_cmd;
  assign io_resp_bits_uop_ctrl_fcn_dw = saved_io_req_bits_uop_ctrl_fcn_dw;
  assign io_resp_bits_uop_ctrl_imm_sel = saved_io_req_bits_uop_ctrl_imm_sel;
  assign io_resp_bits_uop_ctrl_is_load = saved_io_req_bits_uop_ctrl_is_load;
  assign io_resp_bits_uop_ctrl_is_sta = saved_io_req_bits_uop_ctrl_is_sta;
  assign io_resp_bits_uop_ctrl_is_std = saved_io_req_bits_uop_ctrl_is_std;
  assign io_resp_bits_uop_ctrl_op1_sel = saved_io_req_bits_uop_ctrl_op1_sel;
  assign io_resp_bits_uop_ctrl_op2_sel = saved_io_req_bits_uop_ctrl_op2_sel;
  assign io_resp_bits_uop_ctrl_op_fcn = saved_io_req_bits_uop_ctrl_op_fcn;
  assign io_resp_bits_uop_debug_fsrc = saved_io_req_bits_uop_debug_fsrc;
  assign io_resp_bits_uop_debug_inst = saved_io_req_bits_uop_debug_inst;
  assign io_resp_bits_uop_debug_pc = saved_io_req_bits_uop_debug_pc;
  assign io_resp_bits_uop_debug_tsrc = saved_io_req_bits_uop_debug_tsrc;
  assign io_resp_bits_uop_dst_rtype = saved_io_req_bits_uop_dst_rtype;
  assign io_resp_bits_uop_edge_inst = saved_io_req_bits_uop_edge_inst;
  assign io_resp_bits_uop_exc_cause = saved_io_req_bits_uop_exc_cause;
  assign io_resp_bits_uop_exception = saved_io_req_bits_uop_exception;
  assign io_resp_bits_uop_flush_on_commit = saved_io_req_bits_uop_flush_on_commit;
  assign io_resp_bits_uop_fp_single = saved_io_req_bits_uop_fp_single;
  assign io_resp_bits_uop_fp_val = saved_io_req_bits_uop_fp_val;
  assign io_resp_bits_uop_frs3_en = saved_io_req_bits_uop_frs3_en;
  assign io_resp_bits_uop_ftq_idx = saved_io_req_bits_uop_ftq_idx;
  assign io_resp_bits_uop_fu_code = saved_io_req_bits_uop_fu_code;
  assign io_resp_bits_uop_imm_packed = saved_io_req_bits_uop_imm_packed;
  assign io_resp_bits_uop_inst = saved_io_req_bits_uop_inst;
  assign io_resp_bits_uop_iq_type = saved_io_req_bits_uop_iq_type;
  assign io_resp_bits_uop_is_amo = saved_io_req_bits_uop_is_amo;
  assign io_resp_bits_uop_is_br = saved_io_req_bits_uop_is_br;
  assign io_resp_bits_uop_is_fence = saved_io_req_bits_uop_is_fence;
  assign io_resp_bits_uop_is_fencei = saved_io_req_bits_uop_is_fencei;
  assign io_resp_bits_uop_is_jal = saved_io_req_bits_uop_is_jal;
  assign io_resp_bits_uop_is_jalr = saved_io_req_bits_uop_is_jalr;
  assign io_resp_bits_uop_is_rvc = saved_io_req_bits_uop_is_rvc;
  assign io_resp_bits_uop_is_sfb = saved_io_req_bits_uop_is_sfb;
  assign io_resp_bits_uop_is_sys_pc2epc = saved_io_req_bits_uop_is_sys_pc2epc;
  assign io_resp_bits_uop_is_unique = saved_io_req_bits_uop_is_unique;
  assign io_resp_bits_uop_iw_p1_poisoned = saved_io_req_bits_uop_iw_p1_poisoned;
  assign io_resp_bits_uop_iw_p2_poisoned = saved_io_req_bits_uop_iw_p2_poisoned;
  assign io_resp_bits_uop_iw_state = saved_io_req_bits_uop_iw_state;
  assign io_resp_bits_uop_ldq_idx = saved_io_req_bits_uop_ldq_idx;
  assign io_resp_bits_uop_ldst = saved_io_req_bits_uop_ldst;
  assign io_resp_bits_uop_ldst_is_rs1 = saved_io_req_bits_uop_ldst_is_rs1;
  assign io_resp_bits_uop_ldst_val = saved_io_req_bits_uop_ldst_val;
  assign io_resp_bits_uop_lrs1 = saved_io_req_bits_uop_lrs1;
  assign io_resp_bits_uop_lrs1_rtype = saved_io_req_bits_uop_lrs1_rtype;
  assign io_resp_bits_uop_lrs2 = saved_io_req_bits_uop_lrs2;
  assign io_resp_bits_uop_lrs2_rtype = saved_io_req_bits_uop_lrs2_rtype;
  assign io_resp_bits_uop_lrs3 = saved_io_req_bits_uop_lrs3;
  assign io_resp_bits_uop_mem_cmd = saved_io_req_bits_uop_mem_cmd;
  assign io_resp_bits_uop_mem_signed = saved_io_req_bits_uop_mem_signed;
  assign io_resp_bits_uop_mem_size = saved_io_req_bits_uop_mem_size;
  assign io_resp_bits_uop_pc_lob = saved_io_req_bits_uop_pc_lob;
  assign io_resp_bits_uop_pdst = saved_io_req_bits_uop_pdst;
  assign io_resp_bits_uop_ppred = saved_io_req_bits_uop_ppred;
  assign io_resp_bits_uop_ppred_busy = saved_io_req_bits_uop_ppred_busy;
  assign io_resp_bits_uop_prs1 = saved_io_req_bits_uop_prs1;
  assign io_resp_bits_uop_prs1_busy = saved_io_req_bits_uop_prs1_busy;
  assign io_resp_bits_uop_prs2 = saved_io_req_bits_uop_prs2;
  assign io_resp_bits_uop_prs2_busy = saved_io_req_bits_uop_prs2_busy;
  assign io_resp_bits_uop_prs3 = saved_io_req_bits_uop_prs3;
  assign io_resp_bits_uop_prs3_busy = saved_io_req_bits_uop_prs3_busy;
  assign io_resp_bits_uop_rob_idx = saved_io_req_bits_uop_rob_idx;
  assign io_resp_bits_uop_rxq_idx = saved_io_req_bits_uop_rxq_idx;
  assign io_resp_bits_uop_stale_pdst = saved_io_req_bits_uop_stale_pdst;
  assign io_resp_bits_uop_stq_idx = saved_io_req_bits_uop_stq_idx;
  assign io_resp_bits_uop_taken = saved_io_req_bits_uop_taken;
  assign io_resp_bits_uop_uopc = saved_io_req_bits_uop_uopc;
  assign io_resp_bits_uop_uses_ldq = saved_io_req_bits_uop_uses_ldq;
  assign io_resp_bits_uop_uses_stq = saved_io_req_bits_uop_uses_stq;
  assign io_resp_bits_uop_xcpt_ae_if = saved_io_req_bits_uop_xcpt_ae_if;
  assign io_resp_bits_uop_xcpt_ma_if = saved_io_req_bits_uop_xcpt_ma_if;
  assign io_resp_bits_uop_xcpt_pf_if = saved_io_req_bits_uop_xcpt_pf_if;
  assign io_mem_access_bits_source = 4'd9;
  assign io_mem_access_bits_size = {2'b0,saved_io_req_bits_uop_mem_size};
  assign io_mem_access_bits_address = saved_io_req_bits_addr[32:0];
  assign io_mem_access_bits_data = atomic_command || !returns_data ? {2{saved_io_req_bits_data}} : 128'b0;
  always_comb begin
    io_mem_access_bits_opcode=3'd0; io_mem_access_bits_param=3'd0;
    case(saved_io_req_bits_uop_mem_cmd)
      0,6,7,16: io_mem_access_bits_opcode=3'd4;
      4: begin io_mem_access_bits_opcode=3'd3; io_mem_access_bits_param=3'd3; end
      8: begin io_mem_access_bits_opcode=3'd2; io_mem_access_bits_param=3'd4; end
      9,10,11: begin io_mem_access_bits_opcode=3'd3; io_mem_access_bits_param=saved_io_req_bits_uop_mem_cmd-9; end
      12,13,14,15: begin io_mem_access_bits_opcode=3'd2; io_mem_access_bits_param=saved_io_req_bits_uop_mem_cmd-12; end
      default: begin end
    endcase
    for(int lane=0;lane<16;lane++)
      io_mem_access_bits_mask[lane] = (lane >> saved_io_req_bits_uop_mem_size)==(saved_io_req_bits_addr[3:0] >> saved_io_req_bits_uop_mem_size);
    selected_word = saved_word >> (saved_io_req_bits_addr[2] ? 32 : 0);
    selected_half = selected_word >> (saved_io_req_bits_addr[1] ? 16 : 0);
    selected_byte = selected_half >> (saved_io_req_bits_addr[0] ? 8 : 0);
    case(saved_io_req_bits_uop_mem_size)
      0: io_resp_bits_data={{56{saved_io_req_bits_uop_mem_signed && selected_byte[7]}},selected_byte};
      1: io_resp_bits_data={{48{saved_io_req_bits_uop_mem_signed && selected_half[15]}},selected_half[15:8],selected_byte};
      2: io_resp_bits_data={{32{saved_io_req_bits_uop_mem_signed && selected_word[31]}},selected_word[31:16],selected_half[15:8],selected_byte};
      3: io_resp_bits_data={saved_word[63:32],selected_word[31:16],selected_half[15:8],selected_byte};
    endcase
  end
endmodule
