# Native interface

Top `NV_NVDLA_bdma`, no top parameters. All packed indices descend to zero.

|Port|Direction|Width|
|---|---|---:|
|`nvdla_core_clk`|In|1|
|`nvdla_core_rstn`|In|1|
|`bdma2csb_resp_valid`|Out|1|
|`bdma2csb_resp_pd`|Out|34|
|`bdma2glb_done_intr_pd`|Out|2|
|`bdma2mcif_rd_cdt_lat_fifo_pop`|Out|1|
|`bdma2mcif_rd_req_valid`|Out|1|
|`bdma2mcif_rd_req_ready`|In|1|
|`bdma2mcif_rd_req_pd`|Out|79|
|`bdma2mcif_wr_req_valid`|Out|1|
|`bdma2mcif_wr_req_ready`|In|1|
|`bdma2mcif_wr_req_pd`|Out|515|
|`csb2bdma_req_pvld`|In|1|
|`csb2bdma_req_prdy`|Out|1|
|`csb2bdma_req_pd`|In|63|
|`mcif2bdma_rd_rsp_valid`|In|1|
|`mcif2bdma_rd_rsp_ready`|Out|1|
|`mcif2bdma_rd_rsp_pd`|In|514|
|`mcif2bdma_wr_rsp_complete`|In|1|
|`pwrbus_ram_pd`|In|32|
|`dla_clk_ovr_on_sync`|In|1|
|`global_clk_ovr_on_sync`|In|1|
|`tmc2slcg_disable_clock_gating`|In|1|

The fixed maintenance library profile defines `VLIB_BYPASS_POWER_CG` and `PRAND_OFF`; power clock gates forward the native core clock and optional random-stall helpers return their minimum argument without external PLI. Native assertions remain intact. No top parameters are varied. The active-low asynchronous reset is `nvdla_core_rstn`.

## Exact native index ranges

- `bdma2csb_resp_pd`: packed `[33:0]`
- `bdma2glb_done_intr_pd`: packed `[1:0]`
- `bdma2mcif_rd_req_pd`: packed `[78:0]`
- `bdma2mcif_wr_req_pd`: packed `[514:0]`
- `csb2bdma_req_pd`: packed `[62:0]`
- `mcif2bdma_rd_rsp_pd`: packed `[513:0]`
- `pwrbus_ram_pd`: packed `[31:0]`
