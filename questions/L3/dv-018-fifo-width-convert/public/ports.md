# width_convert Native Interface

The ports are illustrated using the following 4/8 instance; names and directions are identical for the three profiles, with wr_data as [ISIZE-1:0] and rd_data as [OSIZE-1:0]. The following are the native top-level ports; unlisted internal signals are not part of the candidate interface.

| Port | Direction | Width/Index |
|---|---:|---:|
| `clock` | In | 1 bit |
| `rd_data` | Out | [7:0] (8 bits) |
| `rd_last` | Out | 1 bit |
| `rd_ready` | In | 1 bit |
| `rd_vld` | Out | 1 bit |
| `rst_n` | In | 1 bit |
| `wr_align_last` | In | 1 bit |
| `wr_data` | In | [3:0] (4 bits) |
| `wr_last` | In | 1 bit |
| `wr_ready` | Out | 1 bit |
| `wr_vld` | In | 1 bit |

## Parameter profiles

Support is required for p4to8(ISIZE=4,OSIZE=8), p8to4(8,4), and p8to8(8,8). The same parameterized dvbench_model file is used for all three instances; the TB must verify each profile, not merely implement 4/8. No other parameter combinations are declared in this version.
