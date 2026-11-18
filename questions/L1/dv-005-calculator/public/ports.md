# exdbin_mac Native Port Contract

All ports are unsigned. packed range preserves the native index direction; scalar is 1 bit. Only declaration information is provided; the hidden DUT is compiled and connected by the service.

| Port | Direction | packed range |
|---|---|---|
| `bin_ovfl` | output | `scalar` |
| `bin_sum` | output | `[0:63]` |
| `alu_cmd` | input | `[0:3]` |
| `fxu_areg_q` | input | `[0:63]` |
| `local_error_found` | input | `scalar` |
| `fxu_breg_q` | input | `[0:63]` |

Top-level parameter defaults: there are no overridable top-level parameters. Overrides are not allowed in this task.

Instantiate the real DUT using the ports above; do not define a module with the same name or list an empty stub in sources.f. The independent prediction model dvbench_model uses exactly the same port names, directions, and bit widths.
