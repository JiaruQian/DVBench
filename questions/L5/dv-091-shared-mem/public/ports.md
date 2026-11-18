# Native interface

The DUT is shared_mem; the independent model is dvbench_model with exactly these native port names, directions and packed widths. There are no top parameters. Fixed constants are four lanes, 32-bit words, two banks, 128 rows per bank, 3-bit instruction IDs and a four-slot response queue. Every vector uses descending [width-1:0] indexing; lane zero is the least significant slice. Inputs are binary; no X/Z stimulus is required.

| Port | Direction | Width |
| --- | --- | --- |
| clk | In | 1 |
| core_req_activemask_i | In | 4 |
| core_req_blockoffset_i | In | 4 |
| core_req_data_i | In | 128 |
| core_req_instrid_i | In | 3 |
| core_req_iswrite_i | In | 1 |
| core_req_ready_o | Out | 1 |
| core_req_setidx_i | In | 5 |
| core_req_tag_i | In | 24 |
| core_req_valid_i | In | 1 |
| core_req_wordoffset1h_i | In | 16 |
| core_rsp_activemask_o | Out | 4 |
| core_rsp_data_o | Out | 128 |
| core_rsp_instrid_o | Out | 3 |
| core_rsp_iswrite_o | Out | 1 |
| core_rsp_ready_i | In | 1 |
| core_rsp_valid_o | Out | 1 |
| rst_n | In | 1 |

## Exact native index ranges

- `core_req_activemask_i`: packed `[3:0]`
- `core_req_blockoffset_i`: packed `[3:0]`
- `core_req_data_i`: packed `[127:0]`
- `core_req_instrid_i`: packed `[2:0]`
- `core_req_setidx_i`: packed `[4:0]`
- `core_req_tag_i`: packed `[23:0]`
- `core_req_wordoffset1h_i`: packed `[15:0]`
- `core_rsp_activemask_o`: packed `[3:0]`
- `core_rsp_data_o`: packed `[127:0]`
- `core_rsp_instrid_o`: packed `[2:0]`
