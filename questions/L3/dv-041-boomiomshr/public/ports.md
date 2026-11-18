# Native interface

Use every port of `BoomIOMSHR` below. No parameters. `clock` is the sole rising-edge clock, `reset` is synchronous active high. All fields are unsigned and all packed indices descend to zero. The independent `dvbench_model` has the identical native port signature.

| Port | Direction | Width | Packed indices |
|---|---|---:|---|
| `clock` | In | 1 | scalar |
| `io_mem_access_bits_address` | Out | 33 | [32:0] |
| `io_mem_access_bits_data` | Out | 128 | [127:0] |
| `io_mem_access_bits_mask` | Out | 16 | [15:0] |
| `io_mem_access_bits_opcode` | Out | 3 | [2:0] |
| `io_mem_access_bits_param` | Out | 3 | [2:0] |
| `io_mem_access_bits_size` | Out | 4 | [3:0] |
| `io_mem_access_bits_source` | Out | 4 | [3:0] |
| `io_mem_access_ready` | In | 1 | scalar |
| `io_mem_access_valid` | Out | 1 | scalar |
| `io_mem_ack_bits_data` | In | 128 | [127:0] |
| `io_mem_ack_valid` | In | 1 | scalar |
| `io_req_bits_addr` | In | 40 | [39:0] |
| `io_req_bits_data` | In | 64 | [63:0] |
| `io_req_bits_is_hella` | In | 1 | scalar |
| `io_req_bits_uop_bp_debug_if` | In | 1 | scalar |
| `io_req_bits_uop_bp_xcpt_if` | In | 1 | scalar |
| `io_req_bits_uop_br_mask` | In | 20 | [19:0] |
| `io_req_bits_uop_br_tag` | In | 5 | [4:0] |
| `io_req_bits_uop_bypassable` | In | 1 | scalar |
| `io_req_bits_uop_csr_addr` | In | 12 | [11:0] |
| `io_req_bits_uop_ctrl_br_type` | In | 4 | [3:0] |
| `io_req_bits_uop_ctrl_csr_cmd` | In | 3 | [2:0] |
| `io_req_bits_uop_ctrl_fcn_dw` | In | 1 | scalar |
| `io_req_bits_uop_ctrl_imm_sel` | In | 3 | [2:0] |
| `io_req_bits_uop_ctrl_is_load` | In | 1 | scalar |
| `io_req_bits_uop_ctrl_is_sta` | In | 1 | scalar |
| `io_req_bits_uop_ctrl_is_std` | In | 1 | scalar |
| `io_req_bits_uop_ctrl_op1_sel` | In | 2 | [1:0] |
| `io_req_bits_uop_ctrl_op2_sel` | In | 3 | [2:0] |
| `io_req_bits_uop_ctrl_op_fcn` | In | 4 | [3:0] |
| `io_req_bits_uop_debug_fsrc` | In | 2 | [1:0] |
| `io_req_bits_uop_debug_inst` | In | 32 | [31:0] |
| `io_req_bits_uop_debug_pc` | In | 40 | [39:0] |
| `io_req_bits_uop_debug_tsrc` | In | 2 | [1:0] |
| `io_req_bits_uop_dst_rtype` | In | 2 | [1:0] |
| `io_req_bits_uop_edge_inst` | In | 1 | scalar |
| `io_req_bits_uop_exc_cause` | In | 64 | [63:0] |
| `io_req_bits_uop_exception` | In | 1 | scalar |
| `io_req_bits_uop_flush_on_commit` | In | 1 | scalar |
| `io_req_bits_uop_fp_single` | In | 1 | scalar |
| `io_req_bits_uop_fp_val` | In | 1 | scalar |
| `io_req_bits_uop_frs3_en` | In | 1 | scalar |
| `io_req_bits_uop_ftq_idx` | In | 6 | [5:0] |
| `io_req_bits_uop_fu_code` | In | 10 | [9:0] |
| `io_req_bits_uop_imm_packed` | In | 20 | [19:0] |
| `io_req_bits_uop_inst` | In | 32 | [31:0] |
| `io_req_bits_uop_iq_type` | In | 3 | [2:0] |
| `io_req_bits_uop_is_amo` | In | 1 | scalar |
| `io_req_bits_uop_is_br` | In | 1 | scalar |
| `io_req_bits_uop_is_fence` | In | 1 | scalar |
| `io_req_bits_uop_is_fencei` | In | 1 | scalar |
| `io_req_bits_uop_is_jal` | In | 1 | scalar |
| `io_req_bits_uop_is_jalr` | In | 1 | scalar |
| `io_req_bits_uop_is_rvc` | In | 1 | scalar |
| `io_req_bits_uop_is_sfb` | In | 1 | scalar |
| `io_req_bits_uop_is_sys_pc2epc` | In | 1 | scalar |
| `io_req_bits_uop_is_unique` | In | 1 | scalar |
| `io_req_bits_uop_iw_p1_poisoned` | In | 1 | scalar |
| `io_req_bits_uop_iw_p2_poisoned` | In | 1 | scalar |
| `io_req_bits_uop_iw_state` | In | 2 | [1:0] |
| `io_req_bits_uop_ldq_idx` | In | 5 | [4:0] |
| `io_req_bits_uop_ldst` | In | 6 | [5:0] |
| `io_req_bits_uop_ldst_is_rs1` | In | 1 | scalar |
| `io_req_bits_uop_ldst_val` | In | 1 | scalar |
| `io_req_bits_uop_lrs1` | In | 6 | [5:0] |
| `io_req_bits_uop_lrs1_rtype` | In | 2 | [1:0] |
| `io_req_bits_uop_lrs2` | In | 6 | [5:0] |
| `io_req_bits_uop_lrs2_rtype` | In | 2 | [1:0] |
| `io_req_bits_uop_lrs3` | In | 6 | [5:0] |
| `io_req_bits_uop_mem_cmd` | In | 5 | [4:0] |
| `io_req_bits_uop_mem_signed` | In | 1 | scalar |
| `io_req_bits_uop_mem_size` | In | 2 | [1:0] |
| `io_req_bits_uop_pc_lob` | In | 6 | [5:0] |
| `io_req_bits_uop_pdst` | In | 7 | [6:0] |
| `io_req_bits_uop_ppred` | In | 6 | [5:0] |
| `io_req_bits_uop_ppred_busy` | In | 1 | scalar |
| `io_req_bits_uop_prs1` | In | 7 | [6:0] |
| `io_req_bits_uop_prs1_busy` | In | 1 | scalar |
| `io_req_bits_uop_prs2` | In | 7 | [6:0] |
| `io_req_bits_uop_prs2_busy` | In | 1 | scalar |
| `io_req_bits_uop_prs3` | In | 7 | [6:0] |
| `io_req_bits_uop_prs3_busy` | In | 1 | scalar |
| `io_req_bits_uop_rob_idx` | In | 7 | [6:0] |
| `io_req_bits_uop_rxq_idx` | In | 2 | [1:0] |
| `io_req_bits_uop_stale_pdst` | In | 7 | [6:0] |
| `io_req_bits_uop_stq_idx` | In | 5 | [4:0] |
| `io_req_bits_uop_taken` | In | 1 | scalar |
| `io_req_bits_uop_uopc` | In | 7 | [6:0] |
| `io_req_bits_uop_uses_ldq` | In | 1 | scalar |
| `io_req_bits_uop_uses_stq` | In | 1 | scalar |
| `io_req_bits_uop_xcpt_ae_if` | In | 1 | scalar |
| `io_req_bits_uop_xcpt_ma_if` | In | 1 | scalar |
| `io_req_bits_uop_xcpt_pf_if` | In | 1 | scalar |
| `io_req_ready` | Out | 1 | scalar |
| `io_req_valid` | In | 1 | scalar |
| `io_resp_bits_data` | Out | 64 | [63:0] |
| `io_resp_bits_is_hella` | Out | 1 | scalar |
| `io_resp_bits_uop_bp_debug_if` | Out | 1 | scalar |
| `io_resp_bits_uop_bp_xcpt_if` | Out | 1 | scalar |
| `io_resp_bits_uop_br_mask` | Out | 20 | [19:0] |
| `io_resp_bits_uop_br_tag` | Out | 5 | [4:0] |
| `io_resp_bits_uop_bypassable` | Out | 1 | scalar |
| `io_resp_bits_uop_csr_addr` | Out | 12 | [11:0] |
| `io_resp_bits_uop_ctrl_br_type` | Out | 4 | [3:0] |
| `io_resp_bits_uop_ctrl_csr_cmd` | Out | 3 | [2:0] |
| `io_resp_bits_uop_ctrl_fcn_dw` | Out | 1 | scalar |
| `io_resp_bits_uop_ctrl_imm_sel` | Out | 3 | [2:0] |
| `io_resp_bits_uop_ctrl_is_load` | Out | 1 | scalar |
| `io_resp_bits_uop_ctrl_is_sta` | Out | 1 | scalar |
| `io_resp_bits_uop_ctrl_is_std` | Out | 1 | scalar |
| `io_resp_bits_uop_ctrl_op1_sel` | Out | 2 | [1:0] |
| `io_resp_bits_uop_ctrl_op2_sel` | Out | 3 | [2:0] |
| `io_resp_bits_uop_ctrl_op_fcn` | Out | 4 | [3:0] |
| `io_resp_bits_uop_debug_fsrc` | Out | 2 | [1:0] |
| `io_resp_bits_uop_debug_inst` | Out | 32 | [31:0] |
| `io_resp_bits_uop_debug_pc` | Out | 40 | [39:0] |
| `io_resp_bits_uop_debug_tsrc` | Out | 2 | [1:0] |
| `io_resp_bits_uop_dst_rtype` | Out | 2 | [1:0] |
| `io_resp_bits_uop_edge_inst` | Out | 1 | scalar |
| `io_resp_bits_uop_exc_cause` | Out | 64 | [63:0] |
| `io_resp_bits_uop_exception` | Out | 1 | scalar |
| `io_resp_bits_uop_flush_on_commit` | Out | 1 | scalar |
| `io_resp_bits_uop_fp_single` | Out | 1 | scalar |
| `io_resp_bits_uop_fp_val` | Out | 1 | scalar |
| `io_resp_bits_uop_frs3_en` | Out | 1 | scalar |
| `io_resp_bits_uop_ftq_idx` | Out | 6 | [5:0] |
| `io_resp_bits_uop_fu_code` | Out | 10 | [9:0] |
| `io_resp_bits_uop_imm_packed` | Out | 20 | [19:0] |
| `io_resp_bits_uop_inst` | Out | 32 | [31:0] |
| `io_resp_bits_uop_iq_type` | Out | 3 | [2:0] |
| `io_resp_bits_uop_is_amo` | Out | 1 | scalar |
| `io_resp_bits_uop_is_br` | Out | 1 | scalar |
| `io_resp_bits_uop_is_fence` | Out | 1 | scalar |
| `io_resp_bits_uop_is_fencei` | Out | 1 | scalar |
| `io_resp_bits_uop_is_jal` | Out | 1 | scalar |
| `io_resp_bits_uop_is_jalr` | Out | 1 | scalar |
| `io_resp_bits_uop_is_rvc` | Out | 1 | scalar |
| `io_resp_bits_uop_is_sfb` | Out | 1 | scalar |
| `io_resp_bits_uop_is_sys_pc2epc` | Out | 1 | scalar |
| `io_resp_bits_uop_is_unique` | Out | 1 | scalar |
| `io_resp_bits_uop_iw_p1_poisoned` | Out | 1 | scalar |
| `io_resp_bits_uop_iw_p2_poisoned` | Out | 1 | scalar |
| `io_resp_bits_uop_iw_state` | Out | 2 | [1:0] |
| `io_resp_bits_uop_ldq_idx` | Out | 5 | [4:0] |
| `io_resp_bits_uop_ldst` | Out | 6 | [5:0] |
| `io_resp_bits_uop_ldst_is_rs1` | Out | 1 | scalar |
| `io_resp_bits_uop_ldst_val` | Out | 1 | scalar |
| `io_resp_bits_uop_lrs1` | Out | 6 | [5:0] |
| `io_resp_bits_uop_lrs1_rtype` | Out | 2 | [1:0] |
| `io_resp_bits_uop_lrs2` | Out | 6 | [5:0] |
| `io_resp_bits_uop_lrs2_rtype` | Out | 2 | [1:0] |
| `io_resp_bits_uop_lrs3` | Out | 6 | [5:0] |
| `io_resp_bits_uop_mem_cmd` | Out | 5 | [4:0] |
| `io_resp_bits_uop_mem_signed` | Out | 1 | scalar |
| `io_resp_bits_uop_mem_size` | Out | 2 | [1:0] |
| `io_resp_bits_uop_pc_lob` | Out | 6 | [5:0] |
| `io_resp_bits_uop_pdst` | Out | 7 | [6:0] |
| `io_resp_bits_uop_ppred` | Out | 6 | [5:0] |
| `io_resp_bits_uop_ppred_busy` | Out | 1 | scalar |
| `io_resp_bits_uop_prs1` | Out | 7 | [6:0] |
| `io_resp_bits_uop_prs1_busy` | Out | 1 | scalar |
| `io_resp_bits_uop_prs2` | Out | 7 | [6:0] |
| `io_resp_bits_uop_prs2_busy` | Out | 1 | scalar |
| `io_resp_bits_uop_prs3` | Out | 7 | [6:0] |
| `io_resp_bits_uop_prs3_busy` | Out | 1 | scalar |
| `io_resp_bits_uop_rob_idx` | Out | 7 | [6:0] |
| `io_resp_bits_uop_rxq_idx` | Out | 2 | [1:0] |
| `io_resp_bits_uop_stale_pdst` | Out | 7 | [6:0] |
| `io_resp_bits_uop_stq_idx` | Out | 5 | [4:0] |
| `io_resp_bits_uop_taken` | Out | 1 | scalar |
| `io_resp_bits_uop_uopc` | Out | 7 | [6:0] |
| `io_resp_bits_uop_uses_ldq` | Out | 1 | scalar |
| `io_resp_bits_uop_uses_stq` | Out | 1 | scalar |
| `io_resp_bits_uop_xcpt_ae_if` | Out | 1 | scalar |
| `io_resp_bits_uop_xcpt_ma_if` | Out | 1 | scalar |
| `io_resp_bits_uop_xcpt_pf_if` | Out | 1 | scalar |
| `io_resp_ready` | In | 1 | scalar |
| `io_resp_valid` | Out | 1 | scalar |
| `reset` | In | 1 | scalar |

## Exact native index ranges

- `io_mem_access_bits_address`: packed `[32:0]`
- `io_mem_access_bits_data`: packed `[127:0]`
- `io_mem_access_bits_mask`: packed `[15:0]`
- `io_mem_access_bits_opcode`: packed `[2:0]`
- `io_mem_access_bits_param`: packed `[2:0]`
- `io_mem_access_bits_size`: packed `[3:0]`
- `io_mem_access_bits_source`: packed `[3:0]`
- `io_mem_ack_bits_data`: packed `[127:0]`
- `io_req_bits_addr`: packed `[39:0]`
- `io_req_bits_data`: packed `[63:0]`
- `io_req_bits_uop_br_mask`: packed `[19:0]`
- `io_req_bits_uop_br_tag`: packed `[4:0]`
- `io_req_bits_uop_csr_addr`: packed `[11:0]`
- `io_req_bits_uop_ctrl_br_type`: packed `[3:0]`
- `io_req_bits_uop_ctrl_csr_cmd`: packed `[2:0]`
- `io_req_bits_uop_ctrl_imm_sel`: packed `[2:0]`
- `io_req_bits_uop_ctrl_op1_sel`: packed `[1:0]`
- `io_req_bits_uop_ctrl_op2_sel`: packed `[2:0]`
- `io_req_bits_uop_ctrl_op_fcn`: packed `[3:0]`
- `io_req_bits_uop_debug_fsrc`: packed `[1:0]`
- `io_req_bits_uop_debug_inst`: packed `[31:0]`
- `io_req_bits_uop_debug_pc`: packed `[39:0]`
- `io_req_bits_uop_debug_tsrc`: packed `[1:0]`
- `io_req_bits_uop_dst_rtype`: packed `[1:0]`
- `io_req_bits_uop_exc_cause`: packed `[63:0]`
- `io_req_bits_uop_ftq_idx`: packed `[5:0]`
- `io_req_bits_uop_fu_code`: packed `[9:0]`
- `io_req_bits_uop_imm_packed`: packed `[19:0]`
- `io_req_bits_uop_inst`: packed `[31:0]`
- `io_req_bits_uop_iq_type`: packed `[2:0]`
- `io_req_bits_uop_iw_state`: packed `[1:0]`
- `io_req_bits_uop_ldq_idx`: packed `[4:0]`
- `io_req_bits_uop_ldst`: packed `[5:0]`
- `io_req_bits_uop_lrs1`: packed `[5:0]`
- `io_req_bits_uop_lrs1_rtype`: packed `[1:0]`
- `io_req_bits_uop_lrs2`: packed `[5:0]`
- `io_req_bits_uop_lrs2_rtype`: packed `[1:0]`
- `io_req_bits_uop_lrs3`: packed `[5:0]`
- `io_req_bits_uop_mem_cmd`: packed `[4:0]`
- `io_req_bits_uop_mem_size`: packed `[1:0]`
- `io_req_bits_uop_pc_lob`: packed `[5:0]`
- `io_req_bits_uop_pdst`: packed `[6:0]`
- `io_req_bits_uop_ppred`: packed `[5:0]`
- `io_req_bits_uop_prs1`: packed `[6:0]`
- `io_req_bits_uop_prs2`: packed `[6:0]`
- `io_req_bits_uop_prs3`: packed `[6:0]`
- `io_req_bits_uop_rob_idx`: packed `[6:0]`
- `io_req_bits_uop_rxq_idx`: packed `[1:0]`
- `io_req_bits_uop_stale_pdst`: packed `[6:0]`
- `io_req_bits_uop_stq_idx`: packed `[4:0]`
- `io_req_bits_uop_uopc`: packed `[6:0]`
- `io_resp_bits_data`: packed `[63:0]`
- `io_resp_bits_uop_br_mask`: packed `[19:0]`
- `io_resp_bits_uop_br_tag`: packed `[4:0]`
- `io_resp_bits_uop_csr_addr`: packed `[11:0]`
- `io_resp_bits_uop_ctrl_br_type`: packed `[3:0]`
- `io_resp_bits_uop_ctrl_csr_cmd`: packed `[2:0]`
- `io_resp_bits_uop_ctrl_imm_sel`: packed `[2:0]`
- `io_resp_bits_uop_ctrl_op1_sel`: packed `[1:0]`
- `io_resp_bits_uop_ctrl_op2_sel`: packed `[2:0]`
- `io_resp_bits_uop_ctrl_op_fcn`: packed `[3:0]`
- `io_resp_bits_uop_debug_fsrc`: packed `[1:0]`
- `io_resp_bits_uop_debug_inst`: packed `[31:0]`
- `io_resp_bits_uop_debug_pc`: packed `[39:0]`
- `io_resp_bits_uop_debug_tsrc`: packed `[1:0]`
- `io_resp_bits_uop_dst_rtype`: packed `[1:0]`
- `io_resp_bits_uop_exc_cause`: packed `[63:0]`
- `io_resp_bits_uop_ftq_idx`: packed `[5:0]`
- `io_resp_bits_uop_fu_code`: packed `[9:0]`
- `io_resp_bits_uop_imm_packed`: packed `[19:0]`
- `io_resp_bits_uop_inst`: packed `[31:0]`
- `io_resp_bits_uop_iq_type`: packed `[2:0]`
- `io_resp_bits_uop_iw_state`: packed `[1:0]`
- `io_resp_bits_uop_ldq_idx`: packed `[4:0]`
- `io_resp_bits_uop_ldst`: packed `[5:0]`
- `io_resp_bits_uop_lrs1`: packed `[5:0]`
- `io_resp_bits_uop_lrs1_rtype`: packed `[1:0]`
- `io_resp_bits_uop_lrs2`: packed `[5:0]`
- `io_resp_bits_uop_lrs2_rtype`: packed `[1:0]`
- `io_resp_bits_uop_lrs3`: packed `[5:0]`
- `io_resp_bits_uop_mem_cmd`: packed `[4:0]`
- `io_resp_bits_uop_mem_size`: packed `[1:0]`
- `io_resp_bits_uop_pc_lob`: packed `[5:0]`
- `io_resp_bits_uop_pdst`: packed `[6:0]`
- `io_resp_bits_uop_ppred`: packed `[5:0]`
- `io_resp_bits_uop_prs1`: packed `[6:0]`
- `io_resp_bits_uop_prs2`: packed `[6:0]`
- `io_resp_bits_uop_prs3`: packed `[6:0]`
- `io_resp_bits_uop_rob_idx`: packed `[6:0]`
- `io_resp_bits_uop_rxq_idx`: packed `[1:0]`
- `io_resp_bits_uop_stale_pdst`: packed `[6:0]`
- `io_resp_bits_uop_stq_idx`: packed `[4:0]`
- `io_resp_bits_uop_uopc`: packed `[6:0]`
