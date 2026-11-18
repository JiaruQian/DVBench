# Native interface

Top `instruction_cache`, no top parameters. All packed indices descend to zero.

|Port|Direction|Width|
|---|---|---:|
|`clk`|In|1|
|`rst_n`|In|1|
|`invalid_i`|In|1|
|`core_req_valid_i`|In|1|
|`core_req_addr_i`|In|32|
|`core_req_mask_i`|In|2|
|`core_req_wid_i`|In|3|
|`flush_pipe_valid_i`|In|1|
|`flush_pipe_wid_i`|In|3|
|`core_rsp_valid_o`|Out|1|
|`core_rsp_addr_o`|Out|32|
|`core_rsp_data_o`|Out|64|
|`core_rsp_mask_o`|Out|2|
|`core_rsp_wid_o`|Out|3|
|`core_rsp_status_o`|Out|1|
|`mem_rsp_ready_o`|Out|1|
|`mem_rsp_valid_i`|In|1|
|`mem_rsp_d_source_i`|In|3|
|`mem_rsp_d_addr_i`|In|32|
|`mem_rsp_d_data_i`|In|64|
|`mem_req_ready_i`|In|1|
|`mem_req_valid_o`|Out|1|
|`mem_req_a_source_o`|Out|3|
|`mem_req_a_addr_o`|Out|32|

Fixed source macro profile: XLEN=32, NUM_WARP=8, DEPTH_WARP=3, NUM_FETCH=2, DCACHE_NSETS=32, DCACHE_NWAYS=2, DCACHE_BLOCKWORDS=2, DCACHE_MSHRENTRY=4 and DCACHE_MSHRSUBENTRY=2. No alternate macro profile is requested. Clock is clk and reset is asynchronous active-low rst_n.

## Exact native index ranges

- `core_req_addr_i`: packed `[31:0]`
- `core_req_mask_i`: packed `[1:0]`
- `core_req_wid_i`: packed `[2:0]`
- `core_rsp_addr_o`: packed `[31:0]`
- `core_rsp_data_o`: packed `[63:0]`
- `core_rsp_mask_o`: packed `[1:0]`
- `core_rsp_wid_o`: packed `[2:0]`
- `flush_pipe_wid_i`: packed `[2:0]`
- `mem_req_a_addr_o`: packed `[31:0]`
- `mem_req_a_source_o`: packed `[2:0]`
- `mem_rsp_d_addr_i`: packed `[31:0]`
- `mem_rsp_d_data_i`: packed `[63:0]`
- `mem_rsp_d_source_i`: packed `[2:0]`
