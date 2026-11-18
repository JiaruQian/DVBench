# Native module interface

The top module is `NV_NVDLA_CDP_RDMA_cq`, with no parameters.

| Port | Direction | Width | Role |
| --- | --- | --- | --- |
| nvdla_core_clk | input | 1 | Rising-edge queue clock |
| nvdla_core_rstn | input | 1 | Asynchronous active-low reset |
| cq_wr_pvld | input | 1 | Write request valid |
| cq_wr_prdy | output | 1 | Registered write readiness |
| cq_wr_pd | input | 7 | Write data |
| cq_rd_prdy | input | 1 | Consumer readiness |
| cq_rd_pvld | output | 1 | Presented output validity |
| cq_rd_pd | output | 7 | Presented output data |
| pwrbus_ram_pd | input | 32 | Functionally neutral power input |

Inputs and outputs use these exact names and widths in `dvbench_model`. The model must be self-contained and independent of UVM and DUT outputs. Predict outputs from input history. The complete timing and validity contract is in spec.md.

## Exact native index ranges

- `cq_rd_pd`: packed `[6:0]`
- `cq_wr_pd`: packed `[6:0]`
- `pwrbus_ram_pd`: packed `[31:0]`
