# Native interface

Top vmul_top parameters are fixed to SOFT_THREAD=4,HARD_THREAD=4,MAX_ITER=1; no alternate values are tested. XLEN32,NUM_THREAD4,NUM_WARP8,register destination width8 and warp width3 are fixed. clk is the sole rising-edge clock; rst_n is asynchronous active low. Packed indices descend to0. A self-contained dvbench_model uses the identical fixed-width native ports and needs no external macro file. The dvbench_model module has no parameter declarations and accepts no parameter overrides; it represents only the DUT build with SOFT_THREAD=4,HARD_THREAD=4,MAX_ITER=1. The empty model parameter map describes that fixed model signature,while the DUT parameter values remain the three fixed values stated above.

| Port | Direction | Width | Packed indices |
|---|---|---:|---|
| `clk` | In | 1 | scalar |
| `ctrl_alu_fn_i` | In | 6 | [5:0] |
| `ctrl_reg_idxw_i` | In | 8 | [7:0] |
| `ctrl_reverse_i` | In | 1 | scalar |
| `ctrl_wid_i` | In | 3 | [2:0] |
| `ctrl_wvd_i` | In | 1 | scalar |
| `ctrl_wxd_i` | In | 1 | scalar |
| `in1_i` | In | 128 | [127:0] |
| `in2_i` | In | 128 | [127:0] |
| `in3_i` | In | 128 | [127:0] |
| `in_ready_o` | Out | 1 | scalar |
| `in_valid_i` | In | 1 | scalar |
| `mask_i` | In | 4 | [3:0] |
| `outv_ready_i` | In | 1 | scalar |
| `outv_reg_idxw_o` | Out | 8 | [7:0] |
| `outv_valid_o` | Out | 1 | scalar |
| `outv_warp_id_o` | Out | 3 | [2:0] |
| `outv_wb_wxd_rd_o` | Out | 128 | [127:0] |
| `outv_wvd_mask_o` | Out | 4 | [3:0] |
| `outv_wvd_o` | Out | 1 | scalar |
| `outx_ready_i` | In | 1 | scalar |
| `outx_reg_idwx_o` | Out | 8 | [7:0] |
| `outx_valid_o` | Out | 1 | scalar |
| `outx_warp_id_o` | Out | 3 | [2:0] |
| `outx_wb_wxd_rd_o` | Out | 32 | [31:0] |
| `outx_wxd_o` | Out | 1 | scalar |
| `rst_n` | In | 1 | scalar |

## Exact native index ranges

- `ctrl_alu_fn_i`: packed `[5:0]`
- `ctrl_reg_idxw_i`: packed `[7:0]`
- `ctrl_wid_i`: packed `[2:0]`
- `in1_i`: packed `[127:0]`
- `in2_i`: packed `[127:0]`
- `in3_i`: packed `[127:0]`
- `mask_i`: packed `[3:0]`
- `outv_reg_idxw_o`: packed `[7:0]`
- `outv_warp_id_o`: packed `[2:0]`
- `outv_wb_wxd_rd_o`: packed `[127:0]`
- `outv_wvd_mask_o`: packed `[3:0]`
- `outx_reg_idwx_o`: packed `[7:0]`
- `outx_warp_id_o`: packed `[2:0]`
- `outx_wb_wxd_rd_o`: packed `[31:0]`
