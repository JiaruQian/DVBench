# IEEE802TX Native Port Contract

All ports are unsigned. packed range preserves the native index direction; scalar is 1 bit. Only declaration information is provided; the hidden DUT is compiled and connected by the service.

| Port | Direction | packed range |
|---|---|---|
| `Reset` | input | `scalar` |
| `Clk` | input | `scalar` |
| `clk_en` | input | `scalar` |
| `gmii_txd` | output | `[7:0]` |
| `gmii_tx_en` | output | `scalar` |
| `gmii_tx_er` | output | `scalar` |
| `complete` | output | `scalar` |
| `iEmpty` | input | `scalar` |
| `i8Data` | input | `[15:0]` |
| `oRead` | output | `scalar` |
| `diagnostic` | output | `[2:0]` |
| `Addres` | output | `[8:0]` |

Top-level parameter defaults: {"StateIdle": 0, "StatePreamble": 1, "StateSFD": 2, "StateHeader": 3, "StateData": 4, "StateFCS": 5, "StateIFG": 6}. Overrides are not allowed in this task.

Instantiate the real DUT using the ports above; do not define a module with the same name or list an empty stub in sources.f. The independent prediction model dvbench_model uses exactly the same port names, directions, and bit widths.
