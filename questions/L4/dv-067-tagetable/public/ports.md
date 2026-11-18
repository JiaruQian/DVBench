# Native interface

Instantiate every `TageTable` port below. No parameters. `clock` is the only rising-edge clock; reset is synchronous active high. All packed indices descend to zero. The self-contained `dvbench_model` uses the identical43-port signature.

| Port | Direction | Width | Packed indices |
|---|---|---:|---|
| `clock` | In | 1 | scalar |
| `io_f1_req_ghist` | In | 64 | [63:0] |
| `io_f1_req_pc` | In | 40 | [39:0] |
| `io_f1_req_valid` | In | 1 | scalar |
| `io_f3_resp_0_bits_ctr` | Out | 3 | [2:0] |
| `io_f3_resp_0_bits_u` | Out | 2 | [1:0] |
| `io_f3_resp_0_valid` | Out | 1 | scalar |
| `io_f3_resp_1_bits_ctr` | Out | 3 | [2:0] |
| `io_f3_resp_1_bits_u` | Out | 2 | [1:0] |
| `io_f3_resp_1_valid` | Out | 1 | scalar |
| `io_f3_resp_2_bits_ctr` | Out | 3 | [2:0] |
| `io_f3_resp_2_bits_u` | Out | 2 | [1:0] |
| `io_f3_resp_2_valid` | Out | 1 | scalar |
| `io_f3_resp_3_bits_ctr` | Out | 3 | [2:0] |
| `io_f3_resp_3_bits_u` | Out | 2 | [1:0] |
| `io_f3_resp_3_valid` | Out | 1 | scalar |
| `io_update_alloc_0` | In | 1 | scalar |
| `io_update_alloc_1` | In | 1 | scalar |
| `io_update_alloc_2` | In | 1 | scalar |
| `io_update_alloc_3` | In | 1 | scalar |
| `io_update_hist` | In | 64 | [63:0] |
| `io_update_mask_0` | In | 1 | scalar |
| `io_update_mask_1` | In | 1 | scalar |
| `io_update_mask_2` | In | 1 | scalar |
| `io_update_mask_3` | In | 1 | scalar |
| `io_update_old_ctr_0` | In | 3 | [2:0] |
| `io_update_old_ctr_1` | In | 3 | [2:0] |
| `io_update_old_ctr_2` | In | 3 | [2:0] |
| `io_update_old_ctr_3` | In | 3 | [2:0] |
| `io_update_pc` | In | 40 | [39:0] |
| `io_update_taken_0` | In | 1 | scalar |
| `io_update_taken_1` | In | 1 | scalar |
| `io_update_taken_2` | In | 1 | scalar |
| `io_update_taken_3` | In | 1 | scalar |
| `io_update_u_0` | In | 2 | [1:0] |
| `io_update_u_1` | In | 2 | [1:0] |
| `io_update_u_2` | In | 2 | [1:0] |
| `io_update_u_3` | In | 2 | [1:0] |
| `io_update_u_mask_0` | In | 1 | scalar |
| `io_update_u_mask_1` | In | 1 | scalar |
| `io_update_u_mask_2` | In | 1 | scalar |
| `io_update_u_mask_3` | In | 1 | scalar |
| `reset` | In | 1 | scalar |

## Exact native index ranges

- `io_f1_req_ghist`: packed `[63:0]`
- `io_f1_req_pc`: packed `[39:0]`
- `io_f3_resp_0_bits_ctr`: packed `[2:0]`
- `io_f3_resp_0_bits_u`: packed `[1:0]`
- `io_f3_resp_1_bits_ctr`: packed `[2:0]`
- `io_f3_resp_1_bits_u`: packed `[1:0]`
- `io_f3_resp_2_bits_ctr`: packed `[2:0]`
- `io_f3_resp_2_bits_u`: packed `[1:0]`
- `io_f3_resp_3_bits_ctr`: packed `[2:0]`
- `io_f3_resp_3_bits_u`: packed `[1:0]`
- `io_update_hist`: packed `[63:0]`
- `io_update_old_ctr_0`: packed `[2:0]`
- `io_update_old_ctr_1`: packed `[2:0]`
- `io_update_old_ctr_2`: packed `[2:0]`
- `io_update_old_ctr_3`: packed `[2:0]`
- `io_update_pc`: packed `[39:0]`
- `io_update_u_0`: packed `[1:0]`
- `io_update_u_1`: packed `[1:0]`
- `io_update_u_2`: packed `[1:0]`
- `io_update_u_3`: packed `[1:0]`
