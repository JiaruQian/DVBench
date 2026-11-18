# Native ports and configuration

The DUT is csrexe and the independent model is dvbench_model, with exactly the same native ports. There are no top parameters. This task uses the supplied fixed configuration: eight warp banks, four threads, 32-bit words, three-bit warp indices, eight-bit register indices, eleven-bit SGPR/VGPR bases, eighteen-bit LDS base, seven-bit dispatch tag, four-bit warp count and ten-bit size/coordinate fields. All native values in these widths are legal binary inputs.

| Port | Direction | Width |
| --- | --- | --- |
| CTA2csr_valid_i | In | 1 |
| clk | In | 1 |
| ctrl_csr_i | In | 2 |
| ctrl_custom_signal_0_i | In | 1 |
| ctrl_inst_i | In | 32 |
| ctrl_isvec_i | In | 1 |
| ctrl_reg_idxw_i | In | 8 |
| ctrl_wid_i | In | 3 |
| ctrl_wxd_i | In | 1 |
| dispatch2cu_csr_knl_dispatch_i | In | 32 |
| dispatch2cu_lds_base_dispatch_i | In | 18 |
| dispatch2cu_pds_base_dispatch_i | In | 32 |
| dispatch2cu_sgpr_base_dispatch_i | In | 11 |
| dispatch2cu_vgpr_base_dispatch_i | In | 11 |
| dispatch2cu_wf_size_dispatch_i | In | 10 |
| dispatch2cu_wf_tag_dispatch_i | In | 7 |
| dispatch2cu_wg_id_i | In | 32 |
| dispatch2cu_wg_wf_count_i | In | 4 |
| dispatch2cu_wgid_x_dispatch_i | In | 10 |
| dispatch2cu_wgid_y_dispatch_i | In | 10 |
| dispatch2cu_wgid_z_dispatch_i | In | 10 |
| in1_i | In | 32 |
| in_ready_o | Out | 1 |
| in_valid_i | In | 1 |
| lsu_numw_o | Out | 32 |
| lsu_pds_o | Out | 32 |
| lsu_tid_o | Out | 32 |
| lsu_wid_i | In | 3 |
| out_ready_i | In | 1 |
| out_valid_o | Out | 1 |
| reg_idxw_o | Out | 8 |
| rm_o | Out | 9 |
| rm_wid_i | In | 9 |
| rst_n | In | 1 |
| sgpr_base_o | Out | 88 |
| simt_rpc_o | Out | 32 |
| simt_wid_i | In | 3 |
| vgpr_base_o | Out | 88 |
| warp_id_o | Out | 3 |
| wb_wxd_rd_o | Out | 32 |
| wid_i | In | 3 |
| wxd_o | Out | 1 |

## Exact native index ranges

- `ctrl_csr_i`: packed `[1:0]`
- `ctrl_inst_i`: packed `[31:0]`
- `ctrl_reg_idxw_i`: packed `[7:0]`
- `ctrl_wid_i`: packed `[2:0]`
- `dispatch2cu_csr_knl_dispatch_i`: packed `[31:0]`
- `dispatch2cu_lds_base_dispatch_i`: packed `[17:0]`
- `dispatch2cu_pds_base_dispatch_i`: packed `[31:0]`
- `dispatch2cu_sgpr_base_dispatch_i`: packed `[10:0]`
- `dispatch2cu_vgpr_base_dispatch_i`: packed `[10:0]`
- `dispatch2cu_wf_size_dispatch_i`: packed `[9:0]`
- `dispatch2cu_wf_tag_dispatch_i`: packed `[6:0]`
- `dispatch2cu_wg_id_i`: packed `[31:0]`
- `dispatch2cu_wg_wf_count_i`: packed `[3:0]`
- `dispatch2cu_wgid_x_dispatch_i`: packed `[9:0]`
- `dispatch2cu_wgid_y_dispatch_i`: packed `[9:0]`
- `dispatch2cu_wgid_z_dispatch_i`: packed `[9:0]`
- `in1_i`: packed `[31:0]`
- `lsu_numw_o`: packed `[31:0]`
- `lsu_pds_o`: packed `[31:0]`
- `lsu_tid_o`: packed `[31:0]`
- `lsu_wid_i`: packed `[2:0]`
- `reg_idxw_o`: packed `[7:0]`
- `rm_o`: packed `[8:0]`
- `rm_wid_i`: packed `[8:0]`
- `sgpr_base_o`: packed `[87:0]`
- `simt_rpc_o`: packed `[31:0]`
- `simt_wid_i`: packed `[2:0]`
- `vgpr_base_o`: packed `[87:0]`
- `warp_id_o`: packed `[2:0]`
- `wb_wxd_rd_o`: packed `[31:0]`
- `wid_i`: packed `[2:0]`
