# Native interface

NV_NVDLA_csb_master has no top parameters. There are84 flat native ports; widths and descending indices are exact. nvdla_core_clk and nvdla_falcon_clk are independent rising-edge clocks,with their respective asynchronous active-low rstn inputs. The fixed build includes both FIFO roots and real functional clock gates; FPGA,NO_PLI,PRAND_OFF select the documented configuration without changing the native signature. dvbench_model has the same ports and no formal parameters. It is self-contained and needs no library or macro file.

| Port | Direction | Width | Packed indices |
|---|---|---:|---|
| `nvdla_core_clk` | In | 1 | scalar |
| `nvdla_core_rstn` | In | 1 | scalar |
| `nvdla_falcon_clk` | In | 1 | scalar |
| `nvdla_falcon_rstn` | In | 1 | scalar |
| `pwrbus_ram_pd` | In | 32 | [31:0] |
| `csb2nvdla_valid` | In | 1 | scalar |
| `csb2nvdla_ready` | Out | 1 | scalar |
| `csb2nvdla_addr` | In | 16 | [15:0] |
| `csb2nvdla_wdat` | In | 32 | [31:0] |
| `csb2nvdla_write` | In | 1 | scalar |
| `csb2nvdla_nposted` | In | 1 | scalar |
| `nvdla2csb_valid` | Out | 1 | scalar |
| `nvdla2csb_data` | Out | 32 | [31:0] |
| `nvdla2csb_wr_complete` | Out | 1 | scalar |
| `csb2cfgrom_req_pvld` | Out | 1 | scalar |
| `csb2cfgrom_req_prdy` | In | 1 | scalar |
| `csb2cfgrom_req_pd` | Out | 63 | [62:0] |
| `cfgrom2csb_resp_valid` | In | 1 | scalar |
| `cfgrom2csb_resp_pd` | In | 34 | [33:0] |
| `csb2glb_req_pvld` | Out | 1 | scalar |
| `csb2glb_req_prdy` | In | 1 | scalar |
| `csb2glb_req_pd` | Out | 63 | [62:0] |
| `glb2csb_resp_valid` | In | 1 | scalar |
| `glb2csb_resp_pd` | In | 34 | [33:0] |
| `csb2mcif_req_pvld` | Out | 1 | scalar |
| `csb2mcif_req_prdy` | In | 1 | scalar |
| `csb2mcif_req_pd` | Out | 63 | [62:0] |
| `mcif2csb_resp_valid` | In | 1 | scalar |
| `mcif2csb_resp_pd` | In | 34 | [33:0] |
| `csb2cdma_req_pvld` | Out | 1 | scalar |
| `csb2cdma_req_prdy` | In | 1 | scalar |
| `csb2cdma_req_pd` | Out | 63 | [62:0] |
| `cdma2csb_resp_valid` | In | 1 | scalar |
| `cdma2csb_resp_pd` | In | 34 | [33:0] |
| `csb2csc_req_pvld` | Out | 1 | scalar |
| `csb2csc_req_prdy` | In | 1 | scalar |
| `csb2csc_req_pd` | Out | 63 | [62:0] |
| `csc2csb_resp_valid` | In | 1 | scalar |
| `csc2csb_resp_pd` | In | 34 | [33:0] |
| `csb2cmac_a_req_pvld` | Out | 1 | scalar |
| `csb2cmac_a_req_prdy` | In | 1 | scalar |
| `csb2cmac_a_req_pd` | Out | 63 | [62:0] |
| `cmac_a2csb_resp_valid` | In | 1 | scalar |
| `cmac_a2csb_resp_pd` | In | 34 | [33:0] |
| `csb2cmac_b_req_pvld` | Out | 1 | scalar |
| `csb2cmac_b_req_prdy` | In | 1 | scalar |
| `csb2cmac_b_req_pd` | Out | 63 | [62:0] |
| `cmac_b2csb_resp_valid` | In | 1 | scalar |
| `cmac_b2csb_resp_pd` | In | 34 | [33:0] |
| `csb2cacc_req_pvld` | Out | 1 | scalar |
| `csb2cacc_req_prdy` | In | 1 | scalar |
| `csb2cacc_req_pd` | Out | 63 | [62:0] |
| `cacc2csb_resp_valid` | In | 1 | scalar |
| `cacc2csb_resp_pd` | In | 34 | [33:0] |
| `csb2sdp_rdma_req_pvld` | Out | 1 | scalar |
| `csb2sdp_rdma_req_prdy` | In | 1 | scalar |
| `csb2sdp_rdma_req_pd` | Out | 63 | [62:0] |
| `sdp_rdma2csb_resp_valid` | In | 1 | scalar |
| `sdp_rdma2csb_resp_pd` | In | 34 | [33:0] |
| `csb2sdp_req_pvld` | Out | 1 | scalar |
| `csb2sdp_req_prdy` | In | 1 | scalar |
| `csb2sdp_req_pd` | Out | 63 | [62:0] |
| `sdp2csb_resp_valid` | In | 1 | scalar |
| `sdp2csb_resp_pd` | In | 34 | [33:0] |
| `csb2pdp_rdma_req_pvld` | Out | 1 | scalar |
| `csb2pdp_rdma_req_prdy` | In | 1 | scalar |
| `csb2pdp_rdma_req_pd` | Out | 63 | [62:0] |
| `pdp_rdma2csb_resp_valid` | In | 1 | scalar |
| `pdp_rdma2csb_resp_pd` | In | 34 | [33:0] |
| `csb2pdp_req_pvld` | Out | 1 | scalar |
| `csb2pdp_req_prdy` | In | 1 | scalar |
| `csb2pdp_req_pd` | Out | 63 | [62:0] |
| `pdp2csb_resp_valid` | In | 1 | scalar |
| `pdp2csb_resp_pd` | In | 34 | [33:0] |
| `csb2cdp_rdma_req_pvld` | Out | 1 | scalar |
| `csb2cdp_rdma_req_prdy` | In | 1 | scalar |
| `csb2cdp_rdma_req_pd` | Out | 63 | [62:0] |
| `cdp_rdma2csb_resp_valid` | In | 1 | scalar |
| `cdp_rdma2csb_resp_pd` | In | 34 | [33:0] |
| `csb2cdp_req_pvld` | Out | 1 | scalar |
| `csb2cdp_req_prdy` | In | 1 | scalar |
| `csb2cdp_req_pd` | Out | 63 | [62:0] |
| `cdp2csb_resp_valid` | In | 1 | scalar |
| `cdp2csb_resp_pd` | In | 34 | [33:0] |

## Exact native index ranges

- `cacc2csb_resp_pd`: packed `[33:0]`
- `cdma2csb_resp_pd`: packed `[33:0]`
- `cdp2csb_resp_pd`: packed `[33:0]`
- `cdp_rdma2csb_resp_pd`: packed `[33:0]`
- `cfgrom2csb_resp_pd`: packed `[33:0]`
- `cmac_a2csb_resp_pd`: packed `[33:0]`
- `cmac_b2csb_resp_pd`: packed `[33:0]`
- `csb2cacc_req_pd`: packed `[62:0]`
- `csb2cdma_req_pd`: packed `[62:0]`
- `csb2cdp_rdma_req_pd`: packed `[62:0]`
- `csb2cdp_req_pd`: packed `[62:0]`
- `csb2cfgrom_req_pd`: packed `[62:0]`
- `csb2cmac_a_req_pd`: packed `[62:0]`
- `csb2cmac_b_req_pd`: packed `[62:0]`
- `csb2csc_req_pd`: packed `[62:0]`
- `csb2glb_req_pd`: packed `[62:0]`
- `csb2mcif_req_pd`: packed `[62:0]`
- `csb2nvdla_addr`: packed `[15:0]`
- `csb2nvdla_wdat`: packed `[31:0]`
- `csb2pdp_rdma_req_pd`: packed `[62:0]`
- `csb2pdp_req_pd`: packed `[62:0]`
- `csb2sdp_rdma_req_pd`: packed `[62:0]`
- `csb2sdp_req_pd`: packed `[62:0]`
- `csc2csb_resp_pd`: packed `[33:0]`
- `glb2csb_resp_pd`: packed `[33:0]`
- `mcif2csb_resp_pd`: packed `[33:0]`
- `nvdla2csb_data`: packed `[31:0]`
- `pdp2csb_resp_pd`: packed `[33:0]`
- `pdp_rdma2csb_resp_pd`: packed `[33:0]`
- `pwrbus_ram_pd`: packed `[31:0]`
- `sdp2csb_resp_pd`: packed `[33:0]`
- `sdp_rdma2csb_resp_pd`: packed `[33:0]`
