# Native interface

The selected simt_stack root has no top parameters. clk is the sole rising-edge clock; rst_n is asynchronous active low. The fixed configuration has8 warps,4 lanes,32-bit addresses and3-bit warp IDs. Packed indices descend to0. The self-contained dvbench_model uses the identical native ports without external macro files.

| Port | Direction | Width | Packed indices |
|---|---|---:|---|
| `branch_ctl_mask_init_i` | In | 4 | [3:0] |
| `branch_ctl_opcode_i` | In | 1 | scalar |
| `branch_ctl_pc_branch_i` | In | 32 | [31:0] |
| `branch_ctl_pc_execute_i` | In | 32 | [31:0] |
| `branch_ctl_ready_o` | Out | 1 | scalar |
| `branch_ctl_valid_i` | In | 1 | scalar |
| `branch_ctl_wid_i` | In | 3 | [2:0] |
| `clk` | In | 1 | scalar |
| `complete_valid_o` | Out | 1 | scalar |
| `complete_wid_o` | Out | 3 | [2:0] |
| `fetch_ctl_jump_o` | Out | 1 | scalar |
| `fetch_ctl_new_pc_o` | Out | 32 | [31:0] |
| `fetch_ctl_ready_i` | In | 1 | scalar |
| `fetch_ctl_valid_o` | Out | 1 | scalar |
| `fetch_ctl_wid_o` | Out | 3 | [2:0] |
| `if_mask_mask_i` | In | 4 | [3:0] |
| `if_mask_ready_o` | Out | 1 | scalar |
| `if_mask_valid_i` | In | 1 | scalar |
| `if_mask_wid_i` | In | 3 | [2:0] |
| `input_wid_i` | In | 3 | [2:0] |
| `out_mask_o` | Out | 4 | [3:0] |
| `pc_reconv_i` | In | 32 | [31:0] |
| `pc_reconv_valid_i` | In | 1 | scalar |
| `rst_n` | In | 1 | scalar |

## Exact native index ranges

- `branch_ctl_mask_init_i`: packed `[3:0]`
- `branch_ctl_pc_branch_i`: packed `[31:0]`
- `branch_ctl_pc_execute_i`: packed `[31:0]`
- `branch_ctl_wid_i`: packed `[2:0]`
- `complete_wid_o`: packed `[2:0]`
- `fetch_ctl_new_pc_o`: packed `[31:0]`
- `fetch_ctl_wid_o`: packed `[2:0]`
- `if_mask_mask_i`: packed `[3:0]`
- `if_mask_wid_i`: packed `[2:0]`
- `input_wid_i`: packed `[2:0]`
- `out_mask_o`: packed `[3:0]`
- `pc_reconv_i`: packed `[31:0]`
