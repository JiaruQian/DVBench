# reorder_queue native interface

The following are the top-level ports of the fixed constructed instance; internal signals not listed are not part of the candidate interface.

| Port | Direction | Width/Index |
|---|---:|---:|
| `CLK` | In | 1 bit |
| `DATA` | In | [127:0] (128 bits) |
| `DATA_EN` | In | [3:0] (4 bits) |
| `DATA_EN_COUNT` | In | [2:0] (3 bits) |
| `DONE` | In | 1 bit |
| `ENG_DATA` | Out | [127:0] (128 bits) |
| `ERR` | In | 1 bit |
| `EXT_TAG` | Out | [4:0] (5 bits) |
| `EXT_TAG_VALID` | Out | 1 bit |
| `INT_TAG` | In | [5:0] (6 bits) |
| `INT_TAG_VALID` | In | 1 bit |
| `MAIN_DATA_EN` | Out | [35:0] (36 bits) |
| `MAIN_DONE` | Out | [11:0] (12 bits) |
| `MAIN_ERR` | Out | [11:0] (12 bits) |
| `RST` | In | 1 bit |
| `SG_RX_DATA_EN` | Out | [35:0] (36 bits) |
| `SG_RX_DONE` | Out | [11:0] (12 bits) |
| `SG_RX_ERR` | Out | [11:0] (12 bits) |
| `SG_TX_DATA_EN` | Out | [35:0] (36 bits) |
| `SG_TX_DONE` | Out | [11:0] (12 bits) |
| `SG_TX_ERR` | Out | [11:0] (12 bits) |
| `TAG` | In | [4:0] (5 bits) |
| `VALID` | In | 1 bit |

## Fixed Parameters

This task uses the following compile-time parameters; unlisted parameters are not within the candidate-adjustable range.

| Parameter | Fixed value |
|---|---:|
| `C_PCI_DATA_WIDTH` | `9'd128` |
| `C_NUM_CHNL` | `4'b1100` |
| `C_MAX_READ_REQ_BYTES` | `512` |
| `C_TAG_WIDTH` | `5` |
| `C_PCI_DATA_WORD` | `32'd4` |
| `C_PCI_DATA_COUNT_WIDTH` | `3` |
| `C_NUM_TAGS` | `32` |
| `C_DW_PER_TAG` | `128` |
| `C_TAG_DW_COUNT_WIDTH` | `8` |
| `C_DATA_ADDR_STRIDE_WIDTH` | `5` |
| `C_DATA_ADDR_WIDTH` | `10` |
