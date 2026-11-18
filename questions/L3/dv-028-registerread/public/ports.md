# Native interface

Top `RegisterRead`, no top parameters. All packed indices descend to zero.

|Port|Direction|Width|
|---|---|---:|
|`clock`|In|1|
|`reset`|In|1|
|`io_iss_valids_0`|In|1|
|`io_iss_valids_1`|In|1|
|`io_iss_uops_0_uopc`|In|7|
|`io_iss_uops_0_inst`|In|32|
|`io_iss_uops_0_debug_inst`|In|32|
|`io_iss_uops_0_is_rvc`|In|1|
|`io_iss_uops_0_debug_pc`|In|40|
|`io_iss_uops_0_iq_type`|In|3|
|`io_iss_uops_0_fu_code`|In|10|
|`io_iss_uops_0_iw_state`|In|2|
|`io_iss_uops_0_is_br`|In|1|
|`io_iss_uops_0_is_jalr`|In|1|
|`io_iss_uops_0_is_jal`|In|1|
|`io_iss_uops_0_is_sfb`|In|1|
|`io_iss_uops_0_br_mask`|In|20|
|`io_iss_uops_0_br_tag`|In|5|
|`io_iss_uops_0_ftq_idx`|In|6|
|`io_iss_uops_0_edge_inst`|In|1|
|`io_iss_uops_0_pc_lob`|In|6|
|`io_iss_uops_0_taken`|In|1|
|`io_iss_uops_0_imm_packed`|In|20|
|`io_iss_uops_0_csr_addr`|In|12|
|`io_iss_uops_0_rob_idx`|In|7|
|`io_iss_uops_0_ldq_idx`|In|5|
|`io_iss_uops_0_stq_idx`|In|5|
|`io_iss_uops_0_rxq_idx`|In|2|
|`io_iss_uops_0_pdst`|In|7|
|`io_iss_uops_0_prs1`|In|7|
|`io_iss_uops_0_prs2`|In|7|
|`io_iss_uops_0_prs3`|In|7|
|`io_iss_uops_0_ppred`|In|6|
|`io_iss_uops_0_prs1_busy`|In|1|
|`io_iss_uops_0_prs2_busy`|In|1|
|`io_iss_uops_0_prs3_busy`|In|1|
|`io_iss_uops_0_ppred_busy`|In|1|
|`io_iss_uops_0_stale_pdst`|In|7|
|`io_iss_uops_0_exception`|In|1|
|`io_iss_uops_0_exc_cause`|In|64|
|`io_iss_uops_0_bypassable`|In|1|
|`io_iss_uops_0_mem_cmd`|In|5|
|`io_iss_uops_0_mem_size`|In|2|
|`io_iss_uops_0_mem_signed`|In|1|
|`io_iss_uops_0_is_fence`|In|1|
|`io_iss_uops_0_is_fencei`|In|1|
|`io_iss_uops_0_is_amo`|In|1|
|`io_iss_uops_0_uses_ldq`|In|1|
|`io_iss_uops_0_uses_stq`|In|1|
|`io_iss_uops_0_is_sys_pc2epc`|In|1|
|`io_iss_uops_0_is_unique`|In|1|
|`io_iss_uops_0_flush_on_commit`|In|1|
|`io_iss_uops_0_ldst_is_rs1`|In|1|
|`io_iss_uops_0_ldst`|In|6|
|`io_iss_uops_0_lrs1`|In|6|
|`io_iss_uops_0_lrs2`|In|6|
|`io_iss_uops_0_lrs3`|In|6|
|`io_iss_uops_0_ldst_val`|In|1|
|`io_iss_uops_0_dst_rtype`|In|2|
|`io_iss_uops_0_lrs1_rtype`|In|2|
|`io_iss_uops_0_lrs2_rtype`|In|2|
|`io_iss_uops_0_frs3_en`|In|1|
|`io_iss_uops_0_fp_val`|In|1|
|`io_iss_uops_0_fp_single`|In|1|
|`io_iss_uops_0_xcpt_pf_if`|In|1|
|`io_iss_uops_0_xcpt_ae_if`|In|1|
|`io_iss_uops_0_xcpt_ma_if`|In|1|
|`io_iss_uops_0_bp_debug_if`|In|1|
|`io_iss_uops_0_bp_xcpt_if`|In|1|
|`io_iss_uops_0_debug_fsrc`|In|2|
|`io_iss_uops_0_debug_tsrc`|In|2|
|`io_iss_uops_1_uopc`|In|7|
|`io_iss_uops_1_inst`|In|32|
|`io_iss_uops_1_debug_inst`|In|32|
|`io_iss_uops_1_is_rvc`|In|1|
|`io_iss_uops_1_debug_pc`|In|40|
|`io_iss_uops_1_iq_type`|In|3|
|`io_iss_uops_1_fu_code`|In|10|
|`io_iss_uops_1_iw_state`|In|2|
|`io_iss_uops_1_is_br`|In|1|
|`io_iss_uops_1_is_jalr`|In|1|
|`io_iss_uops_1_is_jal`|In|1|
|`io_iss_uops_1_is_sfb`|In|1|
|`io_iss_uops_1_br_mask`|In|20|
|`io_iss_uops_1_br_tag`|In|5|
|`io_iss_uops_1_ftq_idx`|In|6|
|`io_iss_uops_1_edge_inst`|In|1|
|`io_iss_uops_1_pc_lob`|In|6|
|`io_iss_uops_1_taken`|In|1|
|`io_iss_uops_1_imm_packed`|In|20|
|`io_iss_uops_1_csr_addr`|In|12|
|`io_iss_uops_1_rob_idx`|In|7|
|`io_iss_uops_1_ldq_idx`|In|5|
|`io_iss_uops_1_stq_idx`|In|5|
|`io_iss_uops_1_rxq_idx`|In|2|
|`io_iss_uops_1_pdst`|In|7|
|`io_iss_uops_1_prs1`|In|7|
|`io_iss_uops_1_prs2`|In|7|
|`io_iss_uops_1_prs3`|In|7|
|`io_iss_uops_1_ppred`|In|6|
|`io_iss_uops_1_prs1_busy`|In|1|
|`io_iss_uops_1_prs2_busy`|In|1|
|`io_iss_uops_1_prs3_busy`|In|1|
|`io_iss_uops_1_ppred_busy`|In|1|
|`io_iss_uops_1_stale_pdst`|In|7|
|`io_iss_uops_1_exception`|In|1|
|`io_iss_uops_1_exc_cause`|In|64|
|`io_iss_uops_1_bypassable`|In|1|
|`io_iss_uops_1_mem_cmd`|In|5|
|`io_iss_uops_1_mem_size`|In|2|
|`io_iss_uops_1_mem_signed`|In|1|
|`io_iss_uops_1_is_fence`|In|1|
|`io_iss_uops_1_is_fencei`|In|1|
|`io_iss_uops_1_is_amo`|In|1|
|`io_iss_uops_1_uses_ldq`|In|1|
|`io_iss_uops_1_uses_stq`|In|1|
|`io_iss_uops_1_is_sys_pc2epc`|In|1|
|`io_iss_uops_1_is_unique`|In|1|
|`io_iss_uops_1_flush_on_commit`|In|1|
|`io_iss_uops_1_ldst_is_rs1`|In|1|
|`io_iss_uops_1_ldst`|In|6|
|`io_iss_uops_1_lrs1`|In|6|
|`io_iss_uops_1_lrs2`|In|6|
|`io_iss_uops_1_lrs3`|In|6|
|`io_iss_uops_1_ldst_val`|In|1|
|`io_iss_uops_1_dst_rtype`|In|2|
|`io_iss_uops_1_lrs1_rtype`|In|2|
|`io_iss_uops_1_lrs2_rtype`|In|2|
|`io_iss_uops_1_frs3_en`|In|1|
|`io_iss_uops_1_fp_val`|In|1|
|`io_iss_uops_1_fp_single`|In|1|
|`io_iss_uops_1_xcpt_pf_if`|In|1|
|`io_iss_uops_1_xcpt_ae_if`|In|1|
|`io_iss_uops_1_xcpt_ma_if`|In|1|
|`io_iss_uops_1_bp_debug_if`|In|1|
|`io_iss_uops_1_bp_xcpt_if`|In|1|
|`io_iss_uops_1_debug_fsrc`|In|2|
|`io_iss_uops_1_debug_tsrc`|In|2|
|`io_rf_read_ports_0_addr`|Out|7|
|`io_rf_read_ports_0_data`|In|65|
|`io_rf_read_ports_1_addr`|Out|7|
|`io_rf_read_ports_1_data`|In|65|
|`io_rf_read_ports_2_addr`|Out|7|
|`io_rf_read_ports_2_data`|In|65|
|`io_rf_read_ports_3_addr`|Out|7|
|`io_rf_read_ports_3_data`|In|65|
|`io_rf_read_ports_4_addr`|Out|7|
|`io_rf_read_ports_4_data`|In|65|
|`io_rf_read_ports_5_addr`|Out|7|
|`io_rf_read_ports_5_data`|In|65|
|`io_exe_reqs_0_valid`|Out|1|
|`io_exe_reqs_0_bits_uop_uopc`|Out|7|
|`io_exe_reqs_0_bits_uop_inst`|Out|32|
|`io_exe_reqs_0_bits_uop_debug_inst`|Out|32|
|`io_exe_reqs_0_bits_uop_is_rvc`|Out|1|
|`io_exe_reqs_0_bits_uop_debug_pc`|Out|40|
|`io_exe_reqs_0_bits_uop_iq_type`|Out|3|
|`io_exe_reqs_0_bits_uop_fu_code`|Out|10|
|`io_exe_reqs_0_bits_uop_ctrl_br_type`|Out|4|
|`io_exe_reqs_0_bits_uop_ctrl_op1_sel`|Out|2|
|`io_exe_reqs_0_bits_uop_ctrl_op2_sel`|Out|3|
|`io_exe_reqs_0_bits_uop_ctrl_imm_sel`|Out|3|
|`io_exe_reqs_0_bits_uop_ctrl_op_fcn`|Out|4|
|`io_exe_reqs_0_bits_uop_ctrl_fcn_dw`|Out|1|
|`io_exe_reqs_0_bits_uop_ctrl_csr_cmd`|Out|3|
|`io_exe_reqs_0_bits_uop_ctrl_is_load`|Out|1|
|`io_exe_reqs_0_bits_uop_ctrl_is_sta`|Out|1|
|`io_exe_reqs_0_bits_uop_ctrl_is_std`|Out|1|
|`io_exe_reqs_0_bits_uop_iw_state`|Out|2|
|`io_exe_reqs_0_bits_uop_iw_p1_poisoned`|Out|1|
|`io_exe_reqs_0_bits_uop_iw_p2_poisoned`|Out|1|
|`io_exe_reqs_0_bits_uop_is_br`|Out|1|
|`io_exe_reqs_0_bits_uop_is_jalr`|Out|1|
|`io_exe_reqs_0_bits_uop_is_jal`|Out|1|
|`io_exe_reqs_0_bits_uop_is_sfb`|Out|1|
|`io_exe_reqs_0_bits_uop_br_mask`|Out|20|
|`io_exe_reqs_0_bits_uop_br_tag`|Out|5|
|`io_exe_reqs_0_bits_uop_ftq_idx`|Out|6|
|`io_exe_reqs_0_bits_uop_edge_inst`|Out|1|
|`io_exe_reqs_0_bits_uop_pc_lob`|Out|6|
|`io_exe_reqs_0_bits_uop_taken`|Out|1|
|`io_exe_reqs_0_bits_uop_imm_packed`|Out|20|
|`io_exe_reqs_0_bits_uop_csr_addr`|Out|12|
|`io_exe_reqs_0_bits_uop_rob_idx`|Out|7|
|`io_exe_reqs_0_bits_uop_ldq_idx`|Out|5|
|`io_exe_reqs_0_bits_uop_stq_idx`|Out|5|
|`io_exe_reqs_0_bits_uop_rxq_idx`|Out|2|
|`io_exe_reqs_0_bits_uop_pdst`|Out|7|
|`io_exe_reqs_0_bits_uop_prs1`|Out|7|
|`io_exe_reqs_0_bits_uop_prs2`|Out|7|
|`io_exe_reqs_0_bits_uop_prs3`|Out|7|
|`io_exe_reqs_0_bits_uop_ppred`|Out|6|
|`io_exe_reqs_0_bits_uop_prs1_busy`|Out|1|
|`io_exe_reqs_0_bits_uop_prs2_busy`|Out|1|
|`io_exe_reqs_0_bits_uop_prs3_busy`|Out|1|
|`io_exe_reqs_0_bits_uop_ppred_busy`|Out|1|
|`io_exe_reqs_0_bits_uop_stale_pdst`|Out|7|
|`io_exe_reqs_0_bits_uop_exception`|Out|1|
|`io_exe_reqs_0_bits_uop_exc_cause`|Out|64|
|`io_exe_reqs_0_bits_uop_bypassable`|Out|1|
|`io_exe_reqs_0_bits_uop_mem_cmd`|Out|5|
|`io_exe_reqs_0_bits_uop_mem_size`|Out|2|
|`io_exe_reqs_0_bits_uop_mem_signed`|Out|1|
|`io_exe_reqs_0_bits_uop_is_fence`|Out|1|
|`io_exe_reqs_0_bits_uop_is_fencei`|Out|1|
|`io_exe_reqs_0_bits_uop_is_amo`|Out|1|
|`io_exe_reqs_0_bits_uop_uses_ldq`|Out|1|
|`io_exe_reqs_0_bits_uop_uses_stq`|Out|1|
|`io_exe_reqs_0_bits_uop_is_sys_pc2epc`|Out|1|
|`io_exe_reqs_0_bits_uop_is_unique`|Out|1|
|`io_exe_reqs_0_bits_uop_flush_on_commit`|Out|1|
|`io_exe_reqs_0_bits_uop_ldst_is_rs1`|Out|1|
|`io_exe_reqs_0_bits_uop_ldst`|Out|6|
|`io_exe_reqs_0_bits_uop_lrs1`|Out|6|
|`io_exe_reqs_0_bits_uop_lrs2`|Out|6|
|`io_exe_reqs_0_bits_uop_lrs3`|Out|6|
|`io_exe_reqs_0_bits_uop_ldst_val`|Out|1|
|`io_exe_reqs_0_bits_uop_dst_rtype`|Out|2|
|`io_exe_reqs_0_bits_uop_lrs1_rtype`|Out|2|
|`io_exe_reqs_0_bits_uop_lrs2_rtype`|Out|2|
|`io_exe_reqs_0_bits_uop_frs3_en`|Out|1|
|`io_exe_reqs_0_bits_uop_fp_val`|Out|1|
|`io_exe_reqs_0_bits_uop_fp_single`|Out|1|
|`io_exe_reqs_0_bits_uop_xcpt_pf_if`|Out|1|
|`io_exe_reqs_0_bits_uop_xcpt_ae_if`|Out|1|
|`io_exe_reqs_0_bits_uop_xcpt_ma_if`|Out|1|
|`io_exe_reqs_0_bits_uop_bp_debug_if`|Out|1|
|`io_exe_reqs_0_bits_uop_bp_xcpt_if`|Out|1|
|`io_exe_reqs_0_bits_uop_debug_fsrc`|Out|2|
|`io_exe_reqs_0_bits_uop_debug_tsrc`|Out|2|
|`io_exe_reqs_0_bits_rs1_data`|Out|65|
|`io_exe_reqs_0_bits_rs2_data`|Out|65|
|`io_exe_reqs_0_bits_rs3_data`|Out|65|
|`io_exe_reqs_1_valid`|Out|1|
|`io_exe_reqs_1_bits_uop_uopc`|Out|7|
|`io_exe_reqs_1_bits_uop_inst`|Out|32|
|`io_exe_reqs_1_bits_uop_debug_inst`|Out|32|
|`io_exe_reqs_1_bits_uop_is_rvc`|Out|1|
|`io_exe_reqs_1_bits_uop_debug_pc`|Out|40|
|`io_exe_reqs_1_bits_uop_iq_type`|Out|3|
|`io_exe_reqs_1_bits_uop_fu_code`|Out|10|
|`io_exe_reqs_1_bits_uop_ctrl_br_type`|Out|4|
|`io_exe_reqs_1_bits_uop_ctrl_op1_sel`|Out|2|
|`io_exe_reqs_1_bits_uop_ctrl_op2_sel`|Out|3|
|`io_exe_reqs_1_bits_uop_ctrl_imm_sel`|Out|3|
|`io_exe_reqs_1_bits_uop_ctrl_op_fcn`|Out|4|
|`io_exe_reqs_1_bits_uop_ctrl_fcn_dw`|Out|1|
|`io_exe_reqs_1_bits_uop_ctrl_csr_cmd`|Out|3|
|`io_exe_reqs_1_bits_uop_ctrl_is_load`|Out|1|
|`io_exe_reqs_1_bits_uop_ctrl_is_sta`|Out|1|
|`io_exe_reqs_1_bits_uop_ctrl_is_std`|Out|1|
|`io_exe_reqs_1_bits_uop_iw_state`|Out|2|
|`io_exe_reqs_1_bits_uop_iw_p1_poisoned`|Out|1|
|`io_exe_reqs_1_bits_uop_iw_p2_poisoned`|Out|1|
|`io_exe_reqs_1_bits_uop_is_br`|Out|1|
|`io_exe_reqs_1_bits_uop_is_jalr`|Out|1|
|`io_exe_reqs_1_bits_uop_is_jal`|Out|1|
|`io_exe_reqs_1_bits_uop_is_sfb`|Out|1|
|`io_exe_reqs_1_bits_uop_br_mask`|Out|20|
|`io_exe_reqs_1_bits_uop_br_tag`|Out|5|
|`io_exe_reqs_1_bits_uop_ftq_idx`|Out|6|
|`io_exe_reqs_1_bits_uop_edge_inst`|Out|1|
|`io_exe_reqs_1_bits_uop_pc_lob`|Out|6|
|`io_exe_reqs_1_bits_uop_taken`|Out|1|
|`io_exe_reqs_1_bits_uop_imm_packed`|Out|20|
|`io_exe_reqs_1_bits_uop_csr_addr`|Out|12|
|`io_exe_reqs_1_bits_uop_rob_idx`|Out|7|
|`io_exe_reqs_1_bits_uop_ldq_idx`|Out|5|
|`io_exe_reqs_1_bits_uop_stq_idx`|Out|5|
|`io_exe_reqs_1_bits_uop_rxq_idx`|Out|2|
|`io_exe_reqs_1_bits_uop_pdst`|Out|7|
|`io_exe_reqs_1_bits_uop_prs1`|Out|7|
|`io_exe_reqs_1_bits_uop_prs2`|Out|7|
|`io_exe_reqs_1_bits_uop_prs3`|Out|7|
|`io_exe_reqs_1_bits_uop_ppred`|Out|6|
|`io_exe_reqs_1_bits_uop_prs1_busy`|Out|1|
|`io_exe_reqs_1_bits_uop_prs2_busy`|Out|1|
|`io_exe_reqs_1_bits_uop_prs3_busy`|Out|1|
|`io_exe_reqs_1_bits_uop_ppred_busy`|Out|1|
|`io_exe_reqs_1_bits_uop_stale_pdst`|Out|7|
|`io_exe_reqs_1_bits_uop_exception`|Out|1|
|`io_exe_reqs_1_bits_uop_exc_cause`|Out|64|
|`io_exe_reqs_1_bits_uop_bypassable`|Out|1|
|`io_exe_reqs_1_bits_uop_mem_cmd`|Out|5|
|`io_exe_reqs_1_bits_uop_mem_size`|Out|2|
|`io_exe_reqs_1_bits_uop_mem_signed`|Out|1|
|`io_exe_reqs_1_bits_uop_is_fence`|Out|1|
|`io_exe_reqs_1_bits_uop_is_fencei`|Out|1|
|`io_exe_reqs_1_bits_uop_is_amo`|Out|1|
|`io_exe_reqs_1_bits_uop_uses_ldq`|Out|1|
|`io_exe_reqs_1_bits_uop_uses_stq`|Out|1|
|`io_exe_reqs_1_bits_uop_is_sys_pc2epc`|Out|1|
|`io_exe_reqs_1_bits_uop_is_unique`|Out|1|
|`io_exe_reqs_1_bits_uop_flush_on_commit`|Out|1|
|`io_exe_reqs_1_bits_uop_ldst_is_rs1`|Out|1|
|`io_exe_reqs_1_bits_uop_ldst`|Out|6|
|`io_exe_reqs_1_bits_uop_lrs1`|Out|6|
|`io_exe_reqs_1_bits_uop_lrs2`|Out|6|
|`io_exe_reqs_1_bits_uop_lrs3`|Out|6|
|`io_exe_reqs_1_bits_uop_ldst_val`|Out|1|
|`io_exe_reqs_1_bits_uop_dst_rtype`|Out|2|
|`io_exe_reqs_1_bits_uop_lrs1_rtype`|Out|2|
|`io_exe_reqs_1_bits_uop_lrs2_rtype`|Out|2|
|`io_exe_reqs_1_bits_uop_frs3_en`|Out|1|
|`io_exe_reqs_1_bits_uop_fp_val`|Out|1|
|`io_exe_reqs_1_bits_uop_fp_single`|Out|1|
|`io_exe_reqs_1_bits_uop_xcpt_pf_if`|Out|1|
|`io_exe_reqs_1_bits_uop_xcpt_ae_if`|Out|1|
|`io_exe_reqs_1_bits_uop_xcpt_ma_if`|Out|1|
|`io_exe_reqs_1_bits_uop_bp_debug_if`|Out|1|
|`io_exe_reqs_1_bits_uop_bp_xcpt_if`|Out|1|
|`io_exe_reqs_1_bits_uop_debug_fsrc`|Out|2|
|`io_exe_reqs_1_bits_uop_debug_tsrc`|Out|2|
|`io_exe_reqs_1_bits_rs1_data`|Out|65|
|`io_exe_reqs_1_bits_rs2_data`|Out|65|
|`io_exe_reqs_1_bits_rs3_data`|Out|65|
|`io_kill`|In|1|
|`io_brupdate_b1_resolve_mask`|In|20|
|`io_brupdate_b1_mispredict_mask`|In|20|

## Exact native index ranges

- `io_brupdate_b1_mispredict_mask`: packed `[19:0]`
- `io_brupdate_b1_resolve_mask`: packed `[19:0]`
- `io_exe_reqs_0_bits_rs1_data`: packed `[64:0]`
- `io_exe_reqs_0_bits_rs2_data`: packed `[64:0]`
- `io_exe_reqs_0_bits_rs3_data`: packed `[64:0]`
- `io_exe_reqs_0_bits_uop_br_mask`: packed `[19:0]`
- `io_exe_reqs_0_bits_uop_br_tag`: packed `[4:0]`
- `io_exe_reqs_0_bits_uop_csr_addr`: packed `[11:0]`
- `io_exe_reqs_0_bits_uop_ctrl_br_type`: packed `[3:0]`
- `io_exe_reqs_0_bits_uop_ctrl_csr_cmd`: packed `[2:0]`
- `io_exe_reqs_0_bits_uop_ctrl_imm_sel`: packed `[2:0]`
- `io_exe_reqs_0_bits_uop_ctrl_op1_sel`: packed `[1:0]`
- `io_exe_reqs_0_bits_uop_ctrl_op2_sel`: packed `[2:0]`
- `io_exe_reqs_0_bits_uop_ctrl_op_fcn`: packed `[3:0]`
- `io_exe_reqs_0_bits_uop_debug_fsrc`: packed `[1:0]`
- `io_exe_reqs_0_bits_uop_debug_inst`: packed `[31:0]`
- `io_exe_reqs_0_bits_uop_debug_pc`: packed `[39:0]`
- `io_exe_reqs_0_bits_uop_debug_tsrc`: packed `[1:0]`
- `io_exe_reqs_0_bits_uop_dst_rtype`: packed `[1:0]`
- `io_exe_reqs_0_bits_uop_exc_cause`: packed `[63:0]`
- `io_exe_reqs_0_bits_uop_ftq_idx`: packed `[5:0]`
- `io_exe_reqs_0_bits_uop_fu_code`: packed `[9:0]`
- `io_exe_reqs_0_bits_uop_imm_packed`: packed `[19:0]`
- `io_exe_reqs_0_bits_uop_inst`: packed `[31:0]`
- `io_exe_reqs_0_bits_uop_iq_type`: packed `[2:0]`
- `io_exe_reqs_0_bits_uop_iw_state`: packed `[1:0]`
- `io_exe_reqs_0_bits_uop_ldq_idx`: packed `[4:0]`
- `io_exe_reqs_0_bits_uop_ldst`: packed `[5:0]`
- `io_exe_reqs_0_bits_uop_lrs1`: packed `[5:0]`
- `io_exe_reqs_0_bits_uop_lrs1_rtype`: packed `[1:0]`
- `io_exe_reqs_0_bits_uop_lrs2`: packed `[5:0]`
- `io_exe_reqs_0_bits_uop_lrs2_rtype`: packed `[1:0]`
- `io_exe_reqs_0_bits_uop_lrs3`: packed `[5:0]`
- `io_exe_reqs_0_bits_uop_mem_cmd`: packed `[4:0]`
- `io_exe_reqs_0_bits_uop_mem_size`: packed `[1:0]`
- `io_exe_reqs_0_bits_uop_pc_lob`: packed `[5:0]`
- `io_exe_reqs_0_bits_uop_pdst`: packed `[6:0]`
- `io_exe_reqs_0_bits_uop_ppred`: packed `[5:0]`
- `io_exe_reqs_0_bits_uop_prs1`: packed `[6:0]`
- `io_exe_reqs_0_bits_uop_prs2`: packed `[6:0]`
- `io_exe_reqs_0_bits_uop_prs3`: packed `[6:0]`
- `io_exe_reqs_0_bits_uop_rob_idx`: packed `[6:0]`
- `io_exe_reqs_0_bits_uop_rxq_idx`: packed `[1:0]`
- `io_exe_reqs_0_bits_uop_stale_pdst`: packed `[6:0]`
- `io_exe_reqs_0_bits_uop_stq_idx`: packed `[4:0]`
- `io_exe_reqs_0_bits_uop_uopc`: packed `[6:0]`
- `io_exe_reqs_1_bits_rs1_data`: packed `[64:0]`
- `io_exe_reqs_1_bits_rs2_data`: packed `[64:0]`
- `io_exe_reqs_1_bits_rs3_data`: packed `[64:0]`
- `io_exe_reqs_1_bits_uop_br_mask`: packed `[19:0]`
- `io_exe_reqs_1_bits_uop_br_tag`: packed `[4:0]`
- `io_exe_reqs_1_bits_uop_csr_addr`: packed `[11:0]`
- `io_exe_reqs_1_bits_uop_ctrl_br_type`: packed `[3:0]`
- `io_exe_reqs_1_bits_uop_ctrl_csr_cmd`: packed `[2:0]`
- `io_exe_reqs_1_bits_uop_ctrl_imm_sel`: packed `[2:0]`
- `io_exe_reqs_1_bits_uop_ctrl_op1_sel`: packed `[1:0]`
- `io_exe_reqs_1_bits_uop_ctrl_op2_sel`: packed `[2:0]`
- `io_exe_reqs_1_bits_uop_ctrl_op_fcn`: packed `[3:0]`
- `io_exe_reqs_1_bits_uop_debug_fsrc`: packed `[1:0]`
- `io_exe_reqs_1_bits_uop_debug_inst`: packed `[31:0]`
- `io_exe_reqs_1_bits_uop_debug_pc`: packed `[39:0]`
- `io_exe_reqs_1_bits_uop_debug_tsrc`: packed `[1:0]`
- `io_exe_reqs_1_bits_uop_dst_rtype`: packed `[1:0]`
- `io_exe_reqs_1_bits_uop_exc_cause`: packed `[63:0]`
- `io_exe_reqs_1_bits_uop_ftq_idx`: packed `[5:0]`
- `io_exe_reqs_1_bits_uop_fu_code`: packed `[9:0]`
- `io_exe_reqs_1_bits_uop_imm_packed`: packed `[19:0]`
- `io_exe_reqs_1_bits_uop_inst`: packed `[31:0]`
- `io_exe_reqs_1_bits_uop_iq_type`: packed `[2:0]`
- `io_exe_reqs_1_bits_uop_iw_state`: packed `[1:0]`
- `io_exe_reqs_1_bits_uop_ldq_idx`: packed `[4:0]`
- `io_exe_reqs_1_bits_uop_ldst`: packed `[5:0]`
- `io_exe_reqs_1_bits_uop_lrs1`: packed `[5:0]`
- `io_exe_reqs_1_bits_uop_lrs1_rtype`: packed `[1:0]`
- `io_exe_reqs_1_bits_uop_lrs2`: packed `[5:0]`
- `io_exe_reqs_1_bits_uop_lrs2_rtype`: packed `[1:0]`
- `io_exe_reqs_1_bits_uop_lrs3`: packed `[5:0]`
- `io_exe_reqs_1_bits_uop_mem_cmd`: packed `[4:0]`
- `io_exe_reqs_1_bits_uop_mem_size`: packed `[1:0]`
- `io_exe_reqs_1_bits_uop_pc_lob`: packed `[5:0]`
- `io_exe_reqs_1_bits_uop_pdst`: packed `[6:0]`
- `io_exe_reqs_1_bits_uop_ppred`: packed `[5:0]`
- `io_exe_reqs_1_bits_uop_prs1`: packed `[6:0]`
- `io_exe_reqs_1_bits_uop_prs2`: packed `[6:0]`
- `io_exe_reqs_1_bits_uop_prs3`: packed `[6:0]`
- `io_exe_reqs_1_bits_uop_rob_idx`: packed `[6:0]`
- `io_exe_reqs_1_bits_uop_rxq_idx`: packed `[1:0]`
- `io_exe_reqs_1_bits_uop_stale_pdst`: packed `[6:0]`
- `io_exe_reqs_1_bits_uop_stq_idx`: packed `[4:0]`
- `io_exe_reqs_1_bits_uop_uopc`: packed `[6:0]`
- `io_iss_uops_0_br_mask`: packed `[19:0]`
- `io_iss_uops_0_br_tag`: packed `[4:0]`
- `io_iss_uops_0_csr_addr`: packed `[11:0]`
- `io_iss_uops_0_debug_fsrc`: packed `[1:0]`
- `io_iss_uops_0_debug_inst`: packed `[31:0]`
- `io_iss_uops_0_debug_pc`: packed `[39:0]`
- `io_iss_uops_0_debug_tsrc`: packed `[1:0]`
- `io_iss_uops_0_dst_rtype`: packed `[1:0]`
- `io_iss_uops_0_exc_cause`: packed `[63:0]`
- `io_iss_uops_0_ftq_idx`: packed `[5:0]`
- `io_iss_uops_0_fu_code`: packed `[9:0]`
- `io_iss_uops_0_imm_packed`: packed `[19:0]`
- `io_iss_uops_0_inst`: packed `[31:0]`
- `io_iss_uops_0_iq_type`: packed `[2:0]`
- `io_iss_uops_0_iw_state`: packed `[1:0]`
- `io_iss_uops_0_ldq_idx`: packed `[4:0]`
- `io_iss_uops_0_ldst`: packed `[5:0]`
- `io_iss_uops_0_lrs1`: packed `[5:0]`
- `io_iss_uops_0_lrs1_rtype`: packed `[1:0]`
- `io_iss_uops_0_lrs2`: packed `[5:0]`
- `io_iss_uops_0_lrs2_rtype`: packed `[1:0]`
- `io_iss_uops_0_lrs3`: packed `[5:0]`
- `io_iss_uops_0_mem_cmd`: packed `[4:0]`
- `io_iss_uops_0_mem_size`: packed `[1:0]`
- `io_iss_uops_0_pc_lob`: packed `[5:0]`
- `io_iss_uops_0_pdst`: packed `[6:0]`
- `io_iss_uops_0_ppred`: packed `[5:0]`
- `io_iss_uops_0_prs1`: packed `[6:0]`
- `io_iss_uops_0_prs2`: packed `[6:0]`
- `io_iss_uops_0_prs3`: packed `[6:0]`
- `io_iss_uops_0_rob_idx`: packed `[6:0]`
- `io_iss_uops_0_rxq_idx`: packed `[1:0]`
- `io_iss_uops_0_stale_pdst`: packed `[6:0]`
- `io_iss_uops_0_stq_idx`: packed `[4:0]`
- `io_iss_uops_0_uopc`: packed `[6:0]`
- `io_iss_uops_1_br_mask`: packed `[19:0]`
- `io_iss_uops_1_br_tag`: packed `[4:0]`
- `io_iss_uops_1_csr_addr`: packed `[11:0]`
- `io_iss_uops_1_debug_fsrc`: packed `[1:0]`
- `io_iss_uops_1_debug_inst`: packed `[31:0]`
- `io_iss_uops_1_debug_pc`: packed `[39:0]`
- `io_iss_uops_1_debug_tsrc`: packed `[1:0]`
- `io_iss_uops_1_dst_rtype`: packed `[1:0]`
- `io_iss_uops_1_exc_cause`: packed `[63:0]`
- `io_iss_uops_1_ftq_idx`: packed `[5:0]`
- `io_iss_uops_1_fu_code`: packed `[9:0]`
- `io_iss_uops_1_imm_packed`: packed `[19:0]`
- `io_iss_uops_1_inst`: packed `[31:0]`
- `io_iss_uops_1_iq_type`: packed `[2:0]`
- `io_iss_uops_1_iw_state`: packed `[1:0]`
- `io_iss_uops_1_ldq_idx`: packed `[4:0]`
- `io_iss_uops_1_ldst`: packed `[5:0]`
- `io_iss_uops_1_lrs1`: packed `[5:0]`
- `io_iss_uops_1_lrs1_rtype`: packed `[1:0]`
- `io_iss_uops_1_lrs2`: packed `[5:0]`
- `io_iss_uops_1_lrs2_rtype`: packed `[1:0]`
- `io_iss_uops_1_lrs3`: packed `[5:0]`
- `io_iss_uops_1_mem_cmd`: packed `[4:0]`
- `io_iss_uops_1_mem_size`: packed `[1:0]`
- `io_iss_uops_1_pc_lob`: packed `[5:0]`
- `io_iss_uops_1_pdst`: packed `[6:0]`
- `io_iss_uops_1_ppred`: packed `[5:0]`
- `io_iss_uops_1_prs1`: packed `[6:0]`
- `io_iss_uops_1_prs2`: packed `[6:0]`
- `io_iss_uops_1_prs3`: packed `[6:0]`
- `io_iss_uops_1_rob_idx`: packed `[6:0]`
- `io_iss_uops_1_rxq_idx`: packed `[1:0]`
- `io_iss_uops_1_stale_pdst`: packed `[6:0]`
- `io_iss_uops_1_stq_idx`: packed `[4:0]`
- `io_iss_uops_1_uopc`: packed `[6:0]`
- `io_rf_read_ports_0_addr`: packed `[6:0]`
- `io_rf_read_ports_0_data`: packed `[64:0]`
- `io_rf_read_ports_1_addr`: packed `[6:0]`
- `io_rf_read_ports_1_data`: packed `[64:0]`
- `io_rf_read_ports_2_addr`: packed `[6:0]`
- `io_rf_read_ports_2_data`: packed `[64:0]`
- `io_rf_read_ports_3_addr`: packed `[6:0]`
- `io_rf_read_ports_3_data`: packed `[64:0]`
- `io_rf_read_ports_4_addr`: packed `[6:0]`
- `io_rf_read_ports_4_data`: packed `[64:0]`
- `io_rf_read_ports_5_addr`: packed `[6:0]`
- `io_rf_read_ports_5_data`: packed `[64:0]`
