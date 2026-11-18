# Native ports and configuration

The DUT is ibuffer and model is dvbench_model with matching native ports. Fixed parameters are BUFFER_WIDTH159,SIZE_IBUFFER2,NUM_FETCH2 and eight warp banks. All native binary values are legal. Each fetched pair contains two159-bit instruction/control records; all native output fields are defined even when valid is zero.

| Port | Direction | Width |
| --- | --- | --- |
| clk | In | 1 |
| ibuffer2issue_grant_i | In | 8 |
| ibuffer2issue_io_in_ready_i | In | 8 |
| ibuffer_flush_wid_i | In | 3 |
| ibuffer_flush_wid_valid_i | In | 1 |
| ibuffer_in_control_Signals_alu_fn_i | In | 12 |
| ibuffer_in_control_Signals_aq_i | In | 2 |
| ibuffer_in_control_Signals_atomic_i | In | 2 |
| ibuffer_in_control_Signals_barrier_i | In | 2 |
| ibuffer_in_control_Signals_branch_i | In | 4 |
| ibuffer_in_control_Signals_csr_i | In | 4 |
| ibuffer_in_control_Signals_custom_signal_0_i | In | 2 |
| ibuffer_in_control_Signals_disable_mask_i | In | 2 |
| ibuffer_in_control_Signals_fence_i | In | 2 |
| ibuffer_in_control_Signals_force_rm_rtz_i | In | 2 |
| ibuffer_in_control_Signals_fp_i | In | 2 |
| ibuffer_in_control_Signals_imm_ext_i | In | 12 |
| ibuffer_in_control_Signals_inst_i | In | 64 |
| ibuffer_in_control_Signals_is_vls12_i | In | 2 |
| ibuffer_in_control_Signals_isvec_i | In | 2 |
| ibuffer_in_control_Signals_mask_i | In | 2 |
| ibuffer_in_control_Signals_mem_cmd_i | In | 4 |
| ibuffer_in_control_Signals_mem_i | In | 2 |
| ibuffer_in_control_Signals_mem_unsigned_i | In | 2 |
| ibuffer_in_control_Signals_mem_whb_i | In | 4 |
| ibuffer_in_control_Signals_mop_i | In | 4 |
| ibuffer_in_control_Signals_mul_i | In | 2 |
| ibuffer_in_control_Signals_pc_i | In | 64 |
| ibuffer_in_control_Signals_readmask_i | In | 2 |
| ibuffer_in_control_Signals_reg_idx1_i | In | 16 |
| ibuffer_in_control_Signals_reg_idx2_i | In | 16 |
| ibuffer_in_control_Signals_reg_idx3_i | In | 16 |
| ibuffer_in_control_Signals_reg_idxw_i | In | 16 |
| ibuffer_in_control_Signals_reverse_i | In | 2 |
| ibuffer_in_control_Signals_rl_i | In | 2 |
| ibuffer_in_control_Signals_rm_i | In | 6 |
| ibuffer_in_control_Signals_rm_is_static_i | In | 2 |
| ibuffer_in_control_Signals_sel_alu1_i | In | 4 |
| ibuffer_in_control_Signals_sel_alu2_i | In | 4 |
| ibuffer_in_control_Signals_sel_alu3_i | In | 4 |
| ibuffer_in_control_Signals_sel_imm_i | In | 8 |
| ibuffer_in_control_Signals_sfu_i | In | 2 |
| ibuffer_in_control_Signals_simt_stack_i | In | 2 |
| ibuffer_in_control_Signals_simt_stack_op_i | In | 2 |
| ibuffer_in_control_Signals_tc_i | In | 2 |
| ibuffer_in_control_Signals_wid_i | In | 6 |
| ibuffer_in_control_Signals_writemask_i | In | 2 |
| ibuffer_in_control_Signals_wvd_i | In | 2 |
| ibuffer_in_control_Signals_wxd_i | In | 2 |
| ibuffer_in_control_mask_i | In | 2 |
| ibuffer_in_ready_o | Out | 1 |
| ibuffer_in_valid_i | In | 1 |
| ibuffer_out_valid_o | Out | 8 |
| ibuffer_ready_o | Out | 8 |
| ibuffer_warps_control_Signals_alu_fn_o | Out | 48 |
| ibuffer_warps_control_Signals_aq_o | Out | 8 |
| ibuffer_warps_control_Signals_atomic_o | Out | 8 |
| ibuffer_warps_control_Signals_barrier_o | Out | 8 |
| ibuffer_warps_control_Signals_branch_o | Out | 16 |
| ibuffer_warps_control_Signals_csr_o | Out | 16 |
| ibuffer_warps_control_Signals_custom_signal_0_o | Out | 8 |
| ibuffer_warps_control_Signals_disable_mask_o | Out | 8 |
| ibuffer_warps_control_Signals_fence_o | Out | 8 |
| ibuffer_warps_control_Signals_force_rm_rtz_o | Out | 8 |
| ibuffer_warps_control_Signals_fp_o | Out | 8 |
| ibuffer_warps_control_Signals_imm_ext_o | Out | 48 |
| ibuffer_warps_control_Signals_inst_o | Out | 256 |
| ibuffer_warps_control_Signals_is_vls12_o | Out | 8 |
| ibuffer_warps_control_Signals_isvec_o | Out | 8 |
| ibuffer_warps_control_Signals_mask_o | Out | 8 |
| ibuffer_warps_control_Signals_mem_cmd_o | Out | 16 |
| ibuffer_warps_control_Signals_mem_o | Out | 8 |
| ibuffer_warps_control_Signals_mem_unsigned_o | Out | 8 |
| ibuffer_warps_control_Signals_mem_whb_o | Out | 16 |
| ibuffer_warps_control_Signals_mop_o | Out | 16 |
| ibuffer_warps_control_Signals_mul_o | Out | 8 |
| ibuffer_warps_control_Signals_pc_o | Out | 256 |
| ibuffer_warps_control_Signals_readmask_o | Out | 8 |
| ibuffer_warps_control_Signals_reg_idx1_o | Out | 64 |
| ibuffer_warps_control_Signals_reg_idx2_o | Out | 64 |
| ibuffer_warps_control_Signals_reg_idx3_o | Out | 64 |
| ibuffer_warps_control_Signals_reg_idxw_o | Out | 64 |
| ibuffer_warps_control_Signals_reverse_o | Out | 8 |
| ibuffer_warps_control_Signals_rl_o | Out | 8 |
| ibuffer_warps_control_Signals_rm_is_static_o | Out | 8 |
| ibuffer_warps_control_Signals_rm_o | Out | 24 |
| ibuffer_warps_control_Signals_sel_alu1_o | Out | 16 |
| ibuffer_warps_control_Signals_sel_alu2_o | Out | 16 |
| ibuffer_warps_control_Signals_sel_alu3_o | Out | 16 |
| ibuffer_warps_control_Signals_sel_imm_o | Out | 32 |
| ibuffer_warps_control_Signals_sfu_o | Out | 8 |
| ibuffer_warps_control_Signals_simt_stack_o | Out | 8 |
| ibuffer_warps_control_Signals_simt_stack_op_o | Out | 8 |
| ibuffer_warps_control_Signals_tc_o | Out | 8 |
| ibuffer_warps_control_Signals_wid_o | Out | 24 |
| ibuffer_warps_control_Signals_wvd_o | Out | 8 |
| ibuffer_warps_control_Signals_wxd_o | Out | 8 |
| rst_n | In | 1 |
| warp_sche_io_warp_ready_i | In | 8 |

## Exact native index ranges

- `ibuffer2issue_grant_i`: packed `[7:0]`
- `ibuffer2issue_io_in_ready_i`: packed `[7:0]`
- `ibuffer_flush_wid_i`: packed `[2:0]`
- `ibuffer_in_control_Signals_alu_fn_i`: packed `[11:0]`
- `ibuffer_in_control_Signals_aq_i`: packed `[1:0]`
- `ibuffer_in_control_Signals_atomic_i`: packed `[1:0]`
- `ibuffer_in_control_Signals_barrier_i`: packed `[1:0]`
- `ibuffer_in_control_Signals_branch_i`: packed `[3:0]`
- `ibuffer_in_control_Signals_csr_i`: packed `[3:0]`
- `ibuffer_in_control_Signals_custom_signal_0_i`: packed `[1:0]`
- `ibuffer_in_control_Signals_disable_mask_i`: packed `[1:0]`
- `ibuffer_in_control_Signals_fence_i`: packed `[1:0]`
- `ibuffer_in_control_Signals_force_rm_rtz_i`: packed `[1:0]`
- `ibuffer_in_control_Signals_fp_i`: packed `[1:0]`
- `ibuffer_in_control_Signals_imm_ext_i`: packed `[11:0]`
- `ibuffer_in_control_Signals_inst_i`: packed `[63:0]`
- `ibuffer_in_control_Signals_is_vls12_i`: packed `[1:0]`
- `ibuffer_in_control_Signals_isvec_i`: packed `[1:0]`
- `ibuffer_in_control_Signals_mask_i`: packed `[1:0]`
- `ibuffer_in_control_Signals_mem_cmd_i`: packed `[3:0]`
- `ibuffer_in_control_Signals_mem_i`: packed `[1:0]`
- `ibuffer_in_control_Signals_mem_unsigned_i`: packed `[1:0]`
- `ibuffer_in_control_Signals_mem_whb_i`: packed `[3:0]`
- `ibuffer_in_control_Signals_mop_i`: packed `[3:0]`
- `ibuffer_in_control_Signals_mul_i`: packed `[1:0]`
- `ibuffer_in_control_Signals_pc_i`: packed `[63:0]`
- `ibuffer_in_control_Signals_readmask_i`: packed `[1:0]`
- `ibuffer_in_control_Signals_reg_idx1_i`: packed `[15:0]`
- `ibuffer_in_control_Signals_reg_idx2_i`: packed `[15:0]`
- `ibuffer_in_control_Signals_reg_idx3_i`: packed `[15:0]`
- `ibuffer_in_control_Signals_reg_idxw_i`: packed `[15:0]`
- `ibuffer_in_control_Signals_reverse_i`: packed `[1:0]`
- `ibuffer_in_control_Signals_rl_i`: packed `[1:0]`
- `ibuffer_in_control_Signals_rm_i`: packed `[5:0]`
- `ibuffer_in_control_Signals_rm_is_static_i`: packed `[1:0]`
- `ibuffer_in_control_Signals_sel_alu1_i`: packed `[3:0]`
- `ibuffer_in_control_Signals_sel_alu2_i`: packed `[3:0]`
- `ibuffer_in_control_Signals_sel_alu3_i`: packed `[3:0]`
- `ibuffer_in_control_Signals_sel_imm_i`: packed `[7:0]`
- `ibuffer_in_control_Signals_sfu_i`: packed `[1:0]`
- `ibuffer_in_control_Signals_simt_stack_i`: packed `[1:0]`
- `ibuffer_in_control_Signals_simt_stack_op_i`: packed `[1:0]`
- `ibuffer_in_control_Signals_tc_i`: packed `[1:0]`
- `ibuffer_in_control_Signals_wid_i`: packed `[5:0]`
- `ibuffer_in_control_Signals_writemask_i`: packed `[1:0]`
- `ibuffer_in_control_Signals_wvd_i`: packed `[1:0]`
- `ibuffer_in_control_Signals_wxd_i`: packed `[1:0]`
- `ibuffer_in_control_mask_i`: packed `[1:0]`
- `ibuffer_out_valid_o`: packed `[7:0]`
- `ibuffer_ready_o`: packed `[7:0]`
- `ibuffer_warps_control_Signals_alu_fn_o`: packed `[47:0]`
- `ibuffer_warps_control_Signals_aq_o`: packed `[7:0]`
- `ibuffer_warps_control_Signals_atomic_o`: packed `[7:0]`
- `ibuffer_warps_control_Signals_barrier_o`: packed `[7:0]`
- `ibuffer_warps_control_Signals_branch_o`: packed `[15:0]`
- `ibuffer_warps_control_Signals_csr_o`: packed `[15:0]`
- `ibuffer_warps_control_Signals_custom_signal_0_o`: packed `[7:0]`
- `ibuffer_warps_control_Signals_disable_mask_o`: packed `[7:0]`
- `ibuffer_warps_control_Signals_fence_o`: packed `[7:0]`
- `ibuffer_warps_control_Signals_force_rm_rtz_o`: packed `[7:0]`
- `ibuffer_warps_control_Signals_fp_o`: packed `[7:0]`
- `ibuffer_warps_control_Signals_imm_ext_o`: packed `[47:0]`
- `ibuffer_warps_control_Signals_inst_o`: packed `[255:0]`
- `ibuffer_warps_control_Signals_is_vls12_o`: packed `[7:0]`
- `ibuffer_warps_control_Signals_isvec_o`: packed `[7:0]`
- `ibuffer_warps_control_Signals_mask_o`: packed `[7:0]`
- `ibuffer_warps_control_Signals_mem_cmd_o`: packed `[15:0]`
- `ibuffer_warps_control_Signals_mem_o`: packed `[7:0]`
- `ibuffer_warps_control_Signals_mem_unsigned_o`: packed `[7:0]`
- `ibuffer_warps_control_Signals_mem_whb_o`: packed `[15:0]`
- `ibuffer_warps_control_Signals_mop_o`: packed `[15:0]`
- `ibuffer_warps_control_Signals_mul_o`: packed `[7:0]`
- `ibuffer_warps_control_Signals_pc_o`: packed `[255:0]`
- `ibuffer_warps_control_Signals_readmask_o`: packed `[7:0]`
- `ibuffer_warps_control_Signals_reg_idx1_o`: packed `[63:0]`
- `ibuffer_warps_control_Signals_reg_idx2_o`: packed `[63:0]`
- `ibuffer_warps_control_Signals_reg_idx3_o`: packed `[63:0]`
- `ibuffer_warps_control_Signals_reg_idxw_o`: packed `[63:0]`
- `ibuffer_warps_control_Signals_reverse_o`: packed `[7:0]`
- `ibuffer_warps_control_Signals_rl_o`: packed `[7:0]`
- `ibuffer_warps_control_Signals_rm_is_static_o`: packed `[7:0]`
- `ibuffer_warps_control_Signals_rm_o`: packed `[23:0]`
- `ibuffer_warps_control_Signals_sel_alu1_o`: packed `[15:0]`
- `ibuffer_warps_control_Signals_sel_alu2_o`: packed `[15:0]`
- `ibuffer_warps_control_Signals_sel_alu3_o`: packed `[15:0]`
- `ibuffer_warps_control_Signals_sel_imm_o`: packed `[31:0]`
- `ibuffer_warps_control_Signals_sfu_o`: packed `[7:0]`
- `ibuffer_warps_control_Signals_simt_stack_o`: packed `[7:0]`
- `ibuffer_warps_control_Signals_simt_stack_op_o`: packed `[7:0]`
- `ibuffer_warps_control_Signals_tc_o`: packed `[7:0]`
- `ibuffer_warps_control_Signals_wid_o`: packed `[23:0]`
- `ibuffer_warps_control_Signals_wvd_o`: packed `[7:0]`
- `ibuffer_warps_control_Signals_wxd_o`: packed `[7:0]`
- `warp_sche_io_warp_ready_i`: packed `[7:0]`
