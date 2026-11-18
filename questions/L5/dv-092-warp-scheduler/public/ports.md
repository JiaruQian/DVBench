# Native ports and configuration

The native DUT is warp_scheduler and the model is dvbench_model, with no top parameters. Supplied fixed macros select eight warps,eight workgroups,two fetched instructions,three-bit warp indices,seven-bit tags and32-bit addresses. Every binary native field and all simultaneous input combinations are legal; outputs are defined even when valid is zero.

| Port | Direction | Width |
| --- | --- | --- |
| branch_jump_i | In | 1 |
| branch_new_pc_i | In | 32 |
| branch_ready_o | Out | 1 |
| branch_valid_i | In | 1 |
| branch_wid_i | In | 3 |
| clk | In | 1 |
| flushCache_valid_o | Out | 1 |
| flushCache_wid_o | Out | 3 |
| flush_valid_o | Out | 1 |
| flush_wid_o | Out | 3 |
| ibuffer_ready_i | In | 8 |
| pc_req_addr_o | Out | 32 |
| pc_req_mask_o | Out | 2 |
| pc_req_valid_o | Out | 1 |
| pc_req_wid_o | Out | 3 |
| pc_rsp_addr_i | In | 32 |
| pc_rsp_mask_i | In | 2 |
| pc_rsp_status_i | In | 1 |
| pc_rsp_valid_i | In | 1 |
| pc_rsp_wid_i | In | 3 |
| rst_n | In | 1 |
| scoreboard_busy_i | In | 8 |
| warpReq_dispatch2cu_start_pc_dispatch_i | In | 32 |
| warpReq_dispatch2cu_wf_tag_dispatch_i | In | 7 |
| warpReq_valid_i | In | 1 |
| warpReq_wid_i | In | 3 |
| warpRsp_ready_i | In | 1 |
| warpRsp_valid_o | Out | 1 |
| warpRsp_wid_o | Out | 3 |
| warp_control_ready_o | Out | 1 |
| warp_control_simt_stack_op_i | In | 1 |
| warp_control_valid_i | In | 1 |
| warp_control_wid_i | In | 3 |
| warp_ready_o | Out | 8 |
| wg_id_lookup_o | Out | 3 |
| wg_id_tag_i | In | 7 |

## Exact native index ranges

- `branch_new_pc_i`: packed `[31:0]`
- `branch_wid_i`: packed `[2:0]`
- `flushCache_wid_o`: packed `[2:0]`
- `flush_wid_o`: packed `[2:0]`
- `ibuffer_ready_i`: packed `[7:0]`
- `pc_req_addr_o`: packed `[31:0]`
- `pc_req_mask_o`: packed `[1:0]`
- `pc_req_wid_o`: packed `[2:0]`
- `pc_rsp_addr_i`: packed `[31:0]`
- `pc_rsp_mask_i`: packed `[1:0]`
- `pc_rsp_wid_i`: packed `[2:0]`
- `scoreboard_busy_i`: packed `[7:0]`
- `warpReq_dispatch2cu_start_pc_dispatch_i`: packed `[31:0]`
- `warpReq_dispatch2cu_wf_tag_dispatch_i`: packed `[6:0]`
- `warpReq_wid_i`: packed `[2:0]`
- `warpRsp_wid_o`: packed `[2:0]`
- `warp_control_wid_i`: packed `[2:0]`
- `warp_ready_o`: packed `[7:0]`
- `wg_id_lookup_o`: packed `[2:0]`
- `wg_id_tag_i`: packed `[6:0]`
