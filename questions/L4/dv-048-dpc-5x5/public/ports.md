# Native interface

| Port | Direction | Width | Meaning |
|---|---|---:|---|
| `clk` | input | 1 | Rising-edge sampling clock |
| `reset_n` | input | 1 | Asynchronous active-low reset |
| `bayer_format` | input | 1 | Phase selector sampled at line start |
| `i_dpc_threshold` | input | 8 | Per-cycle strict comparison threshold |
| `i_video_syn` | input | 3 | `{v,d,h}` synchronization inputs |
| `i_data_r0` through `i_data_r4` | input | 8 each | Five same-color row taps |
| `o_video_sync` | output | 3 | Delayed `{v,d,h}` synchronization |
| `o_data` | output | 8 | Corrected or passed-through center sample |

There are no parameters or handshake signals on the selected top.
