# Native ports

The top module is NV_NVDLA_glb. There are no parameters. The independent model is dvbench_model with the following exact ports.

| Port | Direction | Width |
| --- | --- | --- |
| cacc2glb_done_intr_pd | In | 2 |
| cdma_dat2glb_done_intr_pd | In | 2 |
| cdma_wt2glb_done_intr_pd | In | 2 |
| cdp2glb_done_intr_pd | In | 2 |
| core_intr | Out | 1 |
| csb2glb_req_pd | In | 63 |
| csb2glb_req_prdy | Out | 1 |
| csb2glb_req_pvld | In | 1 |
| direct_reset_ | In | 1 |
| glb2csb_resp_pd | Out | 34 |
| glb2csb_resp_valid | Out | 1 |
| nvdla_core_clk | In | 1 |
| nvdla_core_rstn | In | 1 |
| nvdla_falcon_clk | In | 1 |
| nvdla_falcon_rstn | In | 1 |
| pdp2glb_done_intr_pd | In | 2 |
| sdp2glb_done_intr_pd | In | 2 |
| test_mode | In | 1 |

All controls and payloads use stable binary values. The specification defines each native field and clock/reset behavior.

## Exact native index ranges

- `cacc2glb_done_intr_pd`: packed `[1:0]`
- `cdma_dat2glb_done_intr_pd`: packed `[1:0]`
- `cdma_wt2glb_done_intr_pd`: packed `[1:0]`
- `cdp2glb_done_intr_pd`: packed `[1:0]`
- `csb2glb_req_pd`: packed `[62:0]`
- `glb2csb_resp_pd`: packed `[33:0]`
- `pdp2glb_done_intr_pd`: packed `[1:0]`
- `sdp2glb_done_intr_pd`: packed `[1:0]`
